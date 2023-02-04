// SVA constraints for standard mode and registered feedback

module fv_wb_slave_standard(if_wb.monitor wb);
   // in standard mode stall is always assigned to 0
   property p_stall;
      @(posedge wb.clk)
        !wb.stall;
   endproperty
   a_stall: assume property(p_stall);

   // rule 3.35
   property p_cyc_stb_ack;
      @(posedge wb.clk) disable iff (wb.rst)
        $rose(wb.cyc && wb.stb) |-> ##[1:$] wb.ack ##1 !wb.ack;
   endproperty
   a_cyc_stb_ack: assert property(p_cyc_stb_ack);
   c_cyc_stb_ack: cover property(p_cyc_stb_ack);

   // rule 3.60
   property p_stb_qualify_adr;
      @(posedge wb.clk) disable iff (wb.rst)
        wb.stb |-> $stable(wb.adr);
   endproperty
   a_stb_qualify_adr: assume property(p_stb_qualify_adr);

   // rule 3.60
   property p_stb_qualify_dat;
      @(posedge wb.clk) disable iff (wb.rst)
        wb.stb && wb.we |-> $stable(wb.dat_m);
   endproperty
   a_stb_qualify_dat: assume property(p_stb_qualify_dat);

   // rule 3.60
   property p_stb_qualify_we;
      @(posedge wb.clk) disable iff (wb.rst)
        wb.stb |-> $stable(wb.we);
   endproperty
   a_stb_qualify_we: assume property(p_stb_qualify_we);

   property p_stb_cyc;
      @(posedge wb.clk) disable iff (wb.rst)
        wb.stb |-> wb.cyc;
   endproperty
   a_stb_cyc: assume property(p_stb_cyc);

   property p_stb_ack_stb;
      @(posedge wb.clk) disable iff (wb.rst)
        wb.stb && !wb.ack |=> wb.stb;
   endproperty
   a_stb_ack_stb: assume property(p_stb_ack_stb);

   property p_ack_stb;
      @(posedge wb.clk) disable iff (wb.rst)
        wb.ack |=> !wb.stb;
   endproperty
   a_ack_stb: assume property(p_ack_stb);
endmodule
