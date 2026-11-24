`timescale 1ns / 1ps

// 16-bit Hack ALU (Nisan & Schocken, "The Elements of Computing Systems",
// section 2.5.2, figures 2.5a-c). This is the Lab 4 ALU widened to 16 bits.
//
// x, y and out are 16-bit two's complement numbers (range -32768 .. 32767).
// Bit ordering: index 0 is the MSB (sign bit) and index 15 is the LSB.
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
//
// In the Hack CPU (figure 4.5), x is the D register and y is A (a = 0) or
// M (a = 1); the six comp bits c1..c6 are zx nx zy ny f no, in that order.
module alu(
    input  [0:15] x,
    input  [0:15] y,
    input         zx,
    input         nx,
    input         zy,
    input         ny,
    input         f,
    input         no,
    output [0:15] out,
    output        zr,
    output        ng
    );

    wire [0:15] x_pre, y_pre;   // inputs after zero / negate
    wire [0:15] and_out;        // x_pre & y_pre
    wire [0:15] add_out;        // x_pre + y_pre
    wire [0:15] f_out;          // result selected by f

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

    sixteen_bit_adder adder (
        .a(x_pre),
        .b(y_pre),
        .s(add_out),
        .cout()             // overflow / carry out is ignored
    );

    // f = 0 -> AND, f = 1 -> ADD
    mux2_16 select_f (
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
    assign zr = ~(|out);
    assign ng = out[0];
endmodule
