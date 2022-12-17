-- Copyright Mark Saunders 2016

library IEEE;
use IEEE.std_logic_1164.all;

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

    -- AT86RF215 SPI Master Interface
    rf_spi_clk	: out std_logic;
    rf_spi_cs	  : out std_logic;
    rf_spi_miso	: in std_logic;
    rf_spi_mosi	: out std_logic;

    -- Audio I2S Data Interface
    audio_i2s_bclk	: out std_logic;
    audio_i2s_fclk	: out std_logic;
    audio_i2s_dac	: out std_logic;
    audio_i2s_adc	: in std_logic;

    -- Audio I2C Master Interface
    audio_i2c_clk	: out std_logic;
    audio_i2c_sda	: inout std_logic;

    -- MCU SPI Slave Interface
    mcu_spi_clk		: in std_logic;
    mcu_spi_cs		: in std_logic;
    mcu_spi_mosi	: in std_logic;
    mcu_spi_miso	: out std_logic
  );
end openht_fpga_top;

architecture magic of openht_fpga_top is
  signal locked : std_logic;
  signal reset_200Mhz : std_logic;
  signal clk_200Mhz : std_logic;

  signal i2s_source_ctrl : i2s_source_ctrl_type;
  signal i2s_source_data : i2s_source_data_type;

  component clock_pll is
    port(
      clki_i: in std_logic;
      rstn_i: in std_logic;
      clkop_o: out std_logic;
      lock_o: out std_logic
    );
  end component;
begin
  reset_200Mhz <= not locked;

  pll: clock_pll port map(
    clki_i=> clk_125Mhz,
    rstn_i=> rstn,
    clkop_o=> clk_200Mhz,
    lock_o=> locked
  );

  i2s_source_inst : i2s_source
  port map (
    clk => clk_200Mhz,
    rst => reset_200Mhz,
    
    din   => i2s_source_ctrl,
    dout  => i2s_source_data
  );

  audio_i2s_bclk <= i2s_source_data.i2s_clk;
  audio_i2s_fclk <= i2s_source_data.chan_clk;
  audio_i2s_dac <= i2s_source_data.i2s_data;

end magic;
