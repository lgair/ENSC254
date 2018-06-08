.global _start
_start:
    @; 64b number into r0 and r1
    ldr r0, =#35487         ;@ MSB of 64b num here		
    ldr r1, =#260846532		;@ LSB of 64b num here
    ldr r3, =#4294967295	;@ Max num of 32b register 
    mov r6, r3, lsr #1		;@ r6 is midpoint of our set 
    mov r8, #0			    ;@ Midpoint check
isRoot:
    umull r4, r5, r6, r6	;@ r4 - LSB of umull, r5 - MSB of umull
    cmp r0, r5			    ;@ Compare MSB's
    blo isSmaller
    bhi isLarger
    cmp r1, r4			    ;@ Compare LSB's
    blo isSmaller
    bhi isLarger
    beq Root			    ;@ if we get here, we have a root
isSmaller:
    sub r7, r3, r6		    ;@ Subtract midpoint from our total set
    mov r3, r6			    ;@ Move old midpoint to be new max
    mov r7, r7, lsr #1		;@ Find new midpoint 
    cmp r7, r8			    ;@ Check that the new midpoint != 0
    addeq r7, r7, #1
    sub r6, r6, r7		    ;@ Place new midpoint back into r6
    b isRoot
isLarger:			        ;@ Logic same as isSmaller save inverted operations at end
    sub R7, R3, R6
    mov R3, r6
    mov r7, r7, lsr #1
    cmp r7, r8
    subeq r7, r7, #1
    add r6, r6, r7
    b isRoot
Root:
    mov r2, r6			    ;@ Store midpoint
fin:
    b fin

