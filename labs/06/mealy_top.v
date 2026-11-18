`timescale 1ns / 1ps

// Board wrapper for Mealy_Zero_Detector: one BTNC press = one clock edge.
//
//   CLK   (W5)   100 MHz, only used to debounce the button
//   btnC  BTNC (U18)  clock for the FSM
//   sw0   SW0  (V17)  x_in
//   sw1   SW1  (V16)  reset, active low: down = reset, up = run
//   led[0]    LD0      y_out
//   led[15:12] LD12-LD15 one LED per state: LD12=S0, LD13=S1, LD14=S2, LD15=S3
//   7-segment  number of BTNC presses (cleared by reset)
module mealy_top (
    input  CLK,
    input  btnC,
    input  sw0,
    input  sw1,
    output [15:0] led,
    output [0:6]  SSEG_CA,
    output [0:3]  SSEG_AN
);

    wire       step;
    wire [1:0] state;

//    debounce db (
//        .clk(CLK),
//        .noisy(btnC),
//        .clean(step)
//    );

    Mealy_Zero_Detector fsm (
        .y_out(led[0]),
        .x_in(sw0),
        .clock(btnC),
        .reset(sw1),
        .state_out(state)
    );

    assign led[11:1]  = 11'b0;
    assign led[15:12] = 4'b0001 << state;  // light the LED for the current state

    // reset is active low (SW1 down), the counter clears on rst = 1
    press_display presses (
        .clk(CLK),
        .rst(!sw1),
        .press(btnC),
        .SSEG_CA(SSEG_CA),
        .SSEG_AN(SSEG_AN)
    );

endmodule
