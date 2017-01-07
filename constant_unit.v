module constant_unit(
  input clk,
  input cs,
  input [14:0] IM,
  output reg [31:0] extended_IM
);

  parameter NOMATTER = 32'b0000_0000_0000_0000_0000_0000_0000_0000;

  always@(*) begin
    if ( cs == 1'b0 ) begin
      extended_IM = NOMATTER;
    end else begin
      extended_IM = {17{IM[14]}, IM};
    end
  end

endmodule
