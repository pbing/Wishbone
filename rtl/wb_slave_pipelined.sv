/* Classic pipelined bus cycles */

`default_nettype none

module wb_slave_pipelined(if_wb.slave wb);
   parameter waitcycles = 0;

   wire                 valid;
   wire                 ram_cen;
   wire                 ram_wen;
   wire  [15:0]         ram_q;
   logic [1:waitcycles] stall;   // optimized away when no waitcycles

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
       wb.ack <= 1'b0;
     else
       wb.ack <= valid & ~wb.stall;

   always_ff @(posedge wb.clk)
     if (wb.rst)
       stall <= '1;
     else
       if (stall == '0)
         stall <= '1;
       else
         if (valid)
           if (waitcycles < 2)
             stall <= '0;
           else
             stall <= {1'b0, stall[$left(stall):$right(stall) - 1]};

   always_comb
     if (waitcycles == 0)
       wb.stall = 1'b0;
     else
       wb.stall = valid & stall[$right(stall)];
endmodule

`resetall
