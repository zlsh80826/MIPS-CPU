module stimulus;
  parameter data_width = 32;
  parameter address_width = 32;
  parameter address_depth = 2048;
  parameter opcode_width = 7;
  parameter reg_addr_width = 5;
  parameter immediate_width = 15;
  parameter period = 10;
  parameter delay = 1;

  //  Define the input and output file names
  parameter program_code  = "testcase/03_bin.dat";
  parameter program_data  = "testcase/03_data.dat";
  parameter sdf_file      = "processor_syn.sdf";
  parameter fsdb_syn_file = "processor_syn.fsdb";
  parameter fsdb_file     = "processor.fsdb";
  parameter vcd_syn_file  = "processor_syn.vcd";
  parameter vcd_file      = "processor.vcd";
  parameter instr_count   = 20;

  // Define for testbench memory
  localparam BITS = 32;
  localparam word_depth = 2048;
  localparam addr_width = 11;
  localparam wordx = {BITS{1'bx}};
  localparam addrx = {addr_width{1'bx}};

  reg [BITS - 1:0] code_mem [0:word_depth - 1];
  reg [BITS - 1:0] data_mem [0:word_depth - 1];

  reg clk;
  reg rst_n;

  // signals for instruction memory IM
  reg im_cen;
  reg im_wen;
  reg [10:0] im_addr;
  reg [31:0] im_datain;
  reg im_oen;
  wire [31:0] im_dataout;

  // signals for data memory DM
  reg dm_cen;
  reg dm_wen;
  reg [10:0] dm_addr;
  reg [31:0] dm_datain;
  reg dm_oen;
  wire [31:0] dm_dataout;

  reg [data_width - 1:0] pc;
  reg [data_width - 1:0] pc_pre;
  reg [data_width - 1:0] ir;
  reg [opcode_width - 1:0] opcode;
  reg [reg_addr_width - 1:0] dr, sa, sb, sh;
  reg signed [immediate_width - 1:0] imm;
  reg loading;

  processor Processor(
    .clk(clk),
    .rst_n(rst_n),
    .loading(loading),
    .im_cen_load(im_cen),
    .im_wen_load(im_wen),
    .im_oen_load(im_oen),
    .im_addr_load(im_addr),
    .im_datain_load(im_datain),
    .dm_cen_load(dm_cen),
    .dm_wen_load(dm_wen),
    .dm_oen_load(dm_oen),
    .dm_addr_load(dm_addr),
    .dm_datain_load(dm_datain)
  );

  always #(period/2) clk = ~clk;

  initial begin
    `ifdef NETLIST
      $sdf_annotate(sdf_file, Processor);
      `ifdef FSDB
        $fsdbDumpfile(fsdb_syn_file);
        $fsdbDumpvars;
      `else
        $dumpfile(vcd_syn_file);
        $dumpvars(0, stimulus);
      `endif
    `else
      `ifdef FSDB
        $fsdbDumpfile(fsdb_file);
        $fsdbDumpvars;
      `else
        $dumpfile(vcd_file);
        $dumpvars(0, stimulus);
      `endif
    `endif
  end

  integer n;
  initial begin
    // initialization
    clk = 1;
    loading = 1'b0;
    im_cen = 0;
    im_wen = 1'b1;
    im_oen = 1'b1;
    dm_cen = 0;
    dm_wen = 1'b1;
    dm_oen = 1'b1;
    #(period);

    // rst_n = 1'b0;
    // #(period*4) rst_n = 1'b1;
    loading = 1'b1;

    #(period);

    for (n = 0; n < word_depth;n = n + 1) begin
      dm_write(n, data_mem[n]);
      im_write(n, code_mem[n]);
    end
  
    loading = 1'b0;
    #(period);

    idle;

    #(period);
    #(delay)  rst_n = 0;
    #(period*4) rst_n = 1;
    #(period*600);

    $finish;
  end

  // preload code memory
  integer i = 0;
  initial begin
    for (i = 0; i < word_depth; i = i + 1) begin
      code_mem[i] = wordx;
    end

    $readmemb(program_code, code_mem);
`ifdef DEBUG_MEM
    $display("Dumping memory content of %m...");
    for (i = 0; i < word_depth; i = i + 1) begin
      $display("[%d] %b", i, code_mem[i]);
    end
    $display("End of dumping memory content of %m.\n\n");
`endif
  end

  // preload program mem
  initial begin
    for (i = 0; i < word_depth; i = i + 1) begin
      data_mem[i] = wordx;
    end

    $readmemb(program_data, data_mem);
`ifdef DEBUG_MEM
    $display("Dumping memory content of %m...");
    for (i = 0; i < word_depth; i = i + 1) begin
      $display("[%d] %b", i, data_mem[i]);
    end
    $display("End of dumping memory content of %m.\n\n");
`endif
  end

`ifdef DEBUG
  initial begin
    $monitor($time, " [pc=%5d] [ir=%b]", pc, ir);
  end
`endif

  // tasks
  task idle;
    begin
      im_wen = 1;
      im_oen = 1;
      im_datain = 32'bz;
    end
  endtask

/*  task instr_fetch;
    input [address_width - 1:0] program_counter;
    begin
      im_addr = #(delay) program_counter;
      im_wen = 1;
      im_oen = 0;
      @(posedge clk)
      ir = im_dataout;
      opcode = ir[31:25];
      dr = ir[24:20];
      sa = ir[19:15];
      sb = ir[14:10];
      imm = ir[14:0];
      sh = ir[4:0];
    end
  endtask

  task dm_nop;
    begin
      dm_wen = 1;
      dm_oen = 1;
      dm_datain = 32'bz;
    end
  endtask
*/
  task dm_write;
    input [address_width - 1:0] address;
    input [data_width - 1:0] data;
    begin
      @(posedge clk) begin
        #(delay)
        dm_addr = address;
        dm_datain = data;
        dm_wen = 0;
`ifdef DEBUG_DATAMEM_RW
        $display("[", $time, "] Writing %d to DMEM[%d]", dm_datain, dm_addr);
`endif
      end
    end
  endtask

  task im_write;
    input [address_width - 1:0] address;
    input [data_width - 1:0] data;
    begin
      @(posedge clk) begin
        #(delay)
        im_addr = address;
        im_datain = data;
        im_wen = 0;
`ifdef DEBUG_DATAMEM_RW
        $display("[", $time, "] Writing %b to IMEM[%d]", im_datain, im_addr);
`endif
      end
    end
  endtask

  task dm_read;
    input [address_width - 1:0] address;
    begin
      @(posedge clk) begin
        #(delay)
        dm_addr = address;
        dm_wen = 1;
        dm_oen = 0;
      end
      @(posedge clk) begin
        #(delay)
        dm_oen = 0;
`ifdef DEBUG_DATAMEM_RW
        $display("[",$time, "] Reading DMEM[%d]: %d", dm_addr, dm_dataout);
`endif
      end
    end
  endtask

  // De-assembler
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

  always @(posedge clk) begin
    pc_pre = #(delay) pc;
  end

`ifndef CYC_BASED_DEASSEMBLY
  always @(ir) begin
`else
  always @(posedge clk) begin
`endif
    case (ir[31:25])
      NOP: begin
        $display("[%5d] NOP  ", pc_pre);
      end
      MOVA: begin
        $display("[%5d] MOVA R%d, R%d", pc_pre, dr, sa);
      end
      ADD: begin
        $display("[%5d] ADD  R%0d, R%0d", pc_pre, dr, sa);
      end
      SUB: begin
        $display("[%5d] SUB  R%0d, R%0d, R%0d", pc_pre, dr, sa, sb);
      end
      AND: begin
        $display("[%5d] AND  R%0d, R%0d, R%0d", pc_pre, dr, sa, sb);
      end
      OR: begin
        $display("[%5d] OR   R%0d, R%0d, R%0d", pc_pre, dr, sa, sb);
      end
      XOR: begin
        $display("[%5d] XOR  R%0d, R%0d, R%0d", pc_pre, dr, sa, sb);
      end
      NOT: begin
        $display("[%5d] NOT  R%0d, R%0d", pc_pre, dr, sa);
      end
      ADI: begin
        $display("[%5d] ADI  R%0d, R%0d, #(%d)", pc_pre, dr, sa, imm);
      end
      SBI: begin
        $display("[%5d] SBI  R%0d, R%0d, #(%d)", pc_pre, dr, sa, imm);
      end
      ANI: begin
        $display("[%5d] ANI  R%0d, R%0d, #(%d)", pc_pre, dr, sa, imm);
      end
      ORI: begin
        $display("[%5d] ORI  R%0d, R%0d, #(%d)", pc_pre, dr, sa, imm);
      end
      XRI: begin
        $display("[%5d] XRI  R%0d, R%0d, #(%d)", pc_pre, dr, sa, imm);
      end
      AIU: begin
        $display("[%5d] AIU  R%0d, R%0d, #(%d)", pc_pre, dr, sa, imm);
      end
      SIU: begin
        $display("[%5d] SIU  R%0d, R%0d, #(%d)", pc_pre, dr, sa, imm);
      end
      MOVB: begin
        $display("[%5d] MOVB R%0d, R%0d", pc_pre, dr, sb);
      end
      LSR: begin
        $display("[%5d] LSR  R%0d, R%0d >> %d", pc_pre, dr, sa, sh);
      end
      LSL: begin
        $display("[%5d] LSL  R%0d, R%0d << %d", pc_pre, dr, sa, sh);
      end
      LD: begin
        $display("[%5d] LD   R%0d, M[R%0d]", pc_pre, dr, sa);
      end
      ST: begin
        $display("[%5d] ST   R%0d, M[R%0d]", pc_pre, sa, sb);
      end
      JMR: begin
        $display("[%5d] JMR  R%0d", pc_pre, sa);
      end
      SLT: begin
        $display("[%5d] SLT  R%0d, R%0d, R%0d", pc_pre, dr, sa, sb);
      end
      BZ: begin
        $display("[%5d] BZ   R%0d, #(%d)", pc_pre, sa, imm);
      end
      BNZ: begin
        $display("[%5d] BNZ  R%0d, #(%d)", pc_pre, sa, imm);
      end
      JMP: begin
        $display("[%5d] JMP  #(%d)", pc_pre, imm);
      end
      JML: begin
        $display("[%5d] JML  R%0d, #(%d)", pc_pre, dr, imm);
      end
      default: begin
        $display("[%5d] Unknown Instruction! Opcode = %b", pc_pre, opcode);
      end
    endcase
  end
endmodule
