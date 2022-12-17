library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.openht_fpga_types.all;

entity i2s_source is
  port (
    clk : in std_logic; -- 50 Mhz
    rst : in std_logic; -- Active high

    din   : in  i2s_source_ctrl_type;
    dout  : out i2s_source_data_type
  );
end i2s_source;

architecture magic of i2s_source is
  type sample_array is array(0 to 7) of std_logic_vector(0 to 15);

  constant SAMPLE_LEN : integer := 13;
  constant SINE_1K : sample_array :=
    (x"0000", x"5A81", x"7FFF", x"5A81", x"0000", x"A57F", x"8001", x"A57F");

  constant MAIN_DIV       : integer := 30;    -- 12M/30=400k
  constant CHAN_DIV       : integer := 1500;  -- 12M/1500=8k
  constant I2S_FRAME_BITS : integer := 50;    -- 50 bits per I2S frame
  constant SAMPLE_NUM     : integer := 8;     -- 8 samples in the LUT

  type reg_type is record
    count_main  : integer range 0 to MAIN_DIV-1;
    count_lr    : integer range 0 to CHAN_DIV-1;
    bit_num     : integer range 0 to I2S_FRAME_BITS-1;
    sample_num  : integer range 0 to SAMPLE_NUM-1;

    i2s_clk   : std_logic;
    chan_clk  : std_logic;
    i2s_data  : std_logic;
  end record;

  constant init : reg_type :=
  (
    count_main => 0,
    count_lr => 0,
    bit_num => 0,
    sample_num => 0,

    i2s_clk => '0',
    chan_clk => '0',
    i2s_data => '0'
  );

  signal r, rin : reg_type := init;
begin
  -- Combinational process
  comb : process(clk, rst, r, din)
    variable v  : reg_type;
  begin
    v := r; -- default assignment

    -- Main clock generation
    if (r.count_main < MAIN_DIV/2) then
      v.i2s_clk := '0';
    else
      v.i2s_clk := '1';
    end if;

    if (r.count_main = MAIN_DIV-1) then
      v.count_main := 0;
    else
      v.count_main := r.count_main + 1;
    end if;

    -- Derived channel clock
    if (r.count_lr < CHAN_DIV/2) then
      v.chan_clk := '0';
    else
      v.chan_clk := '1';
    end if;

    if (r.count_lr = CHAN_DIV-1) then
      v.count_lr := 0;
    else
      v.count_lr := r.count_lr + 1;
    end if;

    -- Bit generation
    if (r.bit_num = 50-1) then
      v.bit_num := 0;
      v.sample_num := sample_num + 1;
    else
      v.bit_num := r.bit_num + 1;
      if (r.sample_num = 8) then
        v.sample_num := 0;
      end if;
    end if;

    if (r.bit_num >= 0 and r.bit_num < 0+16) then
      v.i2s_data := sine_1k(r.sample_num)(r.bit_num);
    elsif (r.bit_num >= 25 and r.bit_num < 25+16) then
      v.i2s_data := sine_1k(r.sample_num)(r.bit_num-25);
    else
      v.i2s_data := '0';
    end if;

    if (rst = '1') then
      v := init;
    end if;

    rin <= v;
  end process;

  -- Register process
  regs : process (clk)
  begin
    if rising_edge(clk) then
      r <= rin;
    end if;
  end process;

  -- Output process
  output: process (r)
  begin
    dout.i2s_clk <= r.i2s_clk;
    dout.chan_clk <= r.chan_clk;
    dout.i2s_data <= r.i2s_data;
  end process;
end magic;
