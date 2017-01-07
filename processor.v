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
  dm_datain_load,
);

  parameter ADDRESS_WIDTH = 11;
  parameter DATA_WIDTH = 32;

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
  wire dm_cen_internal;
  wire dm_wen_internal;
  wire dm_oen_internal;
  wire [ADDRESS_WIDTH - 1 : 0] dm_addr_internal;
  wire [DATA_WIDTH - 1 : 0 ] dm_datain_internal;

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
  assign dm_cen = (loading == 1'b1) ? dm_cen_load : dm_cen_internal;
  assign dm_wen = (loading == 1'b1) ? dm_wen_load : dm_wen_internal;
  assign dm_oen = (loading == 1'b1) ? dm_oen_load : dm_oen_internal;
  assign dm_addr = (loading == 1'b1) ? dm_addr_load : dm_addr_internal;
  assign dm_datain = (loading == 1'b1) ? dm_datain_load : dm_datain_internal;

  parameter PROGRAM_COUNTER_WIDTH = 32;

  reg [PROGRAM_COUNTER_WIDTH - 1 : 0] pc;
  wire [PROGRAM_COUNTER_WIDTH - 1 : 0] pc_next;
  
  instruction_fetch IFETCH (
    .clk(clk),
    .rst_n(rst_n),
    .pc(pc),
    .pc_next(pc_next),
    .im_cen(im_cen_internal),
    .im_wen(im_wen_internal),
    .im_oen(im_oen_internal),
    .im_addr(im_addr_internal),
    .im_datain(im_datain_internal)
  );

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

endmodule
