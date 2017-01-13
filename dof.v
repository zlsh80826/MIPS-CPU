// decode and operand fetch

module decode_and_operend_fetch #(
  parameter INSTRUCTION_BITS = 32,
  parameter DATA_BITS = 32,
  parameter reg_addr_width = 5,
  parameter immediate_width = 15
) (
  input clk,
  input [INSTRUCTION_BITS - 1 : 0] instruction,
  input [DATA_BITS - 1 : 0] pc_min_one,
  input [DATA_BITS - 1 : 0] AData,
  input [DATA_BITS - 1 : 0] BData,
  input RW_EXE,
  input [DATA_BITS - 1 : 0] forward_data, 
  input [reg_addr_width -1 : 0] DA_EXE,
  input flush,
  input rst_n,
  output reg [DATA_BITS - 1 : 0] pc_min_two,
  output reg RW,
  output reg [reg_addr_width - 1 : 0] DA,
  output reg [1:0] MD,
  output reg [1:0] BS,
  output reg PS,
  output reg MW,
  output reg [3:0] FS,
  output reg [reg_addr_width - 1 : 0] SH,
  output reg [DATA_BITS - 1 : 0] BUSA,
  output reg [DATA_BITS - 1 : 0] BUSB,
  output wire [DATA_BITS - 1 : 0] BUSA_next,
  output wire [DATA_BITS - 1 : 0] BUSB_next,
  output MW_next,
  output [reg_addr_width - 1 : 0] AA,
  output [reg_addr_width - 1 : 0] BA
);

  wire  MA, MB, CS, RW_next, PS_next, MW_nexti, comp_result_DA, comp_result_DB, HB, HA;
  wire [reg_addr_width - 1 : 0] DA_next;
  wire [immediate_width - 1 : 0] IM;
  wire [DATA_BITS - 1 : 0] extended_IM;
  wire [3:0] FS_next;
  wire [1:0] MD_next, BS_next, MUXA_select, MUXB_select;
  wire [1:0] BS_next_flush;
  wire RW_next_flush, MW_next_flush, or_DA_EXE;
  wire [4:0] SH_next; 
 
  assign IM = instruction[14:0];
  assign SH_next = instruction[4:0];
  assign or_DA_EXE = DA_EXE[0] | DA_EXE[1] | DA_EXE[2] | DA_EXE[3] | DA_EXE[4];
  assign HB = (comp_result_DB) & (~MB) & (RW_EXE) & (or_DA_EXE);
  assign HA = (comp_result_DA) & (~MA) & (RW_EXE) & (or_DA_EXE);
  assign MUXA_select[1] = HA;
  assign MUXA_select[0] = MA;
  assign MUXB_select[1] = HB;
  assign MUXB_select[0] = MB;

  assign RW_next_flush = flush & RW_next;
  assign BS_next_flush = {flush, flush} & BS_next;
  assign MW_next_flush = flush & MW_next;

  always@ (posedge clk) begin
    /*if ( rst_n == 1'b0 ) begin
      pc_min_two <= 32'b0;
      RW <= 1'b0;
      DA <= 5'b0;
      MD <= 1'b0;
      BS <= 2'b0;
      PS <= 1'b0;
      MW <= 1'b0;
      FS <= 4'b0;
      SH <= 5'b0;
      BUSA <= 32'b0;
      BUSB <= 32'b0;
    end else begin*/
      pc_min_two <= pc_min_one;
      RW <= RW_next_flush;
      DA <= DA_next;
      MD <= MD_next;
      BS <= BS_next_flush;
      PS <= PS_next;
      MW <= MW_next_flush;
      FS <= FS_next;
      SH <= SH_next;
      BUSA <= BUSA_next;
      BUSB <= BUSB_next;
    // end
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

  three_to_one_mux MUXA (
    .out(BUSA_next),
    .select(MUXA_select),
    .in0(AData),
    .in1(pc_min_one),
    .in2(forward_data)
  );

  three_to_one_mux MUXB (
    .out(BUSB_next),
    .select(MUXB_select),
    .in0(BData),
    .in1(extended_IM),
    .in2(forward_data)
  );

  comp CompDA (
    .in0(DA_EXE),
    .in1(AA),
    .comp_result(comp_result_DA)
  );

  comp CompDB (
    .in0(DA_EXE),
    .in1(BA),
    .comp_result(comp_result_DB)
  );    
endmodule
