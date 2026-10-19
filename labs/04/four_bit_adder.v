`timescale 1ns / 1ps

// 4-bit ripple-carry adder (from Lab 3): s = a + b, cout = carry out of the MSB.
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

    full_adder fa0 (.x(a[3]), .y(b[3]), .cin(1'b0), .s(s[3]), .cout(c1));
    full_adder fa1 (.x(a[2]), .y(b[2]), .cin(c1),   .s(s[2]), .cout(c2));
    full_adder fa2 (.x(a[1]), .y(b[1]), .cin(c2),   .s(s[1]), .cout(c3));
    full_adder fa3 (.x(a[0]), .y(b[0]), .cin(c3),   .s(s[0]), .cout(cout));
endmodule
