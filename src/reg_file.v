module reg_file (
    input wire clk,
    input wire we3,
    input wire [4:0] a1,
    input wire [4:0] a2,
    input wire [4:0] a3,
    input wire [31:0] wd3,
    output wire [31:0] rd1,
    output wire [31:0] rd2
  );

  reg [31:0] rf [31:0];

  // Initialize register 0 to 0


  // Asynchronous read
  // Write-through forwarding (Bypass)
  // If reading the same register being written in the same cycle, returns the new data
  assign rd1 = (a1 == 0) ? 32'b0 :
         ((a3 == a1) && we3) ? wd3 : rf[a1];

  assign rd2 = (a2 == 0) ? 32'b0 :
         ((a3 == a2) && we3) ? wd3 : rf[a2];

  // Synchronous write
  always @(posedge clk)
  begin
    if (we3 && a3 != 0)
    begin
      rf[a3] <= wd3;
    end
  end

endmodule
