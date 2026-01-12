module controller (
    input wire [6:0] op,
    input wire [2:0] funct3,
    input wire funct7b5,
    input wire zero,

    output wire [1:0] resultsrc,
    output wire memwrite,
    output wire pcsrc,
    output wire alusrc,
    output wire regwrite,
    output wire jump, // Needed for JAL/JALR
    output wire branch, // For conditional branches
    output wire [2:0] immsrc,
    output wire [3:0] alucontrol
  );

  wire [1:0] aluop;

  // Main Decoder Logic
  // We can infer signals based on Opcode

  // Internal signals
  // {RegWrite, ImmSrc[2:0], ALUSrc, MemWrite, ResultSrc[1:0], Branch, ALUOp[1:0], Jump}
  // 1 + 3 + 1 + 1 + 2 + 1 + 2 + 1 = 12 bits
  reg [11:0] controls;

  assign {regwrite, immsrc, alusrc, memwrite, resultsrc, branch, aluop, jump} = controls;

  always @(*)
  begin
    case(op)
      7'b0000011:
        controls = 12'b1_000_1_0_01_0_00_0; // LW
      7'b0100011:
        controls = 12'b0_001_1_1_00_0_00_0; // SW
      7'b0110011:
        controls = 12'b1_xxx_0_0_00_0_10_0; // R-type
      7'b1100011:
        controls = 12'b0_010_0_0_00_1_01_0; // BEQ
      7'b0010011:
        controls = 12'b1_000_1_0_00_0_11_0; // I-type ALU
      7'b1101111:
        controls = 12'b1_011_x_0_10_0_xx_1; // JAL
      7'b0110111:
        controls = 12'b1_100_1_0_00_0_00_0; // LUI (ALUOp=ADD)
      default:
        controls = 12'b0_000_0_0_00_0_00_0;
    endcase
  end

  // PC Source Logic
  assign pcsrc = (branch & zero) | jump;

  // ALU Decoder
  alu_decoder ad (
                .alu_op(aluop),
                .funct3(funct3),
                .funct7b5(funct7b5),
                .alu_control(alucontrol)
              );

endmodule
