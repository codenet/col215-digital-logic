`timescale 1ns / 1ps

// One-digit BCD adder: adds two BCD digits a, b (each 0-9).
//   s = units digit of a + b (BCD, 0-9)
//   c = tens digit of a + b (0 or 1)
// Example: a = 7, b = 5 -> 12 -> c = 1, s = 4'b0010.
//
// Bit ordering: index 0 is the MSB, index 3 is the LSB (see four_bit_adder.v).
module bcd_adder(
    input  [0:3] a,
    input  [0:3] b,
    output [0:3] s,
    output       c
);

    // TODO 3: Design the BCD adder. Work through the truth table and the
    //         questions in README.md before writing any code.
    //
    //         Build it from your four_bit_adder (as many instances as you
    //         need) and logic gates. Do NOT use +, -, <, >, / or %, and do
    //         NOT write the truth table as a case/if lookup.

endmodule
