#!/bin/python3

from vunit import VUnit

# Create VUnit instance by parsing command line arguments
vu = VUnit.from_argv()

# Create library 'work'
work_lib = vu.add_library("lib")
work_lib.add_source_files("../../hdl/include/axi_types.vhd")
work_lib.add_source_files("../../hdl/include/i2s_types.vhd")
work_lib.add_source_files("../../hdl/include/openht_fpga_types.vhd")
work_lib.add_source_files("../../hdl/src/at86rf215_tx.vhd")
work_lib.add_source_files("tb_*.vhd")

# Run vunit function
vu.main()

