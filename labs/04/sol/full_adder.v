`timescale 1ns / 1ps

// Full adder (from Lab 3): adds three 1-bit inputs x, y, cin.
//   s    = sum bit
//   cout = carry out
module full_adder(
    input x,
    input y,
    input cin,
    output s,
    output cout
    );

    assign s    = x ^ y ^ cin;
    assign cout = (x & y) | ((x ^ y) & cin);
endmodule
