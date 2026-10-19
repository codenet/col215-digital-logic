`timescale 1ns / 1ps

// Zero / negate unit. Applies two micro-actions to a 4-bit value, in order:
//   if (z == 1) then in  = 0       (zero)
//   if (n == 1) then out = !in     (bit-wise NOT)
module zero_negate(
    input  [0:3] in,
    input        z,
    input        n,
    output [0:3] out
    );
    
    // TODO 1: Implement the two micro-actions with continuous assignments,
    //         using only the bitwise operators &, |, ^, ~.
    //
    //         Hint: first work out a 1-bit version. Which gate passes a bit
    //         through when a control signal is 0 and forces it to 0 when the
    //         control is 1? Which gate passes a bit through when the control
    //         is 0 and inverts it when the control is 1?
    //
    //         To apply a 1-bit signal to all 4 bits at once, use replication:
    //         {4{z}} is the 4-bit vector {z, z, z, z}.
    //
    //         Do NOT use ?:, if, case, or any arithmetic operator.


    // wire [0:3] zeroed;
    // assign zeroed = ...;
    // assign out    = ...;

endmodule
