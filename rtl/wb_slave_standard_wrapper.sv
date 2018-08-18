/* Wrapper for pipelined master connected to standard slave
 * See Wishbone B4, section 5.2
 */

`default_nettype none

module wb_slave_standard_wrapper(if_wb.slave wb);
   parameter waitcycles = 0;

   if_wb wb2(.rst(wb.rst), .clk(wb.clk));

   wb_slave_standard #(waitcycles) wbs(.wb(wb2));

   assign wb.ack    = wb2.ack;
   assign wb2.adr   = wb.adr ;
   assign wb2.cyc   = wb.cyc ;
   assign wb.stall  = wb.cyc & wb.stb & ~wb2.ack; // error in Wishbone B4, section 5.2?
   assign wb2.stb   = wb.stb;
   assign wb2.we    = wb.we;
   assign wb2.dat_m = wb.dat_i;
   assign wb.dat_o  = wb2.dat_s;
endmodule

`resetall
