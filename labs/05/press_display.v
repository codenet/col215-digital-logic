`timescale 1ns / 1ps

// Count button presses in decimal (0 - 9999) and show the count on the
// four 7-segment displays. Leading zeros are blank.
//
//   press  the debounced button: one press = one 0 -> 1 change
//   rst    clears the count to 0
module press_display (
    input        clk,
    input        rst,
    input        press,
    output [0:6] SSEG_CA,
    output [0:3] SSEG_AN
);

    // A press is press going from 0 to 1
    reg press_prev = 1'b0;
    always @(posedge clk)
        press_prev <= press;
    wire pressed = press && !press_prev;

    // Decimal counter, one 4-bit digit each: d3 d2 d1 d0
    reg [3:0] d0 = 4'd0, d1 = 4'd0, d2 = 4'd0, d3 = 4'd0;

    always @(posedge clk) begin
        if (rst) begin
            d0 <= 4'd0; d1 <= 4'd0; d2 <= 4'd0; d3 <= 4'd0;
        end else if (pressed) begin
            if (d0 != 4'd9) d0 <= d0 + 4'd1;
            else begin
                d0 <= 4'd0;
                if (d1 != 4'd9) d1 <= d1 + 4'd1;
                else begin
                    d1 <= 4'd0;
                    if (d2 != 4'd9) d2 <= d2 + 4'd1;
                    else begin
                        d2 <= 4'd0;
                        d3 <= (d3 != 4'd9) ? d3 + 4'd1 : 4'd0;  // 9999 -> 0
                    end
                end
            end
        end
    end

    // Show one display at a time, fast enough that all four look lit
    // (each one for 2^16 cycles = 0.66 ms at 100 MHz)
    reg [17:0] refresh = 18'd0;
    always @(posedge clk)
        refresh <= refresh + 1'b1;
    wire [1:0] select = refresh[17:16];

    // 1110 is blank in ssd.v: hide leading zeros, but always show d0
    localparam BLANK = 4'b1110;
    wire [3:0] show3 = (d3 == 0)                         ? BLANK : d3;
    wire [3:0] show2 = (d3 == 0 && d2 == 0)              ? BLANK : d2;
    wire [3:0] show1 = (d3 == 0 && d2 == 0 && d1 == 0)   ? BLANK : d1;

    wire [0:3] digit =
        (select == 2'd0) ? d0    :
        (select == 2'd1) ? show1 :
        (select == 2'd2) ? show2 :
                           show3;

    ssd display (
        .digit(digit),
        .segment(SSEG_CA)
    );

    // Active-low anodes, SSEG_AN[0] = AN0 (rightmost display)
    assign SSEG_AN =
        (select == 2'd0) ? 4'b0111 :
        (select == 2'd1) ? 4'b1011 :
        (select == 2'd2) ? 4'b1101 :
                           4'b1110;

endmodule
