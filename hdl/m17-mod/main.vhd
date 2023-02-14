--main
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity main_all is
	port(
		clk_i	: in std_logic; -- 12 MHz clock
		data_o  : out std_logic;
		clk_o	: out std_logic;
		--SPI
		spi_mosi : in std_logic;
		spi_sck : in std_logic;
		spi_ncs : in std_logic;
		--debug
		rst		: in std_logic;
		tst_o	: out std_logic
	);
end main_all;

architecture magic of main_all is
	component ddr is
		port(
			clk_i  : in std_logic;
			data_i : in std_logic_vector(1 downto 0);
			rst_i  : in std_logic;
			clk_o  : out std_logic;
			data_o : out std_logic
		);
	end component;
	
	component unpack is
		port(
			clk_i	: in std_logic;
			zero	: in std_logic;						-- send zero words if high
			i_i		: in std_logic_vector(12 downto 0); -- 13-bit signed, sign at the MSB
			q_i		: in std_logic_vector(12 downto 0); -- 13-bit signed, sign at the MSB
			data_o	: out std_logic_vector(1 downto 0)
		);
	end component;
	
	component pll_block is
		port(
			clki_i	: in std_logic;
			clkop_o	: out std_logic
		);
	end component;	
	
	component ook_source is
		port(
			clk_i	: in std_logic;						-- clock source
			mod_o	: out std_logic_vector(15 downto 0)	-- sig out
		);
	end component;
	
	component ramp_source is
		port(
			clk_i	: in std_logic;						-- clock source
			mod_o	: out std_logic_vector(15 downto 0)	-- sig out
		);
	end component;
	
	component fsk_source is
		port(
			clk_i	: in std_logic;						-- clock source
			mod_o	: out std_logic_vector(15 downto 0)	-- sig out
		);
	end component;
	
	component am_modulator is
		port(
			mod_i	: in std_logic_vector(15 downto 0);		-- modulation in
			i_o		: out std_logic_vector(15 downto 0);	-- I data out
			q_o		: out std_logic_vector(15 downto 0)		-- Q data out
		);
	end component;
	
	component fm_modulator is
		port(
			nrst	: in std_logic;						-- reset
			clk_i	: in std_logic;						-- main clock
			mod_i	: in std_logic_vector(15 downto 0);	-- modulation in
			dith_i	: in signed(7 downto 0);			-- phase dither input
			i_o		: out std_logic_vector(15 downto 0);-- I data out
			q_o		: out std_logic_vector(15 downto 0)	-- Q data out
		);
	end component;
	
	component dither_source is
		port(
			clk_i	: in  std_logic;
			trig	: in std_logic;
			out_o	: out signed(7 downto 0)
		);
	end component;
	
	component iq_balancer_16 is
		port(
			i_i		: in std_logic_vector(15 downto 0);			-- I data in
			q_i		: in std_logic_vector(15 downto 0);			-- Q data in
			ib_i	: in std_logic_vector(15 downto 0);			-- I balance in, 0x4000 = "+1.0"
			qb_i	: in std_logic_vector(15 downto 0);			-- Q balance in, 0x4000 = "+1.0"
			i_o		: out std_logic_vector(15 downto 0);		-- I data in
			q_o		: out std_logic_vector(15 downto 0)			-- Q data in
		);
	end component;
	
	component iq_offset is
		port(
			i_i : in std_logic_vector(15 downto 0);
			q_i : in std_logic_vector(15 downto 0);
			ai_i : in std_logic_vector(15 downto 0);
			aq_i : in std_logic_vector(15 downto 0);
			i_o : out std_logic_vector(15 downto 0);
			q_o : out std_logic_vector(15 downto 0)
		);
	end component;
	
	component spi_receiver is
		port(
			mosi_i	: in std_logic;							-- serial data in
			sck_i	: in std_logic;							-- clock
			ncs_i	: in std_logic;							-- slave select signal
			data_o	: out std_logic_vector(31 downto 0);	-- data register
			nrst	: in std_logic;							-- reset
			ena		: in std_logic;							-- enable
			clk_i	: in std_logic							-- fast clock
		);
	end component;
	
	component ctrl_regs is
		port(
			clk_i		: in std_logic;						-- clock in
			rst			: in std_logic;						-- reset
			d_i			: in std_logic_vector(31 downto 0);	-- data in
			ib_o		: out std_logic_vector(15 downto 0);-- I balance out
			qb_o		: out std_logic_vector(15 downto 0);-- Q balance out
			ai_o		: out std_logic_vector(15 downto 0);-- I offset out
			aq_o		: out std_logic_vector(15 downto 0);-- Q offset in
			fmod_o		: out std_logic_vector(15 downto 0)	--FMod register
		);
	end component;
	
	signal data_reg			: std_logic_vector(1 downto 0) := (others => '0');
	signal clk_64			: std_logic := '0';
	signal zero_word		: std_logic := '0';
	signal mod_r			: std_logic_vector(15 downto 0) := (others => '0');
	signal i_r, q_r			: std_logic_vector(15 downto 0) := (others => '0');
	signal ii_r, qq_r		: std_logic_vector(15 downto 0) := (others => '0');
	signal bi_r, bq_r		: std_logic_vector(12 downto 0) := (others => '0');
	signal i_offs, q_offs	: std_logic_vector(15 downto 0) := (others => '0');
	signal i_bal, q_bal		: std_logic_vector(15 downto 0) := x"4000";
	signal dith_r			: signed(7 downto 0) := (others => '0');
	
	signal spi_data			: std_logic_vector(31 downto 0) := (others => '0');
begin
	pll0: pll_block port map(
		clki_i => clk_i,
		clkop_o => clk_64
	);
	
	--mod_source0: ook_source port map(
		--clk_i => clk_64,
		--mod_o => mod_r
	--);
	
	--mod_source0: ramp_source port map(
		--clk_i => clk_i,
		--mod_o => mod_r
	--);
	
	--mod_source0: fsk_source port map(
		--clk_i => clk_i,
		--mod_o => mod_r
	--);
	
	--am_modulator0: am_modulator port map(
		--mod_i => mod_r,
		--i_o => i_r,
		--q_o => q_r
	--);
	
	fm_modulator0: fm_modulator port map(
		nrst => '1',
		clk_i => clk_i,
		mod_i => mod_r,
		dith_i => dith_r,
		i_o	=> i_r,
		q_o => q_r
	);
	
	dither_source0: dither_source port map(
		clk_i => clk_i,
		trig => zero_word,
		out_o => dith_r
	);
	
	iq_balancer0: iq_balancer_16 port map(
		i_i => i_r,
		q_i => q_r,
		ib_i => i_bal,
		qb_i => q_bal,
		i_o => ii_r,
		q_o => qq_r
	);
	
	iq_offset0: iq_offset port map(
		i_i => ii_r,
		q_i => qq_r,
		ai_i => i_offs,
		aq_i => q_offs,
		i_o(15 downto 3) => bi_r,
		q_o(15 downto 3) => bq_r
	);
	
	unpack0: unpack port map(
		clk_i => clk_64,
		zero => zero_word,
		i_i => bi_r,
		q_i => bq_r,
		data_o => data_reg
	);
	
	ddr0: ddr port map(
		clk_i => clk_64,
		data_i => data_reg,
		rst_i => '0',
		clk_o => clk_o,
		data_o => data_o
	);
	
	spi0: spi_receiver port map(
		mosi_i => spi_mosi,
		sck_i => spi_sck,
		ncs_i => spi_ncs,
		data_o => spi_data,
		nrst => '1',
		ena => '1',
		clk_i => clk_i
	);
	
	regs0: ctrl_regs port map(
		clk_i => clk_i,
		rst => rst,
		d_i => spi_data,
		ib_o => i_bal,
		qb_o => q_bal,
		ai_o => i_offs,
		aq_o => q_offs,
		fmod_o => mod_r
	);
	
	-- the sample rate is set to 400k, so 9 out of 10 samples
	-- has to be 'zero words'
	process(clk_64)
		variable counter : integer range 0 to 10*32 := 0;
	begin
		if rising_edge(clk_64) then
			if counter=10*32-1 then
				counter := 0;
			else
				if counter<16 then
					zero_word <= '0';
				else
					zero_word <= '1';
				end if;
				counter := counter + 1;
			end if;
		end if;
	end process;
	
	tst_o <= '0' when i_bal=x"0000" else '1'; -- test LED, ON when data good
end magic;
