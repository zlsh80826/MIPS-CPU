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
  integer i;

  always @(*) begin
    AData = register[AAddress];
    BData = register[BAddress];
  end

  always @(posedge clk, negedge rst_n) begin
    if ( rst_n == 1'b0 ) begin
      for ( i = 0; i < DEPTH; i = i + 1 ) begin
        register[i] <= 32'b0;
      end
    end else begin
      if ( WriteEnable == 1'b1 ) begin 
        for ( i = 0; i < DEPTH; i = i + 1 ) begin
          if ( i == DAddress )
            register[i] <= DData;
          else 
            register[i] <= register[i];
        end
      end else begin
        for ( i = 0; i < DEPTH; i = i + 1 ) begin
          register[i] <= register[i];
        end
      end
    end
  end

endmodule
