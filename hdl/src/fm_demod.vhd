-- Copyright Mark Saunders 2016

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.openht_fpga_types.all;

entity fm_demod is
  port (
    clk : in std_logic; -- 50 Mhz
    rst : in std_logic; -- Active high

    din     : in    fm_demod_ctrl_type;
    dout    : out   fm_demod_data_type
  );
end fm_demod;

architecture magic of fm_demod is
  constant SAMPLE_LEN: integer := 13;

  type reg_type is record
    re_delay1 : std_logic_vector(SAMPLE_LEN-1 downto 0);
    re_delay2 : std_logic_vector(SAMPLE_LEN-1 downto 0);
  end record;

  constant init : reg_type :=
  (
    re_delay1 => (others => '0'),
    re_delay2 => (others => '0')
  );

  signal r, rin : reg_type := init;

begin
  -- Combinational process
  comb : process(clk, rst, r, din)
    variable v  : reg_type;
  begin
    v := r; -- default assignment


    if (rst = '0') then
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
  end process;
end magic;