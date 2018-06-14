.global asm_main

asm_main:
    ldr r0, =0x41210000     ;@ r0 is the address of the LED's 
    ldr r1, =0              ;@ r1 is the value of the LED's we are turning on/off
    ldr r2, =0              ;@ r2 is the count 
    ldr r3, =1000000        ;@ loop max
OnCycle:
    ldr r1, =0b10000000
    str r1, [r0]
    add r2, r2, #1
    cmp r2, r3
    beq MidCycle1
    b OnCycle
MidCycle1:
    mov r2, #0
    b OffCycle
MidCycle2:
    mov r2, #0
    b OnCycle
OffCycle:
    ldr r1, =0b000000000
    str r1, [r0]
    add r2, r2, #1
    cmp r2, r3
    beq MidCycle2
    b Offcycle
