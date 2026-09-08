module seven_segment_decoder (
    input [9:0] SW,
    output reg [7:0] SSEG_CA,
    output reg [3:0] SSEG_AN
);

    always @(*) begin
        // Enable only the MSB display (lightmost), active low
        SSEG_AN = 4'b0000; 

        // Priority: highest switch takes precedence (SW9 > SW8 > ... > SW0)
        // Cathodes are active-low: 0 = LED ON, 1 = LED OFF
        if (SW[9]) begin
            SSEG_CA = 8'b10010010;  // CA[7:0] = DP,g,f,e,d,c,b,a
        end
        else if (SW[8]) begin
            SSEG_CA = 8'b00000000;
        end
        else if (SW[7]) begin
            SSEG_CA = 8'b00000000;
        end
        else if (SW[6]) begin
            SSEG_CA = 8'b00000000;
        end
        else if (SW[5]) begin
            SSEG_CA = 8'b00000000;
        end
        else if (SW[4]) begin
            SSEG_CA = 8'b00000000;
        end
        else if (SW[3]) begin
            SSEG_CA = 8'b00000000;
        end
        else if (SW[2]) begin
            SSEG_CA = 8'b00000000;
        end
        else if (SW[1]) begin
            SSEG_CA = 8'b00000000;
        end
        else if (SW[0]) begin
            SSEG_CA = 8'b00000000;
        end
        else begin
            // No switch ON: all LEDs OFF
            SSEG_CA = 8'b00000000;
        end
    end

endmodule
