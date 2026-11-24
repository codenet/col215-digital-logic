// Computes RAM[2] = RAM[0] * RAM[1]  (RAM[1] >= 0)
    @R2
    M=0
    @R1
    D=M
    @i
    M=D     // i = R1
(LOOP)
    @i
    D=M
    @END
    D;JEQ   // if i == 0 goto END
    @R0
    D=M
    @R2
    M=D+M   // R2 = R2 + R0
    @i
    M=M-1   // i = i - 1
    @LOOP
    0;JMP
(END)
    @END
    0;JMP
