module inst_mem #(
    parameter MEM_DEPTH = 256
  ) (
    input wire [31:0] a,
    output wire [31:0] rd
  );

  reg [31:0] RAM [0 : MEM_DEPTH-1]; // Verified array name is RAM

  // Memory initialization is handled by the testbench.

  assign rd = RAM[a[31:2]];

endmodule
