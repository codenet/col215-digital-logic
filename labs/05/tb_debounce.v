`timescale 1ns / 1ps

// Self-checking testbench for debounce.
//
// STABLE_CYCLES is 5 here instead of 1 000 000, so a button must stay the
// same for 5 clk cycles before clean follows it. noisy changes on the
// falling edge of clk, like a button that is not synchronized to clk.
//
// Test 1: short pulses (1 to 4 cycles) must not change clean.
// Test 2: a bouncy press must make clean go to 1 exactly once, on the
//         5th clk edge after the bouncing stops.
// Test 3: while the button is held, clean must stay 1.
// Test 4: a bouncy release must make clean go to 0 exactly once, on the
//         5th clk edge after the bouncing stops.
module tb_debounce;

    localparam STABLE = 5;

    reg  clk   = 1'b0;
    reg  noisy = 1'b0;
    wire clean;

    debounce #(.STABLE_CYCLES(STABLE)) dut (
        .clk(clk),
        .noisy(noisy),
        .clean(clean)
    );

    always #5 clk = ~clk;  // 100 MHz

    integer errors  = 0;
    integer changes = 0;  // times clean changed

    always @(clean) if ($time > 0) changes = changes + 1;

    // Set noisy to b on the next falling edge, and keep it for n cycles
    task hold(input b, input integer n);
        begin
            @(negedge clk); noisy = b;
            repeat (n - 1) @(negedge clk);
        end
    endtask

    // Check that clean is b (just after a rising edge)
    task check(input b, input [8*40-1:0] what);
        begin
            if (clean !== b) begin
                $display("FAIL: %0s: clean=%b, expected %b (at %0d ns)",
                         what, clean, b, $time);
                errors = errors + 1;
            end
        end
    endtask

    // Set noisy to b and leave it there. clean must still be the old value
    // after STABLE - 1 rising edges, and be b after STABLE rising edges.
    task settle(input b, input [8*40-1:0] what);
        begin
            @(negedge clk); noisy = b;
            repeat (STABLE - 1) @(posedge clk);
            #1 check(!b, {what, " too early"});
            @(posedge clk);
            #1 check(b, {what, " too late"});
        end
    endtask

    initial begin
        // Idle
        repeat (10) @(negedge clk);
        check(1'b0, "idle");

        // Test 1: pulses shorter than STABLE, with gaps of 1 and 2 cycles.
        // Every 0 must restart the count.
        changes = 0;
        hold(1, 1); hold(0, 2);
        hold(1, 2); hold(0, 2);
        hold(1, 3); hold(0, 1);
        hold(1, 4); hold(0, 1);
        hold(1, 4); hold(0, 1);
        hold(1, 4); hold(0, 10);
        check(1'b0, "test 1: short pulses");
        if (changes != 0) begin
            $display("FAIL: test 1: clean changed %0d times on short pulses, expected 0",
                     changes);
            errors = errors + 1;
        end else
            $display("Test 1: short pulses ignored");

        // Test 2: bouncy press
        changes = 0;
        hold(1, 2); hold(0, 1); hold(1, 3); hold(0, 2); hold(1, 1); hold(0, 1);
        settle(1, "test 2: press");
        if (changes != 1) begin
            $display("FAIL: test 2: clean changed %0d times on one press, expected 1",
                     changes);
            errors = errors + 1;
        end else
            $display("Test 2: one press, clean went to 1 once");

        // Test 3: hold the button
        changes = 0;
        repeat (20) @(negedge clk);
        check(1'b1, "test 3: held");
        if (changes != 0) begin
            $display("FAIL: test 3: clean changed %0d times while held, expected 0",
                     changes);
            errors = errors + 1;
        end else
            $display("Test 3: clean stays 1 while held");

        // Test 4: bouncy release
        changes = 0;
        hold(0, 1); hold(1, 2); hold(0, 3); hold(1, 1); hold(0, 4); hold(1, 1);
        settle(0, "test 4: release");
        repeat (10) @(negedge clk);
        if (changes != 1) begin
            $display("FAIL: test 4: clean changed %0d times on one release, expected 1",
                     changes);
            errors = errors + 1;
        end else
            $display("Test 4: one release, clean went to 0 once");

        if (errors == 0)
            $display("tb_debounce: ALL TESTS PASSED");
        else
            $display("tb_debounce: %0d TESTS FAILED", errors);
        $finish;
    end

endmodule
