module rv_pl ( // keep this name as your top module of rv_mc core
    input wire clk, // keep this name: clk
    input wire rst_n // keep this name: rst_n, must be synchronized low-active reset
    // output wire [31:0] writedata,
    // output wire [31:0] dataadr,
    // output wire memwrite
    // Removed output ports to strictly follow instructions: "exact module name, IO port names... as below"
    // "io_input" also removed.
  );

  // =========================================================================
  // Wires and Registers Definition
  // =========================================================================

  // Reset Synchronization
  reg rst_sync_1;
  reg rst;

  always @(posedge clk)
  begin
    rst_sync_1 <= !rst_n;
    rst <= rst_sync_1; // Active-high synchronized reset
  end

  // Tie-off removed IO input
  wire [7:0] io_input = 8'b0;

  // Hazard Unit Signals
  wire stall_f, stall_d;
  wire flush_d, flush_e;
  wire [1:0] forward_a_e, forward_b_e;

  // --- Fetch Stage Signals ---
  wire [31:0] pc_f, pc_next_f, pc_plus4_f;
  wire [31:0] instr_f;

  // --- Decode Stage Signals ---
  reg [31:0] instr_d, pc_d, pc_plus4_d;
  wire [31:0] imm_ext_d;
  wire [31:0] rd1_d, rd2_d;
  wire [4:0] rs1_d, rs2_d, rd_d;

  // Control Signals Decoder Output
  wire reg_write_d, mem_write_d, alu_src_d, jump_d, branch_d;
  wire [1:0] result_src_d;
  wire [2:0] imm_src_d;
  wire [3:0] alu_control_d;

  // --- Execute Stage Signals ---
  reg reg_write_e, mem_write_e, alu_src_e, jump_e, branch_e;
  reg [1:0] result_src_e;
  reg [3:0] alu_control_e;
  reg [31:0] rd1_e, rd2_e, pc_e, imm_ext_e, pc_plus4_e;
  reg [4:0] rs1_e, rs2_e, rd_e;

  wire [31:0] src_a_e, src_b_e;    // After forwarding
  wire [31:0] src_b_imm_e;         // After immediate mux
  wire [31:0] alu_result_e;
  wire [31:0] write_data_e;        // Data to write to memory (from rd2)
  wire [31:0] pc_target_e;
  wire zero_e;
  wire pc_src_e; // Branch/Jump decision

  // --- Memory Stage Signals ---
  reg reg_write_m, mem_write_m;
  reg [1:0] result_src_m;
  reg [31:0] alu_result_m, write_data_m, pc_plus4_m;
  reg [4:0] rd_m;

  wire [31:0] read_data_m;
  wire [31:0] mem_read_data_internal;

  // --- Writeback Stage Signals ---
  reg reg_write_w;
  reg [1:0] result_src_w;
  reg [31:0] alu_result_w, read_data_w, pc_plus4_w;
  reg [4:0] rd_w;

  wire [31:0] result_w;

  // =========================================================================
  // Fetch Stage (F)
  // =========================================================================

  // PC Mux
  muxN #(32,2) pcmux (
         .data({pc_target_e, pc_plus4_f}), // Select Branch Target if pc_src_e is true
         .s(pc_src_e),
         .y(pc_next_f)
       );

  // PC Register
  reg [31:0] pc_current;
  assign pc_f = pc_current;

  // Note: Using 'rst' (synchronized active high) for internal logic reset
  always @(posedge clk) // Synchronous Reset
  begin
    if (rst)
    begin
      pc_current <= 0;
    end
    else if (!stall_f)
    begin
      pc_current <= pc_next_f;
    end
  end

  // Instruction Memory
  inst_mem IMEM ( // keep this name IMEM
             .a(pc_f),
             .rd(instr_f)
           );

  // PC Adder
  adder pcadd4 (
          .a(pc_f),
          .b(32'd4),
          .y(pc_plus4_f)
        );

  // =========================================================================
  // Pipeline Register: Fetch -> Decode (F/D)
  // =========================================================================
  always @(posedge clk)
  begin
    if (rst)
    begin // Reset
      instr_d <= 0;
      pc_d <= 0;
      pc_plus4_d <= 0;
    end
    else if (flush_d)
    begin // Flush
      instr_d <= 0;
      pc_d <= 0;
      pc_plus4_d <= 0;
    end
    else if (!stall_d)
    begin // Enable
      instr_d <= instr_f;
      pc_d <= pc_f;
      pc_plus4_d <= pc_plus4_f;
    end
  end

  // =========================================================================
  // Decode Stage (D)
  // =========================================================================

  assign rs1_d = (instr_d[6:0] == 7'b0110111) ? 5'd0 : instr_d[19:15]; // Force rs1=0 for LUI
  assign rs2_d = instr_d[24:20];
  assign rd_d  = instr_d[11:7];

  // Controller
  controller c (
               .op(instr_d[6:0]),
               .funct3(instr_d[14:12]),
               .funct7b5(instr_d[30]),
               .zero(1'b0), // Zero not used in Decode for Control generation
               // Control Outputs
               .resultsrc(result_src_d),
               .memwrite(mem_write_d),
               .pcsrc(), // Not used here, derived in Execute
               .alusrc(alu_src_d),
               .regwrite(reg_write_d),
               .jump(jump_d),
               .branch(branch_d),
               .immsrc(imm_src_d),
               .alucontrol(alu_control_d)
             );

  // Register File
  reg_file RF ( // keep this name RF
             .clk(clk),
             .we3(reg_write_w), // Writeback stage signal
             .a1(rs1_d),
             .a2(rs2_d),
             .a3(rd_w),         // Writeback stage destination
             .wd3(result_w),    // Writeback data
             .rd1(rd1_d),
             .rd2(rd2_d)
           );

  // Sign Extend
  sign_extend se (
                .instr(instr_d[31:7]),
                .immsrc(imm_src_d),
                .immext(imm_ext_d)
              );

  // =========================================================================
  // Pipeline Register: Decode -> Execute (D/E)
  // =========================================================================
  always @(posedge clk)
  begin
    if (rst || flush_e)
    begin
      reg_write_e <= 0;
      mem_write_e <= 0;
      result_src_e <= 0;
      alu_control_e <= 0;
      alu_src_e <= 0;
      jump_e <= 0;
      branch_e <= 0;

      rd1_e <= 0;
      rd2_e <= 0;
      pc_e <= 0;
      rs1_e <= 0;
      rs2_e <= 0;
      rd_e <= 0;
      imm_ext_e <= 0;
      pc_plus4_e <= 0;
      rs1_e <= 0;
      rs2_e <= 0;
    end
    else
    begin
      reg_write_e <= reg_write_d;
      mem_write_e <= mem_write_d;
      result_src_e <= result_src_d;
      alu_control_e <= alu_control_d;
      alu_src_e <= alu_src_d;
      jump_e <= jump_d;
      branch_e <= branch_d;

      rd1_e <= rd1_d;
      rd2_e <= rd2_d;
      pc_e <= pc_d;
      rs1_e <= rs1_d;
      rs2_e <= rs2_d;
      rd_e <= rd_d;
      imm_ext_e <= imm_ext_d;
      pc_plus4_e <= pc_plus4_d;
    end
  end

  // =========================================================================
  // Execute Stage (E)
  // =========================================================================

  // Forwarding Muxes
  // ForwardA
  muxN #(32,3) forward_a_mux (
         .data({alu_result_m, result_w, rd1_e}),
         .s(forward_a_e),
         .y(src_a_e)
       );

  // ForwardB (also gives WriteDataE)
  muxN #(32,3) forward_b_mux (
         .data({alu_result_m, result_w, rd2_e}),
         .s(forward_b_e),
         .y(write_data_e)
       );

  // ALU Source B Mux (Immediate vs Register)
  muxN #(32,2) srcb_mux (
         .data({imm_ext_e, write_data_e}),
         .s(alu_src_e),
         .y(src_b_imm_e)
       );

  // ALU
  alu alu (
        .srca(src_a_e),
        .srcb(src_b_imm_e),
        .alucontrol(alu_control_e),
        .aluresult(alu_result_e),
        .zero(zero_e)
      );

  // PC Target Adder
  adder pcaddbranch (
          .a(pc_e),
          .b(imm_ext_e),
          .y(pc_target_e)
        );

  // Branch/Jump Decision
  assign pc_src_e = (branch_e & zero_e) | jump_e;

  // =========================================================================
  // Pipeline Register: Execute -> Memory (E/M)
  // =========================================================================
  always @(posedge clk)
  begin
    if (rst)
    begin
      reg_write_m <= 0;
      mem_write_m <= 0;
      result_src_m <= 0;
      alu_result_m <= 0;
      write_data_m <= 0;
      rd_m <= 0;
      pc_plus4_m <= 0;
    end
    else
    begin
      reg_write_m <= reg_write_e;
      mem_write_m <= mem_write_e;
      result_src_m <= result_src_e;
      alu_result_m <= alu_result_e;
      write_data_m <= write_data_e;
      rd_m <= rd_e;
      pc_plus4_m <= pc_plus4_e;
    end
  end

  // =========================================================================
  // Memory Stage (M)
  // =========================================================================

  // MMIO Read Logic
  assign read_data_m = (alu_result_m == 32'hFFFFF004) ? {24'b0, io_input} : mem_read_data_internal;

  // Data Memory
  data_mem DMEM ( // keep this name DMEM
             .clk(clk),
             .we(mem_write_m),
             .a(alu_result_m),
             .wd(write_data_m),
             .rd(mem_read_data_internal)
           );

  // =========================================================================
  // Pipeline Register: Memory -> Writeback (M/W)
  // =========================================================================
  always @(posedge clk)
  begin
    if (rst)
    begin
      reg_write_w <= 0;
      result_src_w <= 0;
      alu_result_w <= 0;
      read_data_w <= 0;
      rd_w <= 0;
      pc_plus4_w <= 0;
    end
    else
    begin
      reg_write_w <= reg_write_m;
      result_src_w <= result_src_m;
      alu_result_w <= alu_result_m;
      read_data_w <= read_data_m;
      rd_w <= rd_m;
      pc_plus4_w <= pc_plus4_m;
    end
  end

  // =========================================================================
  // Writeback Stage (W)
  // =========================================================================

  // Result Mux
  muxN #(32,3) result_mux (
         .data({pc_plus4_w, read_data_w, alu_result_w}),
         .s(result_src_w),
         .y(result_w)
       );

  // =========================================================================
  // Hazard Unit Instantiation
  // =========================================================================
  hazard_unit hu (
                .rs1_d(rs1_d),
                .rs2_d(rs2_d),
                .rs1_e(rs1_e),
                .rs2_e(rs2_e),
                .rd_e(rd_e),
                .rd_m(rd_m),
                .rd_w(rd_w),
                .reg_write_m(reg_write_m),
                .reg_write_w(reg_write_w),
                .result_src_e0(result_src_e[0]),
                .pc_src_e(pc_src_e),

                .forward_a_e(forward_a_e),
                .forward_b_e(forward_b_e),
                .stall_f(stall_f),
                .stall_d(stall_d),
                .flush_d(flush_d),
                .flush_e(flush_e)
              );

endmodule
