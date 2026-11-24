`timescale 1ns / 1ps

// Self-checking testbench for the whole computer (cpu + memories).
//
// Runs the programs in programs/ (assembled to .hack with the nand2tetris
// assembler) on several inputs and checks the results left in RAM:
//
//   Add    RAM[0] = 2 + 3
//   Max    RAM[2] = max(RAM[0], RAM[1])
//   Sum    RAM[1] = 1 + 2 + ... + RAM[0]               (figure 4.4)
//   Mult   RAM[2] = RAM[0] * RAM[1]
//   Fill   RAM[RAM[0] + i] = i for i < RAM[1]          (pointers, A=M, AM=, MD=)
//   Jumps  RAM[1] = mask of the jumps taken for RAM[0] (all 8 jump fields)
//
// Each program gets its own computer; all of them share the clock and reset.
module tb_computer;

    reg clk = 0;
    reg reset = 1;
    always #5 clk = ~clk;

    computer #(.ROM_FILE("programs/Add.hack"))   add   (.clk(clk), .reset(reset));
    computer #(.ROM_FILE("programs/Max.hack"))   max   (.clk(clk), .reset(reset));
    computer #(.ROM_FILE("programs/Sum.hack"))   sum   (.clk(clk), .reset(reset));
    computer #(.ROM_FILE("programs/Mult.hack"))  mult  (.clk(clk), .reset(reset));
    computer #(.ROM_FILE("programs/Fill.hack"))  fill  (.clk(clk), .reset(reset));
    computer #(.ROM_FILE("programs/Jumps.hack")) jumps (.clk(clk), .reset(reset));

    localparam CYCLES = 3000;   // enough for the longest run (Sum with n = 100)

    integer errors = 0, tests = 0;
    integer i, k, n, a, b;

    task expect;
        input [8*6-1:0]  prog;
        input [8*24-1:0] what;
        input [0:15]     got, want;
        begin
            tests = tests + 1;
            if (got !== want) begin
                if (errors < 20) $display("FAIL: %0s %0s = %0d, expected %0d",
                                          prog, what, $signed(got), $signed(want));
                errors = errors + 1;
            end
        end
    endtask

    // Clear every RAM (registers keep their values, as in the Hack computer)
    task clear_ram;
        begin
            for (i = 0; i < 32768; i = i + 1) begin
                add.ram[i] = 0; max.ram[i] = 0; sum.ram[i] = 0;
                mult.ram[i] = 0; fill.ram[i] = 0; jumps.ram[i] = 0;
            end
        end
    endtask

    // Restart every program from address 0 and run it
    task run;
        begin
            reset = 1;
            @(posedge clk); #1;
            reset = 0;
            repeat (CYCLES) @(posedge clk);
            #1;
        end
    endtask

    // Expected Jumps mask for an ALU output v
    function integer jump_mask;
        input integer v;
        begin
            jump_mask = 64;                         // JMP
            if (v > 0)  jump_mask = jump_mask | 1;  // JGT
            if (v == 0) jump_mask = jump_mask | 2;  // JEQ
            if (v >= 0) jump_mask = jump_mask | 4;  // JGE
            if (v < 0)  jump_mask = jump_mask | 8;  // JLT
            if (v != 0) jump_mask = jump_mask | 16; // JNE
            if (v <= 0) jump_mask = jump_mask | 32; // JLE
        end
    endfunction

    initial begin
        for (k = 0; k < 8; k = k + 1) begin
            // Inputs for this round
            case (k)
                0: begin a = 0;      b = 0;   n = 0;   end
                1: begin a = 1;      b = 7;   n = 1;   end
                2: begin a = 7;      b = 3;   n = 10;  end
                3: begin a = -5;     b = 4;   n = 100; end
                4: begin a = 12;     b = -9;  n = 50;  end
                5: begin a = 32767;  b = 1;   n = 2;   end
                6: begin a = -32768; b = 0;   n = 20;  end
                7: begin a = -1;     b = 15;  n = 37;  end
            endcase

            clear_ram;
            max.ram[0]   = a;           max.ram[1]  = b;
            sum.ram[0]   = n;
            mult.ram[0]  = a;           mult.ram[1] = b < 0 ? -b : b;
            fill.ram[0]  = 100 + 10*k;  fill.ram[1] = k + 3;
            jumps.ram[0] = a;
            run;

            expect("Add", "RAM[0]", add.ram[0], 5);
            expect("Max", "RAM[2]", max.ram[2], a > b ? a : b);
            expect("Sum", "RAM[1]", sum.ram[1], n * (n + 1) / 2);
            expect("Mult", "RAM[2]", mult.ram[2], a * (b < 0 ? -b : b));
            for (i = 0; i < k + 3; i = i + 1)
                expect("Fill", "RAM[base + i]", fill.ram[100 + 10*k + i], i);
            expect("Fill", "RAM[base + n]", fill.ram[100 + 10*k + k + 3], 0);
            expect("Jumps", "RAM[1]", jumps.ram[1], jump_mask(a));
        end

        if (errors == 0)
            $display("computer: ALL %0d TESTS PASSED", tests);
        else
            $display("computer: %0d of %0d TESTS FAILED", errors, tests);
        $finish;
    end
endmodule
