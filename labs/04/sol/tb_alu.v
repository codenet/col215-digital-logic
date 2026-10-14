`timescale 1ns / 1ps

// Self-checking testbench for alu.
//
// Part 1: the 18 functions of figure 2.5b. For every x, y (256 pairs) the
//         ALU output is compared against the function itself (x+1, x-y, ...),
//         computed as a 4-bit two's complement number.
// Part 2: all 64 settings of the control bits. For every x, y the ALU output
//         is compared against the pseudocode of figure 2.5c.
//
// In both parts zr and ng are checked as well.
module tb_alu;

    reg  [0:3] x, y;
    reg        zx, nx, zy, ny, f, no;
    wire [0:3] out;
    wire       zr, ng;

    reg  [0:5]  ctrl [0:17];     // control bits zx nx zy ny f no, figure 2.5b
    reg  [0:47] name [0:17];     // 6-character function name
    reg  [0:3]  expected;
    integer i, j, k;
    integer errors = 0, tests = 0, fn_errors;

    alu dut (
        .x(x), .y(y),
        .zx(zx), .nx(nx), .zy(zy), .ny(ny), .f(f), .no(no),
        .out(out), .zr(zr), .ng(ng)
    );

    // The function each row of figure 2.5b is meant to compute.
    function [0:3] spec;
        input integer row;
        input [0:3] a, b;
        case (row)
            0:  spec = 0;
            1:  spec = 1;
            2:  spec = -1;
            3:  spec = a;
            4:  spec = b;
            5:  spec = ~a;
            6:  spec = ~b;
            7:  spec = -a;
            8:  spec = -b;
            9:  spec = a + 1;
            10: spec = b + 1;
            11: spec = a - 1;
            12: spec = b - 1;
            13: spec = a + b;
            14: spec = a - b;
            15: spec = b - a;
            16: spec = a & b;
            17: spec = a | b;
        endcase
    endfunction

    // The pseudocode of figure 2.5c.
    function [0:3] model;
        input [0:5] c;
        input [0:3] a, b;
        reg   [0:3] xx, yy, o;
        begin
            xx = c[0] ? 4'b0000 : a;
            xx = c[1] ? ~xx     : xx;
            yy = c[2] ? 4'b0000 : b;
            yy = c[3] ? ~yy     : yy;
            o  = c[4] ? xx + yy : xx & yy;
            model = c[5] ? ~o : o;
        end
    endfunction

    task check;
        begin
            tests = tests + 1;
            if (out !== expected || zr !== (expected == 0) || ng !== expected[0]) begin
                if (errors < 20) $display("FAIL: x=%0d y=%0d zx=%b nx=%b zy=%b ny=%b f=%b no=%b -> out=%0d zr=%b ng=%b, expected out=%0d zr=%b ng=%b",
                         $signed(x), $signed(y), zx, nx, zy, ny, f, no,
                         $signed(out), zr, ng,
                         $signed(expected), expected == 0, expected[0]);
                if (errors == 19) $display("(further failures not printed)");
                errors = errors + 1;
                fn_errors = fn_errors + 1;
            end
        end
    endtask

    initial begin
        ctrl[0]  = 6'b101010; name[0]  = "     0";
        ctrl[1]  = 6'b111111; name[1]  = "     1";
        ctrl[2]  = 6'b111010; name[2]  = "    -1";
        ctrl[3]  = 6'b001100; name[3]  = "     x";
        ctrl[4]  = 6'b110000; name[4]  = "     y";
        ctrl[5]  = 6'b001101; name[5]  = "    !x";
        ctrl[6]  = 6'b110001; name[6]  = "    !y";
        ctrl[7]  = 6'b001111; name[7]  = "    -x";
        ctrl[8]  = 6'b110011; name[8]  = "    -y";
        ctrl[9]  = 6'b011111; name[9]  = "   x+1";
        ctrl[10] = 6'b110111; name[10] = "   y+1";
        ctrl[11] = 6'b001110; name[11] = "   x-1";
        ctrl[12] = 6'b110010; name[12] = "   y-1";
        ctrl[13] = 6'b000010; name[13] = "   x+y";
        ctrl[14] = 6'b010011; name[14] = "   x-y";
        ctrl[15] = 6'b000111; name[15] = "   y-x";
        ctrl[16] = 6'b000000; name[16] = "   x&y";
        ctrl[17] = 6'b010101; name[17] = "   x|y";

        // Part 1: the 18 documented functions
        $display("Part 1: functions of figure 2.5b");
        for (k = 0; k < 18; k = k + 1) begin
            fn_errors = 0;
            {zx, nx, zy, ny, f, no} = ctrl[k];
            for (i = 0; i < 16; i = i + 1) begin
                for (j = 0; j < 16; j = j + 1) begin
                    x = i;
                    y = j;
                    #10;
                    expected = spec(k, x, y);
                    check;
                end
            end
            $display("  %s  (%b): %s", name[k], ctrl[k],
                     fn_errors == 0 ? "PASS" : "FAIL");
        end

        // Part 2: all 64 control settings
        $display("Part 2: all 64 control settings");
        fn_errors = 0;
        for (k = 0; k < 64; k = k + 1) begin
            {zx, nx, zy, ny, f, no} = k;
            for (i = 0; i < 16; i = i + 1) begin
                for (j = 0; j < 16; j = j + 1) begin
                    x = i;
                    y = j;
                    #10;
                    expected = model({zx, nx, zy, ny, f, no}, x, y);
                    check;
                end
            end
        end
        $display("  %s", fn_errors == 0 ? "PASS" : "FAIL");

        if (errors == 0)
            $display("alu: ALL %0d TESTS PASSED", tests);
        else
            $display("alu: %0d of %0d TESTS FAILED", errors, tests);
        $finish;
    end
endmodule
