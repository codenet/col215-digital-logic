`timescale 1ns / 1ps

// Self-checking testbench for detector_mealy.
//
// The FSM runs on clk but only moves when tick is 1. Here a tick comes every
// 8 clk cycles instead of every 2 seconds. Between ticks, x is changed
// freely, just like flipping SW0 on the board.
//
// Part 1 checks that z is correct ON every tick (at the clock edge).
// Part 2 changes x several times between two ticks and reports what z did.
module tb_mealy;

    reg clk  = 1'b0;
    reg rst  = 1'b1;
    reg tick = 1'b0;
    reg x    = 1'b0;

    wire       z;
    wire [1:0] state;

    mealy_fsm dut (
        .clk(clk), .rst(rst), .tick(tick), .x(x),
        .z(z), .state(state)
    );

    always #5 clk = ~clk;  // 100 MHz

    integer errors     = 0;
    integer detections = 0;  // real 1 0 1s, seen on ticks
    integer between    = 0;  // times z changed between ticks
    integer pulses     = 0;  // times z went 0 -> 1

    // Reference model: the last two bits seen on ticks
    reg [1:0] hist = 2'b00;
    reg       expect_z;

    // 1 during a tick's clock edge, so that changes caused by the tick
    // itself are not counted as "between ticks"
    reg at_tick = 1'b0;
    always @(posedge clk) at_tick = tick;
    always @(negedge clk) at_tick = 1'b0;

    always @(z)       if (!rst && !at_tick) between = between + 1;
    always @(posedge z) if (!rst)           pulses  = pulses + 1;

    // On every tick, z must say "this tick completes 1 0 1"
    always @(posedge clk) begin
        if (tick && !rst) begin
            expect_z = (hist == 2'b10) && x;
            if (expect_z)
                detections = detections + 1;
            if (z !== expect_z) begin
                $display("FAIL: z=%b on a tick with last bits %b and x=%b, expected %b",
                         z, hist, x, expect_z);
                errors = errors + 1;
            end
            hist = {hist[0], x};
        end
    end

    // Set x to b, then tick once
    task send(input b);
        begin
            @(negedge clk); #1 x = b;
            repeat (3) @(negedge clk);
            #1 tick = 1'b1;
            @(negedge clk); #1 tick = 1'b0;
            repeat (3) @(negedge clk);
        end
    endtask

    // Flip x between 1 and 0 n times without ticking, ending at 0
    task wiggle(input integer n);
        integer k;
        begin
            for (k = 0; k < n; k = k + 1) begin
                @(negedge clk); #1 x = 1'b1;
                @(negedge clk); #1 x = 1'b0;
            end
        end
    endtask

    initial begin
        repeat (3) @(negedge clk);
        #1 rst = 1'b0;

        // Part 1: 1 0 1 0 1 1 0 1 0 0 1 contains three 1 0 1s
        send(1); send(0); send(1); send(0); send(1); send(1);
        send(0); send(1); send(0); send(0); send(1);

        if (errors == 0)
            $display("Part 1: z correct on every tick (%0d detections)", detections);

        // Part 2: send 0 (now the last bits are 1 0), then flip x up and
        // down 3 times before sending 1. One more 1 0 1, so 4 in total.
        between = 0;
        send(0);
        wiggle(3);
        send(1);

        #50;
        $display("Part 2: z changed %0d times between ticks", between);
        $display("Part 2: a counter watching z saw %0d detections (real: %0d)",
                 pulses, detections);

        if (errors == 0)
            $display("tb_mealy: ALL TESTS PASSED");
        else
            $display("tb_mealy: %0d TESTS FAILED", errors);
        $finish;
    end

endmodule
