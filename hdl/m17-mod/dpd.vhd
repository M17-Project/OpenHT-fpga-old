-------------------------------------------------
-- IQ polynomial digital predistortion model
--
-- Wojciech Kaczmarski, SP5WWP
-- M17 Project
-- February 2023
-------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dpd is
	port(
		-- p1*x + p2*|x|^2 + p3*x^3
		p1 : signed(15 downto 0);
		p2 : signed(15 downto 0);
		p3 : signed(15 downto 0);
		i_i : in std_logic_vector(15 downto 0);
		q_i : in std_logic_vector(15 downto 0);
		i_o: out std_logic_vector(15 downto 0);
		q_o: out std_logic_vector(15 downto 0)
	);
end dpd;

architecture magic of dpd is
	signal i1 : std_logic_vector(31 downto 0) := (others => '0');
	signal i2 : std_logic_vector(47 downto 0) := (others => '0');
	signal i3 : std_logic_vector(63 downto 0) := (others => '0');
	signal imul : std_logic_vector(31 downto 0) := (others => '0');

	signal q1 : std_logic_vector(31 downto 0) := (others => '0');
	signal q2 : std_logic_vector(47 downto 0) := (others => '0');
	signal q3 : std_logic_vector(63 downto 0) := (others => '0');
	signal qmul : std_logic_vector(31 downto 0) := (others => '0');
begin
	--0x4000 is "+1.00"
	imul <= std_logic_vector(signed(i_i) * signed(i_i));
	i1 <= std_logic_vector(signed(i_i) * p1);
	i2 <= std_logic_vector(signed(imul) * p2) when signed(i_i)>=0 else std_logic_vector(-signed(imul) * p2);
	i3 <= std_logic_vector(signed(imul) * signed(i_i) * p3);
	i_o <= std_logic_vector(signed(i1(29 downto 14)) + signed(i2(43 downto 28)) + signed(i3(57 downto 42)));

	qmul <= std_logic_vector(signed(q_i) * signed(q_i));
	q1 <= std_logic_vector(signed(q_i) * p1);
	q2 <= std_logic_vector(signed(qmul) * p2) when signed(q_i)>=0 else std_logic_vector(-signed(qmul) * p2);
	q3 <= std_logic_vector(signed(qmul) * signed(q_i) * p3);
	q_o <= std_logic_vector(signed(q1(29 downto 14)) + signed(q2(43 downto 28)) + signed(q3(57 downto 42)));
end magic;
