/* Testbench
 * standard master connected to standard slave
 */

module tb1;
   timeunit 1ns;
   timeprecision 1ps;

   parameter adr_width = 16;
   parameter dat_width = 16;

   const realtime tclk  = 1s / 100.0e6;

   bit                      rst = 1'b1;
   bit                      clk;

   `include "tasks.svh"

   if_wb wb(.*);

   wb_slave_standard dut(.*);

   always #(0.5 * tclk) clk = ~clk;

   initial
     begin:main
        $timeformat(-9, 3, " ns");

        wb.adr   = '0;
        wb.dat_m = 'z;
        wb.we    = 1'b0;
        wb.cyc   = 1'b0;
        wb.stb   = 1'b0;

        repeat (3) @(posedge clk);
        rst = 1'b0;
        repeat (3) @(posedge clk);

        for (int i = 1; i <= 10; i++)
          begin
             write_single_standard(i, 100 + i);
             @(posedge clk);
          end

        repeat(10) @(posedge clk);

        for (int i = 1; i <= 10; i++)
          begin
             read_single_standard(i);
             @(posedge clk);
          end

        repeat(10) @(posedge clk);

        for (int i = 11; i <= 20; i++)
          write_single_standard(i, 200 + i);

        repeat(10) @(posedge clk);

        for (int i = 11; i <= 20; i++)
          read_single_standard(i);

        #100ns $finish;
     end:main
endmodule
