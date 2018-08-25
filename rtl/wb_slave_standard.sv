/* Classic standard bus cycles */

`default_nettype none

module wb_slave_standard(if_wb.slave wb);
   parameter waitcycles = 0;

   wire                 valid;
   wire                 ram_cen;
   wire                 ram_wen;
   wire  [15:0]         ram_q;
   logic [0:waitcycles] ack;

   /* Single port RAM */
   ram64kx16 ram(.clk (wb.clk),
                 .a   (wb.adr),
                 .d   (wb.dat_i),
                 .q   (ram_q),
                 .cen (ram_cen),
                 .wen (ram_wen));

   assign ram_cen  = valid;
   assign ram_wen  = ram_cen & wb.we;
   assign wb.dat_o = wb.cyc && wb.ack && !wb.we ? ram_q :'x; // pessimistic simulation

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
