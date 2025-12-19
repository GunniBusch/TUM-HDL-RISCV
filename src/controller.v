module controller (
    input wire clk,
    input wire rst,
    input wire [6:0] op,
    input wire [2:0] funct3,
    input wire funct7b5,
    input wire zero,

    // Control Signal Outputs
    output wire sel_mem_addr,
    output wire we_pc, we_ir, we_rf, we_mem, we_alu,
    output wire [1:0] sel_result,
    output wire [1:0] sel_alu_src_a,
    output wire [1:0] sel_alu_src_b,
    output wire [2:0] sel_ext, // ImmSrc encoded
    output wire [3:0] alu_control
  );

  wire [1:0] alu_op;

  instr_decoder dec_imm (
                  .op(op),
                  .sel_ext(sel_ext)
                );

  fsm fsm_inst (
        .clk(clk),
        .rst(rst),
        .op(op),
        .zero(zero),
        .we_pc(we_pc),
        .we_ir(we_ir),
        .we_rf(we_rf),
        .we_mem(we_mem),
        .we_alu(we_alu),
        .sel_mem_addr(sel_mem_addr),
        .sel_result(sel_result),
        .sel_alu_src_a(sel_alu_src_a),
        .sel_alu_src_b(sel_alu_src_b),
        .alu_op(alu_op)
      );

  alu_decoder dec_alu (
                .alu_op(alu_op),
                .funct3(funct3),
                .funct7b5(funct7b5),
                .alu_control(alu_control)
              );

endmodule
