clear -all

# read design
analyze -sv ../../rtl/if_wb.sv
analyze -sv ../../rtl/ram64kx16.sv
analyze -sv ../../rtl/wb_slave_standard.sv
analyze -sv tb.sv

# read constraints
analyze -sv fv_wb_slave_standard.sv

#elaborate -top tb -param dut.ram.mem_size 8 -param dut.waitcycles 0
#elaborate -top tb -param dut.ram.mem_size 8 -param dut.waitcycles 1
elaborate -top tb -param dut.ram.mem_size 8 -param dut.waitcycles 3

clock clk
reset -expression rst

check_assumptions
prove -all
