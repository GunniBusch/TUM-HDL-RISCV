module alu (
    input wire [31:0] srca,
    input wire [31:0] srcb,
    input wire [3:0] alucontrol,
    output reg [31:0] aluresult,
    output wire zero
  );

  always @(*)
  begin
    case (alucontrol)
      4'b0000:
        aluresult = srca + srcb; // basic ADD
      4'b0001:
        aluresult = srca - srcb; // SUB my cpu is so fast
      4'b0010:
        aluresult = srca & srcb; // AND
      4'b0011:
        aluresult = srca | srcb; // OR
      4'b0100:
        aluresult = srca ^ srcb; // spicy logic
      4'b0101:
        aluresult = ($signed(srca) < $signed(srcb)) ? 32'b1 : 32'b0; // is A smaller? lets find out
      4'b0110:
        aluresult = srca << srcb[4:0];
      4'b0111:
        aluresult = srca >> srcb[4:0];
      4'b1000:
        aluresult = $signed(srca) >>> srcb[4:0]; // slide to the right
      4'b1001:
        aluresult = (srca < srcb) ? 32'b1 : 32'b0;
      4'b1010:
        aluresult = srcb; // Yoink B
      default:
        aluresult = 32'bx; // garbage in, garbage out
    endcase
  end

  assign zero = (aluresult == 32'b0);

endmodule
