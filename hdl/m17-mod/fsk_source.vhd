--2FSK source
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fsk_source is
	port(
		clk_i	: in std_logic;						-- clock source
		mod_o	: out std_logic_vector(15 downto 0)	-- sig out
	);
end fsk_source;

architecture magic of fsk_source is
begin
	process(clk_i)
		variable cnt : integer range 0 to 12000000 := 0;
	begin
		if rising_edge(clk_i) then
			if cnt=12000000-1 then
				cnt := 0;
			else
				cnt := cnt + 1;
			end if;
			
			if cnt<12000000/2 then
				mod_o <= x"0CCC";
			else
				mod_o <= x"F334";
			end if;
		end if;
	end process;
end magic;
