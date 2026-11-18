`timescale 1ns / 1ps

// 7-segment decoder (active-low segments, segment[0] = a ... segment[6] = g).
//   0000 - 1001 : digits 0 - 9
//   1111        : minus sign
//   anything else: blank
module ssd(
    input  [0:3] digit,
    output [0:6] segment
);

    assign segment =
        (digit == 4'b0000) ? 7'b0000001 : // 0
        (digit == 4'b0001) ? 7'b1001111 : // 1
        (digit == 4'b0010) ? 7'b0010010 : // 2
        (digit == 4'b0011) ? 7'b0000110 : // 3
        (digit == 4'b0100) ? 7'b1001100 : // 4
        (digit == 4'b0101) ? 7'b0100100 : // 5
        (digit == 4'b0110) ? 7'b0100000 : // 6
        (digit == 4'b0111) ? 7'b0001111 : // 7
        (digit == 4'b1000) ? 7'b0000000 : // 8
        (digit == 4'b1001) ? 7'b0000100 : // 9
        (digit == 4'b1111) ? 7'b1111110 : // minus sign (segment g only)
                              7'b1111111;  // blank
endmodule
