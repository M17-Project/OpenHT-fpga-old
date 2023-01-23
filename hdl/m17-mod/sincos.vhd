-------------------------------------------------------------
-- Unsigned 16-bit, 256-entry sine/cosine look up tables
--
-- Wojciech Kaczmarski, SP5WWP
-- M17 Project
-- January 2023
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
        x"3F00", x"408B", x"4217", x"43A2",
        x"452C", x"46B6", x"483E", x"49C5",
        x"4B4A", x"4CCD", x"4E4E", x"4FCD",
        x"5149", x"52C3", x"5439", x"55AC",
        x"571B", x"5887", x"59EF", x"5B53",
        x"5CB2", x"5E0D", x"5F63", x"60B4",
        x"6200", x"6346", x"6487", x"65C2",
        x"66F7", x"6826", x"694E", x"6A70",
        x"6B8C", x"6CA0", x"6DAE", x"6EB4",
        x"6FB3", x"70AA", x"719A", x"7282",
        x"7361", x"7439", x"7509", x"75D0",
        x"768F", x"7745", x"77F3", x"7898",
        x"7934", x"79C7", x"7A51", x"7AD1",
        x"7B49", x"7BB7", x"7C1C", x"7C78",
        x"7CCA", x"7D12", x"7D51", x"7D86",
        x"7DB2", x"7DD4", x"7DEC", x"7DFB",
        x"7E00", x"7DFB", x"7DEC", x"7DD4",
        x"7DB2", x"7D86", x"7D51", x"7D12",
        x"7CCA", x"7C78", x"7C1C", x"7BB7",
        x"7B49", x"7AD1", x"7A51", x"79C7",
        x"7934", x"7898", x"77F3", x"7745",
        x"768F", x"75D0", x"7509", x"7439",
        x"7361", x"7282", x"719A", x"70AA",
        x"6FB3", x"6EB4", x"6DAE", x"6CA0",
        x"6B8C", x"6A70", x"694E", x"6826",
        x"66F7", x"65C2", x"6487", x"6346",
        x"6200", x"60B4", x"5F63", x"5E0D",
        x"5CB2", x"5B53", x"59EF", x"5887",
        x"571B", x"55AC", x"5439", x"52C3",
        x"5149", x"4FCD", x"4E4E", x"4CCD",
        x"4B4A", x"49C5", x"483E", x"46B6",
        x"452C", x"43A2", x"4217", x"408B",
        x"3F00", x"3D74", x"3BE8", x"3A5D",
        x"38D3", x"3749", x"35C1", x"343A",
        x"32B5", x"3132", x"2FB1", x"2E32",
        x"2CB6", x"2B3C", x"29C6", x"2853",
        x"26E4", x"2578", x"2410", x"22AC",
        x"214D", x"1FF2", x"1E9C", x"1D4B",
        x"1BFF", x"1AB9", x"1978", x"183D",
        x"1708", x"15D9", x"14B1", x"138F",
        x"1273", x"115F", x"1051", x"0F4B",
        x"0E4C", x"0D55", x"0C65", x"0B7D",
        x"0A9E", x"09C6", x"08F6", x"082F",
        x"0770", x"06BA", x"060C", x"0567",
        x"04CB", x"0438", x"03AE", x"032E",
        x"02B6", x"0248", x"01E3", x"0187",
        x"0135", x"00ED", x"00AE", x"0079",
        x"004D", x"002B", x"0013", x"0004",
        x"0000", x"0004", x"0013", x"002B",
        x"004D", x"0079", x"00AE", x"00ED",
        x"0135", x"0187", x"01E3", x"0248",
        x"02B6", x"032E", x"03AE", x"0438",
        x"04CB", x"0567", x"060C", x"06BA",
        x"0770", x"082F", x"08F6", x"09C6",
        x"0A9E", x"0B7D", x"0C65", x"0D55",
        x"0E4C", x"0F4B", x"1051", x"115F",
        x"1273", x"138F", x"14B1", x"15D9",
        x"1708", x"183D", x"1978", x"1AB9",
        x"1BFF", x"1D4B", x"1E9C", x"1FF2",
        x"214D", x"22AC", x"2410", x"2578",
        x"26E4", x"2853", x"29C6", x"2B3C",
        x"2CB6", x"2E32", x"2FB1", x"3132",
        x"32B5", x"343A", x"35C1", x"3749",
        x"38D3", x"3A5D", x"3BE8", x"3D74"
	);

	constant coslut : lut_arr := (
        x"7E00", x"7DFB", x"7DEC", x"7DD4",
        x"7DB2", x"7D86", x"7D51", x"7D12",
        x"7CCA", x"7C78", x"7C1C", x"7BB7",
        x"7B49", x"7AD1", x"7A51", x"79C7",
        x"7934", x"7898", x"77F3", x"7745",
        x"768F", x"75D0", x"7509", x"7439",
        x"7361", x"7282", x"719A", x"70AA",
        x"6FB3", x"6EB4", x"6DAE", x"6CA0",
        x"6B8C", x"6A70", x"694E", x"6826",
        x"66F7", x"65C2", x"6487", x"6346",
        x"6200", x"60B4", x"5F63", x"5E0D",
        x"5CB2", x"5B53", x"59EF", x"5887",
        x"571B", x"55AC", x"5439", x"52C3",
        x"5149", x"4FCD", x"4E4E", x"4CCD",
        x"4B4A", x"49C5", x"483E", x"46B6",
        x"452C", x"43A2", x"4217", x"408B",
        x"3F00", x"3D74", x"3BE8", x"3A5D",
        x"38D3", x"3749", x"35C1", x"343A",
        x"32B5", x"3132", x"2FB1", x"2E32",
        x"2CB6", x"2B3C", x"29C6", x"2853",
        x"26E4", x"2578", x"2410", x"22AC",
        x"214D", x"1FF2", x"1E9C", x"1D4B",
        x"1BFF", x"1AB9", x"1978", x"183D",
        x"1708", x"15D9", x"14B1", x"138F",
        x"1273", x"115F", x"1051", x"0F4B",
        x"0E4C", x"0D55", x"0C65", x"0B7D",
        x"0A9E", x"09C6", x"08F6", x"082F",
        x"0770", x"06BA", x"060C", x"0567",
        x"04CB", x"0438", x"03AE", x"032E",
        x"02B6", x"0248", x"01E3", x"0187",
        x"0135", x"00ED", x"00AE", x"0079",
        x"004D", x"002B", x"0013", x"0004",
        x"0000", x"0004", x"0013", x"002B",
        x"004D", x"0079", x"00AE", x"00ED",
        x"0135", x"0187", x"01E3", x"0248",
        x"02B6", x"032E", x"03AE", x"0438",
        x"04CB", x"0567", x"060C", x"06BA",
        x"0770", x"082F", x"08F6", x"09C6",
        x"0A9E", x"0B7D", x"0C65", x"0D55",
        x"0E4C", x"0F4B", x"1051", x"115F",
        x"1273", x"138F", x"14B1", x"15D9",
        x"1708", x"183D", x"1978", x"1AB9",
        x"1BFF", x"1D4B", x"1E9C", x"1FF2",
        x"214D", x"22AC", x"2410", x"2578",
        x"26E4", x"2853", x"29C6", x"2B3C",
        x"2CB6", x"2E32", x"2FB1", x"3132",
        x"32B5", x"343A", x"35C1", x"3749",
        x"38D3", x"3A5D", x"3BE8", x"3D74",
        x"3EFF", x"408B", x"4217", x"43A2",
        x"452C", x"46B6", x"483E", x"49C5",
        x"4B4A", x"4CCD", x"4E4E", x"4FCD",
        x"5149", x"52C3", x"5439", x"55AC",
        x"571B", x"5887", x"59EF", x"5B53",
        x"5CB2", x"5E0D", x"5F63", x"60B4",
        x"6200", x"6346", x"6487", x"65C2",
        x"66F7", x"6826", x"694E", x"6A70",
        x"6B8C", x"6CA0", x"6DAE", x"6EB4",
        x"6FB3", x"70AA", x"719A", x"7282",
        x"7361", x"7439", x"7509", x"75D0",
        x"768F", x"7745", x"77F3", x"7898",
        x"7934", x"79C7", x"7A51", x"7AD1",
        x"7B49", x"7BB7", x"7C1C", x"7C78",
        x"7CCA", x"7D12", x"7D51", x"7D86",
        x"7DB2", x"7DD4", x"7DEC", x"7DFB"
	);
begin
	process(theta_i)
	begin
		sine_o   <= sinlut(to_integer(unsigned(theta_i)));
		cosine_o <= coslut(to_integer(unsigned(theta_i)));
	end process;
end architecture;