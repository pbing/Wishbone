/* Classic standard bus cycles */

`default_nettype none

module wb_slave_standard(if_wb.slave wb);
   wire valid;
   wire ram_cen;
   wire ram_wen;

   /* Single port RAM */
   ram64kx16 ram(.clk (wb.clk),
                 .a   (wb.adr),
                 .d   (wb.dat_i),
                 .q   (wb.dat_o),
                 .cen (ram_cen),
                 .wen (ram_wen));

   assign ram_cen = valid & ~wb.ack;
   assign ram_wen = ram_cen & wb.we;

   /* Wishbone control */
   assign valid   = wb.cyc & wb.stb;

   always_ff @(posedge wb.clk)
     if (wb.rst)
       wb.ack <= 1'b0;
     else
       wb.ack <= valid & ~wb.ack;
   //       wb.ack <= valid && !wb.ack && ({$random} % 3 != 0);

   assign wb.stall = 1'b0;
endmodule

`resetall
