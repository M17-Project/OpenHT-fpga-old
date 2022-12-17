#!/bin/python3

from vunit import VUnit

# Create VUnit instance by parsing command line arguments
vu = VUnit.from_argv()

# Create library 'work'
work_lib = vu.add_library("lib")
work_lib.add_source_files("../../hdl/openht_fpga_types.vhd")
work_lib.add_source_files("../../hdl/at86rf215_tx.vhd")
work_lib.add_source_files("*.vhd")

# Run vunit function
vu.main()

