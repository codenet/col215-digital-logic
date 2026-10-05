`timescale 1ns / 1ps

// Self-checking testbench for four_bit_adder.
// Applies all 256 combinations of a, b and compares {cout, s} against a + b.
module tb_four_bit_adder;

    reg  [0:3] a, b;
    wire [0:3] s;
    wire cout;

    integer i, j;
    integer errors = 0;

    four_bit_adder dut (
        .a(a),
        .b(b),
        .s(s),
        .cout(cout)
    );

    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i;
                b = j;
                #10;
                if ({cout, s} !== i + j) begin
                    $display("FAIL: %0d + %0d -> cout=%b s=%b, expected cout=%b s=%b",
                             i, j, cout, s, (i + j) >> 4, (i + j) & 4'hf);
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0)
            $display("four_bit_adder: ALL 256 TESTS PASSED");
        else
            $display("four_bit_adder: %0d of 256 TESTS FAILED", errors);
        $finish;
    end
endmodule
