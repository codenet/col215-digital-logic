`timescale 1ns / 1ps

// Self-checking testbench for bcd_adder.
// Applies all 100 combinations of BCD digits a, b (0-9) and checks that
// c is the tens digit and s is the units digit of a + b.
module tb_bcd_adder;

    reg  [0:3] a, b;
    wire [0:3] s;
    wire c;

    integer i, j;
    integer errors = 0;

    bcd_adder dut (
        .a(a),
        .b(b),
        .s(s),
        .c(c)
    );

    initial begin
        for (i = 0; i < 10; i = i + 1) begin
            for (j = 0; j < 10; j = j + 1) begin
                a = i;
                b = j;
                #10;
                if (c !== (i + j) / 10 || s !== (i + j) % 10) begin
                    $display("FAIL: %0d + %0d -> c=%b s=%b, expected c=%b s=%b",
                             i, j, c, s, (i + j) / 10, (i + j) % 10);
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0)
            $display("bcd_adder: ALL 100 TESTS PASSED");
        else
            $display("bcd_adder: %0d of 100 TESTS FAILED", errors);
        $finish;
    end
endmodule
