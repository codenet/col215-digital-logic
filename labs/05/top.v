`timescale 1ns / 1ps

// Toggle a light with the center button.
//
//   btnC  BTNC (U18)  center push button
//   led   LD0  (U16)  flips every time btnC is pressed
//
// The button is debounced first, then we look for its rising edge
// (0 -> 1) so that one press toggles the LED exactly once, no matter
// how long the button is held down.
module top #(
    parameter STABLE_CYCLES = 1_000_000
)(
    input      CLK,
    input      btnC,
    output reg led = 1'b0
);

    wire btn_clean;

    debounce #(
        .STABLE_CYCLES(STABLE_CYCLES)
    ) db (
        .clk(CLK),
        .btn_in(btnC),
        .btn_out(btn_clean)
    );

    // Remember last cycle's value to detect the press (rising edge)
    reg btn_prev = 1'b0;
    wire pressed;
    assign pressed = btn_clean & ~btn_prev;

    always @(posedge CLK) begin
        if (pressed)
            led <= ~led;
        btn_prev <= btn_clean;
    end

endmodule
