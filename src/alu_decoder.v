module alu_decoder (
    input wire [1:0] alu_op,
    input wire [2:0] funct3,
    input wire funct7b5,
    output reg [3:0] alu_control
);

  always @(*) begin
    case (alu_op)
      2'b00: alu_control = 4'b0000; // LW/SW/PC+4 (ADD)
      2'b01: alu_control = 4'b0001; // BEQ (SUB)
      
      2'b10: begin // R-Type
        case (funct3)
          3'b000: alu_control = (funct7b5) ? 4'b0001 : 4'b0000; // SUB/ADD
          3'b001: alu_control = 4'b0110; // SLL
          3'b010: alu_control = 4'b0101; // SLT
          3'b011: alu_control = 4'b1001; // SLTU
          3'b100: alu_control = 4'b0100; // XOR
          3'b101: alu_control = (funct7b5) ? 4'b1000 : 4'b0111; // SRA/SRL
          3'b110: alu_control = 4'b0011; // OR
          3'b111: alu_control = 4'b0010; // AND
          default: alu_control = 4'b0000;
        endcase
      end

      2'b11: begin // I-Type
        case (funct3)
          3'b000: alu_control = 4'b0000; // ADDI (Always ADD, ignore funct7)
          3'b001: alu_control = 4'b0110; // SLLI
          3'b010: alu_control = 4'b0101; // SLTI
          3'b011: alu_control = 4'b1001; // SLTIU
          3'b100: alu_control = 4'b0100; // XORI
          3'b101: alu_control = (funct7b5) ? 4'b1000 : 4'b0111; // SRAI/SRLI (Check bit 30)
          3'b110: alu_control = 4'b0011; // ORI
          3'b111: alu_control = 4'b0010; // ANDI
          default: alu_control = 4'b0000;
        endcase
      end

      default: alu_control = 4'b0000;
    endcase
  end
endmodule
