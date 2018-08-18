/* Wrapper for standard master connected to pipelined slave
 * See Wishbone B4, section 5.1
 *
 * Warning: Does not work with slaves with wait cycles.
 */

`default_nettype none

module wb_slave_pipelined_wrapper(if_wb.slave wb);
   enum {IDLE, WAIT} state, next;

   if_wb wb2(.rst(wb.rst), .clk(wb.clk));

   wb_slave_pipelined #(0) wbs(.wb(wb2));

   assign wb.ack    = wb2.ack;
   assign wb2.adr   = wb.adr ;
   assign wb2.cyc   = wb.cyc ;
   assign wb.stall  = wb2.stall;
   assign wb2.stb   = (state == IDLE) ? wb.stb : 1'b0;
   assign wb2.we    = wb.we;
   assign wb2.dat_m = wb.dat_i;
   assign wb.dat_o  = wb2.dat_s;

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
