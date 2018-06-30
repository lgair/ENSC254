.global asm_main
.align 4
memory: .space 2000000
.align 4

asm_main:
  	LDR R0, =0x41210000 	;@ r0 is the address of LED
  	LDR R1, =0x41200000 	;@ r1 is button addresses
  	LDR R3, =memory 		;@ array address
  	LDR R7, =0b10000000 	;@ LED number we are turning on or off
  	MOV R8, #0 				;@ debouncer
  	LDR R9, =#650000 		;@ might be too long lower the value
  	MOV R10, #0
  	MOV R11, #0
  	MOV R12, #0
  	MOV R4, #0
	mov r2, #4

  	check:
		MOV R8, #0			;@ delay counter
		LDR R5, [R1]		;@ current state
		cmp r5, r11			;@ r11 is previous state of buttons starts at 0
		bgt isPushed
		bmi isReleased
		beq off
	isPushed:
		eors r12 , r11, r5	;@ r12 most recent button pressed
		b delay
	isReleased:
		eors r12, r5, r11	;@ r12 most recent button released
		b delay
	delay: 					;@ wait for the button to settle down
		ADD R8, R8, #1
		CMP R8,R9
		BNE delay
		beq LEDState
	LEDState:
		and r6, r10, r7	    ;@ and summed LED's with the target LED to check for collisions
		cmp r6 , #0
		bne ShiftLED
		beq noShift
	noShift:				;@ determine if we are adding/subtracting LED from state
		cmp r5, r11			;@ compare the button states again
		mul r12, r12, r2	;@ multiply the button by 4 to calculate the offset maybe we need to use another register
		;@str r7, [r3, r12]	;@ load state of LED value at mem location with offset of r12
		mov r11, r5			;@ current state of buttons now becomes previous state
		bgt addToState
		blt removeFromState
		beq check			;@ no delta therefore wait and check for new button press
	addToState:
		orr r10, r10, r7	;@ add new light to LEDState register
		str r10, [r0]		;@ write to LED's
		str r7, [r3, r12]	;@ store individual LED value to memory with offset or r12
		                    ;@ maybe put check to see if mem is storing properly
		b check 			;@ LED should light, wait for new button press
	removeFromState:
		ldr r4, [r3, r12]	;@ Load LED value corresponding to button released
		eor r10, r10, r4	;@ remove this from the LED state
		b off
	ShiftLED:
		lsr r7, r7, #1		;@ colision detected, shift right once
		eors r7, #0			;@ check if we have reached LED0
		beq EdgeCase
		bne check
	EdgeCase:
		ldr r7, =#0b10000000;@ reset to LED7 if we reach LED0
		b check
	off:					;@ turn off LED when no button is pressed
  		STR R10, [R0]		;@ turns off repective LED's
  		b check

