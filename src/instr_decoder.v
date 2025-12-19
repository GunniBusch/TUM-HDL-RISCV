module instr_decoder (
    input wire [6:0] op,
    output reg [2:0] sel_ext // ImmSrc
  );
  // Opcode Encoding
  localparam OP_LW      = 7'b0000011;
  localparam OP_SW      = 7'b0100011;
  localparam OP_R_TYPE  = 7'b0110011;
  localparam OP_I_TYPE  = 7'b0010011;
  localparam OP_BEQ     = 7'b1100011;
  localparam OP_JAL     = 7'b1101111;
  localparam OP_LUI     = 7'b0110111;
  localparam OP_JALR    = 7'b1100111;

  always @(*)
  begin
    case (op)
      OP_I_TYPE:
        sel_ext = 3'b000;
      OP_LW:
        sel_ext = 3'b000;
      OP_JALR:
        sel_ext = 3'b000;
      OP_SW:
        sel_ext = 3'b001; // S-type
      OP_BEQ:
        sel_ext = 3'b010; // B-type
      OP_JAL:
        sel_ext = 3'b011; // J-type
      OP_LUI:
        sel_ext = 3'b100; // U-type
      default:
        sel_ext = 3'b000;
    endcase
  end

endmodule
