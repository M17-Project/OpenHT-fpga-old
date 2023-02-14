--positive ramp source (sawtooth)
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ramp_source is
	port(
		clk_i	: in std_logic;						-- clock source
		mod_o	: out std_logic_vector(15 downto 0)	-- sig out
	);
end ramp_source;

architecture magic of ramp_source is
	signal cnt_reg : std_logic_vector(15 downto 0) := (others => '0');
begin
	process(clk_i)
		variable cnt : integer range 0 to 1200 := 0;
	begin
		if rising_edge(clk_i) then
			if cnt=1200-1 then
				cnt := 0;
				cnt_reg <= std_logic_vector(unsigned(cnt_reg)+1);
			else
				cnt := cnt + 1;
			end if;
		end if;
	end process;
	
	mod_o <= cnt_reg;
end magic;
