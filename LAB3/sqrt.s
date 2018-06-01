;@ this is the .s file for lab 3
_start:
    mov r0, #1  ;@ MSB of 64b  num here
    mov r1, #1  ;@ LSB of 64b num here
    mov r2, #0  ;@ Initialize and store calculated root
    mov r3  #0  ;@ Lower bound for bisection
    mov r4, #64 ;@ Upper bound for intersection MSB (64b)
    mov r5, #65 ;@ Upper Bound for intersection LSB (64b)

;@ BISECTION FOR SQRT:
;@ For sqrt(A) start with two initial values a lower value (LOW) than sqrt(A), and a higher value (HIGH) than sqrt(A) where A is a positive real number
;@ Let the Midpoint - m be, m=(L+H)/2.
;@ does m^2 = A?
;@ If m^2 < A let L = m
;@ else m^2 > A let H = M

search:
    add r6, r3, r4  ;@ S=(L+H)
    rrx r6, r6     ;@ S/2: r6 is the midpoint calculated using a Rotate Rightwith Extend (bitwise shift right by one (divide by 2)
    mul r6, r6, r6
    teq r6, r0      ;@ Test Equality between A and m^2
    beq continue
    bgt UpdateH
    blt UpdateL
    b search
continue:
    mov r2, r6
UpdateH:
    mov r4, r6
    b search

UpdateL:
    mov r3, r6
    b search
