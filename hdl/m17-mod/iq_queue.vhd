--IQ queue
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity iq_queue is
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
end iq_queue;

architecture magic of iq_queue is
	signal p_trig	: std_logic := '0';
	signal counting	: std_logic := '0';
	signal i_latch, q_latch : std_logic_vector(7 downto 0);
begin
	process(clk_i)
		variable counter : integer range 0 to 205 := 0;
	begin
		if(rising_edge(clk_i)) then
			p_trig <= trig_i;
		
			if(nrst='0') then
				counter := 0;
				counting <= '0';
				nCS <= '1';
			else
				-- rising edge at trig_in
				if(trig_i='1' and p_trig='0') then
					counting <= '1';
				end if;
				
				-- counting
				if(counting='1') then
					if(counter=205-1) then
						counter := 0;
						counting <= '0';
					else
						counter := counter + 1;
					end if;
				end if;
				
				-- do stuff
				if(counting='1') then
					if(counter=1) then
						i_latch <= i_i;
						q_latch <= q_i;
						nCS <= '0';
						d_o <= x"81";
					elsif(counter=2) then
						trig_o <= '1';
					elsif(counter=3) then
						trig_o <= '0';
						
					elsif(counter=51) then
						d_o <= x"27";
					elsif(counter=52) then
						trig_o <= '1';
					elsif(counter=53) then
						trig_o <= '0';
						
					elsif(counter=101) then
						d_o <= i_latch;
					elsif(counter=102) then
						trig_o <= '1';
					elsif(counter=103) then
						trig_o <= '0';
						
					elsif(counter=151) then
						d_o <= q_latch;
					elsif(counter=152) then
						trig_o <= '1';
					elsif(counter=153) then
						trig_o <= '0';
					
					elsif(counter=201) then
						nCS <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;
end magic;
