`timescale 1ns / 1ps

// Debounce a push button. You build this in four steps (see the README):
//   Step 1  THRESHOLD: clean = 1 only after the button has been 1 for a while
//   Step 2  count down instead of starting over (but never below 0)
//   Step 3  MAX: stop counting up at MAX
//   Step 4  synchronize the button before using it
module debounce #(
    parameter THRESHOLD = 100_000,    // 1 ms at 100 MHz
    parameter MAX       = 2**21 - 1   // about 21 ms at 100 MHz (step 3)
)(
    input      clk,
    input      noisy,
    output reg clean = 1'b0
);

    // Counter
    reg [31:0] count = 0;

    always @(posedge clk) begin
        // TODO: steps 1 to 4

        // PLACEHOLDER: no debouncing at all. Delete in step 1.
        clean <= noisy;
    end

endmodule
