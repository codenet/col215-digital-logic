// Counts up forever on the 7-segment display.
// The display is memory mapped at RAM address 32767 (all 15 address bits 1).
// A=-1 sets A to 1111111111111111, so M is RAM[32767].
    A=-1
    M=0     // display = 0
(LOOP)
    A=-1
    M=M+1   // display = display + 1
    @LOOP
    0;JMP   // goto LOOP
