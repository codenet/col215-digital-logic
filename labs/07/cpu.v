`timescale 1ns / 1ps

// Hack CPU (Nisan & Schocken, section 5.2.2, figure 5.8): the A, D and PC
// registers, the ALU, and the control logic that decodes the instruction.
// Every instruction takes one clock cycle.
//
//   inM          value of RAM[A] (M), read combinationally by computer.v
//   outM         ALU output, the value written to RAM[A]
//   writeM       write outM to RAM[addressM] at the next rising edge
//   addressM     A register (15 bits)
//   pc           address of the next instruction in ROM (15 bits)
//
// reset = 1 sets pc to 0 at the next rising edge.
//
// Bit ordering: index 0 is the MSB, so the instruction reads left to right
// exactly as the assembler prints it (figure 4.5):
//
//   A-instruction:  0 v v v v v v v v v v v v v v v      A = v
//   C-instruction:  1 1 1 a c c c c c c d d d j j j      dest = comp ; jump
//   index:          0 1 2 3 4 5 6 7 8 9 . . 12 . . 15
module cpu(
    input         clk,
    input         reset,
    input  [0:15] instruction,
    input  [0:15] inM,
    output [0:15] outM,
    output        writeM,
    output [0:14] addressM,
    output [0:14] pc
    );

    reg  [0:15] A = 16'b0;
    reg  [0:15] D = 16'b0;
    reg  [0:14] PC = 15'b0;

    // TODO: Build the rest of the CPU, following figure 5.8: the control
    //       logic that decodes the instruction, and the datapath (the ALU
    //       and the two Mux16s). Declare and drive every signal used below.

    always @(posedge clk) begin
        if (load_a) A <= a_in;
        if (load_d) D <= alu_out;

        if (reset)     PC <= 15'b0;
        else if (jump) PC <= A[1:15];
        else           PC <= PC + 1'b1;
    end

    assign outM     = alu_out;
    assign addressM = A[1:15];
    assign pc       = PC;
endmodule
