module inst_mem (
    input wire [31:0] a,
    output wire [31:0] rd
  );

  reg [31:0] RAM [0:255];

  // Memory initialization is handled by the testbench.

  assign rd = RAM[a[31:2]];

endmodule
