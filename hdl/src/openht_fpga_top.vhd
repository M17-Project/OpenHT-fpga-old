library IEEE;
use IEEE.std_logic_1164.all;

use work.axi_types.all;
use work.i2s_types.all;
use work.openht_fpga_types.all;

entity openht_fpga_top is
  port (
    clk_125Mhz  : std_logic;
    rstn        : std_logic;

    -- AT86RF215 Data Interface
    rf_txclk	: out std_logic;
    rf_txdat	: out std_logic;
    rf_rxclk	: in std_logic;
    rf_rx09		: in std_logic;
    rf_rx24		: in std_logic;

    -- MCU I2S Slave Interface
    mcu_i2s_sck     : in std_logic;
    mcu_i2s_ws      : in std_logic;
    mcu_i2s_sd_mosi : in std_logic;
    mcu_i2s_sd_miso : out std_logic;

    -- MCU SPI Slave Interface
    mcu_spi_clk		: in std_logic;
    mcu_spi_cs		: in std_logic;
    mcu_spi_mosi	: in std_logic;
    mcu_spi_miso	: out std_logic
  );
end openht_fpga_top;

architecture magic of openht_fpga_top is
  signal locked : std_logic;
  signal reset_128Mhz : std_logic;
  signal clk_128Mhz : std_logic;

  signal mcu_i2s_mosi : i2s_master_out_type;
  signal mcu_i2s_miso : i2s_slave_out_type;

  signal mcu_tx_data_mosi : axis_master_out_type;
  signal mcu_tx_data_miso : axis_slave_out_type;

  signal rf_tx_lvds : at86rf215_tx_data_type;

  component clock_pll is
    port(
      clki_i: in std_logic;
      rstn_i: in std_logic;
      clkop_o: out std_logic;
      lock_o: out std_logic
    );
  end component;
begin
  reset_128Mhz <= not locked;

  pll: clock_pll port map(
    clki_i=> clk_125Mhz,
    rstn_i=> rstn,
    clkop_o=> clk_128Mhz,
    lock_o=> locked
  );

  -- Microcontroller I2S slave module
  mcu_i2s_inst : mcu_i2s_slave 
  port map(
    clk => clk_128Mhz,
    rst => reset_128Mhz,

    i2s_mosi => mcu_i2s_mosi,
    i2s_miso => mcu_i2s_miso,

    axis_tx_mosi => mcu_tx_data_mosi,
    axis_tx_miso => mcu_tx_data_miso
  );

  mcu_i2s_mosi.sck <= mcu_i2s_sck;
  mcu_i2s_mosi.ws  <= mcu_i2s_ws;
  mcu_i2s_mosi.sd  <= mcu_i2s_sd_mosi;

  mcu_i2s_sd_miso <= mcu_i2s_miso.sd;


  -- RF module transmitter interface
  at86rf215_tx_inst : at86rf215_tx
  port map (
    clk => clk_128Mhz,
    rst => reset_128Mhz,
    
    axis_tx_mosi  => mcu_tx_data_mosi,
    axis_tx_miso  => mcu_tx_data_miso,

    lvds_out => rf_tx_lvds
  );

  rf_txclk <= rf_tx_lvds.lvds_clk;
  rf_txdat <= rf_tx_lvds.lvds_data;

end magic;
