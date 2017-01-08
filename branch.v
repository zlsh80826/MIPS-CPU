module branch (
  input clk,
  input rst_n,
  input zero,
  input PS,
  input [1:0] BS,
  input [31:0] BrA,
  input [31:0] RAA,
  input [31:0] pc_min_one,
  output reg [31:0] pc,
  output flush,
  output reg flush_delay
);

  wire [1:0] select;
  wire [31:0] pc_next;

  reg flush;

  assign select[1] = BS[1];
  assign select[0] = ((PS ^ zero) | BS[1]) & BS[0];
  // assign flush = ~(select[0] | select[1]);

  always@ (posedge clk) begin
    pc <= pc_next;
    flush_delay <= flush;
  end

  four_to_one_mux MUXC (
    .select(select),
    .rst_n(rst_n),
    .in0(pc_min_one),
    .in1(BrA),
    .in2(RAA),
    .in3(BrA),
    .out(pc_next)
  );

  always@ (*) begin
    if ( rst_n == 1'b0 ) begin 
      flush <= 1'b1;
    end else begin
      flush <= ~(select[0] | select[1]);
    end
  end

endmodule
