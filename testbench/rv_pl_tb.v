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
    $display("x18 (4096): %d", dut.RF.rf[18]);
    $display("x19 (4097): %d", dut.RF.rf[19]);
    $display("x20 (4097): %d", dut.RF.rf[20]);
    $display("------------------------");

    $finish;
  end

endmodule
