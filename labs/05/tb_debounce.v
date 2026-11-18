`timescale 1ns / 1ps

// Self-checking testbench for debounce.
//
// THRESHOLD is 5 and MAX is 20 here, instead of 1 ms and 21 ms, so the test
// is short. noisy changes on the falling edge of clk.
//
// From a count of 0, a steady press reaches clean = 1 after THRESHOLD + 4
// clk edges (2 for the synchronizer, THRESHOLD + 1 to count past THRESHOLD,
// 1 for the clean register). From MAX, a steady release reaches clean = 0
// after MAX - THRESHOLD + 3 edges.
//
// Test 1: short pulses (up to THRESHOLD cycles) must not change clean.
// Test 2: a bouncy press must make clean go to 1 exactly once.
// Test 3: while the button is held, clean must stay 1.
// Test 4: a short drop while held (less than MAX - THRESHOLD) is ignored.
// Test 5: a bouncy release must make clean go to 0 exactly once.
module tb_debounce;

    localparam THRESHOLD = 5;
    localparam MAX       = 20;

    reg  clk   = 1'b0;
    reg  noisy = 1'b0;
    wire clean;

    debounce #(.THRESHOLD(THRESHOLD), .MAX(MAX)) dut (
        .clk(clk),
        .noisy(noisy),
        .clean(clean)
    );

    always #5 clk = ~clk;  // 100 MHz

    integer errors  = 0;
    integer changes = 0;  // times clean changed
    integer e0;           // errors at the start of a test

    always @(clean) if ($time > 0) changes = changes + 1;

    // Set noisy to b on the next falling edge, and keep it for n cycles
    task hold(input b, input integer n);
        begin
            @(negedge clk); noisy = b;
            repeat (n - 1) @(negedge clk);
        end
    endtask

    // Check that clean is b
    task check(input b, input [8*40-1:0] what);
        begin
            if (clean !== b) begin
                $display("FAIL: %0s: clean=%b, expected %b (at %0d ns)",
                         what, clean, b, $time);
                errors = errors + 1;
            end
        end
    endtask

    // Check that clean changed exactly n times since changes was cleared
    task check_changes(input integer n, input [8*40-1:0] what);
        begin
            if (changes != n) begin
                $display("FAIL: %0s: clean changed %0d times, expected %0d",
                         what, changes, n);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // Idle
        repeat (10) @(negedge clk);
        check(1'b0, "idle");

        // Test 1: pulses of 1 to THRESHOLD cycles, each followed by a long
        // gap so the count goes back to 0
        changes = 0; e0 = errors;
        hold(1, 1); hold(0, 10);
        hold(1, 2); hold(0, 10);
        hold(1, 3); hold(0, 10);
        hold(1, 4); hold(0, 10);
        hold(1, 5); hold(0, 10);
        check(1'b0, "test 1: short pulses");
        check_changes(0, "test 1: short pulses");
        if (errors == e0) $display("Test 1: short pulses ignored");

        // Test 2: bouncy press, then held. clean must be 1 at the latest
        // THRESHOLD + 4 edges after the bouncing stops.
        changes = 0; e0 = errors;
        hold(1, 2); hold(0, 1); hold(1, 3); hold(0, 2); hold(1, 1); hold(0, 1);
        @(negedge clk); noisy = 1'b1;
        repeat (THRESHOLD + 4) @(posedge clk);
        #1 check(1'b1, "test 2: press too slow");
        check_changes(1, "test 2: one press");
        if (errors == e0) $display("Test 2: one press, clean went to 1 once");

        // Test 3: keep holding, long enough for the count to reach MAX
        changes = 0; e0 = errors;
        repeat (2 * MAX) @(negedge clk);
        check(1'b1, "test 3: held");
        check_changes(0, "test 3: held");
        if (errors == e0) $display("Test 3: clean stays 1 while held");

        // Test 4: drop to 0 for less than MAX - THRESHOLD cycles while held
        changes = 0; e0 = errors;
        hold(0, MAX - THRESHOLD - 5);
        hold(1, 2 * MAX);
        check(1'b1, "test 4: short drop");
        check_changes(0, "test 4: short drop");
        if (errors == e0) $display("Test 4: short drop while held ignored");

        // Test 5: bouncy release. clean must be 0 at the latest
        // MAX - THRESHOLD + 3 edges after the bouncing stops.
        changes = 0; e0 = errors;
        hold(0, 1); hold(1, 2); hold(0, 3); hold(1, 1); hold(0, 4); hold(1, 1);
        @(negedge clk); noisy = 1'b0;
        repeat (MAX - THRESHOLD + 3) @(posedge clk);
        #1 check(1'b0, "test 5: release too slow");
        repeat (2 * MAX) @(negedge clk);
        check_changes(1, "test 5: one release");
        if (errors == e0) $display("Test 5: one release, clean went to 0 once");

        if (errors == 0)
            $display("tb_debounce: ALL TESTS PASSED");
        else
            $display("tb_debounce: %0d TESTS FAILED", errors);
        $finish;
    end

endmodule
