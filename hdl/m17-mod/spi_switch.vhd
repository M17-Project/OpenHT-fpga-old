--SPI switch
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity spi_switch is
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
end spi_switch;

architecture magic of spi_switch is
begin
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if ctrl='0' then
				n_cs_o <= n_cs0_i;
				miso0_o <= miso_i;
				mosi_o <= mosi0_i;
				sck_o <= sck0_i;
			else
				n_cs_o <= n_cs1_i;
				miso1_o <= miso_i;
				mosi_o <= mosi1_i;
				sck_o <= sck1_i;
			end if;
		end if;
	end process;
end magic;
