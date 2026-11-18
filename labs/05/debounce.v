`timescale 1ns / 1ps

// Debouncer for a mechanical push button.
//
// When a button is pressed or released, its contact bounces for a few
// milliseconds, so the raw signal flips between 0 and 1 many times before
// settling. This module only lets a new value through once the input has
// held that value for STABLE_CYCLES clock cycles in a row.
//
//   btn_in   raw button (asynchronous, bouncy)
//   btn_out  clean, debounced level (synchronous to clk)
//
// With the 100 MHz Basys3 clock, the default of 1,000,000 cycles = 10 ms.
module debounce #(
    parameter STABLE_CYCLES = 1_000_000
)(
    input      clk,
    input      btn_in,
    output reg btn_out = 1'b0
);

    // Two flip-flop synchronizer: the button is not tied to clk, so pass it
    // through two registers before using it to avoid metastability.
    reg sync_0 = 1'b0;
    reg sync_1 = 1'b0;

    // TODO: on every rising edge of clk, shift btn_in into sync_0, and
    //       sync_0 into sync_1. Use sync_1 (not btn_in) everywhere below.
    always @(posedge clk) begin
        // TODO
    end

    // Count how long the input has disagreed with the current output.
    // Any bounce back to the old value resets the count.
    reg [$clog2(STABLE_CYCLES):0] count = 0;

    // TODO: on every rising edge of clk:
    //   - if sync_1 equals btn_out, nothing is changing: reset count to 0
    //   - else if count has reached STABLE_CYCLES - 1, the input has been
    //     steady long enough: copy sync_1 into btn_out and reset count
    //   - else increment count
    always @(posedge clk) begin
        // TODO

        // PLACEHOLDER: passes the raw button straight through with no
        // debouncing. Program the board like this first and press btnC a
        // few times: every bounce counts as a press, so the LED often
        // toggles more than once (or seems to ignore the press). Delete
        // this line once the logic above is written.
        btn_out <= btn_in;
    end

endmodule
