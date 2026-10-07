`timescale 1ns / 1ps

// Self-checking testbench for full_adder.
// Applies all 8 input combinations and compares against x + y + cin.
module tb_full_adder;

    reg x, y, cin;
    wire s, cout;

    integer i;
    integer errors = 0;

    full_adder dut (
        .x(x),
        .y(y),
        .cin(cin),
        .s(s),
        .cout(cout)
    );

    initial begin
        for (i = 0; i < 8; i = i + 1) begin
            {x, y, cin} = i;
            #10;
            if ({cout, s} !== x + y + cin) begin
                $display("FAIL: x=%b y=%b cin=%b -> cout=%b s=%b, expected cout=%b s=%b",
                         x, y, cin, cout, s, (x + y + cin) >> 1, (x + y + cin) & 1);
                errors = errors + 1;
            end
        end

        if (errors == 0)
            $display("full_adder: ALL 8 TESTS PASSED");
        else
            $display("full_adder: %0d of 8 TESTS FAILED", errors);
        $finish;
    end
endmodule
