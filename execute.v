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
  input [DATA_BITS - 1 : 0] DData, 
  output reg RW_WB,
  output reg [reg_addr_width - 1:0] DA_WB,
  output reg [1:0] MD_WB,
  output wire [DATA_BITS - 1:0] BrA,
  output reg [DATA_BITS - 1:0] result,
  output reg determinate,
  output reg [DATA_BITS - 1 : 0] DData_next,
  output [DATA_BITS - 1 : 0] forward_data,
  output zero
);

  wire determinate_next, overflow, carryout, zero, negative;
  wire [DATA_BITS - 1 : 0] result_next;
  wire [DATA_BITS - 1 : 0] extended_determinate_next;

  assign determinate_next = negative ^ overflow;
  assign extended_determinate_next = {31'b0, determinate_next};

  always@ (posedge clk) begin
    RW_WB <= RW;
    DA_WB <= DA;
    MD_WB <= MD;
    result <= result_next;
    determinate <= determinate_next;
    DData_next <= DData;
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

  three_to_one_mux MUXDFORWARD (
    .select(MD),
    .in0(result_next),
    .in1(DData),
    .in2(extended_determinate_next),
    .out(forward_data)
  );

endmodule
