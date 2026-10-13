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

    // TODO 2: Write the truth table of a 1-bit 2-to-1 mux (a, b, sel -> out),
    //         derive a simplified Boolean expression, and apply it to all
    //         4 bits with one continuous assignment.
    //
    //         Use only &, |, ^, ~ and replication ({4{sel}}).
    //         Do NOT use ?:, if or case.
    //
    // assign out = ...;
endmodule
