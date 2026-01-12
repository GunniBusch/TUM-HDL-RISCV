module hazard_unit (
    input wire [4:0] rs1_e,
    input wire [4:0] rs2_e,
    input wire [4:0] rs1_d,
    input wire [4:0] rs2_d,
    input wire [4:0] rd_e,
    input wire [4:0] rd_m,
    input wire [4:0] rd_w,
    input wire reg_write_m,
    input wire reg_write_w,
    input wire result_src_e0, // 1 if load instruction in Execute
    input wire pc_src_e,      // Branch/Jump taken in Execute

    output reg [1:0] forward_a_e,
    output reg [1:0] forward_b_e,
    output wire stall_f,
    output wire stall_d,
    output wire flush_d,
    output wire flush_e
  );

  wire lw_stall;

  // Data Forwarding Logic (RAW Hazards)
  always @(*)
  begin
    forward_a_e = 2'b00;
    forward_b_e = 2'b00;

    // Forward A
    if ((rs1_e != 0) && (rs1_e == rd_m) && reg_write_m)
    begin
      forward_a_e = 2'b10; // Forward from Memory Stage
    end
    else if ((rs1_e != 0) && (rs1_e == rd_w) && reg_write_w)
    begin
      forward_a_e = 2'b01; // Forward from Writeback Stage
    end

    // Forward B
    if ((rs2_e != 0) && (rs2_e == rd_m) && reg_write_m)
    begin
      forward_b_e = 2'b10; // Forward from Memory Stage
    end
    else if ((rs2_e != 0) && (rs2_e == rd_w) && reg_write_w)
    begin
      forward_b_e = 2'b01; // Forward from Writeback Stage
    end
  end

  // Load-Use Data Hazard Detection
  // If instruction in Execute is Load (ResultSrcE0 == 1)
  // AND it writes to a register used by instruction in Decode
  assign lw_stall = result_src_e0 && ((rs1_d == rd_e) || (rs2_d == rd_e));

  // Stalling Logic
  assign stall_f = lw_stall;
  assign stall_d = lw_stall;

  // Flushing Logic
  // Flush Decode if branch is taken (Control Hazard)
  // Flush Execute if Load-Use Hazard (Stall D means we insert NOP in E)
  assign flush_d = pc_src_e;
  assign flush_e = lw_stall || pc_src_e;

endmodule
