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
  end record;

  constant init : reg_type :=
  (
    shift_register => (others => '0')
  );

  signal r, rin : reg_type := init;
begin
  -- Combinational process
  comb : process(clk, rst, r, i2s_mosi, axis_tx_miso)
    variable v  : reg_type;
  begin
    v := r; -- default assignment

    -- if (din.valid) then 
    --   v.shift_counter := 32;
    --   v.shift_register := I_SYNC & din.i_data & Q_SYNC & din.q_data;
    --   v.lvds_clk := '0';
    -- end if;

    -- if (r.shift_counter > 0) then 
    --   v.shift_counter := r.shift_counter - 1;
    --   v.shift_register(31 downto 0) := r.shift_register(30 downto 0) & '0';
    --   v.lvds_clk := not r.lvds_clk;
    -- end if;

    -- v.lvds_data := r.shift_register(31);

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
    -- dout.lvds_clk <= r.lvds_clk;
    -- dout.lvds_data <= r.lvds_data;
  end process;
end butler;