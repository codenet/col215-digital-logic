`timescale 1ns / 1ps

// Board wrapper for the 4-bit ALU.
//
//   x[0:3]    SW3 (MSB) .. SW0 (LSB)
//   y[0:3]    SW15 (MSB) .. SW12 (LSB)
//   ctrl[0:5] SW9 .. SW4  =  zx nx zy ny f no  (same order as figure 2.5b)
//
//   out_led[0:3]  LD3 (MSB) .. LD0 (LSB)  raw output bits
//   zr_led        LD15
//   ng_led        LD14
//   7-segment     out as a signed decimal: sign on AN1, magnitude on AN0
module top(
    input  [0:3] x,
    input  [0:3] y,
    input  [0:5] ctrl,
    input        CLK,
    output [0:3] out_led,
    output       zr_led,
    output       ng_led,
    output [0:3] SSEG_AN,
    output [0:6] SSEG_CA
);

    wire [0:3] out;
    wire zr, ng;

    alu dut (
        .x(x),
        .y(y),
        .zx(ctrl[0]),
        .nx(ctrl[1]),
        .zy(ctrl[2]),
        .ny(ctrl[3]),
        .f(ctrl[4]),
        .no(ctrl[5]),
        .out(out),
        .zr(zr),
        .ng(ng)
    );

    assign out_led = out;
    assign zr_led  = zr;
    assign ng_led  = ng;

    // Magnitude of the two's complement result (0 .. 8)
    wire [0:3] magnitude;
    assign magnitude = out[0] ? (~out + 4'b0001) : out;

    // Clock divider / counter
    reg [19:0] counter = 20'b0;

    always @(posedge CLK) begin
        counter <= counter + 1'b1;
    end

    // Alternate between the two displays fast enough that both look lit
    wire select;
    assign select = counter[15];

    // 1111 shows a minus sign, 1110 is blank (see ssd.v)
    wire [0:3] digit;
    assign digit = select ? magnitude : (out[0] ? 4'b1111 : 4'b1110);

    ssd display (
        .digit(digit),
        .segment(SSEG_CA)
    );

    // Active-low anodes, SSEG_AN[0] = AN0 (rightmost display)
    assign SSEG_AN = select ? 4'b0111 : 4'b1011;

endmodule
