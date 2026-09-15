module seven_segment_decoder (
    input [9:0] SW,
    output [7:0] SSEG_CA,
    output [3:0] SSEG_AN
);
		// TODO: Enable only the MSB display (rightmost), active low
		SSEG_AN = 4'b0000; 

		// Priority: highest switch takes precedence (SW9 > SW8 > ... > SW0)
		// Cathodes are active-low: 0 = LED ON, 1 = LED OFF
		// CA[7:0] = DP,g,f,e,d,c,b,a
		SSEG_CA = SW[9] ? 8'b10010010:
							SW[8] ? 8'b00000000:
							SW[7] ? 8'b00000000:	// TODO
							8'b00000000;	// No switch ON: all LEDs OFF
endmodule
