/* Classic standard bus cycles */

`default_nettype none

module wb_slave_standard(if_wb.slave wb);
   parameter waitcycles = 0;

   wire                 valid;
   logic                ram_cen;
   wire                 ram_wen;
   logic [0:waitcycles] ack;

   /* Single port RAM */
   ram64kx16 ram(.clk (wb.clk),
                 .a   (wb.adr),
                 .d   (wb.dat_i),
                 .q   (wb.dat_o),
                 .cen (ram_cen),
                 .wen (ram_wen));

   always_comb
     if (waitcycles == 0)
       ram_cen = valid & ~wb.ack;
     else
       ram_cen = valid & ack[$right(ack) - 1] & ~ack[$right(ack)];

   assign ram_wen = ram_cen & wb.we;

   /* Wishbone control */
   assign valid = wb.cyc & wb.stb;

   always_ff @(posedge wb.clk)
     if (wb.rst)
       ack <= '0;
     else
       if (!wb.ack)
         if (waitcycles == 0)
           ack <= valid;
         else
           ack <= {valid, ack[$left(ack):$right(ack) - 1]};
       else
         ack <= '0;

   assign wb.ack = ack[$right(ack)];
endmodule

`resetall
