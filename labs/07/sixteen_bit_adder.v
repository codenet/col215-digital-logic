`timescale 1ns / 1ps

// 16-bit ripple-carry adder: s = a + b, cout = carry out of the MSB.
//
// Bit ordering: vectors are declared [0:15], so index 0 is the MSB and
// index 15 is the LSB (same convention as four_bit_adder in Lab 4).
module sixteen_bit_adder(
    input  [0:15] a,
    input  [0:15] b,
    output [0:15] s,
    output        cout
    );

    // c[i] is the carry into bit i; c[16] = 0 is the carry into the LSB,
    // c[0] is the carry out of the MSB.
    wire [0:16] c;
    assign c[16] = 1'b0;
    assign cout  = c[0];

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : fa
            full_adder bit_i (
                .x(a[i]),
                .y(b[i]),
                .cin(c[i + 1]),
                .s(s[i]),
                .cout(c[i])
            );
        end
    endgenerate
endmodule
