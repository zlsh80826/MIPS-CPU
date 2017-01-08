module two_to_one_mux #(
  parameter BITS = 32
) (
  input select,
  input [BITS - 1 : 0] in0,
  input [BITS - 1 : 0] in1,
  output reg [BITS - 1 : 0] out
);

  always@(*) begin
    if ( select == 1'b1 ) begin
      out = in1;
    end else begin
      out = in0;
    end
  end

endmodule
