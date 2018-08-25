/* Tasks */

task write_single_standard
  (input [adr_width - 1 : 0] a,
   input [dat_width - 1 : 0] d);

   wb.we    <= 1'b1;
   wb.adr   <= a;
   wb.dat_m <= d;
   wb.cyc   <= 1'b1;
   wb.stb   <= 1'b1;

   do @(posedge clk); while(!wb.ack);

   wb.stb   <= 1'b0;
   wb.cyc   <= 1'b0;
endtask

task write_single_pipelined1
  (input [adr_width - 1 : 0] a,
   input [dat_width - 1 : 0] d);

   wb.we    <= 1'b1;
   wb.adr   <= a;
   wb.dat_m <= d;
   wb.cyc   <= 1'b1;
   wb.stb   <= 1'b1;

   do @(posedge clk); while(wb.stall);
endtask

task write_single_pipelined
  (input [adr_width - 1 : 0] a,
   input [dat_width - 1 : 0] d);

   write_single_pipelined1(a, d);

   wb.stb <= 1'b0;
   @(posedge clk);
   wb.cyc <= 1'b0;
endtask

task read_single_standard
  (input [dat_width - 1 : 0] a);

   wb.we  <= 1'b0;
   wb.adr <= a;
   wb.cyc <= 1'b1;
   wb.stb <= 1'b1;

   do @(posedge clk); while(!wb.ack);

   wb.stb <= 1'b0;
   wb.cyc <= 1'b0;
endtask

task read_single_pipelined1
  (input [dat_width - 1 : 0] a);

   wb.we  <= 1'b0;
   wb.adr <= a;
   wb.cyc <= 1'b1;
   wb.stb <= 1'b1;

   do @(posedge clk); while(wb.stall);
endtask

task read_single_pipelined
  (input [dat_width - 1 : 0] a);

   read_single_pipelined1(a);
   
   wb.stb <= 1'b0;
   @(posedge clk);
   wb.cyc <= 1'b0;
endtask
