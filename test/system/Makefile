# Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

HDL_DIR = $(PWD)/../hdl

VHDL_SOURCES += \
	$(HDL_DIR)/i2s_source.vhd \
	$(HDL_DIR)/openht_fpga_types.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = i2s_source

# MODULE is the basename of the Python test file
MODULE = test_i2s_source

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
