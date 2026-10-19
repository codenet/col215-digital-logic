`timescale 1ns / 1ps

// Zero / negate unit. Applies two micro-actions to a 4-bit value, in order:
//   if (z == 1) then in  = 0       (zero)
//   if (n == 1) then out = !in     (bit-wise NOT)
//
// The ALU uses three copies of this module:
//   x input:  z = zx, n = nx
//   y input:  z = zy, n = ny
//   output:   z = 0,  n = no
module zero_negate(
    input  [0:3] in,
    input        z,
    input        n,
    output [0:3] out
    );

    wire [0:3] zeroed;

    // AND every bit with ~z: passes 'in' when z = 0, forces 0000 when z = 1.
    assign zeroed = in & {4{~z}};

    // XOR every bit with n: passes 'zeroed' when n = 0, inverts it when n = 1.
    assign out = zeroed ^ {4{n}};
endmodule
