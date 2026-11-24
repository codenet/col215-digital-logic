`timescale 1ns / 1ps

// Show a 16-bit value as 4 hexadecimal digits on the four 7-segment
// displays. Segments and anodes are active low; segment[0] = a ... g.
module hex_display (
    input         clk,          // 100 MHz
    input  [0:15] value,
    output [0:6]  SSEG_CA,
    output [0:3]  SSEG_AN
);

    // Show one display at a time, fast enough that all four look lit
    // (each one for 2^16 cycles = 0.66 ms at 100 MHz)
    reg [17:0] refresh = 18'd0;
    always @(posedge clk)
        refresh <= refresh + 1'b1;
    wire [1:0] select = refresh[17:16];

    // AN0 (rightmost) shows the least significant digit
    wire [0:3] digit =
        (select == 2'd0) ? value[12:15] :
        (select == 2'd1) ? value[8:11]  :
        (select == 2'd2) ? value[4:7]   :
                           value[0:3];

    assign SSEG_CA =
        (digit == 4'h0) ? 7'b0000001 :
        (digit == 4'h1) ? 7'b1001111 :
        (digit == 4'h2) ? 7'b0010010 :
        (digit == 4'h3) ? 7'b0000110 :
        (digit == 4'h4) ? 7'b1001100 :
        (digit == 4'h5) ? 7'b0100100 :
        (digit == 4'h6) ? 7'b0100000 :
        (digit == 4'h7) ? 7'b0001111 :
        (digit == 4'h8) ? 7'b0000000 :
        (digit == 4'h9) ? 7'b0000100 :
        (digit == 4'hA) ? 7'b0001000 :
        (digit == 4'hB) ? 7'b1100000 :
        (digit == 4'hC) ? 7'b0110001 :
        (digit == 4'hD) ? 7'b1000010 :
        (digit == 4'hE) ? 7'b0110000 :
                          7'b0111000;   // F

    // SSEG_AN[0] = AN0 (rightmost display)
    assign SSEG_AN =
        (select == 2'd0) ? 4'b0111 :
        (select == 2'd1) ? 4'b1011 :
        (select == 2'd2) ? 4'b1101 :
                           4'b1110;
endmodule
