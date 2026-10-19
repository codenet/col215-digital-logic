`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.10.2026 15:45:51
// Design Name: 
// Module Name: bcd_adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bcd_adder(
    input  [0:3] a,
    input  [0:3] b,
    output [0:3] s,
    output       c
);

    wire [0:3] binary_sum;
    wire carry1;
    wire carry2;

    wire [0:3] correction;
    wire [0:3] corrected_sum;

    // First 4-bit addition
    four_bit_adder add1 (
        .a(a),
        .b(b),
        .s(binary_sum),
        .cout(carry1)
    );

    // Add 6 if binary result > 9 or carry occurred
    assign correction = carry1 || 
                        (binary_sum[0] && (binary_sum[1] || binary_sum[2]));

    // Correction is either 0000 or 0110
    wire [0:3] correction_value;
    assign correction_value = correction ? 4'b0110 : 4'b0000;

    // Add correction
    four_bit_adder add2 (
        .a(binary_sum),
        .b(correction_value),
        .s(s),
        .cout(carry2)
    );

    // BCD carry
    assign c = correction;

endmodule

