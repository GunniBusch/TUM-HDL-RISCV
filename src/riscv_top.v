
module riscv_top (
    input wire clk,
    input wire rst,
    output wire [31:0] writedata,
    output wire [31:0] dataadr,
    output wire memwrite
  );

  wire [31:0] pc, instr, readdata;

  // Instantiate Processor (Controller + Datapath)
  // For simplicity in this single-cycle design, we can keep everything in riscv_top or separate.
  // I will instantiate the memories here and the rest in a "riscv" module or just put everything here.
  // Given the lab manual structure, I'll put the datapath and controller here.

  wire [31:0] pcnext, pcplus4, pctarget;
  wire [31:0] immext;
  wire [31:0] srca, srcb;
  wire [31:0] aluout; // dataadr
  wire [31:0] result;
  wire zero, pcsrc, alusrc, regwrite, jump;
  wire [1:0] resultsrc;
  wire [2:0] immsrc;
  wire [3:0] alucontrol;

  // Controller
  controller c (
               .op(instr[6:0]),
               .funct3(instr[14:12]),
               .funct7b5(instr[30]),
               .zero(zero),
               .resultsrc(resultsrc),
               .memwrite(memwrite),
               .pcsrc(pcsrc),
               .alusrc(alusrc),
               .regwrite(regwrite),
               .immsrc(immsrc),
               .alucontrol(alucontrol)
             );

  // Datapath

  // PC Logic
  muxN #(32,2) pcmux (
         .data({pcplus4, pctarget}),
         .s(pcsrc),
         .y(pcnext)
       );

  pc pcreg (
       .clk(clk),
       .rst(rst),
       .pc_next(pcnext),
       .pc(pc)
     );

  adder pcadd4 (
          .a(pc),
          .b(32'd4),
          .y(pcplus4)
        );

  adder pcaddbranch (
          .a(pc),
          .b(immext),
          .y(pctarget)
        );

  // Instruction Memory
  inst_mem imem (
             .a(pc),
             .rd(instr)
           );

  // Register File Logic
  reg_file rf (
             .clk(clk),
             .we3(regwrite),
             .a1(instr[19:15]),
             .a2(instr[24:20]),
             .a3(instr[11:7]),
             .wd3(result),
             .rd1(srca),
             .rd2(writedata)
           );

  sign_extend se (
                .instr(instr[31:7]),
                .immsrc(immsrc),
                .immext(immext)
              );

  // ALU Logic
  muxN #(32,2) srcbmux (
         .data({writedata,immext}),
         .s(alusrc),
         .y(srcb)
       );

  alu alu (
        .srca(srca),
        .srcb(srcb),
        .alucontrol(alucontrol),
        .aluresult(aluout),
        .zero(zero)
      );

  // Data Memory
  data_mem dmem (
             .clk(clk),
             .we(memwrite),
             .a(aluout),
             .wd(writedata),
             .rd(readdata)
           );

  // Results Logic (choosing what to save basically)
  muxN #(32,3) resultmux (
         .data({aluout, readdata, pcplus4}),
         .s(resultsrc),
         .y(result)
       );
  assign dataadr = aluout;

endmodule


