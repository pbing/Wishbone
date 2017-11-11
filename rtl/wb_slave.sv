/* Wishbone Slave */

`default_nettype none

/* RAM with 64 K cells of 16 bits */
module ram64kx16
  #(parameter adr_width = 16,
    parameter dat_width = 16)
   (input  wire                      clk,
    input  wire  [adr_width - 1 : 0] a,
    input  wire  [dat_width - 1 : 0] d,
    output logic [dat_width - 1 : 0] q,
    input  wire                      cen,
    input  wire                      wen);

   logic [dat_width - 1 : 0] mem[2 ** adr_width];

   always_ff @(posedge clk)
     if (cen && wen)
       mem[a] <= d;

   always_ff @(posedge clk)
     if (cen)
       q <= mem[a];
endmodule

/* Classic standard bus cycles */
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

/* Classic pipelined bus cycles */
module wb_slave_pipelined(if_wb.slave wb);
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

   assign ram_cen = valid;
   assign ram_wen = ram_cen & wb.we;

   /* Wishbone control */
   assign valid = wb.cyc & wb.stb;

   always_ff @(posedge wb.clk)
     if (wb.rst)
       wb.ack <= 1'b0;
     else
       wb.ack <= valid & ~wb.stall;

   always_ff @(posedge wb.clk)
     if (wb.rst)
       wb.stall <= 1'b0;
     else
       wb.stall <= 1'b0;
   //       wb.stall <= ({$random} % 3 == 0);
endmodule

/* Wrapper for pipelined master connected with standard slave
 * See Wishbone B4, section 5.2
 */
module wb_slave_standard_wrapper(if_wb.slave wb);

   if_wb wb2(.rst(wb.rst), .clk(wb.clk));

   wb_slave_standard wbs(.wb(wb2));

   assign wb.ack    = wb2.ack;
   assign wb2.adr   = wb.adr ;
   assign wb2.cyc   = wb.cyc ;
   assign wb.stall  = wb.cyc & ~wb2.ack;
   assign wb2.stb   = wb.stb;
   assign wb2.we    = wb.we;
   assign wb2.dat_i = wb.dat_i;
   assign wb.dat_o  = wb2.dat_o;
endmodule

`resetall

/* Wrapper for pipelined master connected with standard slave
 * See Wishbone B4, section 5.1
 */
module wb_slave_pipelined_wrapper(if_wb.slave wb);
   enum {IDLE, WAIT} state, next;

   if_wb wb2(.rst(wb.rst), .clk(wb.clk));

   wb_slave_pipelined wbs(.wb(wb2));

   assign wb.ack    = wb2.ack;
   assign wb2.adr   = wb.adr ;
   assign wb2.cyc   = wb.cyc ;
   assign wb.stall  = wb2.stall;
   assign wb2.stb   = (state == IDLE) ? wb.stb : 1'b0;
   assign wb2.we    = wb.we;
   assign wb2.dat_i = wb.dat_i;
   assign wb.dat_o  = wb2.dat_o;

   /* FSM */
   always_ff @(posedge wb.clk)
     if (wb.rst)
       state <= IDLE;
     else
       state <= next;

   always_comb
     begin
        next = state;

        case (state)
          IDLE: if (wb.stb)  next = WAIT;
          WAIT: if (wb2.ack) next = IDLE;
        endcase
     end
endmodule

`resetall
