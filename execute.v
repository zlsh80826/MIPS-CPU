module execute #(
  parameter DATA_BITS = 32,
  parameter reg_addr_width = 5,
  parameter PROGRAM_COUNTER_WIDTH = 32
) (
  input clk, 
  input RW,
  input [reg_addr_width - 1:0] DA,
  input [1:0] MD,
  input [1:0] BS,
  input PS,
  input MW,
  input [3:0] FS,
  input [reg_addr_width - 1:0] SH,
  input [DATA_BITS - 1:0] BUSA,
  input [DATA_BITS - 1:0] BUSB,
  input [PROGRAM_COUNTER_WIDTH - 1:0] pc_min_two,
  output reg RW_WB,
  output reg [reg_addr_width - 1:0] DA_WB,
  output reg [1:0] MD_WB,
  output wire [DATA_BITS - 1:0] BrA,
  output reg [DATA_BITS - 1:0] result,
  output reg determinate
);

  wire determinate_next, overflow, carryout, zero, negative;
  wire [DATA_BITS - 1 : 0] result_next;

  assign determinate_next = negative ^ overflow;

  always@ (posedge clk) begin
    RW_WB <= RW;
    DA_WB <= DA;
    MD_WB <= MD;
    result <= result_next;
    determinate <= determinate_next;
  end

  function_unit FunctionUnit (
    .A(BUSA),
    .B(BUSB),
    .Result(result_next),
    .FunctionSelect(FS),
    .SH(SH),
    .Overflow(overflow),
    .CarryOut(carryout),
    .Negative(negative),
    .Zero(zero)
  );

  adder Adder (
    .in0(pc_min_two),
    .in1(BUSB),
    .out(BrA)
  ); 

endmodule
