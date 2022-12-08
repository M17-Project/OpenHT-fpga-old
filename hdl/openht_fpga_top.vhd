-- Copyright Mark Saunders 2016

library IEEE;
use IEEE.std_logic_1164.all;

use work.nxp_fpga_types.all;

entity openht_fpga_top is
    port (
        -- AT86RF215 Data Interface
        RF_TXCLK	: out std_logic;
		RF_TXDAT	: out std_logic;
		RF_RXCLK	: in std_logic;
		RX_RX09		: in std_logic;
		RX_RX24		: in std_logic;

		-- AT86RF215 SPI Master Interface
		RF_SPI_CLK	: out std_logic;
		RF_SPI_CS	: out std_logic;
		RF_SPI_MISO	: in std_logic;
		RF_SPI_MOSI	: out std_logic;

        -- Audio I2S Data Interface
        AUDIO_I2S_BCLK	: out std_logic;
		AUDIO_I2S_FCLK	: out std_logic;
		AUDIO_I2S_DAC	: out std_logic;
		AUDIO_I2S_ADC	: in std_logic;

		-- Audio I2C Master Interface
		AUDIO_I2C_SCL	: out std_logic;
		AUDIO_I2C_SDA	: inout std_logic;

		-- MCU SPI Slave Interface
		MCU_SPI_CLK		: in std_logic;
		MCU_SPI_CS		: in std_logic;
		MCU_SPI_MOSI	: in std_logic;
		MCU_SPI_MISO	: out std_logic
    );
end openht_fpga_top;

architecture magic of openht_fpga_top is

begin


end magic;
