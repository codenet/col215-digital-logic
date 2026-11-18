`timescale 1ns / 1ps

// Board wrapper for debounce: count BTNC presses.
//
//   CLK   (W5)   100 MHz
//   btnC  BTNC (U18)  the button to debounce
//   btnU  BTNU (T18)  clear the count
//   led[15]   LD15     the button as it is (no debouncing)
//   led[0]    LD0      clean, the debounced button
//   7-segment  number of presses: 0 -> 1 changes of clean
module debounce_top (
    input         CLK,
    input         btnC,
    input         btnU,
    output [15:0] led,
    output [0:6]  SSEG_CA,
    output [0:3]  SSEG_AN
);

    wire clean;

    debounce db (
        .clk(CLK),
        .noisy(btnC),
        .clean(clean)
    );

    assign led[15]   = btnC;
    assign led[14:1] = 14'b0;
    assign led[0]    = clean;

    press_display presses (
        .clk(CLK),
        .rst(btnU),
        .press(clean),
        .SSEG_CA(SSEG_CA),
        .SSEG_AN(SSEG_AN)
    );

endmodule
