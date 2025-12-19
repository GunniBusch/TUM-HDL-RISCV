module mem (
    input wire clk,
    input wire we,
    input wire [31:0] a,
    input wire [31:0] wd,
    output wire [31:0] rd
  );

  parameter MEM_DEPTH = 256;
  reg [31:0] RAM [0 : MEM_DEPTH-1]; // Keep this name: RAM

  // Check: NO initial block here!

  // Combinational Read (Asynchronous)
  assign rd = RAM[a[31:2]];

  // Synchronous Write
  always @(posedge clk)
  begin
    if (we)
    begin
      RAM[a[31:2]] <= wd;
    end
  end

endmodule
