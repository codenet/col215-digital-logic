`timescale 1ns / 1ps

// Debounce a push button.
// A counter goes up while the button is 1 and down while it is 0, and stops
// at 0 and at MAX. clean is 1 while the counter is above THRESHOLD.
module debounce #(
    parameter THRESHOLD = 100_000,    // 1 ms at 100 MHz
    parameter MAX       = 2**21 - 1   // about 21 ms at 100 MHz
)(
    input      clk,
    input      noisy,
    output reg clean = 1'b0
);

    // Bring the button into the clk domain (given). Use only s1 below.
    reg s0 = 1'b0, s1 = 1'b0;

    // Counter
    reg [31:0] count = 0;

    always @(posedge clk) begin
        s0 <= noisy;
        s1 <= s0;

        // TODO 1a: if s1 is 1, count up, but not past MAX. If s1 is 0, count
        // down, but not below 0. Then set clean to 1 if count is above
        // THRESHOLD, and to 0 otherwise.

        // PLACEHOLDER: no debouncing at all. Delete once the logic above works.
        clean <= s1;
    end

endmodule
