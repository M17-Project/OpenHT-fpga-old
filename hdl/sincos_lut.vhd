-------------------------------------------------------------
-- Unsigned 16-bit, 256-entry sine/cosine look up tables
--
-- Wojciech Kaczmarski, SP5WWP
-- M17 Project
-- December 2022
-------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sincos_lut is
    port(
        theta_i		:   in  std_logic_vector(7 downto 0);
        sine_o		:   out std_logic_vector(15 downto 0);
		cosine_o	:   out std_logic_vector(15 downto 0)
    );
end entity;

architecture magic of sincos_lut is
	type lut_arr is array (integer range 0 to 255) of std_logic_vector (15 downto 0);
	
	constant sinlut : lut_arr := (
        x"8000", x"8324", x"8647", x"896A",
        x"8C8B", x"8FAB", x"92C7", x"95E1",
        x"98F8", x"9C0B", x"9F19", x"A223",
        x"A527", x"A826", x"AB1E", x"AE10",
        x"B0FB", x"B3DE", x"B6B9", x"B98C",
        x"BC56", x"BF16", x"C1CD", x"C47A",
        x"C71C", x"C9B3", x"CC3F", x"CEBF",
        x"D133", x"D39A", x"D5F4", x"D842",
        x"DA81", x"DCB3", x"DED6", x"E0EB",
        x"E2F1", x"E4E7", x"E6CE", x"E8A5",
        x"EA6C", x"EC23", x"EDC9", x"EF5E",
        x"F0E1", x"F254", x"F3B5", x"F503",
        x"F640", x"F76B", x"F883", x"F989",
        x"FA7C", x"FB5C", x"FC29", x"FCE2",
        x"FD89", x"FE1C", x"FE9C", x"FF08",
        x"FF61", x"FFA6", x"FFD7", x"FFF5",
        x"FFFF", x"FFF5", x"FFD7", x"FFA6",
        x"FF61", x"FF08", x"FE9C", x"FE1C",
        x"FD89", x"FCE2", x"FC29", x"FB5C",
        x"FA7C", x"F989", x"F883", x"F76B",
        x"F640", x"F503", x"F3B5", x"F254",
        x"F0E1", x"EF5E", x"EDC9", x"EC23",
        x"EA6C", x"E8A5", x"E6CE", x"E4E7",
        x"E2F1", x"E0EB", x"DED6", x"DCB3",
        x"DA81", x"D842", x"D5F4", x"D39A",
        x"D133", x"CEBF", x"CC3F", x"C9B3",
        x"C71C", x"C47A", x"C1CD", x"BF16",
        x"BC56", x"B98C", x"B6B9", x"B3DE",
        x"B0FB", x"AE10", x"AB1E", x"A826",
        x"A527", x"A223", x"9F19", x"9C0B",
        x"98F8", x"95E1", x"92C7", x"8FAB",
        x"8C8B", x"896A", x"8647", x"8324",
        x"8000", x"7CDB", x"79B8", x"7695",
        x"7374", x"7054", x"6D38", x"6A1E",
        x"6707", x"63F4", x"60E6", x"5DDC",
        x"5AD8", x"57D9", x"54E1", x"51EF",
        x"4F04", x"4C21", x"4946", x"4673",
        x"43A9", x"40E9", x"3E32", x"3B85",
        x"38E3", x"364C", x"33C0", x"3140",
        x"2ECC", x"2C65", x"2A0B", x"27BD",
        x"257E", x"234C", x"2129", x"1F14",
        x"1D0E", x"1B18", x"1931", x"175A",
        x"1593", x"13DC", x"1236", x"10A1",
        x"0F1E", x"0DAB", x"0C4A", x"0AFC",
        x"09BF", x"0894", x"077C", x"0676",
        x"0583", x"04A3", x"03D6", x"031D",
        x"0276", x"01E3", x"0163", x"00F7",
        x"009E", x"0059", x"0028", x"000A",
        x"0001", x"000A", x"0028", x"0059",
        x"009E", x"00F7", x"0163", x"01E3",
        x"0276", x"031D", x"03D6", x"04A3",
        x"0583", x"0676", x"077C", x"0894",
        x"09BF", x"0AFC", x"0C4A", x"0DAB",
        x"0F1E", x"10A1", x"1236", x"13DC",
        x"1593", x"175A", x"1931", x"1B18",
        x"1D0E", x"1F14", x"2129", x"234C",
        x"257E", x"27BD", x"2A0B", x"2C65",
        x"2ECC", x"3140", x"33C0", x"364C",
        x"38E3", x"3B85", x"3E32", x"40E9",
        x"43A9", x"4673", x"4946", x"4C21",
        x"4F04", x"51EF", x"54E1", x"57D9",
        x"5AD8", x"5DDC", x"60E6", x"63F4",
        x"6707", x"6A1E", x"6D38", x"7054",
        x"7374", x"7695", x"79B8", x"7CDB");

	constant coslut : lut_arr := (
        x"FFFF", x"FFF5", x"FFD7", x"FFA6",
        x"FF61", x"FF08", x"FE9C", x"FE1C",
        x"FD89", x"FCE2", x"FC29", x"FB5C",
        x"FA7C", x"F989", x"F883", x"F76B",
        x"F640", x"F503", x"F3B5", x"F254",
        x"F0E1", x"EF5E", x"EDC9", x"EC23",
        x"EA6C", x"E8A5", x"E6CE", x"E4E7",
        x"E2F1", x"E0EB", x"DED6", x"DCB3",
        x"DA81", x"D842", x"D5F4", x"D39A",
        x"D133", x"CEBF", x"CC3F", x"C9B3",
        x"C71C", x"C47A", x"C1CD", x"BF16",
        x"BC56", x"B98C", x"B6B9", x"B3DE",
        x"B0FB", x"AE10", x"AB1E", x"A826",
        x"A527", x"A223", x"9F19", x"9C0B",
        x"98F8", x"95E1", x"92C7", x"8FAB",
        x"8C8B", x"896A", x"8647", x"8324",
        x"8000", x"7CDB", x"79B8", x"7695",
        x"7374", x"7054", x"6D38", x"6A1E",
        x"6707", x"63F4", x"60E6", x"5DDC",
        x"5AD8", x"57D9", x"54E1", x"51EF",
        x"4F04", x"4C21", x"4946", x"4673",
        x"43A9", x"40E9", x"3E32", x"3B85",
        x"38E3", x"364C", x"33C0", x"3140",
        x"2ECC", x"2C65", x"2A0B", x"27BD",
        x"257E", x"234C", x"2129", x"1F14",
        x"1D0E", x"1B18", x"1931", x"175A",
        x"1593", x"13DC", x"1236", x"10A1",
        x"0F1E", x"0DAB", x"0C4A", x"0AFC",
        x"09BF", x"0894", x"077C", x"0676",
        x"0583", x"04A3", x"03D6", x"031D",
        x"0276", x"01E3", x"0163", x"00F7",
        x"009E", x"0059", x"0028", x"000A",
        x"0001", x"000A", x"0028", x"0059",
        x"009E", x"00F7", x"0163", x"01E3",
        x"0276", x"031D", x"03D6", x"04A3",
        x"0583", x"0676", x"077C", x"0894",
        x"09BF", x"0AFC", x"0C4A", x"0DAB",
        x"0F1E", x"10A1", x"1236", x"13DC",
        x"1593", x"175A", x"1931", x"1B18",
        x"1D0E", x"1F14", x"2129", x"234C",
        x"257E", x"27BD", x"2A0B", x"2C65",
        x"2ECC", x"3140", x"33C0", x"364C",
        x"38E3", x"3B85", x"3E32", x"40E9",
        x"43A9", x"4673", x"4946", x"4C21",
        x"4F04", x"51EF", x"54E1", x"57D9",
        x"5AD8", x"5DDC", x"60E6", x"63F4",
        x"6707", x"6A1E", x"6D38", x"7054",
        x"7374", x"7695", x"79B8", x"7CDB",
        x"7FFF", x"8324", x"8647", x"896A",
        x"8C8B", x"8FAB", x"92C7", x"95E1",
        x"98F8", x"9C0B", x"9F19", x"A223",
        x"A527", x"A826", x"AB1E", x"AE10",
        x"B0FB", x"B3DE", x"B6B9", x"B98C",
        x"BC56", x"BF16", x"C1CD", x"C47A",
        x"C71C", x"C9B3", x"CC3F", x"CEBF",
        x"D133", x"D39A", x"D5F4", x"D842",
        x"DA81", x"DCB3", x"DED6", x"E0EB",
        x"E2F1", x"E4E7", x"E6CE", x"E8A5",
        x"EA6C", x"EC23", x"EDC9", x"EF5E",
        x"F0E1", x"F254", x"F3B5", x"F503",
        x"F640", x"F76B", x"F883", x"F989",
        x"FA7C", x"FB5C", x"FC29", x"FCE2",
        x"FD89", x"FE1C", x"FE9C", x"FF08",
        x"FF61", x"FFA6", x"FFD7", x"FFF5");
begin
	process(theta_i)
	begin
		sine_o   <= sinlut(to_integer(unsigned(theta_i)));
		cosine_o <= coslut(to_integer(unsigned(theta_i)));
	end process;
end architecture;