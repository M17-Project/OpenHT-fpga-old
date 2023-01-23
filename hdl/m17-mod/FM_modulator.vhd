--FM modulator
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fm_modulator is
	port(
		nrst	: in std_logic;						-- reset
		clk_i	: in std_logic;						-- main clock
		mod_i	: in std_logic_vector(15 downto 0);	-- modulation in
		i_o		: out std_logic_vector(7 downto 0);	-- I data out
		q_o		: out std_logic_vector(7 downto 0)	-- Q data out
	);
end fm_modulator;

architecture magic of fm_modulator is
	signal raw_i : std_logic_vector(15 downto 0) := (others => '0');
	signal raw_q : std_logic_vector(15 downto 0) := (others => '0');
	signal phase : std_logic_vector(15 downto 0) := (others => '0');
	
	component sincos_lut is
		port(
			theta_i		:   in  std_logic_vector(7 downto 0);
			sine_o		:   out std_logic_vector(15 downto 0);
			cosine_o	:   out std_logic_vector(15 downto 0)
		);
	end component;
begin
	-- sincos LUT
	sincos_lut0: sincos_lut port map(theta_i => phase(15 downto 8), sine_o => raw_q, cosine_o => raw_i);

	process(clk_i)
		variable counter : integer range 0 to 250 := 0;
	begin
		if rising_edge(clk_i) then
			if nrst='1' then
				if counter=250-1 then
					phase <= std_logic_vector(unsigned(phase) + unsigned(mod_i)); -- update phase accumulator
					counter := 0;
				else
					counter := counter + 1;
				end if;
			else
				counter := 0;
				phase <= (others => '0');
			end if;
		end if;
	end process;
	
	-- convert vectors to AT86-format
	i_o <= "1" & raw_i(14 downto 8);
	q_o <= "1" & raw_q(14 downto 8);
end magic;
