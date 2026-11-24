`timescale 1ns / 1ps

// 16-bit 2-to-1 multiplexer:
//   sel = 0  ->  out = a
//   sel = 1  ->  out = b
module mux2_16(
    input  [0:15] a,
    input  [0:15] b,
    input         sel,
    output [0:15] out
    );

    // Each bit is the 1-bit mux  out = (a & ~sel) | (b & sel).
    assign out = (a & {16{~sel}}) | (b & {16{sel}});
endmodule
