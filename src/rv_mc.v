module rv_mc (
    input wire clk,
    input wire rst
  );


  reg [31:0] instr_reg;        // IR
  reg [31:0] data_reg;         // MDR
  reg [31:0] rd1_reg, rd2_reg; // A, B
  reg [31:0] alu_reg;          // ALUOut/ALU_Reg
  reg [31:0] pc_reg;
  reg [31:0] pc_old_reg; // Saved PC for Branch/Jump

  // Control Signals (Output from Controller)
  wire we_pc, we_ir, we_rf, we_mem, we_alu; // Added we_alu
  wire sel_mem_addr;                // 0:PC, 1:ALU_Reg
  wire [1:0] sel_result;            // 00:ALU_Reg, 01:Data_Reg, 10:ALU_Direct, 11:ImmExt
  wire [1:0] sel_alu_src_a;         // 00:PC, 01:PC_Old, 10:RD1_Reg
  wire [1:0] sel_alu_src_b;         // 01:Imm, 10:4, 00:RD2_Reg
  wire [3:0] alu_control;
  wire [2:0] sel_ext;

  wire zero;

  // Datapath Wires
  wire [31:0] mem_adr, mem_rd;
  wire [31:0] rd1, rd2;
  wire [31:0] imm_ext;
  wire [31:0] src_a, src_b;
  wire [31:0] alu_result;
  wire [31:0] result;


  // Unified Memory
  assign mem_adr = (sel_mem_addr) ? alu_reg : pc_reg;

  mem MEM (
        .clk(clk),
        .we(we_mem),
        .a(mem_adr),
        .wd(rd2_reg),
        .rd(mem_rd)
      );

  // Instruction Register (IR) & PC_Old
  always @(posedge clk)
  begin
    if (we_ir)
    begin
      instr_reg <= mem_rd;
      pc_old_reg <= pc_reg; // Capture current PC before update
    end
  end

  // Memory Data Register (MDR)
  always @(posedge clk)
  begin
    data_reg <= mem_rd;
  end

  // Register File & Sign Extension
  reg_file rf (
             .clk(clk),
             .we3(we_rf),
             .a1(instr_reg[19:15]), // rs1
             .a2(instr_reg[24:20]), // rs2
             .a3(instr_reg[11:7]),  // rd
             .wd3(result),          // Write Data
             .rd1(rd1),
             .rd2(rd2)
           );

  sign_extend se (
                .instr(instr_reg[31:7]),
                .immsrc(sel_ext),
                .immext(imm_ext)
              );

  // Operand Registers (RD1, RD2)
  always @(posedge clk)
  begin
    rd1_reg <= rd1;
    rd2_reg <= rd2;
  end

  // ALU & Muxes
  // SrcA Mux: 00=PC, 01=PC_Old, 10=RD1
  muxN #(32, 4) mux_src_a (
         .data({32'b0, rd1_reg, pc_old_reg, pc_reg}), // {11, 10, 01, 00}
         .s(sel_alu_src_a),
         .y(src_a)
       );

  muxN #(32, 4) mux_src_b (
         .data({32'd0, 32'd4, imm_ext, rd2_reg}), // {3, 2, 1, 0}
         .s(sel_alu_src_b),
         .y(src_b)
       );

  alu ALU (
        .srca(src_a),
        .srcb(src_b),
        .alucontrol(alu_control),
        .aluresult(alu_result),
        .zero(zero)
      );

  // ALU Register (alu_reg) with Enable
  always @(posedge clk)
  begin
    if (we_alu)
      alu_reg <= alu_result;
  end

  // Result Mux & PC
  // 00: alu_reg (PC+4 from S0 or Result)
  // 01: data_reg (Load)
  // 10: alu_result (Direct PC update)
  // 11: imm_ext (LUI)
  muxN #(32, 4) mux_result (
         .data({imm_ext, alu_result, data_reg, alu_reg}), // {3, 2, 1, 0}
         .s(sel_result),
         .y(result)
       );

  always @(posedge clk)
  begin
    if (rst)
      pc_reg <= 32'd0;
    else if (we_pc)
      pc_reg <= result;
  end



  controller c (
               .clk(clk),
               .rst(rst),
               .op(instr_reg[6:0]),
               .funct3(instr_reg[14:12]),
               .funct7b5(instr_reg[30]),
               .zero(zero),
               .sel_mem_addr(sel_mem_addr),
               .we_pc(we_pc),
               .we_ir(we_ir),
               .we_rf(we_rf),
               .we_mem(we_mem),
               .we_alu(we_alu),
               .sel_result(sel_result),
               .sel_alu_src_a(sel_alu_src_a),
               .sel_alu_src_b(sel_alu_src_b),
               .sel_ext(sel_ext),
               .alu_control(alu_control)
             );

endmodule
