`timescale 1ns / 1ps

// Self-checking testbench for cpu.
//
// Executes every one of the 65536 instructions, each from several starting
// states (A, D, M), and compares the result against the Hack specification
// (figure 4.5):
//
//   before the clock edge:  writeM, addressM, and outM (C-instructions only)
//   after the clock edge:   the new A, D and PC
//
// The starting state is set by writing the cpu's A, D and PC registers
// directly, so keep those register names in cpu.v.
module tb_cpu;

    reg         clk = 0, reset = 0;
    reg  [0:15] instruction, inM;
    wire [0:15] outM;
    wire        writeM;
    wire [0:14] addressM, pc;

    localparam N_STATES = 4;

    reg  [0:15] s_a [0:N_STATES-1];     // starting A, D, M
    reg  [0:15] s_d [0:N_STATES-1];
    reg  [0:15] s_m [0:N_STATES-1];
    reg  [0:14] pc0;                    // starting PC

    reg  [0:15] a0, d0, m0, out, e_a, e_d;
    reg  [0:14] e_pc;
    reg         e_write, j, bad;
    integer     i, s;
    integer     errors = 0, tests = 0;

    cpu dut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .inM(inM),
        .outM(outM),
        .writeM(writeM),
        .addressM(addressM),
        .pc(pc)
    );

    // The ALU, as in the pseudocode of figure 2.5c
    function [0:15] alu_model;
        input [0:5]  c;
        input [0:15] x, y;
        reg   [0:15] xx, yy, o;
        begin
            xx = c[0] ? 16'h0000 : x;
            xx = c[1] ? ~xx      : xx;
            yy = c[2] ? 16'h0000 : y;
            yy = c[3] ? ~yy      : yy;
            o  = c[4] ? xx + yy  : xx & yy;
            alu_model = c[5] ? ~o : o;
        end
    endfunction

    initial begin
        // Starting states chosen so that the ALU output is zero, negative and
        // positive for many comp fields. A and M differ, so a wrong a-bit is
        // caught.
        s_a[0] = 16'd5;     s_d[0] = 16'd0;     s_m[0] = 16'd7;
        s_a[1] = 16'd100;   s_d[1] = 16'd3;     s_m[1] = 16'hFFFE;
        s_a[2] = 16'h1234;  s_d[2] = 16'hFFFF;  s_m[2] = 16'd0;
        s_a[3] = 16'h7FFF;  s_d[3] = 16'h8000;  s_m[3] = 16'd1;
        pc0 = 15'd300;

        for (i = 0; i < 65536; i = i + 1) begin
            for (s = 0; s < N_STATES; s = s + 1) begin
                instruction = i;
                a0 = s_a[s];
                d0 = s_d[s];
                m0 = s_m[s];
                dut.A  = a0;
                dut.D  = d0;
                dut.PC = pc0;
                inM    = m0;
                #1;

                // Expected behaviour
                e_a = a0; e_d = d0; e_pc = pc0 + 1; e_write = 0;
                out = 16'bx;
                if (!instruction[0]) begin
                    e_a = instruction;                      // @value
                end else begin
                    out = alu_model(instruction[4:9], d0,
                                    instruction[3] ? m0 : a0);
                    if (instruction[10]) e_a = out;         // dest A
                    if (instruction[11]) e_d = out;         // dest D
                    e_write = instruction[12];              // dest M
                    j = (instruction[13] && $signed(out) < 0) ||
                        (instruction[14] && out == 0) ||
                        (instruction[15] && $signed(out) > 0);
                    if (j) e_pc = a0[1:15];
                end

                // Before the clock edge
                bad = writeM !== e_write || addressM !== a0[1:15] ||
                      (instruction[0] && outM !== out);

                // After the clock edge
                clk = 1; #1;
                bad = bad || dut.A !== e_a || dut.D !== e_d || pc !== e_pc;
                clk = 0; #1;

                tests = tests + 1;
                if (bad) begin
                    if (errors < 20) $display("FAIL: instruction=%b A=%0d D=%0d M=%0d -> outM=%0d writeM=%b, then A=%0d D=%0d PC=%0d; expected outM=%0d writeM=%b, then A=%0d D=%0d PC=%0d",
                             instruction, $signed(a0), $signed(d0), $signed(m0),
                             $signed(outM), writeM, $signed(dut.A), $signed(dut.D), pc,
                             $signed(out), e_write, $signed(e_a), $signed(e_d), e_pc);
                    if (errors == 19) $display("(further failures not printed)");
                    errors = errors + 1;
                end
            end
        end

        // reset sends the PC back to 0, whatever the instruction
        tests = tests + 1;
        instruction = 16'b1110101010000111;     // 0;JMP
        dut.A = 16'd42;
        reset = 1; #1;
        clk = 1; #1;
        clk = 0; #1;
        reset = 0;
        if (pc !== 0) begin
            $display("FAIL: reset -> PC=%0d, expected 0", pc);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("cpu: ALL %0d TESTS PASSED", tests);
        else
            $display("cpu: %0d of %0d TESTS FAILED", errors, tests);
        $finish;
    end
endmodule
