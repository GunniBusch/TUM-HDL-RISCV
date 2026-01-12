module data_mem #(
    parameter MEM_DEPTH = 256
  ) (
    input wire clk,
    input wire we,
    input wire [31:0] a,
    input wire [31:0] wd,
    output wire [31:0] rd
  );

  reg [31:0] RAM [0 : MEM_DEPTH-1]; // Verified array name is RAM

  // Combinational read
  assign rd = RAM[a[31:2]];

  // Synchronous write
  always @(posedge clk)
  begin
    if (we)
    begin
      RAM[a[31:2]] <= wd;
    end
  end

endmodule
