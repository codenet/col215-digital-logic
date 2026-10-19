`timescale 1ns / 1ps

// 4-bit 2-to-1 multiplexer:
//   sel = 0  ->  out = a
//   sel = 1  ->  out = b
module mux2_4(
    input  [0:3] a,
    input  [0:3] b,
    input        sel,
    output [0:3] out
    );

    // Each bit is the 1-bit mux  out = (a & ~sel) | (b & sel).
    assign out = (a & {4{~sel}}) | (b & {4{sel}});
endmodule
