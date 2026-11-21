`timescale 1ns/1ps

module int8_adder_clk (
    input                   clk,
    input      signed [7:0] a,
    input      signed [7:0] b,
    output reg signed [8:0] result
);

always @(posedge clk) begin
result <= a+b;
end

endmodule
