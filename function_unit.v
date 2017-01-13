module function_unit #(
  parameter DATA_WIDTH = 32,
  parameter SHIFTER_WIDTH = 5
) (
  input [DATA_WIDTH - 1 : 0] A,
  input [DATA_WIDTH - 1 : 0] B,
  output reg [DATA_WIDTH - 1 : 0] Result,
  input [3:0]  FunctionSelect,
  input [SHIFTER_WIDTH - 1 : 0] SH,
  output reg Overflow,
  output reg CarryOut,
  output Negative,
  output reg Zero
);
    
  parameter UNDEFINE = 32'b00000000_00000000_00000000_00000000;   

  wire [DATA_WIDTH - 1 : 0] inverseA, inverseB;

  assign inverseA = ~A;
  assign inverseB = ~B;

  always@(*) begin
      case(FunctionSelect)
          4'b0001: begin
            Overflow <= overflow(A, 32'b00000000_00000000_00000000_00000001, Result);
          end
          4'b0010: begin
            Overflow <= overflow(A, B, Result);
          end
          4'b0011: begin
            Overflow <= overflow(A, B, Result);
          end
          4'b0100: begin
            Overflow <= overflow(A, inverseB, Result);
          end
          4'b0101: begin
            Overflow <= overflow(A, inverseB, Result);
          end
          4'b0110: begin
            Overflow <= overflow(A, 32'b11111111_11111111_11111111_11111111, Result);
          end
          default: begin
            Overflow <= 32'b0;
          end
      endcase 
  end

  always@(*) begin
    case(FunctionSelect)
      4'b0000: begin
        Result = A;
        CarryOut = 1'b0;
      end 
      4'b0001: begin
        {CarryOut, Result} = A + 32'd1;
      end
      4'b0010: begin
        {CarryOut, Result} = A + B;
      end
      4'b0011: begin
        {CarryOut, Result} = A + B + 32'd1;
      end
      4'b0100: begin
        {CarryOut, Result} = A + inverseB;
      end
      4'b0101: begin
        {CarryOut, Result} = A + inverseB + 32'd1;
      end
      4'b0110: begin
        {CarryOut, Result} = A - 32'd1;
      end
      4'b0111: begin
        Result = A;
        CarryOut = 32'b0;
      end
      4'b1000: begin
        Result = A & B;
        CarryOut = 32'b0;
      end
      4'b1001: begin
        Result = A | B;
        CarryOut = 32'b0;
      end
      4'b1010: begin
        Result = A ^ B;
        CarryOut = 32'b0;
      end
      4'b1011: begin
        Result = inverseA;
        CarryOut = 32'b0;
      end
      4'b1100: begin
        Result = B;
        CarryOut = 32'b0;
      end
      4'b1101: begin
        Result = A >> SH;
        CarryOut = 32'b0;
      end
      4'b1110: begin
        {CarryOut, Result} = A << SH;
      end
      default: begin
        Result = UNDEFINE;
        CarryOut = 32'b0;
      end
    endcase
    if ( Result == 32'b0 ) begin
      Zero = 1'b1;
    end else begin
      Zero = 1'b0;
    end
  end

  assign Negative = Result[DATA_WIDTH - 1];
  // assign Zero = (Result == 32'b00000000_00000000_00000000_00000000) ? 1'b1 : 1'b0;

  function overflow; 
    input [DATA_WIDTH - 1 : 0] a, b, result;
    begin
      overflow = ( (a[DATA_WIDTH - 1] == 1'b0) && (b[DATA_WIDTH - 1] == 1'b0) && (result[DATA_WIDTH - 1] == 1'b1) ) |
                 ( (a[DATA_WIDTH - 1] == 1'b1) && (b[DATA_WIDTH - 1] == 1'b1) && (result[DATA_WIDTH - 1] == 1'b0) );
    end
  endfunction

endmodule 
