module decoder (
  parameter INSTRUCTION_SIZE = 32,
  parameter REGISTER_ADDR_WIDTH = 5
) (
  input [INSTRUCTION_SIZE - 1 : 0] instruction;
  output reg RW,
  output reg [REGISTER_ADDR_WIDTH - 1 : 0] DA,
  output reg [1:0] MD,
  output reg [1:0] BS,
  output reg PS,
  output reg MW,
  output reg [3:0] FS,
  output reg MA,
  output reg MB,
  output reg [REGISTER_ADDR_WIDTH - 1 : 0] AA,
  output reg [REGISTER_ADDR_WIDTH - 1 : 0] BA,
  output reg CS
);

  localparam opcode_width = 7;
  localparam one_bit_dont_care = 1'b0;
  localparam two_bits_dont_care = 2'b0;
  localparam four_bits_dont_care = 4'b0;
  
  /*reg RW_next;
  reg [REGISTER_ADDR_WIDTH - 1 : 0] DA_next;
  reg [1:0] MD_next;
  reg [1:0] BS_next;
  reg PS_next;
  reg MW_next;
  reg [3:0] FS_next;*/

  wire [opcode_width - 1 : 0] opcode;

  parameter NOP  = 7'b0000000;
  parameter MOVA = 7'b1000000;
  parameter ADD  = 7'b0000010;
  parameter SUB  = 7'b0000101;
  parameter AND  = 7'b0001000;
  parameter OR   = 7'b0001001;
  parameter XOR  = 7'b0001010;
  parameter NOT  = 7'b0001011;
  parameter ADI  = 7'b0100010;
  parameter SBI  = 7'b0100101;
  parameter ANI  = 7'b0101000;
  parameter ORI  = 7'b0101001;
  parameter XRI  = 7'b0101010;
  parameter AIU  = 7'b0100010;
  parameter SIU  = 7'b0100101;
  parameter MOVB = 7'b0001100;
  parameter LSR  = 7'b0001101;
  parameter LSL  = 7'b0001110;
  parameter LD   = 7'b0010000;
  parameter ST   = 7'b0100000;
  parameter JMR  = 7'b1110000;
  parameter SLT  = 7'b1100101;
  parameter BZ   = 7'b1100000;
  parameter BNZ  = 7'b1001000;
  parameter JMP  = 7'b1101000;
  parameter JML  = 7'b0110000;

  assign opcode = instruction[31:25];

  always@(*) begin
    RW = 1'b1;
    MD = 2'b0;
    BS = 2'b0;
    PS = one_bit_dont_care;
    MW = 1'b0;
    MA = 1'b0;
    CS = one_bit_dont_care;
    DA = instruction[24:20];
    AA = instruction[19:15];
    BA = instruction[14:10];
    case(opcode)
      NOP: begin
        RW = 1'b0;
        MD = two_bits_dont_care;
        FS = four_bits_dont_care;
        MB = one_bit_dont_care;
        MA = one_bit_dont_care;
      end 
      MOVE: begin
        FS = 4'b0000;
        MB = one_bit_dont_care;
      end
      ADD: begin
        FS = 4'b0010;
        MB = 1'b0;
      end
      SUB: begin
        FS = 4'b0101;
        MB = 1'b0;
      end
      AND: begin
        FS = 4'b1000;
        MB = 1'b0;
      end
      OR: begin
        FS = 4'b1001;
        MB = 1'b0;
      end
      XOR: begin
        FS = 4'b1010;
        MB = 1'b0;
      end
      NOT: begin
        FS = 4'b0111;
        MB = one_bit_dont_care;
      end
      ADI: begin
        FS = 4'b0010;
        MB = 1'b1;
        CS = 1'b1;
      end
      SBI: begin
        FS = 4'b0101;
        MB = 1'b1;
        CS = 1'b1;
      end
      ANI: begin
        FS = 4'b1000;
        MB = 1'b1;
        CS = 1'b0;
      end
      ORI: begin
        FS = 4'b1001;
        MB = 1'b1;
        CS = 1'b0;
      end
      XRI: begin
        FS = 4'b1010;
        MB = 1'b1;
        CS = 1'b0;
      end
      AIU: begin
        FS = 4'b0010;
        MB = 1'b1;
        CS = 1'b0;
      end
      SIU: begin
        FS = 4'b0101;
        MB = 1'b1;
        CS = 1'b0;
      end
      MOVEB: begin
        FS = 4'b1100;
        MB = 1'b0;
        MA = one_bit_dont_care;
      end
      LSR: begin
        FS = 4'b1100;
        MB = one_bit_dont_care;
      end
      LSL: begin
        FS = 4'b1101;
        MB = one_bit_dont_care;
      end
      LD: begin
        MD = 2'b01;
        FS = four_bits_dont_care;
        MB = one_bit_dont_care;
      end
      ST: begin
        RW = 1'b0;
        MD = two_bits_dont_care;
        MW = 1'b1;
        FS = four_bits_dont_care;
        MB = 1'b0;
      end
      JMR: begin
        RW = 1'b0;
        MD = two_bits_dont_care;
        BS = 2'b10;
        FS = four_bits_dont_care;
        MB = one_bit_dont_care;
      end
      SLT: begin
        MD = 2'b10;
        FS = 4'b0101;
        MB = 1'b0;
      end
      BZ: begin
        RW = 1'b0;
        MD = two_bits_dont_care;
        BS = 2'b01;
        PS = 1'b0;
        FS = 4'b0000;
        MB = 1'b1;
        CS = 1'b1;
      end
      BNZ: begin
        RW = 1'b0;
        MD = two_bits_dont_care;
        BS = 2'b01;
        PS = 1'b1;
        FS = 4'b0000;
        MB = 1'b1;
        CS = 1'b1;
      end
      JMP: begin
        RW = 1'b0;
        MD = two_bits_dont_care;
        BS = 2'b11;
        FS = four_bits_dont_care;
        MB = 1'b1;
        MA = one_bit_dont_care;
        CS = 1'b1;
      end
      JML: begin
        BS = 2'b11;
        FS = 4'b0000;
        MB = 1'b1;
        MA = 1'b1;
        CS = 1'b1;
      end
      default: begin
        RW = one_bit_dont_care;
        MD = two_bits_dont_care;
        BS = two_bits_dont_care;
        PS = one_bit_dont_care;
        MW = one_bit_dont_care;
        FS = four_bits_dont_care;
        MB = one_bit_dont_care;
        MA = one_bit_dont_care;
        CS = one_bit_dont_care;
      end
    endcase
  end


