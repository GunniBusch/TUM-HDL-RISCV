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
    output wire [2:0] immsrc,
    output wire [3:0] alucontrol
  );

  wire [1:0] aluop;
  wire branch;
  wire jump;

  main_decoder md (
                 .op(op),
                 .resultsrc(resultsrc),
                 .memwrite(memwrite),
                 .branch(branch),
                 .alusrc(alusrc),
                 .regwrite(regwrite),
                 .jump(jump),
                 .immsrc(immsrc),
                 .aluop(aluop)
               );

  alu_decoder ad (
                .opb5(op[5]),
                .funct3(funct3),
                .funct7b5(funct7b5),
                .aluop(aluop),
                .alucontrol(alucontrol)
              );

  assign pcsrc = (branch & zero) | jump;

endmodule

module main_decoder (
    input wire [6:0] op,
    output reg [1:0] resultsrc,
    output reg memwrite,
    output reg branch,
    output reg alusrc,
    output reg regwrite,
    output reg jump,
    output reg [2:0] immsrc,
    output reg [1:0] aluop
  );

  always @(*)
  begin
    case (op)
      7'b0000011:
      begin // lw
        regwrite = 1;
        immsrc = 2'b00;
        alusrc = 1;
        memwrite = 0;
        resultsrc = 2'b01;
        branch = 0;
        aluop = 2'b00;
        jump = 0;
      end
      7'b0100011:
      begin // sw
        regwrite = 0;
        immsrc = 2'b01;
        alusrc = 1;
        memwrite = 1;
        resultsrc = 2'bxx;
        branch = 0;
        aluop = 2'b00;
        jump = 0;
      end
      7'b0110011:
      begin // R-type
        regwrite = 1;
        immsrc = 2'bxx;
        alusrc = 0;
        memwrite = 0;
        resultsrc = 2'b00;
        branch = 0;
        aluop = 2'b01;
        jump = 0;
      end
      7'b1100011:
      begin // branch me maybe (BEQ)
        regwrite = 0;
        immsrc = 3'b010;
        alusrc = 0;
        memwrite = 0;
        resultsrc = 2'bxx;
        branch = 1;
        aluop = 2'b01;
        jump = 0;
        // Note: BEQ shares aluop 01 (Sub/Branch logic handled in alu_decoder or distinct code?)
        // Manual says R-type is 01. We need subtraction for BEQ.
        // Let's use aluop = 2'b01 (same as R-type? No, BEQ funct3 is 000, R-type ADD/SUB is 000.
        // If we use 01, we need to ensure it subtracts.
        // Using strict Table 3 for R/I. Let's use 2'b11 for others to be safe or use specific code.
        // Resetting aluop to 2'b01 (SUB in our custom logic) -> No, Table 3 says 01 is R-type.
        // Let's use aluop = 2'b00 for lw/sw, 01 for R, 10 for I.
        // We can use 2'b11 for BEQ/LUI.
      end
      7'b1100011:
      begin // BEQ
        regwrite = 0;
        immsrc = 3'b010;
        alusrc = 0;
        memwrite = 0;
        resultsrc = 2'bxx;
        branch = 1;
        aluop = 2'b11;
        jump = 0;
      end
      7'b0010011:
      begin // I-type ALU (Table 3: 10)
        regwrite = 1;
        immsrc = 3'b000;
        alusrc = 1;
        memwrite = 0;
        resultsrc = 2'b00;
        branch = 0;
        aluop = 2'b10;
        jump = 0;
      end
      7'b1101111:
      begin // YEET (jal)
        regwrite = 1;
        immsrc = 3'b011;
        alusrc = 1'bx;
        memwrite = 0;
        resultsrc = 2'b10;
        branch = 0;
        aluop = 2'bxx;
        jump = 1;
      end
      7'b0110111:
      begin // lui
        regwrite = 1;
        immsrc = 3'b100;
        alusrc = 1;
        memwrite = 0;
        resultsrc = 2'b00;
        branch = 0;
        aluop = 2'b11;
        jump = 0;
      end
      default:
      begin // what even is this opcode
        regwrite = 0;
        immsrc = 3'bxxx;
        alusrc = 0;
        memwrite = 0;
        resultsrc = 2'bxx;
        branch = 0;
        aluop = 2'bxx;
        jump = 0;
      end
    endcase
  end

endmodule

module alu_decoder (
    input wire opb5,
    input wire [2:0] funct3,
    input wire funct7b5,
    input wire [1:0] aluop,
    output reg [3:0] alucontrol
  );

  always @(*)
  begin
    case (aluop)
      2'b00:
        alucontrol = 4'b0000; // lw/sw (Add)
      2'b11:
      begin
        if (opb5)
          alucontrol = 4'b1010; // LUI (Copy B), opcode 0110111 (bit 5 is 1)
        else
          alucontrol = 4'b0001;      // BEQ (Sub), opcode 1100011 (bit 5 is 0)
      end
      2'b01:
      begin // R-Type (Table 3: 01)
        case (funct3)
          3'b000:
            if (funct7b5)
              alucontrol = 4'b0001; // sub
            else
              alucontrol = 4'b0000; // add
          3'b001:
            alucontrol = 4'b0110; // sll
          3'b010:
            alucontrol = 4'b0101; // slt
          3'b011:
            alucontrol = 4'b1001; // sltu
          3'b100:
            alucontrol = 4'b0100; // xor
          3'b101:
            if (funct7b5)
              alucontrol = 4'b1000; // sra
            else
              alucontrol = 4'b0111; // srl
          3'b110:
            alucontrol = 4'b0011; // or
          3'b111:
            alucontrol = 4'b0010; // and
          default:
            alucontrol = 4'bxxxx;
        endcase
      end
      2'b10:
      begin // I-Type (Table 3: 10)
        case (funct3)
          3'b000:
            alucontrol = 4'b0000; // addi
          3'b001:
            alucontrol = 4'b0110; // slli
          3'b010:
            alucontrol = 4'b0101; // slti
          3'b011:
            alucontrol = 4'b1001; // sltiu
          3'b100:
            alucontrol = 4'b0100; // xori
          3'b101:
            if (funct7b5)
              alucontrol = 4'b1000; // srai
            else
              alucontrol = 4'b0111; // srli
          3'b110:
            alucontrol = 4'b0011; // ori
          3'b111:
            alucontrol = 4'b0010; // andi
          default:
            alucontrol = 4'bxxxx;
        endcase
      end
      default:
        alucontrol = 4'bxxxx;

    endcase
  end

endmodule
