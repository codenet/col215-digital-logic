`timescale 1ns / 1ps

// Self-checking testbench for the debounced toggle.
// Uses a short STABLE_CYCLES so the simulation finishes quickly, and
// models each press/release as a burst of bounces before settling.
module tb_top;

    localparam STABLE = 50;  // cycles the button must hold steady

    reg CLK = 1'b0;
    reg btnC = 1'b0;
    wire led;

    integer i;
    integer errors = 0;

    top #(.STABLE_CYCLES(STABLE)) dut (
        .CLK(CLK),
        .btnC(btnC),
        .led(led)
    );

    always #5 CLK = ~CLK;  // 100 MHz

    // Bounce `n` times (each glitch shorter than STABLE), then settle at `level`
    task bounce_to(input level, input integer n);
        begin
            for (i = 0; i < n; i = i + 1) begin
                btnC = level;
                #((3 + i * 7 % 20) * 10);
                btnC = ~level;
                #((2 + i * 5 % 15) * 10);
            end
            btnC = level;
            #((STABLE + 10) * 10);
        end
    endtask

    task press(input expected);
        begin
            bounce_to(1'b1, 8);   // press with bounces
            #((STABLE * 3) * 10); // hold
            bounce_to(1'b0, 8);   // release with bounces
            if (led !== expected) begin
                $display("FAIL: after press led=%b, expected %b", led, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        #200;
        if (led !== 1'b0) begin
            $display("FAIL: led should start off");
            errors = errors + 1;
        end

        press(1'b1);
        press(1'b0);
        press(1'b1);
        press(1'b0);

        // A short glitch alone must not toggle the LED
        btnC = 1'b1;
        #((STABLE / 2) * 10);
        btnC = 1'b0;
        #((STABLE * 2) * 10);
        if (led !== 1'b0) begin
            $display("FAIL: short glitch toggled the led");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("tb_top: ALL TESTS PASSED");
        else
            $display("tb_top: %0d TESTS FAILED", errors);
        $finish;
    end
endmodule
