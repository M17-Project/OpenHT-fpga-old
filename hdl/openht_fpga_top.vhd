-- Copyright Mark Saunders 2016

library IEEE;
use IEEE.std_logic_1164.all;

use work.openht_fpga_types.all;

entity openht_fpga_top is
  port (
    clk_12Mhz   : std_logic;
    rstn        : std_logic;

    -- AT86RF215 Data Interface
    rf_txclk	: out std_logic;
    rf_txdat	: out std_logic;
    rf_rxclk	: in std_logic;
    rf_rx09		: in std_logic;
    rf_rx24		: in std_logic;

    -- AT86RF215 SPI Master Interface
    rf_spi_clk	: out std_logic;
    rf_spi_cs	  : out std_logic;
    rf_spi_miso	: in std_logic;
    rf_spi_mosi	: out std_logic;

    -- Audio I2S Data Interface
    audo_i2s_bclk	: out std_logic;
    audo_i2s_fclk	: out std_logic;
    audo_i2s_dac	: out std_logic;
    audo_i2s_adc	: in std_logic;

    -- Audio I2C Master Interface
    audo_i2c_clk	: out std_logic;
    audo_i2c_sda	: inout std_logic;

    -- MCU SPI Slave Interface
    mcu_spi_clk		: in std_logic;
    mcu_spi_cs		: in std_logic;
    mcu_spi_mosi	: in std_logic;
    mcu_spi_miso	: out std_logic
  );
end openht_fpga_top;

architecture magic of openht_fpga_top is
  signal reset : std_logic;
begin
  reset <= not rstn;



  i2s_source_inst : i2s_source
  port map (
    clk =>
  )

end magic;
