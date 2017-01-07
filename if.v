module instruction_fetch (
  input clk,
  input rst_n,
  input [31:0] pc,
  output reg [31:0]pc_next,
  output reg im_cen,
  output reg im_wen,
  output reg im_oen,
  output reg [10:0] im_addr,
  output reg [31:0] im_datain );

  localparam UNDEFINE = 32'b0;

  always@ (posedge clk, negedge rst_n) begin
    if (rst_n == 0) begin
      pc_next <= 32'b0;
      im_cen  <= 1'b1;
      im_wen  <= 1'b1;
      im_oen  <= 1'b1;
      im_addr <= 11'b0;
      im_datain <= UNDEFINE;
    end else begin
      pc_next <= pc + 32'b1;
      im_cen  <= 1'b0;
      im_wen  <= 1'b1;
      im_oen  <= 1'b0;
      im_addr <= pc;
      im_datain <= UNDEFINE;
    end
  end
endmodule
