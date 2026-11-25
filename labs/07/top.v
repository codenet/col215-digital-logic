`timescale 1ns / 1ps

// Board wrapper for the Hack computer.
//
//   CLK        W5    100 MHz, divided down to a slow clock for the computer
//   btnC       U18   reset: hold it until pc (the LEDs) goes back to 0
//   led[14:0]  LD14 (MSB) .. LD0 (LSB): pc, the address of the next instruction
//   led[15]    LD15  the computer's clock
//   7-segment  RAM[32767] (memory mapped, see computer.v), in hexadecimal
module top #(
    parameter ROM_FILE = "programs/Counter.hack"
    ) (
    input         CLK,
    input         btnC,
    output [15:0] led,
    output [0:6]  SSEG_CA,
    output [0:3]  SSEG_AN
);

    // Slow clock: 100 MHz / 2^24 = about 6 instructions per second
    reg [23:0] div = 24'd0;
    always @(posedge CLK)
        div <= div + 1'b1;
    wire cpu_clk = div[23];

    wire [0:15] ssd;
    wire [0:14] pc;

    computer #(.ROM_FILE(ROM_FILE)) hack (
        .clk(cpu_clk),
        .reset(btnC),
        .ssd(ssd),
        .pc(pc)
    );

    hex_display display (
        .clk(CLK),
        .value(ssd),
        .SSEG_CA(SSEG_CA),
        .SSEG_AN(SSEG_AN)
    );

    assign led[14:0] = pc;
    assign led[15]   = cpu_clk;
endmodule
