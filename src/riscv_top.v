module riscv_top (
    input wire clk,
    input wire rst,
    output wire [31:0] writedata,
    output wire [31:0] dataadr,
    output wire memwrite
  );

  wire [31:0] pc, instr, readdata;
  wire [31:0] pcnext, pcplus4, pctarget;
  wire [31:0] immext;
  wire [31:0] srca, srcb;
  wire [31:0] result;
  wire [31:0] aluout; // Internal ALU result before output assign

  // Control Signals
  wire [1:0] resultsrc;
  wire pcsrc, alusrc, regwrite, zero;
  wire [2:0] immsrc;
  wire [3:0] alucontrol;

  // DIY bullshit


  // Becuase me inventing a complicated way
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



  // PC Logic because idk
  muxN #(32,2) pcmux (
         .data({pctarget, pcplus4}),
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



  muxN #(32,2) srcbmux (
         .data({immext, writedata}),
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

  // Map internal/external signals
  assign dataadr = aluout;



  muxN #(32,3) resultmux (
         .data({pcplus4, readdata, aluout}),
         .s(resultsrc),
         .y(result)
       );




  // Instruction Memory
  inst_mem imem (
             .a(pc),
             .rd(instr)
           );

  // Data Memory
  data_mem dmem (
             .clk(clk),
             .we(memwrite),
             .a(dataadr),
             .wd(writedata),
             .rd(readdata)
           );

endmodule
