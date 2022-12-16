library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package openht_fpga_types is

  type fm_demod_ctrl_type is record
    -- AXI Stream Bus
    axis_tvalid  : std_logic;
    axis_tdata   : std_logic_vector(15 downto 0);
    axis_tid     : std_logic_vector(1 downto 0);
  end record;

  type fm_demod_data_type is record
    -- AXI Stream Bus
    axis_tvalid  : std_logic;
    axis_tdata   : std_logic_vector(15 downto 0);
    axis_tid     : std_logic_vector(1 downto 0);
  end record;

  component fm_demod
  port (
    clk     : in    std_logic;
    rst     : in    std_logic;

    din     : in    fm_demod_ctrl_type;
    dout    : out   fm_demod_data_type
  );
  end component;

  type i2s_source_ctrl_type is record
    -- AXI Stream Bus
    axis_tvalid  : std_logic;
    axis_tdata   : std_logic_vector(15 downto 0);
    axis_tid     : std_logic_vector(1 downto 0);
  end record;

  type i2s_source_data_type is record
    i2s_clk   : std_logic;
    chan_clk  : std_logic;
    i2s_data  : std_logic;
  end record;

  component i2s_source
  port (
    clk     : in    std_logic;
    rst     : in    std_logic;

    din     : in    i2s_source_ctrl_type;
    dout    : out   i2s_source_data_type
  );
  end component;
end package;
