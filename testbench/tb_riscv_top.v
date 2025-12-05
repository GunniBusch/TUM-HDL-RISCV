module tb_riscv_top;

  reg clk;
  reg rst;
  wire [31:0] writedata;
  wire [31:0] dataadr;
  wire memwrite;

  riscv_top dut (
              .clk(clk),
              .rst(rst),
              .writedata(writedata),
              .dataadr(dataadr),
              .memwrite(memwrite)
            );

  initial
  begin
    clk = 0;
    forever
      #5 clk = ~clk;
  end

  initial
  begin
    $dumpfile("riscv_test.vcd");
    $dumpvars(0, tb_riscv_top);
    // Reset
    rst = 1;
    #22;
    rst = 0;

    // Load the hex file (testbench doing the heavy lifting per req 3.1)
    $readmemh("../program.hex", dut.imem.RAM);

    // Let it rip
    #200;

    $finish; // nap time
  end

endmodule
