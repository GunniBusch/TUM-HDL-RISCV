module fsm (
    input wire clk,
    input wire rst,
    input wire [6:0] op,
    input wire zero,

    // Outputs
    output reg we_pc, we_ir, we_rf, we_mem, we_alu,
    output reg sel_mem_addr,
    output reg [1:0] sel_result,
    output reg [1:0] sel_alu_src_a,
    output reg [1:0] sel_alu_src_b,
    output reg [1:0] alu_op
  );

  // State Encoding
  localparam S0_FETCH     = 4'd0;
  localparam S1_DECODE    = 4'd1;
  localparam S2_EXE_ADDR  = 4'd2;
  localparam S3_MEM_RD    = 4'd3;
  localparam S4_WB_MEM    = 4'd4;
  localparam S5_MEM_WR    = 4'd5;
  localparam S6_EXE_R     = 4'd6;
  localparam S7_WB_ALU    = 4'd7;
  localparam S8_BEQ       = 4'd8;
  localparam S9_EXE_I     = 4'd9;
  localparam S10_JAL      = 4'd10;
  localparam S11_LUI      = 4'd11;
  localparam S12_JAL_JUMP = 4'd12;
  localparam S13_BEQ_TGT  = 4'd13;

  // Opcode Encoding
  localparam OP_LW      = 7'b0000011;
  localparam OP_SW      = 7'b0100011;
  localparam OP_R_TYPE  = 7'b0110011;
  localparam OP_I_TYPE  = 7'b0010011;
  localparam OP_BEQ     = 7'b1100011;
  localparam OP_JAL     = 7'b1101111;
  localparam OP_LUI     = 7'b0110111;

  reg [3:0] current_state, next_state;

  // State Register
  always @(posedge clk or posedge rst)
  begin
    if (rst)
      current_state <= S0_FETCH;
    else
      current_state <= next_state;
  end

  // Next State Logic
  always @(*)
  begin
    case (current_state)
      S0_FETCH:
        next_state = S1_DECODE;
      S1_DECODE:
      begin
        case (op)
          OP_LW:
            next_state = S2_EXE_ADDR;
          OP_SW:
            next_state = S2_EXE_ADDR;
          OP_R_TYPE:
            next_state = S6_EXE_R;
          OP_I_TYPE:
            next_state = S9_EXE_I;
          OP_BEQ:
            next_state = S8_BEQ;
          OP_JAL:
            next_state = S10_JAL;
          OP_LUI:
            next_state = S11_LUI;
          default:
            next_state = S0_FETCH;
        endcase
      end
      S2_EXE_ADDR:
      begin
        if (op == OP_LW)
          next_state = S3_MEM_RD;
        else
          next_state = S5_MEM_WR;
      end
      S3_MEM_RD:
        next_state = S4_WB_MEM;
      S4_WB_MEM:
        next_state = S0_FETCH;
      S5_MEM_WR:
        next_state = S0_FETCH;
      S6_EXE_R:
        next_state = S7_WB_ALU;
      S7_WB_ALU:
        next_state = S0_FETCH;

      S8_BEQ:
      begin
        if (zero)
          next_state = S13_BEQ_TGT;
        else
          next_state = S0_FETCH;
      end
      S13_BEQ_TGT:
        next_state = S0_FETCH;

      S9_EXE_I:
        next_state = S7_WB_ALU;

      S10_JAL:
        next_state = S12_JAL_JUMP;
      S12_JAL_JUMP:
        next_state = S0_FETCH;

      S11_LUI:
        next_state = S0_FETCH;
      default:
        next_state = S0_FETCH;
    endcase
  end

  // Output Logic (State-Based)
  always @(*)
  begin
    // Defaults
    we_pc = 0;
    we_ir = 0;
    we_rf = 0;
    we_mem = 0;
    we_alu = 0;
    sel_mem_addr = 0;
    sel_result = 0;
    sel_alu_src_a = 0;
    sel_alu_src_b = 0;
    alu_op = 0;

    case (current_state)
      S0_FETCH:
      begin
        sel_mem_addr = 0; // PC
        we_ir = 1;
        we_alu = 1; // Capture PC+4
        sel_alu_src_a = 2'b00; // PC
        sel_alu_src_b = 2'b10; // 4
        alu_op = 2'b00;        // ADD
        sel_result = 2'b10;    // Direct ALU Result (PC+4)
        we_pc = 1;             // Update PC
      end
      S1_DECODE:
      begin
        sel_alu_src_a = 2'b00;
        sel_alu_src_b = 2'b01;
        alu_op = 2'b00;
      end
      S2_EXE_ADDR:
      begin
        we_alu = 1;
        sel_alu_src_a = 2'b10; // RD1 (Base)
        sel_alu_src_b = 2'b01; // Imm (Offset)
        alu_op = 2'b00;        // ADD
      end
      S3_MEM_RD:
      begin
        sel_mem_addr = 1; // ALU_Reg
      end
      S4_WB_MEM:
      begin
        sel_result = 2'b01; // Data_Reg
        we_rf = 1;
      end
      S5_MEM_WR:
      begin
        sel_mem_addr = 1; // ALU_Reg
        we_mem = 1;
      end
      S6_EXE_R:
      begin
        we_alu = 1;
        sel_alu_src_a = 2'b10; // RD1
        sel_alu_src_b = 2'b00; // RD2
        alu_op = 2'b10;        // Funct dependent
      end
      S7_WB_ALU:
      begin
        sel_result = 2'b00; // ALU_Reg
        we_rf = 1;
      end

      S8_BEQ:
      begin
        // Compare A-B
        sel_alu_src_a = 2'b10; // RD1
        sel_alu_src_b = 2'b00; // RD2
        alu_op = 2'b01;        // SUB
        // No write. Zero flag used in Next State logic.
      end
      S13_BEQ_TGT:
      begin
        // Calc Target: PC_Old + Imm
        sel_alu_src_a = 2'b01; // PC_OLD
        sel_alu_src_b = 2'b01; // Imm
        alu_op = 2'b00;        // ADD

        sel_result = 2'b10;    // Direct
        we_pc = 1;             // Update PC
      end

      S10_JAL:
      begin
        // Link: RD = PC+4 (Held in ALU_Reg from S0)
        sel_result = 2'b00; // ALU_Reg
        we_rf = 1;
      end
      S12_JAL_JUMP:
      begin
        // Jump: PC = PC + Imm
        sel_alu_src_a = 2'b01; // PC_OLD
        sel_alu_src_b = 2'b01; // Imm
        alu_op = 2'b00; // ADD

        sel_result = 2'b10; // ALU Result Direct
        we_pc = 1;
      end

      S9_EXE_I:
      begin
        we_alu = 1; // ENABLE WRITE
        sel_alu_src_a = 2'b10; // A
        sel_alu_src_b = 2'b01; // Imm
        alu_op = 2'b11;        // I-Type (Distinct from R-Type)
      end

      S11_LUI:
      begin
        sel_result = 2'b11; // ImmExt
        we_rf = 1;
      end
    endcase
  end
endmodule
