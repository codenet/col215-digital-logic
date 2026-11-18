`timescale 1ns / 1ps

// Debounce a push button.
// clean only takes the new value after the button has stayed there for
// STABLE_CYCLES clk cycles.
module debounce #(
    parameter STABLE_CYCLES = 1_000_000  // 10 ms at 100 MHz
)(
    input      clk,
    input      noisy,
    output reg clean = 1'b0
);
    // Counter
    reg [31:0] count = 0;

    always @(posedge clk) begin
        // TODO 1a: if noisy == clean, reset the counter. Otherwise count up,
        // and when the counter reaches STABLE_CYCLES - 1, copy noisy into
        // clean and reset the counter.

        // PLACEHOLDER: no debouncing at all. Delete once the logic above works.
        clean <= noisy;
    end

endmodule
