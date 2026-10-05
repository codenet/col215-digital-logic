`timescale 1ns / 1ps

// 4-bit ripple-carry adder: s = a + b, cout = carry out of the MSB.
//
// Bit ordering: vectors are declared [0:3], so index 0 is the MSB and
// index 3 is the LSB. For example a = 4'b0011 means a[0]=0 ... a[3]=1.
module four_bit_adder(
    input [0:3] a,
    input [0:3] b,
    output [0:3] s,
    output cout
    );

    // Internal carries: c1 goes from bit 3 -> bit 2, c2 from 2 -> 1, c3 from 1 -> 0
    wire c1, c2, c3;

    // Least significant bit. There is no carry in to this adder, so cin = 0.
    full_adder fa0 (
        .x(a[3]),
        .y(b[3]),
        .cin(1'b0),
        .s(s[3]),
        .cout(c1)
    );

    // TODO 2: Instantiate three more full_adders (fa1, fa2, fa3) for
    //         bits 2, 1 and 0. Each stage's cin is the previous stage's
    //         cout. The cout of the MSB stage (fa3) drives the module's cout.
    //
    //         Do NOT use the + operator.
endmodule
