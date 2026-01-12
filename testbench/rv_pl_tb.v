module rv_pl_tb;

  reg  clk = 0;
  reg  rst_n = 0; // Active low reset start at 0

  // Instance of pipeline processor
  rv_pl dut (
          .clk(clk),
          .rst_n(rst_n)
        );

  always #5  clk = ! clk;

  initial
  begin
    rst_n = 0;
    #12 rst_n = 1; // Release reset
  end

  initial
  begin
    $dumpfile("rv_pl_test.vcd");
    $dumpvars(0, rv_pl_tb);

    // Initialize Memory Hierarchically
    $readmemh("/Users/leonadomaitis/tum/hdl/TUM-HDL-RISCV/testbench/program.hex", dut.IMEM.RAM);

    // Run simulation
    #5000;

    $display("\n\n--------------------\n\n");
    $display("--- Final Register State ---");
    // Access registers hierarchically: dut.RF.rf
    $display("x1 (10): %d", dut.RF.rf[1]);
    $display("x2 (20): %d", dut.RF.rf[2]);
    $display("x3 (30): %d", dut.RF.rf[3]);
    $display("x4 (10): %d", dut.RF.rf[4]);
    $display("x5 (0):  %d", dut.RF.rf[5]);
    $display("x6 (30): %d", dut.RF.rf[6]);
    $display("x7 (30): %d", dut.RF.rf[7]);
    $display("x8 (-5): %d", $signed(dut.RF.rf[8]));
    $display("x9 (5):  %d", dut.RF.rf[9]);
    $display("x10 (1): %d", dut.RF.rf[10]);
    $display("x11 (0): %d", dut.RF.rf[11]);
    $display("x12 (1): %d", dut.RF.rf[12]);
    $display("x13 (16): %d", dut.RF.rf[13]);
    $display("x14 (4): %d", dut.RF.rf[14]);
    // x15 was overwritten/used for SRA
    $display("x16 (-4): %d", $signed(dut.RF.rf[16]));
    $display("x17 (>0): %d", dut.RF.rf[17]);
    $display("x18 (4096): %d", dut.RF.rf[18]);
    $display("x19 (4097): %d", dut.RF.rf[19]);
    $display("x20 (4097): %d", dut.RF.rf[20]);
    // Logic/Set check
    $display("x24 (0): %d", dut.RF.rf[24]);
    $display("x25 (1): %d", dut.RF.rf[25]);
    $display("x26 (2): %d", dut.RF.rf[26]);
    $display("x27 (1): %d", dut.RF.rf[27]);
    $display("x28 (0): %d", dut.RF.rf[28]);
    // Reg Shifts
    $display("x30 (2): %d", dut.RF.rf[30]);
    $display("x31 (8): %d", dut.RF.rf[31]);
    $display("x21 (0): %d", dut.RF.rf[21]); // Should be 0 (skipped)
    $display("x23 (173): %d", dut.RF.rf[23]); // Should be 173 (executed after jump)
    $display("------------------------");

    $finish;
  end

endmodule
