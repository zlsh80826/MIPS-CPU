module three_to_one_mux #(
  parameter DATA_WIDTH = 32
) (
  input [1:0] select,
  input [DATA_WIDTH - 1 : 0] in0,
  input [DATA_WIDTH - 1 : 0] in1,
  input [DATA_WIDTH - 1 : 0] in2,
  output reg out
);

  always@(*) begin
    if ( select == 2'b10 ) begin
      out = in2;
    end else if ( select == 2'b01 ) begin
      out = in1;
    end else begin
      out = in0;
    end
  end

endmodule
