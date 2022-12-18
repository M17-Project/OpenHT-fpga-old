library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i2s_types.all;
use work.axi_types.all;
use work.openht_fpga_types.all;

entity mcu_i2s_slave is
  port (
    clk       : in    std_logic; 
    rst       : in    std_logic;

    i2s_mosi  : in  i2s_master_out_type;
    i2s_miso  : out i2s_slave_out_type;

    axis_tx_mosi : out axis_master_out_type;
    axis_tx_miso : in axis_slave_out_type
  );
end mcu_i2s_slave;

architecture butler of mcu_i2s_slave is
  type reg_type is record
    shift_register : std_logic_vector(15 downto 0);

    clk_sync : std_logic_vector(2 downto 0);
    word_sync : std_logic_vector(2 downto 0);
    data_sync : std_logic_vector(2 downto 0);

    axis_tx_mosi : axis_master_out_type;
  end record;

  constant init : reg_type :=
  (
    shift_register => (others => '0'),

    clk_sync => (others => '0'),
    word_sync => (others => '0'),
    data_sync => (others => '0'),

    axis_tx_mosi => axis_master_out_init
  );

  signal r, rin : reg_type := init;
begin
  -- Combinational process
  comb : process(clk, rst, r, i2s_mosi, axis_tx_miso)
    variable v  : reg_type;
  begin
    v := r; -- default assignment

    v.clk_sync(2 downto 0) := i2s_mosi.sck & r.clk_sync(2 downto 1);
    v.word_sync(2 downto 0) := i2s_mosi.ws & r.word_sync(2 downto 1);
    v.data_sync(2 downto 0) := i2s_mosi.sd & r.data_sync(2 downto 1);

    if (r.clk_sync(1) = '1' and r.clk_sync(0) = '0') then 
      v.shift_register(15 downto 0) := r.shift_register(15 downto 1) & r.data_sync(0);
    end if;

    v.axis_tx_mosi.tvalid := '0';
    if (r.word_sync(1) = '1' and r.word_sync(0) = '0') then 
      v.axis_tx_mosi.tvalid := '1';
      v.axis_tx_mosi.tdata := r.shift_register;
      v.axis_tx_mosi.tid := "0";
    end if;

    if (r.word_sync(1) = '0' and r.word_sync(0) = '1') then 
      v.axis_tx_mosi.tvalid := '1';
      v.axis_tx_mosi.tdata := r.shift_register;
      v.axis_tx_mosi.tid := "1";
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
    axis_tx_mosi <= r.axis_tx_mosi;
  end process;
end butler;