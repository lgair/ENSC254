.global _start
_start:
    ;@12345678^2 into r0 & r1
    ldr r0, =#35487  	;@ MSB of 64b num here
	ldr r1, =#260846532 ;@ LSB of 64b num here
    mov r2, #0  	    ;@ Initialize and store calculated root
    ldr r3, =#4294967295;@ Largest number that can fit in a register (2^32)-1
    mov r4, #0 		    ;@ LSB for UMULL
    mov r5, #0 		    ;@ MSB for UMULL
    rrx r6, r3 		    ;@ midpoint starting at 1/2 LB
isRoot:
    umull r4, r5, r6, r6    ;@ Multiply the midpoint by itself, break into two registers
    cmp r0, r5              ;@ compare MSB registers of the multipliication
    bhi isSmaller
    bls isLarger
    cmp r1, r4              ;@ Compare LSB registers of the multiplication
    bhi isSmaller
    bls isLarger
    beq Root                ;@if we get here we know we have a root
isSmaller:
    sub r7, r3, r6  ;@ subtract the midpoint from the largest possible 32b number
    mov r4, r6      ;@ move the old midpoint to be the new max 32b number
    rrx r7, r7      ;@ calculate new midpoint
    sub r6, r6, r7  ;@ reinstate new midpoint over old one
    b isRoot
isLarger:           ;@ Logic is the same as isSmall, save operations at the end are inverted
    sub r7, r3, r6
    mov r4, r6
    rrx r7, r7
    add r6, r6, r7
    b isRoot
Root:
    mov r2, r4
End:
    b End
