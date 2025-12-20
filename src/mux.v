module muxN #(
    parameter WIDTH = 32,
    parameter N = 4
  )(
    input wire [WIDTH*N-1:0] data,                 // flat packed input
    input wire [$clog2(N)-1:0] s,
    output wire [WIDTH-1:0] y
  );



  assign y = data[s*WIDTH +: WIDTH];


endmodule
