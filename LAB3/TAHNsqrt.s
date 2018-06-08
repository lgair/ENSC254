@ This is Tahns Algorithm
.global _start
_start:
    MOV R8, #0  
    @; 12345678^2 split into 2 register
    LDR R0, =#35487
    LDR R1, =#260846532
@; this number is (2^32)-1 because 2^32 is impossible for a register
    LDR R3, =#4294967295
    MOV R4, R3, LSR #1
@; start the program here to test whether we have found the root of the r1 and r2 number
STARTTEST:
    UMULL R6, R5, R4, R4
    CMP R0, R5
    BLT LESSTHAN
    BGT GREATERTHAN
    CMP R1, R6
    BLT LESSTHAN
    BGT GREATERTHAN
    BEQ FINAL
@; case to do when result of test is less than  r0 and r1 number
LESSTHAN:
    SUB R7, R3, R4
    MOV R3, R4
    MOV R7, R7, LSR #1
    CMP R7, R8
    ADDEQ R7, R7, #1
    SUB R4, R4, R7
    B STARTTEST
@; case to do when the result of the test is larger than r0 and r1 number
GREATERTHAN:
    SUB R7, R3, R4
    MOV R3, R4
    MOV R7, R7, LSR #1
    CMP R7, R8
    SUBEQ R7, R7, #1
    ADD R4, R4, R7
    B STARTTEST
@; ending condition
FINAL:
    MOV R2, R4
@; to prevent system from crashing
DONE:
    B DONE
