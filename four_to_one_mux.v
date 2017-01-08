module four_to_one_mux #(
  parameter BITS = 32
) (
  input [1:0] select,
  input rst_n,
  input [BITS - 1 : 0] in0,
  input [BITS - 1 : 0] in1,
  input [BITS - 1 : 0] in2,
  input [BITS - 1 : 0] in3,
  output reg [BITS - 1 : 0] out
);

  always@ (rst_n) begin
    if (rst_n == 1'b0) begin
      out = 32'b0;
    end
  end

  always@ (*) begin
    if ( select == 2'b11 ) begin
      out = in3;
    end else if ( select == 2'b10) begin
      out = in2;
    end else if ( select == 2'b01) begin
      out = in1;
    end else begin
      out = in0;
    end
  end

endmodule
