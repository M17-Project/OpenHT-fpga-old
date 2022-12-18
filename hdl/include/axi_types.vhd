library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package axi_types is
  type axis_master_out_type is record
    tvalid  : std_logic;
    tdata   : std_logic_vector(15 downto 0);
    tid     : std_logic_vector(0 downto 0);
  end record;

  type axis_slave_out_type is record
    tready  : std_logic;
  end record;
end package;
