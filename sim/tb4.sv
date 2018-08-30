/* Testbench
 * standard master connected to pipelined slave
 */

module tb4;
   timeunit 1ns;
   timeprecision 1ps;

   parameter adr_width  = 16;
   parameter dat_width  = 16;

   const realtime tclk = 1s / 100.0e6;

   bit rst = 1'b1;
   bit clk;

`include "tasks.svh"

   if_wb wb(.*);

   wb_slave_pipelined_wrapper dut(.*);

`ifdef ASSERT_ON
            wb_checker wb_checker(wb);
   bind dut wb_checker wb2_checker(wb2);
`endif

   always #(0.5 * tclk) clk = ~clk;

   always @(posedge clk)
     begin:monitor
        logic [15:0] dat_o, dat_i;

        dat_o <= wb.dat_m;
        dat_i <= wb.dat_s;

        if (wb.cyc && wb.ack && wb.we)
          $strobe("%t DAT_O = %d", $realtime, dat_o);

        if (wb.cyc && wb.ack && !wb.we)
          $strobe("%t DAT_I = %d", $realtime, dat_i);
     end:monitor

   initial
     begin:main
        $timeformat(-9, 3, " ns");

        wb.adr   = '0;
        wb.dat_m = $random;
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
