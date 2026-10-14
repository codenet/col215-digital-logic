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

    // Pre-set the y input
    zero_negate pre_y (
        .in(y),
        .z(zy),
        .n(ny),
        .out(y_pre)
    );

    // Compute both candidate results
    assign and_out = x_pre & y_pre;

    four_bit_adder adder (
        .a(x_pre),
        .b(y_pre),
        .s(add_out),
        .cout()             // overflow / carry out is ignored
    );

    // f = 0 -> AND, f = 1 -> ADD
    mux2_4 select_f (
        .a(and_out),
        .b(add_out),
        .sel(f),
        .out(f_out)
    );

    // Post-set the output (never zeroed, only optionally negated)
    zero_negate post_out (
        .in(f_out),
        .z(1'b0),
        .n(no),
        .out(out)
    );

    // Status flags
    assign zr = ~(out[0] | out[1] | out[2] | out[3]);
    assign ng = out[0];
endmodule
