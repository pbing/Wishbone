/* RAM with 64 K cells of 16 bits */

`default_nettype none

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

`resetall
