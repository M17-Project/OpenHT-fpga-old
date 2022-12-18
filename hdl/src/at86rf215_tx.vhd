library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.axi_types.all;
use work.openht_fpga_types.all;

entity at86rf215_tx is
  port (
    clk : in std_logic; -- 128 Mhz
    rst : in std_logic; -- Active high

    axis_tx_mosi  : in  axis_master_out_type;
    axis_tx_miso  : out axis_slave_out_type;

    lvds_out  : out at86rf215_tx_data_type
  );
end at86rf215_tx;

architecture bitaccelerator of at86rf215_tx is
  constant I_SYNC : std_logic_vector(1 downto 0) := "10";
  constant Q_SYNC : std_logic_vector(1 downto 0) := "01";    

  type reg_type is record
    shift_register : std_logic_vector(31 downto 0);
    shift_counter : integer range 0 to 32;

    lvds_clk  : std_logic;
    lvds_data : std_logic;
  end record;

  constant init : reg_type :=
  (
    shift_register => (others => '0'),
    shift_counter => 0,

    lvds_clk => '0',
    lvds_data => '0'
  );

  signal r, rin : reg_type := init;
begin
  -- Combinational process
  comb : process(clk, rst, r, axis_tx_mosi)
    variable v  : reg_type;
  begin
    v := r; -- default assignment

    if (axis_tx_mosi.tvalid = '1') then 
      if (axis_tx_mosi.tid = "0") then 
        v.shift_register(31 downto 16) := I_SYNC & axis_tx_mosi.tdata(13 downto 0);
      end if;

      if (axis_tx_mosi.tid = "1") then 
        v.shift_register(15 downto 0) := Q_SYNC & axis_tx_mosi.tdata(13 downto 0);
        v.shift_counter := 32;
        v.lvds_clk := '0';
      end if;
    end if;

    if (r.shift_counter > 0) then 
      v.shift_counter := r.shift_counter - 1;
      v.shift_register(31 downto 0) := r.shift_register(30 downto 0) & '0';
      v.lvds_clk := not r.lvds_clk;
    end if;

    v.lvds_data := r.shift_register(31);

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
    lvds_out.lvds_clk <= r.lvds_clk;
    lvds_out.lvds_data <= r.lvds_data;
  end process;
end bitaccelerator;
