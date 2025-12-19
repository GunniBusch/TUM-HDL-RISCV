module rv_mc_tb;

  reg clk = 0;
  reg rst = 1;

  // Performance Counters
  integer cycles = 0;
  integer instructions = 0;

  // Instantiate the Multi-Cycle Processor
  rv_mc dut (
          .clk(clk),
          .rst(rst)
        );

  // Clock Generation
  always #5 clk = !clk;

  // Cycle Counter
  always @(posedge clk)
  begin
    cycles = cycles + 1;
    if (dut.we_ir)
    begin // Count instruction fetch
      instructions = instructions + 1;
    end
  end

  // Reset Logic & Simulation
  initial
  begin
    rst = 1;
    #10 rst = 0;
  end

  // Simulation Control & Memory loading
  initial
  begin
    $dumpfile("rv_mc_test.vcd");
    $dumpvars(0, rv_mc_tb);

    // Load Program into Unified Memory Check NO initial block in mem.v!
    $readmemh("testbench/program_simple.hex", dut.MEM.RAM);
    // $readmemh("testbench/program.hex", dut.MEM.RAM); // Full test

    // Run simulation
    #5000;

    $display("\n\n--------------------\n\n");
    $display("--- Performance Metrics ---");
    $display("Total Cycles: %d", cycles);
    $display("Total Instructions: %d", instructions);
    $display("CPI: %f", (instructions > 0) ? $itor(cycles)/instructions : 0.0);

    $display("\n--- Final Register State ---");
    // Access internal Register File via hierarchy
    $display("x1 (10): %d", dut.rf.rf[1]);
    $display("x2 (20): %d", dut.rf.rf[2]);
    $display("x3 (30): %d", dut.rf.rf[3]);
    $display("x4: %d", dut.rf.rf[4]);
    $display("------------------------");

    $finish;
  end

  // Debug Prints
  always @(posedge clk)
  begin
    if (dut.we_rf)
    begin
      $display("RegWrite at Time %t: Data=%h", $time, dut.result);
    end
    if (dut.we_pc)
    begin
      //$display("PCUpdate at Time %t: PC=%h", $time, dut.result);
    end
  end

endmodule
