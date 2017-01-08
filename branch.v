module branch (
  input clk,
  input rst_n,
  input zero,
  input PS,
  input [1:0] BS,
  input [31:0] BrA,
  input [31:0] RAA,
  input [31:0] pc_min_one,
  output [31:0] pc
);

  wire [1:0] select;
  // wire [31:0] pc_next;

  /*always@ (posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0) begin
      pc <= 32'd0;
    end else begin
      pc <= pc;
    end
  end*/

  assign select[1] = BS[1];
  assign select[0] = ((PS ^ zero) | BS[1]) & BS[0];

  four_to_one_mux MUXC (
    .select(select),
    .rst_n(rst_n),
    .in0(pc_min_one),
    .in1(BrA),
    .in2(RAA),
    .in3(BrA),
    .out(pc)
  );

endmodule
