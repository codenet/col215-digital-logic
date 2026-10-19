`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.10.2026 15:57:24
// Design Name: 
// Module Name: top
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


module top(
    input  [0:3] a,
    input  [0:3] b,
    input        CLK,
    output [0:3] SSEG_AN,
    output [0:6] SSEG_CA
);

    // BCD addition result
    wire [0:3] sum;
    wire carry;

    bcd_adder add (
        .a(a),
        .b(b),
        .s(sum),
        .c(carry)
    );

    // Clock divider / counter
    reg [19:0] counter = 20'b0;

    always @(posedge CLK) begin
        counter <= counter + 1'b1;
    end

    // Select which SSD is active
    // Use one counter bit as the multiplexing clock
    wire select;
    assign select = counter[15];

    // BCD digit to display
    // carry = tens digit (0 or 1)
    wire [0:3] digit;

    assign digit = select ? sum : {3'b000, carry};

    // Seven-segment decoder
    ssd display (
        .digit(digit),
        .segment(SSEG_CA)
    );

    // Active-low anodes
    // Only one display is enabled at a time
    assign SSEG_AN = select ? 4'b1101 : 4'b1110;

endmodule
