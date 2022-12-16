--I2C high-Z
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;

entity lvds_test is
	port(
		in_12M : in std_logic;
		clock : out std_logic;
		data : out std_logic
	);
end lvds_test;

architecture lvds_test_arch of lvds_test is
	--both samples are 16 bits: sync(2) & value(13) & '0'
	--signal I_sample : std_logic_vector(0 to 15) := "10" & "0111111111111" & "0";
	--signal Q_sample : std_logic_vector(0 to 15) := "01" & "0000000000000" & "0";
	signal I_sample : std_logic_vector(0 to 15) := x"AAAA";
	signal Q_sample : std_logic_vector(0 to 15) := x"0000";

	signal cnt : integer range 0 to 12000 := 0;
	signal o : std_logic := '0';
	signal bit_cnt1 : integer range 0 to 32 := 0;
	signal bit_cnt2 : integer range 0 to 32 := 0;
begin
	process(in_12M, cnt)
	begin
		if(rising_edge(in_12M)) then
			if(cnt = 12000-1) then
				cnt <= 0;
			else
				cnt <= cnt + 1;
			end if;
		end if;
	end process;
	
	process(cnt)
	begin
		if(cnt < 6000) then
			o <= '1';
		else
			o <= '0';
		end if;
	end process;
	
	process(o, bit_cnt1, bit_cnt2)
	begin
		if(rising_edge(o)) then
			if(bit_cnt1 = 16-1) then
				bit_cnt1 <= 0;
			else
				bit_cnt1 <= bit_cnt1 + 1;
			end if;
		end if;
		if(falling_edge(o)) then
			if(bit_cnt2 = 16-1) then
				bit_cnt2 <= 0;
			else
				bit_cnt2 <= bit_cnt2 + 1;
			end if;
		end if;
	end process;
	
	process(bit_cnt1, bit_cnt2)
	begin
		if(bit_cnt1 = 0 and bit_cnt2 = 15) then
			data <= Q_sample(15);
		elsif(bit_cnt1+bit_cnt2 < 16) then
			data <= I_sample(bit_cnt1+bit_cnt2);
		else
			data <= Q_sample(bit_cnt1+bit_cnt2-16);
		end if;
	end process;
	
	clock <= o;
end;
