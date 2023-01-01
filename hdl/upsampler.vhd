-------------------------------------------------------------
-- 48k -> 1200k (25x) upsampler
--
-- Wojciech Kaczmarski, SP5WWP
-- M17 Project
-- January 2023
-------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity upsampler is
	port(
		clk_i	: in  std_logic;						-- should be 1.2 MHz
		data_i	: in  std_logic_vector(15 downto 0);	-- 16-bit sample in
		data_o	: out std_logic_vector(15 downto 0)
	);
end upsampler;

architecture magic of upsampler is
begin
	-- alternately output data_i and 24x 0 samples
	process(clk_i)
		variable sample_cnt : integer range 0 to 25 := 0;
	begin
		if(rising_edge(clk_i)) then
			if(sample_cnt = 24) then
				data_o <= data_i;
				sample_cnt := 0;
			else
				data_o <= (others => '0');
				sample_cnt := sample_cnt + 1;
			end if;
		end if;
	end process;
end magic;
