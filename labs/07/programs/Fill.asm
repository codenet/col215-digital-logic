// Sets RAM[RAM[0] + i] = i for i = 0 .. RAM[1] - 1
// (RAM[0] must be above the variables, e.g. 100)
    @R0
    D=M
    @ptr
    M=D     // ptr = R0
    @i
    M=0     // i = 0
(LOOP)
    @i
    D=M
    @R1
    D=D-M
    @END
    D;JGE   // if i >= R1 goto END
    @i
    D=M
    @ptr
    A=M
    M=D     // RAM[ptr] = i
    @ptr
    AM=M+1  // ptr = ptr + 1
    @i
    MD=M+1  // i = i + 1
    @LOOP
    0;JMP
(END)
    @END
    0;JMP
