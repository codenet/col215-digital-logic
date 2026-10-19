`timescale 1ns / 1ps

// 4-bit Hack ALU (Nisan & Schocken, "The Elements of Computing Systems",
// section 2.5.2, figures 2.5a-c), scaled down from 16 bits to 4 bits.
//
// x, y and out are 4-bit two's complement numbers (range -8 .. 7).
// Bit ordering: index 0 is the MSB (sign bit) and index 3 is the LSB.
//
//   if (zx) x = 0          // zero the x input
//   if (nx) x = !x         // negate (bit-wise NOT) the x input
//   if (zy) y = 0          // zero the y input
//   if (ny) y = !y         // negate (bit-wise NOT) the y input
//   if (f)  out = x + y    // two's complement addition (overflow ignored)
//   else    out = x & y    // bit-wise AND
//   if (no) out = !out     // negate (bit-wise NOT) the output
//   zr = (out == 0)
//   ng = (out < 0)
module alu(
    input  [0:3] x,
    input  [0:3] y,
    input        zx,
    input        nx,
    input        zy,
    input        ny,
    input        f,
    input        no,
    output [0:3] out,
    output       zr,
    output       ng
    );

    wire [0:3] x_pre, y_pre;    // inputs after zero / negate
    wire [0:3] and_out;         // x_pre & y_pre
    wire [0:3] add_out;         // x_pre + y_pre
    wire [0:3] f_out;           // result selected by f

    // Pre-set the x input
    zero_negate pre_x (
        .in(x),
        .z(zx),
        .n(nx),
        .out(x_pre)
    );

    // TODO 3: Complete the datapath, following the block diagram in the
    //         README:
    //           a) pre_y:    a zero_negate for the y input (zy, ny) -> y_pre
    //           b) and_out:  bit-wise AND of x_pre and y_pre
    //           c) adder:    a four_bit_adder computing x_pre + y_pre -> add_out
    //                        (leave its cout unconnected: .cout() )
    //           d) select_f: a mux2_4 choosing and_out (f = 0) or
    //                        add_out (f = 1) -> f_out
    //           e) post_out: a zero_negate on f_out that never zeroes and
    //                        negates when no = 1 -> out
    //
    //         Do NOT use +, -, ?:, if or case.


    // TODO 4: Status flags. Using only &, |, ~ on the bits of out:
    //           zr = 1 exactly when out is 0000
    //           ng = 1 exactly when out is negative (two's complement)
    //
    // assign zr = ...;
    // assign ng = ...;
endmodule
