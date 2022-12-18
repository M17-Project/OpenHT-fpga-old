library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package i2s_types is
  -- Signals from I2S master to slave
  type i2s_master_out_type is record 
    sck : std_logic;  -- Serial clock
    ws  : std_logic;
    sd  : std_logic;  -- Serial data from master
  end record;

  -- Signals for I2S slave to master
  type i2s_slave_out_type is record 
    sd : std_logic;   -- Serial data to master
  end record;
end package;
