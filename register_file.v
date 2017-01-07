module register_file #(
  parameter DATA_BITS = 32,
  parameter ADDR_BITS = 5,
  parameter DEPTH = 1 << ADDR_BITS
) ( 
  input clk,
  input WriteEnable,
  input [DATA_BITS - 1 : 0] DData
  input [DATA_BITS - 1 : 0] AData,
  input [DATA_BITS - 1 : 0] BData,
  input [ADDR_BITS - 1 : 0] DAddress,
  output reg [ADDR_BITS - 1 : 0] AAddress,
  output reg [ADDR_BITS - 1 : 0] BAddress,
);

  reg [DATA_BITS - 1 : 0] register [0 : DEPTH - 1];
  integer i;

  always @(*) begin
    AData = register[AAddress];
    BData = register[BAddress];
  end

  always @(posedge clk) begin
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

endmodule