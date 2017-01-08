module register_file #(
  parameter DATA_BITS = 32,
  parameter ADDR_BITS = 5,
  parameter DEPTH = 1 << ADDR_BITS
) ( 
  input clk,
  input rst_n,
  input WriteEnable,
  input [DATA_BITS - 1 : 0] DData,
  output reg [DATA_BITS - 1 : 0] AData,
  output reg [DATA_BITS - 1 : 0] BData,
  input [ADDR_BITS - 1 : 0] DAddress,
  input [ADDR_BITS - 1 : 0] AAddress,
  input [ADDR_BITS - 1 : 0] BAddress
);

  reg [DATA_BITS - 1 : 0] register [0 : DEPTH - 1];

  always @(*) begin
    AData = register[AAddress];
    BData = register[BAddress];
  end

  always @(posedge clk) begin
    register[0] <= 32'b0;
    if ( WriteEnable == 1'b1 ) begin 
      register[DAddress] <= DData;
    end else begin
      register[DAddress] <= register[DAddress];
    end
  end

  // debug 
  reg [31:0] r1;
  reg [31:0] r2;
  reg [31:0] r3;
  reg [31:0] r4;
  reg [31:0] r5;
  reg [31:0] r6;
  reg [31:0] r7;
  reg [31:0] r8;
  reg [31:0] r9;
  reg [31:0] r10;
  reg [31:0] r11;
  reg [31:0] r12;
  reg [31:0] r13;
  reg [31:0] r14;
  reg [31:0] r15;
  reg [31:0] r16;
  reg [31:0] r17;
  reg [31:0] r18;
  reg [31:0] r19;
  reg [31:0] r20;
  reg [31:0] r21;
  reg [31:0] r22;
  reg [31:0] r23;
  reg [31:0] r24;
  reg [31:0] r25;
  reg [31:0] r26;
  reg [31:0] r27;
  reg [31:0] r28;
  reg [31:0] r29;
  reg [31:0] r30;
  reg [31:0] r31;
  reg [31:0] r0;

  always@ (*) begin
    r0 = register[0];
    r1 = register[1];
    r2 = register[2];
    r3 = register[3];
    r4 = register[4];
    r5 = register[5];
    r6 = register[6];
    r7 = register[7];
    r8 = register[8];
    r9 = register[9];
    r10 = register[10];
    r11 = register[11];
    r12 = register[12];
    r13 = register[13];
    r14 = register[14];
    r15 = register[15];
    r16 = register[16];
    r17 = register[17];
    r18 = register[18];
    r19 = register[19];
    r20 = register[20];
    r21 = register[21];
    r22 = register[22];
    r23 = register[23];
    r24 = register[24];
    r25 = register[25];
    r26 = register[26];
    r27 = register[27];
    r28 = register[28];
    r29 = register[29];
    r30 = register[30];
    r31 = register[31];
  end

endmodule
