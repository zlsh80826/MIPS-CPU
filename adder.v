module adder #(
  parameter DATA_WIDTH = 32
) (
  input [DATA_WIDTH - 1:0] in0,
  input [DATA_WIDTH - 1:0] in1,
  output [DATA_WIDTH - 1:0] out
);

  assign out = in0 + in1;

endmodule
  
