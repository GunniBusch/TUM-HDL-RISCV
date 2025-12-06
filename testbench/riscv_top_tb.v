


//s

module riscv_top_tb;

  // Parameters

  //Ports
  reg  clk;
  reg  rst;
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
    $dumpfile("riscv_test.vcd");
    $dumpvars(0, riscv_top_tb);

    // Load the hex file (testbench doing the heavy lifting per req 3.1)
    $readmemh("/Users/leonadomaitis/tum/hdl/TUM-HDL-RISCV/testbench/program.hex", dut.imem.RAM);

    // Let it rip
    #200;
    $finish; // nap time
  end
endmodule
