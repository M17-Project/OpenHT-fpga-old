--SPI receiver
library IEEE;
use IEEE.std_logic_1164.all;

entity spi_rx is
	port(
		cs : in std_logic;
		mosi : in std_logic;
		sck : in std_logic;
		d : out std_logic_vector(0 to 15)
	);
end spi_rx;

architecture spi_rx_arch of spi_rx is
	signal data_reg : std_logic_vector(0 to 15) := x"0000";
begin
	process(cs)
	begin
		--if(falling_edge(cs)) then
			--data_reg <= x"0000";
		if(rising_edge(cs)) then
			d <= data_reg;
		end if;
	end process;
	
	process(sck)
	begin
		if(rising_edge(sck)) then
			data_reg <= data_reg(1 to 15) & mosi;
		end if;
	end process;
end;
