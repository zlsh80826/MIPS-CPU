// decode and operand fetch

module decode_and_operend_fetch #(
  parameter INSTRUCTION_BITS = 32,
  parameter DATA_BITS = 32,
  parameter reg_addr_width = 5,
  parameter immediate_width = 15
) (
  input clk,
  input [INSTRUCTION_BITS - 1 : 0] instruction,
  input [DATA_BITS - 1:0]pc_min_one,
  input [DATA_BITS - 1:0] AData,
  input [DATA_BITS - 1:0] BData,
  output reg [DATA_BITS - 1:0] pc_min_two,
  output reg RW,
  output reg [reg_addr_width - 1 : 0] DA,
  output reg [1:0] MD,
  output reg [1:0] BS,
  output reg PS,
  output reg MW,
  output reg [3:0] FS,
  output reg [reg_addr_width - 1 : 0] SH,
  output reg [DATA_BITS - 1:0] BUSA,
  output reg [DATA_BITS - 1:0] BUSB,
  output [DATA_BITS - 1:0] BUSA_next,
  output [DATA_BITS - 1:0] BUSB_next,
  output MW_next,
  output [reg_addr_width - 1:0] AA,
  output [reg_addr_width - 1:0] BA
);

  wire  MA, MB, CS, RW_next, PS_next, MW_next;
  wire [reg_addr_width - 1 : 0] DA_next;
  wire [immediate_width - 1 : 0] IM;
  wire [DATA_BITS - 1 : 0] extended_IM, BUSA_next, BUSB_next;
  wire [3:0] FS_next;
  wire [1:0] MD_next, BS_next;
  
  assign IM = instruction[14:0];
  assign SH_next = instruction[4:0];

  always@ (posedge clk) begin
    pc_min_two <= pc_min_one;
    RW <= RW_next;
    DA <= DA_next;
    MD <= MD_next;
    BS <= BS_next;
    PS <= PS_next;
    MW <= MW_next;
    FS <= FS_next;
    SH <= SH_next;
    BUSA <= BUSA_next;
    BUSB <= BUSB_next;
  end

  decoder Decoder(
    .instruction(instruction),
    .RW(RW_next),
    .DA(DA_next),
    .MD(MD_next),
    .BS(BS_next),
    .PS(PS_next),
    .MW(MW_next),
    .FS(FS_next),
    .MA(MA),
    .MB(MB),
    .AA(AA),
    .BA(BA),
    .CS(CS)
  ); 

  constant_unit ConstantUnit(
    .CS(CS),
    .IM(IM),
    .extended_IM(extended_IM)
  );

  two_to_one_mux MUXA (
    .out(BUSA_next),
    .select(MA),
    .in0(AData),
    .in1(pc_min_one)
  );

  two_to_one_mux MUXB (
    .out(BUSB_next),
    .select(MB),
    .in0(BData),
    .in1(extended_IM)
  );
    
endmodule
