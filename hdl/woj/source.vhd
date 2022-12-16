--I2S sample source
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
 
entity sig_source is
    port(
        clk : in std_logic;
		data : in std_logic_vector(0 to 15);
        i2s_clk : out std_logic;
        lr_clk : buffer std_logic;
        outp : out std_logic;
		n_bsy : out std_logic
    );
end sig_source;
 
architecture sig_source_arch of sig_source is
    
    signal count_main : integer := 0;		--0 to 29 (12M/30=400k)
    signal count_lr : integer := 0;			--0 to 1499 (12M/1500=8k)
	signal bit_num : integer := 0;			--0 to 49 (50 bits per I2S frame)
    signal main_clk : std_logic := '0';
    signal chan_clk : std_logic := '0';
    signal o : std_logic := '0';
begin
    process(count_main, count_lr)
    begin
        -- Main clock generation 
        if (count_main < 15) then 
            main_clk <= '0';
        else 
            main_clk <= '1';
        end if;
 
        -- Derived channel clock 
        if (count_lr < 750) then 
            chan_clk <= '0'; 
        else 
            chan_clk <= '1'; 
        end if;
    end process;

    process(clk)
    begin
        if (rising_edge(clk)) then 
            if (count_main = 30-1) then 
                count_main <= 0; 
            else 
                count_main <= count_main + 1;
            end if;
            
            if (count_lr = 1500-1) then 
                count_lr <= 0; 
            else 
                count_lr <= count_lr + 1;
            end if;
        end if;
    end process;
	
	process(main_clk)
	begin
		if (falling_edge(main_clk)) then
			if (bit_num = 50-1) then
                bit_num <= 0;
            else
                bit_num <= bit_num + 1;
            end if;
		end if;
	end process;
	
	process(bit_num)
	begin
		if (bit_num >= 0 and bit_num < 0+16) then
			n_bsy <= '0';
			o <= data(bit_num);
		elsif (bit_num >= 25 and bit_num < 25+16) then
			o <= data(bit_num-25);
		else
			n_bsy <= '1';
			o <= '0';
		end if;
	end process;
    
    i2s_clk <= main_clk;
    lr_clk <= chan_clk;
    outp <= o;
end sig_source_arch;