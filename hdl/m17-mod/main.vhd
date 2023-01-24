--main
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity main_all is
	port(
		clk_i	: in std_logic; -- 12 MHz clock
		spi_sw	: in std_logic;
		-- SPI from the micro
		n_CS_i	: in std_logic;
		MISO_o	: out std_logic;
		MOSI_i	: in std_logic;
		SCK_i	: in std_logic;
		-- SPI to the AT86
		n_CS_o	: out std_logic;
		MISO_i	: in std_logic;
		MOSI_o	: out std_logic;
		SCK_o	: out std_logic;
		--global reset
		nrst	: in std_logic
		--test
		--tst		: out std_logic
	);
end main_all;

architecture magic of main_all is
	signal clk_1_2		: std_logic;									-- 1.2 MHz
	signal trig			: std_logic;									-- data transfer trigger for SPI0
	signal data			: std_logic_vector(7 downto 0);
	signal spi_trig 	: std_logic := '0';
	signal n_CS_net		: std_logic := '1';
	signal MOSI_net		: std_logic := '1';
	signal MISO_net		: std_logic := '1';
	signal SCK_net		: std_logic := '1';
	signal raw_i		: std_logic_vector(7 downto 0);					-- raw
	signal raw_q		: std_logic_vector(7 downto 0);
	signal bal_i		: std_logic_vector(7 downto 0);					-- balanced
	signal bal_q		: std_logic_vector(7 downto 0);
	signal raw_mod		: std_logic_vector(15 downto 0);				-- modulating signal
	
	-- SPI master
	component spi_master is
		generic(
			slaves  : integer := 1;	--number of spi slaves
			d_width : integer := 8	--data bus width
		);
		port(
			clock   : in     std_logic;                             --system clock
			reset_n : in     std_logic;                             --asynchronous reset
			enable  : in     std_logic;                             --initiate transaction
			cpol    : in     std_logic;                             --spi clock polarity
			cpha    : in     std_logic;                             --spi clock phase
			cont    : in     std_logic;                             --continuous mode command
			clk_div : in     integer;                               --system clock cycles per 1/2 period of sclk
			addr    : in     integer;                               --address of slave
			tx_data : in     std_logic_vector(d_width-1 downto 0);  --data to transmit
			miso    : in     std_logic;                             --master in, slave out
			sclk    : buffer std_logic;                             --spi clock
			ss_n    : buffer std_logic_vector(slaves-1 downto 0);   --slave select
			mosi    : out    std_logic;                             --master out, slave in
			busy    : out    std_logic;                             --busy / data ready signal
			rx_data : out    std_logic_vector(d_width-1 downto 0)   --data received
		);
	end component;
	
	-- IQ balancer
	component iq_balancer is
		port(
			i_i		: in std_logic_vector(7 downto 0);			-- I data in
			q_i		: in std_logic_vector(7 downto 0);			-- Q data in
			ib_i	: in std_logic_vector(15 downto 0);			-- I balance in
			qb_i	: in std_logic_vector(15 downto 0);			-- Q balance in
			i_o		: out std_logic_vector(7 downto 0);			-- I data in
			q_o		: out std_logic_vector(7 downto 0)			-- Q data in
		);
	end component;
	
	-- data queue
	component iq_queue is
		port(
			clk_i	: in std_logic;						-- 12 MHz clock
			trig_i	: in std_logic;						-- trigger in
			i_i		: in std_logic_vector(7 downto 0);	-- I data in
			q_i		: in std_logic_vector(7 downto 0);	-- Q data in
			d_o		: out std_logic_vector(7 downto 0);	-- data out
			trig_o	: out std_logic := '0';				--trigger out
			nCS		: out std_logic := '1';
			--global reset
			nrst	: in std_logic
		);
	end component;
	
	-- SPI switch
	component spi_switch is
		port(
			-- clock
			clk_i	: in std_logic;
			-- control
			ctrl	: in std_logic;
			-- port 0
			n_cs0_i	: in std_logic;
			miso0_o	: out std_logic;
			mosi0_i	: in std_logic;
			sck0_i	: in std_logic;
			-- port 1
			n_cs1_i	: in std_logic;
			miso1_o	: out std_logic;
			mosi1_i	: in std_logic;
			sck1_i	: in std_logic;
			-- output
			n_cs_o	: out std_logic;
			miso_i	: in std_logic;
			mosi_o	: out std_logic;
			sck_o	: out std_logic	
		);
	end component;
	
	---- AM modulator
	--component am_modulator is
		--port(
			--mod_i	: in std_logic_vector(7 downto 0);	-- modulation in
			--i_o		: out std_logic_vector(7 downto 0);	-- I data out
			--q_o		: out std_logic_vector(7 downto 0)	-- Q data out
		--);
	--end component;
	
	---- OOK modulation source
	--component ook_source is
		--port(
			--clk_i	: in std_logic;						-- clock source
			--mod_o	: out std_logic_vector(7 downto 0)	-- modulation out
		--);
	--end component;
	
	component fm_modulator is
		port(
			nrst	: in std_logic;						-- reset
			clk_i	: in std_logic;						-- main clock
			mod_i	: in std_logic_vector(15 downto 0);	-- modulation in
			i_o		: out std_logic_vector(7 downto 0);	-- I data out
			q_o		: out std_logic_vector(7 downto 0)	-- Q data out
		);
	end component;
	
	--component fsk_source is
		--port(
			--clk_i	: in std_logic;						-- clock source
			--mod_o	: out std_logic_vector(15 downto 0)	-- modulation out
		--);
	--end component;
	
	component spi_receiver is
		port(
			mosi_i	: in std_logic;							-- serial data in
			sck_i	: in std_logic;							-- clock
			ncs_i	: in std_logic;							-- slave select signal
			data_o	: out std_logic_vector(15 downto 0);	-- data register
			nrst	: in std_logic;							-- reset
			ena		: in std_logic;							-- enable
			clk_i	: in std_logic							-- fast clock
		);
	end component;
begin
	-- SPI for the DACs
	spi0: spi_master port map(clock => clk_i, reset_n => nrst, enable => spi_trig, cpol => '1', cpha => '1', cont => '0',
		clk_div => 2, addr => 0, tx_data => data, miso => '0', sclk => SCK_net, mosi => MOSI_net); --ss_n(0) => n_CS0

	-- IQ balancer
	iq_balancer0: iq_balancer port map(i_i => raw_i, q_i => raw_q, ib_i => x"8000", qb_i => x"8000",
		i_o => bal_i, q_o => bal_q);

	-- queue for the data to be sent over SPI0
	iq_queue0: iq_queue port map(clk_i => clk_i, trig_i => trig, i_i => bal_i, q_i => bal_q, d_o => data, trig_o => spi_trig,
		nCS => n_CS_net, nrst => nrst);

	-- SPI switch
	spi_switch0: spi_switch port map(clk_i => clk_i, ctrl => spi_sw,
		n_cs0_i => n_CS_i, miso0_o => MISO_o,	mosi0_i => MOSI_i, sck0_i => SCK_i,
		n_cs1_i => n_CS_net, miso1_o => MISO_net, mosi1_i => MOSI_net, sck1_i => SCK_net,
		n_cs_o => n_CS_o, miso_i => MISO_i, mosi_o => MOSI_o, sck_o => SCK_o);

	-- AM modulator
	--am_mod0: am_modulator port map(mod_i => raw_mod(7 downto 0)), i_o => raw_i, q_o => raw_q);
	
	-- OOK source
	--ook_source0: ook_source port map(clk_i => clk_i, mod_o => raw_mod(7 downto 0));
	
	-- FM mod
	fm_modulator0: fm_modulator port map(nrst => nrst, clk_i => clk_i, mod_i => raw_mod, i_o => raw_i, q_o => raw_q);
	
	-- 2FSK source
	--fsk_source0: fsk_source port map(clk_i => clk_i, mod_o => raw_mod);
	
	-- SPI receiver for the baseband samples
	spi_receiver0: spi_receiver port map(mosi_i	=> MOSI_i, sck_i => SCK_i, ncs_i => n_CS_i, data_o => raw_mod,
		nrst => nrst, ena => spi_sw, clk_i => clk_i);

	-- trig the SPI data transaction from the micro once in a while
	process(clk_i)
		variable counter : integer range 0 to 250;
	begin
		if(rising_edge(clk_i)) then
			if(nrst='0') then
				counter := 0;
			else
				if(counter=250-1) then
					counter := 0;
					trig <= '1';
				else
					counter := counter + 1;
					trig <= '0';
				end if;
			end if;
		end if;
	end process;
	
	--tst <= '0';--spi_trig;
end magic;
