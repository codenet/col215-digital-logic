`timescale 1ns / 1ps

// Self-checking testbench for mux2_4.
// Applies all 16 x 16 values of a, b with both values of sel (512 tests).
module tb_mux2_4;

    reg  [0:3] a, b;
    reg        sel;
    wire [0:3] out;

    reg  [0:3] expected;
    integer i, j, k;
    integer errors = 0;

    mux2_4 dut (
        .a(a),
        .b(b),
        .sel(sel),
        .out(out)
    );

    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                for (k = 0; k < 2; k = k + 1) begin
                    a   = i;
                    b   = j;
                    sel = k;
                    #10;
                    expected = sel ? b : a;
                    if (out !== expected) begin
                        $display("FAIL: a=%b b=%b sel=%b -> out=%b, expected %b",
                                 a, b, sel, out, expected);
                        errors = errors + 1;
                    end
                end
            end
        end

        if (errors == 0)
            $display("mux2_4: ALL 512 TESTS PASSED");
        else
            $display("mux2_4: %0d of 512 TESTS FAILED", errors);
        $finish;
    end
endmodule
