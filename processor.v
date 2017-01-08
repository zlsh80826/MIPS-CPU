module processor(
  clk,
  rst_n,
  loading,
  im_cen_load,
  im_wen_load,
  im_oen_load,
  im_addr_load,
  im_datain_load,
  dm_cen_load,
  dm_wen_load,
  dm_oen_load,
  dm_addr_load,
  dm_datain_load
);

  parameter ADDRESS_WIDTH = 11;
  parameter REG_ADDR_WIDTH = 5;
  parameter DATA_WIDTH = 32;
  parameter INSTRUCTION_WIDTH = 32;
  parameter PROGRAM_COUNTER_WIDTH = 32;

  input clk, rst_n, loading, im_cen_load, im_wen_load, im_oen_load, dm_cen_load, dm_wen_load, dm_oen_load;
  input [ADDRESS_WIDTH - 1 : 0] im_addr_load, dm_addr_load;
  input [DATA_WIDTH - 1 : 0] im_datain_load, dm_datain_load;

  // internal manipulate instruction memory signals
  wire im_cen_internal;
  wire im_wen_internal;
  wire im_oen_internal;
  wire [ADDRESS_WIDTH - 1 : 0] im_addr_internal;
  wire [DATA_WIDTH - 1 : 0] im_datain_internal;
  
  // internal manipulate data memory signals
  // wire dm_cen_internal;
  // wire dm_wen_internal;
  // wire dm_oen_internal;
  // wire [ADDRESS_WIDTH - 1 : 0] dm_addr_internal;
  // wire [DATA_WIDTH - 1 : 0] dm_datain_internal;

  // final manipulate instruction memory signals
  wire im_cen;
  wire im_wen;
  wire im_oen;
  wire [ADDRESS_WIDTH - 1 : 0] im_addr;
  wire [DATA_WIDTH - 1 : 0] im_datain;
  wire [DATA_WIDTH - 1 : 0] im_dataout;  

  // final manipulate data memory signals
  wire dm_cen;
  wire dm_wen;
  wire dm_oen;
  wire [ADDRESS_WIDTH - 1 : 0] dm_addr;
  wire [DATA_WIDTH - 1 : 0 ] dm_datain;
  wire [DATA_WIDTH - 1 : 0 ] dm_dataout;

  wire [PROGRAM_COUNTER_WIDTH - 1 : 0] pc, pc_next;
  wire [PROGRAM_COUNTER_WIDTH - 1 : 0] pc_min_one, pc_min_two;

  wire [DATA_WIDTH - 1:0] AData, BData, DData, BUSA, BUSB, BUSD, BrA, fu_result, extended_determinate, DData_WB, forward_data;
  wire [DATA_WIDTH - 1:0] BUSA_next, BUSB_next, instruction;
  wire [REG_ADDR_WIDTH - 1:0] DA, AA, BA, DA_WB;
  wire [3:0] FS;
  wire [1:0] MD, BS, MD_WB;
  wire RW, PS, MW, RW_WB, determinate, MW_next, flush, flush_delay, zero;
  wire [4:0] SH;

  /*always@(posedge clk) begin
    $display("c: %b %b %b %b", im_cen, im_cen_load, im_cen_internal, loading);
    $display("w: %b %b %b %b", im_wen, im_wen_load, im_wen_internal, loading);
    $display("i: %b %b %b %b", im_oen, im_oen_load, im_oen_internal, loading);
  end*/

  // choose the final manipulate instruction memory signals
  assign im_cen = (loading == 1'b1) ? im_cen_load : im_cen_internal;
  assign im_wen = (loading == 1'b1) ? im_wen_load : im_wen_internal;
  assign im_oen = (loading == 1'b1) ? im_oen_load : im_oen_internal;
  assign im_addr = (loading == 1'b1) ? im_addr_load : im_addr_internal;
  assign im_datain = (loading == 1'b1) ? im_datain_load : im_datain_internal;
 
  // choose the final manipulate data memory signals
  assign dm_cen = (loading == 1'b1) ? dm_cen_load : 1'b0;
  assign dm_wen = (loading == 1'b1) ? dm_wen_load : ~MW_next;
  assign dm_oen = (loading == 1'b1) ? dm_oen_load : 1'b0;
  assign dm_addr = (loading == 1'b1) ? dm_addr_load : BUSA_next[10:0];
  assign dm_datain = (loading == 1'b1) ? dm_datain_load : BUSB_next;

  assign instruction = im_dataout & {32{flush_delay}};

  // combinational circuit to determinate pc
  branch Branch (
    .clk(clk),
    .rst_n(rst_n),
    .zero(zero),
    .PS(PS),
    .BS(BS),
    .BrA(BrA),
    .RAA(BUSA),
    .pc_min_one(pc_next),
    .pc(pc),
    .flush(flush),
    .flush_delay(flush_delay)
  );

  // fetch instruction
  // TODO: remove instruction
  instruction_fetch IFETCH (
    .clk(clk),
    .rst_n(rst_n),
    .pc(pc),
    .pc_min_one(pc_min_one),
    .im_cen(im_cen_internal),
    .im_wen(im_wen_internal),
    .im_oen(im_oen_internal),
    .im_addr(im_addr_internal),
    .im_datain(im_datain_internal),
    .pc_next(pc_next)
  );

  decode_and_operend_fetch DOF (
    .clk(clk),
    .instruction(instruction),
    .pc_min_one(pc_min_one),
    .AData(AData),
    .BData(BData),
    .pc_min_two(pc_min_two),
    .RW(RW),
    .DA(DA),
    .MD(MD),
    .BS(BS),
    .PS(PS),
    .MW(MW),
    .FS(FS),
    .SH(SH),
    .BUSA(BUSA),
    .BUSB(BUSB),
    .AA(AA),
    .BA(BA),
    .BUSA_next(BUSA_next),
    .BUSB_next(BUSB_next),
    .MW_next(MW_next),
    .RW_EXE(RW),
    .DA_EXE(DA),
    .forward_data(forward_data),
    .flush(flush)
  );

  execute EXECUTE (
    .clk(clk),
    .RW(RW),
    .DA(DA),
    .MD(MD),
    .BS(BS),
    .PS(PS),
    .MW(MW),
    .FS(FS),
    .SH(SH),
    .BUSA(BUSA),
    .BUSB(BUSB),
    .RW_WB(RW_WB),
    .DA_WB(DA_WB),
    .MD_WB(MD_WB),
    .BrA(BrA),
    .pc_min_two(pc_min_two),
    .result(fu_result),
    .determinate(determinate),
    .DData(dm_dataout),
    .DData_next(DData_WB),
    .forward_data(forward_data),
    .zero(zero)
  );

  // im_dataout will be the instruction to decoder
  RAM2Kx32 InstructionMemory (
   .Q(im_dataout),
   .CLK(clk),
   .CEN(im_cen),
   .WEN(im_wen),
   .A(im_addr),
   .D(im_datain),
   .OEN(im_oen)
  );

  RAM2Kx32 DataMemory (
   .Q(dm_dataout),
   .CLK(clk),
   .CEN(dm_cen),
   .WEN(dm_wen),
   .A(dm_addr),
   .D(dm_datain),
   .OEN(dm_oen)
  );

  // TODO: check the source of DA
  // change BUSD to forwarding data
  register_file RegisterFile (
    .clk(clk),
    .rst_n(rst_n),
    .WriteEnable(RW),
    .DData(forward_data),
    .AData(AData),
    .BData(BData),
    .DAddress(DA),
    .AAddress(AA),
    .BAddress(BA)
  );

  assign extended_determinate = {31'b0, determinate};

  three_to_one_mux MUXD (
    .select(MD_WB),
    .in0(fu_result),
    .in1(DData_WB),
    .in2(extended_determinate),
    .out(BUSD)
  );
endmodule
