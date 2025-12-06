


//s

module riscv_top_tb;

  // Parameters

  //Ports
  reg  clk = 0;
  reg  rst = 1;
  wire [31:0] writedata;
  wire [31:0] dataadr;
  wire  memwrite;

  riscv_top dut (
              .clk(clk),
              .rst(rst),
              .writedata(writedata),
              .dataadr(dataadr),
              .memwrite(memwrite)
            );

  always #5  clk = ! clk ;




  initial
  begin
    rst = 1;
    #10 rst = 0;
  end

  initial
  begin
    $dumpfile("riscv_test.vcd");
    $dumpvars(0, riscv_top_tb);

    // Load the hex file
    $readmemh("/Users/leonadomaitis/tum/hdl/TUM-HDL-RISCV/testbench/program.hex", dut.imem.RAM);

    // Run simulation
    #500; // Increased to ensure program completes

    $display("--- Final Register State ---");
    $display("x1 (10): %d", dut.rf.rf[1]);
    $display("x2 (20): %d", dut.rf.rf[2]);
    $display("x3 (30): %d", dut.rf.rf[3]);
    $display("x4 (10): %d", dut.rf.rf[4]);
    $display("x5 (0):  %d", dut.rf.rf[5]);
    $display("x6 (30): %d", dut.rf.rf[6]);
    $display("x7 (30): %d", dut.rf.rf[7]);
    $display("x8 (-5): %d", $signed(dut.rf.rf[8]));
    $display("x9 (5):  %d", dut.rf.rf[9]);
    $display("x18 (4096): %d", dut.rf.rf[18]);
    $display("x19 (4097): %d", dut.rf.rf[19]);
    $display("x20 (4097): %d", dut.rf.rf[20]);
    $display("------------------------");

    $finish;
  end
endmodule
