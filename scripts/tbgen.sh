#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "Not enough parameters."
	exit
fi

mkdir $1
cd $1

#makefile
cat > makefile << EOF
GHDL=ghdl
FLAGS="--std=08"

all:
	@\$(GHDL) -a \$(FLAGS) $1_test.vhd $1.vhd
	@\$(GHDL) -e \$(FLAGS) $1_test
	@\$(GHDL) -r \$(FLAGS) $1_test --wave=$1_test.ghw --stop-time=100ms
EOF

#main VHD
cat > $1.vhd << EOF
--$1
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity $1 is
	port(
		--
	);
end $1;

architecture magic of $1 is
	--
begin
	process
	begin
		--
	end process;
end magic;
EOF

#testbench VHD
cat > $1_test.vhd << EOF
--$1 test
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity $1_test is
	--
end $1_test;

architecture sim of $1_test is
	component $1 is
		port(
			--
		);
	end component;

	--
begin
	dut: $1 port map(--);

	process
	begin
		--
	end process;

	process
	begin
		clk_i <= not clk_i;
		wait for 0.1 ms;
	end process;
end sim;
EOF
