`timescale 1ns / 1ps

// The 7-segment display is memory mapped: writing to RAM address 32767
// (all 15 address bits 1, e.g. after A=-1) also shows the value on the
// display. The word is stored in the RAM as well, so reading it back works.
//
// ssd and pc are brought out of the module so that the board (top.v) can
// show them.
module computer #(
    parameter ROM_FILE = "program.hack"
    ) (
    input         clk,
    input         reset,
    output reg [0:15] ssd = 16'b0,  // value shown on the 7-segment display
    output     [0:14] pc
    );

    localparam SSD_ADDRESS = 15'b111111111111111;   // 32767

    reg  [0:15] rom [0:32767];   // This is where the program lives.
    reg  [0:15] ram [0:32767];   // This is where the data lives.

    reg  [0:15] instruction = 16'b0;
    reg  [0:15] inM = 16'b0;
    wire [0:15] outM;
    wire        writeM;
    wire [0:14] addressM;

    integer i;
    initial begin
        for (i = 0; i < 32768; i = i + 1) rom[i] = 16'b0;
        for (i = 0; i < 32768; i = i + 1) ram[i] = 16'b0;
        $readmemb(ROM_FILE, rom);
    end

    cpu cpu (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .inM(inM),
        .outM(outM),
        .writeM(writeM),
        .addressM(addressM),
        .pc(pc)
    );

    // The CPU updates pc and A at the rising edge. Both memories are read
    // half a cycle later, at the falling edge, so instruction and inM are
    // ready before the next rising edge. (Reading at a clock edge lets the
    // FPGA build these large memories from block RAM.)
    always @(negedge clk) begin
        instruction <= rom[pc];
        inM         <= ram[addressM];
    end

    always @(posedge clk) begin
        if (writeM) ram[addressM] <= outM;
        if (writeM && addressM == SSD_ADDRESS) ssd <= outM;
    end
endmodule
