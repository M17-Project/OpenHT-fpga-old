--main, top-level file
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
--use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity main is
	port(
		--i2s source
		clk_12M  : in std_logic;
		clk_400k : out std_logic;
		clk_8k : buffer std_logic;
		i2s_out : out std_logic;
		
		--i2c and bypass
		i2c_scl : in std_logic;
		i2c_sda : in std_logic;
		i2c_scl_bp : out std_logic;
		i2c_sda_bp : out std_logic;
		
		--spi receiver
		spi_mosi : in std_logic;
		spi_sck : in std_logic;
		spi_cs : in std_logic;
		
		--lvds clock out test
		lvds_clock : out std_logic;
		lvds_data : out std_logic
	);
end main;

architecture main_arch of main is
	component sig_source is
		port(
			clk : in std_logic;
			data : in std_logic_vector(0 to 15);
			i2s_clk : out std_logic;
			lr_clk : buffer std_logic;
			outp : out std_logic;
			n_bsy : out std_logic
		);
	end component;
	
	component spi_rx is
		port(
			cs : in std_logic;
			mosi : in std_logic;
			sck : in std_logic;
			d : out std_logic_vector(0 to 15)
		);
	end component;
	
	component lvds_test is
	port(
		in_12M : in std_logic;
		clock : out std_logic;
		data : out std_logic
	);
	end component;
	
    signal spi_data : std_logic_vector(0 to 15) := x"0000";
	signal spi_data_buff : std_logic_vector(0 to 15) := x"0000";
	signal n_b : std_logic := '1';
begin
	i2s: sig_source port map (clk => clk_12M, data => spi_data, i2s_clk => clk_400k, lr_clk => clk_8k, outp => i2s_out, n_bsy => n_b);
	spi: spi_rx port map (cs => spi_cs, mosi => spi_mosi, sck => spi_sck, d => spi_data_buff);
	lvds: lvds_test port map (in_12M => clk_12M, clock => lvds_clock, data => lvds_data);
	
	process(n_b)
	begin
		if(rising_edge(n_b)) then
			spi_data <= spi_data_buff;
		end if;
	end process;
	
	i2c_scl_bp <= i2c_scl;
	i2c_sda_bp <= i2c_sda;
end main_arch;
