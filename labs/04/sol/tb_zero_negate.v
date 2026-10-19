`timescale 1ns / 1ps

// Self-checking testbench for zero_negate.
// Applies all 16 values of 'in' with all 4 combinations of z, n (64 tests).
module tb_zero_negate;

    reg  [0:3] in;
    reg        z, n;
    wire [0:3] out;

    reg  [0:3] expected;
    integer i, j;
    integer errors = 0;

    zero_negate dut (
        .in(in),
        .z(z),
        .n(n),
        .out(out)
    );

    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                in     = i;
                {z, n} = j;
                #10;
                expected = z ? 4'b0000 : in;
                expected = n ? ~expected : expected;
                if (out !== expected) begin
                    $display("FAIL: in=%b z=%b n=%b -> out=%b, expected %b",
                             in, z, n, out, expected);
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0)
            $display("zero_negate: ALL 64 TESTS PASSED");
        else
            $display("zero_negate: %0d of 64 TESTS FAILED", errors);
        $finish;
    end
endmodule
