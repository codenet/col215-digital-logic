`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.10.2026 15:45:51
// Design Name: 
// Module Name: four_bit_adder
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


module four_bit_adder(
    input [0:3] a,
    input [0:3] b,
    output [0:3] s,
    output cout
    );
    
    wire c1, c2, c3;

    full_adder fa0 (
        .x(a[3]),
        .y(b[3]),
        .cin(1'b0),
        .s(s[3]),
        .cout(c1)
    );

    full_adder fa1 (
        .x(a[2]),
        .y(b[2]),
        .cin(c1),
        .s(s[2]),
        .cout(c2)
    );

    full_adder fa2 (
        .x(a[1]),
        .y(b[1]),
        .cin(c2),
        .s(s[1]),
        .cout(c3)
    );

    full_adder fa3 (
        .x(a[0]),
        .y(b[0]),
        .cin(c3),
        .s(s[0]),
        .cout(cout)
    );
endmodule
