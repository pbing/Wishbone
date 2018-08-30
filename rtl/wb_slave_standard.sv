/* Classic standard bus cycles */

`default_nettype none

module wb_slave_standard(if_wb.slave wb);
   parameter waitcycles = 0;

   wire                 valid;
   wire                 ram_cen;
   wire                 ram_wen;
   wire  [15:0]         ram_q;

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
   assign wb.stall = 1'b0;

   /* Wishbone control */
   assign valid = wb.cyc & wb.stb;

   generate
      case (waitcycles)
        0:
          begin:w0
             logic ack;

             always_ff @(posedge wb.clk)
               if (wb.rst)
                 ack <= 1'b0;
               else
                 if (!wb.ack)
                   ack <= valid;
                 else
                   ack <= 1'b0;

             assign wb.ack = ack;
          end:w0

        default
          begin:wn
             logic [0:waitcycles] ack;

             always_ff @(posedge wb.clk)
               if (wb.rst)
                 ack <= '0;
               else
                 if (!wb.ack)
                   ack <= {valid, ack[$left(ack):$right(ack) - 1]};
                 else
                   ack <= '0;

             assign wb.ack = ack[$right(ack)];
          end:wn
      endcase
   endgenerate

endmodule

`resetall
