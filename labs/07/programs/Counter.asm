// Counts up forever: RAM[0] = 0, 1, 2, ...
// On the board, the 7-segment display shows each value written to RAM.
    @0
    M=0     // RAM[0] = 0
(LOOP)
    @0
    M=M+1   // RAM[0] = RAM[0] + 1
    @LOOP
    0;JMP   // goto LOOP
