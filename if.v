module instruction_fetch (
  input clk,
  input rst_n,
  input [31:0] pc,
  input [31:0] im_dataout,
  output reg [31:0] pc_min_one,
  output reg im_cen,
  output reg im_wen,
  output reg im_oen,
  output reg [10:0] im_addr,
  output reg [31:0] im_datain,
  output reg [31:0] instruction, 
  output reg [31:0] pc_next );

  localparam UNDEFINE = 32'b0;


  always@ (posedge clk, negedge rst_n) begin
    pc_min_one <= pc_next;
    instruction <= im_dataout;
  end

  always@ (*) begin
    im_cen = 1'b0;
    im_wen = 1'b1;
    im_oen = 1'b0;
    im_addr = pc[10:0];
    im_datain = UNDEFINE;
    pc_next = pc + 32'd1;
  end

endmodule
