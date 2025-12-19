module alu_decoder (
    input wire [1:0] alu_op,
    input wire [2:0] funct3,
    input wire funct7b5,
    output reg [3:0] alu_control
  );

  always @(*)
  begin
    case (alu_op)
      2'b00:
        alu_control = 4'b0000; // Add (for LW/SW/PC+4)
      2'b01:
        alu_control = 4'b0001; // Sub (for BEQ)
      2'b10:
      begin // R-type or I-type
        case (funct3)
          3'b000:
          begin
            if (funct7b5)
              alu_control = 4'b0001; // SUB
            else
              alu_control = 4'b0000; // ADD
          end
          3'b010:
            alu_control = 4'b0101; // SLT
          3'b110:
            alu_control = 4'b0011; // OR
          3'b111:
            alu_control = 4'b0010; // AND
          // Add other operations as needed
          default:
            alu_control = 4'b0000;
        endcase
      end
      default:
        alu_control = 4'b0000;
    endcase
  end

endmodule
