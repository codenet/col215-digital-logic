`timescale 1ns / 1ps

// Self-checking testbench for the 16-bit alu.
//
// Part 1: the comp table of figure 4.5 (the Hack instruction set). Each of
//         the 28 comp mnemonics is decoded exactly as the Hack CPU does it:
//           x = D,  y = (a == 0) ? A : M,  {zx,nx,zy,ny,f,no} = c1..c6
//         and the ALU output is compared against the mnemonic itself
//         (D+1, D-M, A&D, ...), computed as a 16-bit two's complement number.
// Part 2: all 64 settings of the control bits. The ALU output is compared
//         against the pseudocode of figure 2.5c.
//
// Exhaustive testing is impossible at 16 bits, so every check runs over a
// set of corner-case values (0, +-1, max, min, alternating bits, ...) in all
// combinations, followed by random values.
//
// In both parts zr and ng are checked as well.
module tb_alu;

    reg  [0:15] x, y;
    reg         zx, nx, zy, ny, f, no;
    wire [0:15] out;
    wire        zr, ng;

    localparam N_COMP   = 28;   // rows of figure 4.5 (18 with a = 0, 10 with a = 1)
    localparam N_CORNER = 16;
    localparam N_RANDOM = 2000;

    reg  [0:6]  comp   [0:N_COMP-1];    // a c1 c2 c3 c4 c5 c6
    reg  [0:39] name   [0:N_COMP-1];    // 5-character mnemonic
    reg  [0:15] corner [0:N_CORNER-1];
    reg  [0:15] d, a, m, expected;
    integer i, j, k, r;
    integer errors = 0, tests = 0, fn_errors;
    integer seed = 215;

    alu dut (
        .x(x), .y(y),
        .zx(zx), .nx(nx), .zy(zy), .ny(ny), .f(f), .no(no),
        .out(out), .zr(zr), .ng(ng)
    );

    function [0:15] spec;
        input integer row;
        input [0:15] dd, aa, mm;
        case (row)
            // a = 0
            0:  spec = 0;
            1:  spec = 1;
            2:  spec = -1;
            3:  spec = dd;
            4:  spec = aa;
            5:  spec = ~dd;
            6:  spec = ~aa;
            7:  spec = -dd;
            8:  spec = -aa;
            9:  spec = dd + 1;
            10: spec = aa + 1;
            11: spec = dd - 1;
            12: spec = aa - 1;
            13: spec = dd + aa;
            14: spec = dd - aa;
            15: spec = aa - dd;
            16: spec = dd & aa;
            17: spec = dd | aa;
            // a = 1
            18: spec = mm;
            19: spec = ~mm;
            20: spec = -mm;
            21: spec = mm + 1;
            22: spec = mm - 1;
            23: spec = dd + mm;
            24: spec = dd - mm;
            25: spec = mm - dd;
            26: spec = dd & mm;
            27: spec = dd | mm;
        endcase
    endfunction

    // The pseudocode of figure 2.5c.
    function [0:15] model;
        input [0:5] c;
        input [0:15] xin, yin;
        reg   [0:15] xx, yy, o;
        begin
            xx = c[0] ? 16'h0000 : xin;
            xx = c[1] ? ~xx      : xx;
            yy = c[2] ? 16'h0000 : yin;
            yy = c[3] ? ~yy      : yy;
            o  = c[4] ? xx + yy  : xx & yy;
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

    // Part 1 helper: decode row k of figure 4.5 for the given D, A, M and check.
    task check_comp;
        input integer row;
        begin
            x = d;
            y = comp[row][0] ? m : a;
            {zx, nx, zy, ny, f, no} = comp[row][1:6];
            #10;
            expected = spec(row, d, a, m);
            check;
        end
    endtask

    // Part 2 helper: apply control setting c to x, y and check.
    task check_ctrl;
        input [0:5] c;
        begin
            {zx, nx, zy, ny, f, no} = c;
            #10;
            expected = model(c, x, y);
            check;
        end
    endtask

    initial begin
        // Figure 4.5: comp mnemonic, a bit, c1..c6
        comp[0]  = 7'b0_101010; name[0]  = "    0";
        comp[1]  = 7'b0_111111; name[1]  = "    1";
        comp[2]  = 7'b0_111010; name[2]  = "   -1";
        comp[3]  = 7'b0_001100; name[3]  = "    D";
        comp[4]  = 7'b0_110000; name[4]  = "    A";
        comp[5]  = 7'b0_001101; name[5]  = "   !D";
        comp[6]  = 7'b0_110001; name[6]  = "   !A";
        comp[7]  = 7'b0_001111; name[7]  = "   -D";
        comp[8]  = 7'b0_110011; name[8]  = "   -A";
        comp[9]  = 7'b0_011111; name[9]  = "  D+1";
        comp[10] = 7'b0_110111; name[10] = "  A+1";
        comp[11] = 7'b0_001110; name[11] = "  D-1";
        comp[12] = 7'b0_110010; name[12] = "  A-1";
        comp[13] = 7'b0_000010; name[13] = "  D+A";
        comp[14] = 7'b0_010011; name[14] = "  D-A";
        comp[15] = 7'b0_000111; name[15] = "  A-D";
        comp[16] = 7'b0_000000; name[16] = "  D&A";
        comp[17] = 7'b0_010101; name[17] = "  D|A";
        comp[18] = 7'b1_110000; name[18] = "    M";
        comp[19] = 7'b1_110001; name[19] = "   !M";
        comp[20] = 7'b1_110011; name[20] = "   -M";
        comp[21] = 7'b1_110111; name[21] = "  M+1";
        comp[22] = 7'b1_110010; name[22] = "  M-1";
        comp[23] = 7'b1_000010; name[23] = "  D+M";
        comp[24] = 7'b1_010011; name[24] = "  D-M";
        comp[25] = 7'b1_000111; name[25] = "  M-D";
        comp[26] = 7'b1_000000; name[26] = "  D&M";
        comp[27] = 7'b1_010101; name[27] = "  D|M";

        corner[0]  = 16'h0000;  // 0
        corner[1]  = 16'h0001;  // 1
        corner[2]  = 16'h0002;  // 2
        corner[3]  = 16'hFFFF;  // -1
        corner[4]  = 16'hFFFE;  // -2
        corner[5]  = 16'h7FFF;  // largest positive
        corner[6]  = 16'h8000;  // most negative
        corner[7]  = 16'h8001;
        corner[8]  = 16'h5555;
        corner[9]  = 16'hAAAA;
        corner[10] = 16'h00FF;
        corner[11] = 16'hFF00;
        corner[12] = 16'h0F0F;
        corner[13] = 16'h1234;
        corner[14] = 16'h4000;
        corner[15] = 16'hC000;

        // Part 1: the comp table of figure 4.5
        $display("Part 1: comp table of figure 4.5");
        for (k = 0; k < N_COMP; k = k + 1) begin
            fn_errors = 0;
            // D against every corner value for A and M (A and M differ, so
            // a wrong a-bit is caught)
            for (i = 0; i < N_CORNER; i = i + 1) begin
                for (j = 0; j < N_CORNER; j = j + 1) begin
                    d = corner[i];
                    a = corner[j];
                    m = corner[N_CORNER - 1 - j];
                    check_comp(k);
                end
            end
            for (r = 0; r < N_RANDOM; r = r + 1) begin
                d = $random(seed);
                a = $random(seed);
                m = $random(seed);
                check_comp(k);
            end
            $display("  %s  (a=%b c=%b): %s", name[k], comp[k][0], comp[k][1:6],
                     fn_errors == 0 ? "PASS" : "FAIL");
        end

        // Part 2: all 64 control settings
        $display("Part 2: all 64 control settings");
        fn_errors = 0;
        for (k = 0; k < 64; k = k + 1) begin
            for (i = 0; i < N_CORNER; i = i + 1) begin
                for (j = 0; j < N_CORNER; j = j + 1) begin
                    x = corner[i];
                    y = corner[j];
                    check_ctrl(k);
                end
            end
            for (r = 0; r < N_RANDOM; r = r + 1) begin
                x = $random(seed);
                y = $random(seed);
                check_ctrl(k);
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
