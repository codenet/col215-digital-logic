`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.10.2026 15:53:40
// Design Name: 
// Module Name: ssd
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
                              7'b1111111;  // invalid ? OFF
endmodule
