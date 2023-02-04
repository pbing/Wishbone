/* Testbench */

module tb;
   logic rst;
   logic clk;

   if_wb wb(.*);

   wb_slave_standard dut(.*);

   fv_wb_slave_standard fv(.*); 
endmodule
