/*
    Author: Aaron Hornby
    UCID: 10176084
    Latest Date: 03/24/2018		

--- This program implements a simple device driver for a SNES controller. It registers button taps and button holds. 

*/

.text

// CONSTANTS:
FALSE = 0
TRUE = 1

NEITHER = 0
TAPPED = 1
HELD = 2

PRESSED = 0
NOTPRESSED = 1


.global initDriver
initDriver:
	push {fp, lr}
	mov		fp, sp
	
	bl		getGpioPtr // r0 = address of GPIOSET0 (base GPIO address)
	ldr		r1, =gpio_base_address // address of label
	str		r0, [r1] // store base GPIO address		
	
	pop {fp, lr}
	bx		lr
	

	
// should call this function every fixed time step (short, but long enough to deal with hardware inconsistencies)
.global processData
processData:
	push {fp, lr}
	mov		fp, sp
	
	bl	 	Read_SNES // r0 = BUTTONS register (pressed info for this read)
	bl		updatePressedButtons // set previous = current and current = new	
	bl		updateButtonStates
	
	pop {fp, lr}
	bx		lr


	
// param: r0 = BUTTONS register for this read
updatePressedButtons:
	push {fp, lr}
	mov		fp, sp
	push {r4, r5}
	
	ldr		r1, =pressedButtonsPrevious
	ldr		r2, =pressedButtonsCurrent
	
	// 1. move current into previous
	
	mov		r3, #0 // index of array (init)
	b		updatePressedButtonsCond1
updatePressedButtonsLoop1:
	ldr		r4, [r2, r3, lsl #2] // get current[i]
	str		r4, [r1, r3, lsl #2] // set previous[i] = current[i]
	add		r3, #1 // i++
updatePressedButtonsCond1:
	cmp		r3, #12 // length of array
	blt		updatePressedButtonsLoop1	
	
	// 2. move new into current	
	
	mov		r3, #0 // index of array (init)
	mov		r4, #1 // init bitmask
	b		updatePressedButtonsCond2
updatePressedButtonsLoop2:
	tst		r0, r4 // mask BUTTONS register
	moveq		r5, #0 // extract bit value
	movne		r5, #1 // extract bit value
	str		r5, [r2, r3, lsl #2] // set current[i] to new value
	lsl		r4, #1 // shift bitmask over by 1 bit
	add		r3, #1 // i++
updatePressedButtonsCond2:
	cmp		r3, #12 // length of array
	blt		updatePressedButtonsLoop2
	
	pop {r4, r5}
	pop {fp, lr}
	bx		lr
	
	
	
updateButtonStates:	
	push {fp, lr}
	mov		fp, sp
	
	mov 		r0, #0 // i (init)
	ldr		r1, =pressedButtonsPrevious
	ldr		r2, =pressedButtonsCurrent
	ldr		r3, =buttonStates
	b		updateButtonStatesCond1
updateButtonStatesLoop1:	
	ldr 		r4, [r1, r0, lsl #2] // previous[i]
	ldr		r5, [r2, r0, lsl #2] // current[i]
		
	cmp		r5, #NOTPRESSED
	bne		currentPressed
currentNotPressed: // if not pressed in current read...	
	mov		r6, #NEITHER // new state
	b		updateButtonStates_endif1
currentPressed:
	cmp		r4, #NOTPRESSED
	moveq		r6, #TAPPED // new state
	movne		r6, #HELD // new state
updateButtonStates_endif1:	
	str		r6, [r3, r0, lsl #2] // state[i]
	
	add		r0, #1 // i++
updateButtonStatesCond1:	
	cmp		r0, #12 // length of array
	blt		updateButtonStatesLoop1
	
	pop {fp, lr}
	bx		lr
	
	
	
// are all buttons currently not pressed?	
// return: are all buttons currently not pressed?
.global is_SNES_Reset	
is_SNES_Reset: 
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =buttonStates
	mov		r1, #0 // i
	mov		r2, #TRUE // assume that all buttons will not be pressed initially
	b		is_SNES_ResetCond1
is_SNES_ResetLoop1:
	ldr		r3, [r0, r1, lsl #2] // get next button's state
	cmp		r3, #NEITHER // if this button is TAPPED or HELD, specify that SNES hasnt been reset and break out of loop  
	movne		r2, #FALSE
	bne		is_SNES_AfterLoop1
	// otherwise (if button is not pressed, continue to check next button)
	add		r1, #1 // i++
is_SNES_ResetCond1:	
	cmp		r1, #12
	blt		is_SNES_ResetLoop1

is_SNES_AfterLoop1:	
	mov		r0, r2
	
	pop {fp, lr}
	bx		lr
	
	

// Integer divider function
// Param: r0 = numerator
// Param: r1 = denominator
// Return: r0 = quotient
// Return: r1 = remainder
.global Int_Div
Int_Div:
	push {fp, lr}
	mov		fp, sp

	mov		r2, r1 // init "product" = quotient * denominator to be the denominator
	mov		r3, #0 // init quotient
	b		int_div_cond1 // pre-test

int_div_loop1:	
	add		r3, #1	// quotient++
	add		r2, r1	// product += denominator	
int_div_cond1:
	cmp		r0, r2	// compare numerator vs. product
	bge		int_div_loop1 // loop if numerator >= product

	// otherwise, fall through to calculate final results...
	sub		r2, r1 // product -= denominator (reduce the product to be the largest multiple of denominator that is <= numerator)
	sub		r1, r0, r2 // return r1 (remainder) = numerator - product
	mov		r0, r3 // return r0 (quotient)

	pop {fp, lr}
	bx		lr // return

	
	
// Initializes a GPIO line (general)
// Param: r0 = line number
// Param: r1 = function code
Init_GPIO:
	push {fp, lr}
	mov		fp, sp
	push {r4, r5, r6, r7, r8}
 
	mov		r4, r0 // save line number (0 to 53) into r4
	mov		r5, r1 // save function code (3 bits) into r5

	mov		r0, r4 // numerator = line number
	mov		r1, #10 // denominator = 10
	bl		Int_Div // n = line number / 10
	mov		r6, r0 // r6 = quotient (n)
	mov		r7, r1 // r7 = remainder

	ldr		r0, =gpio_base_address // label address
	ldr		r0, [r0] // gpio base address
	
	ldr		r1, [r0, r6, lsl #2] // r1 = copy of GPFSEL{n} at address = base + 4*n
	mov		r2, #7 // r2 = 0b0111 (bitmask)
	mov		r8, #3 
	mul		r8, r7 // r8 = 3*remainder (index of first bit in register corresponding to pin)
	lsl		r2, r8 // shift bitmask to line up with respective bits
	bic		r1, r2 // clear the bits corresponding to pin
	lsl		r5, r8 // shift bitmask (function code) to line up with respective bits
	orr		r1, r5 // set pin function in r1
	str		r1, [r0, r6, lsl #2] // write copy back into GPRFSEL{n}

	pop {r4, r5, r6, r7, r8}
	pop {fp, lr}
	bx		lr // return

	
	
// Writes a bit to the SNES latch line (GPIO9)
// Param: r0 = bit value
Write_Latch:
	push {fp, lr}
	mov		fp, sp
	push {r4}
	
	mov		r4, r0 // save bit value into r4

	mov		r0, #9 // line number
	mov		r1, #1 // write-function code
	bl		Init_GPIO // init latch to WRITE

	ldr		r0, =gpio_base_address // label address
	ldr		r0, [r0] // gpio base address

	mov		r1, #1
	lsl		r1, #9 // line up the 1 with the 9th bit (bit #8)
	teq		r4, #0 // determine whether to use CLR or SET based on what bit value was passed in
	streq		r1, [r0, #40] // GPCLR0
	strne		r1, [r0, #28] // GPSET0

	pop {r4}
	pop {fp, lr}
	bx		lr

	
	
// Writes a bit to the SNES clock line (GPIO11)
// Param: r0 = bit value
Write_Clock:
	push {fp, lr}
	mov		fp, sp
	push {r4}
	
	mov		r4, r0 // save bit value into r4

	mov 		r0, #11 // line number 
	mov		r1, #1 // write-function code
	bl		Init_GPIO // init clock to WRITE

	ldr		r0, =gpio_base_address // label address
	ldr		r0, [r0] // gpio base address

	mov		r1, #1
	lsl		r1, #11 // line up the 1 with the 11th bit (bit #10) 
	teq		r4, #0 // determine whether to use CLR or SET based on what bit value was passed in
	streq		r1, [r0, #40] // GPCLR0
	strne		r1, [r0, #28] // GPSET0

	pop {r4}
	pop {fp, lr}
	bx		lr

	
	
// Reads a bit from the SNES data line (GPIO10)
// Return: r0 = value of bit
Read_Data:
	push {fp, lr}
	mov		fp, sp

	mov		r0, #10 // line number
	mov		r1, #0 // read-function code
	bl		Init_GPIO // init data to READ

	ldr 		r0, =gpio_base_address // label address
	ldr		r0, [r0] // gpio base address
	ldr		r0, [r0, #52] // get copy of GPLEV0
	mov		r1, #1
	lsl		r1, #10 // line up the 1 with the 10th bit (bit #9)
	and		r0, r1 // mask out every other bit
	teq		r0, #0 // check if result of mask is 0000....0000 or 0000..1..0000
	moveq		r0, #0 // read a 0
	movne		r0, #1 // read a 1

	pop {fp, lr}
	bx		lr

	
	
// Reads input (buttons pressed) from a SNES controller
// Return: r0 = code of pressed button 
Read_SNES:
	push {fp, lr}
	mov		fp, sp
	push {r4, r10}

	mov		r10, #0 // init BUTTONS REGISTER

	mov		r0, #1
	bl		Write_Clock // write 1 to clock

	mov		r0, #1
	bl		Write_Latch // write 1 to latch

	mov		r0, #12
	bl		delayMicroseconds // wait(12) - to sample buttons

	mov		r0, #0
	bl		Write_Latch // write 0 to latch

	mov		r4, #0 // i = 0 (init bit to read)
pulseLoop:
	mov		r0, #6
	bl		delayMicroseconds // wait(6)
	
	mov		r0, #0
	bl		Write_Clock // write 0 to clock (falling edge)

	mov		r0, #6
	bl		delayMicroseconds // wait(6)

	bl		Read_Data // r0 = next read button cell value (0-pressed or 1-notPressed)
	
	lsl		r0, r4 // shift value by i to put in proper place (bit i) in BUTTONS
	add		r10, r0 // buttons[i] = value

	mov		r0, #1
	bl		Write_Clock // write 1 to clock (rising edge)

	add		r4, #1 // i++

	cmp		r4, #16  // i vs. 16
	blt		pulseLoop // if (i < 16) then loop to get value of next button   
	
	// get here after processing every button...

	mov		r0, r10 // return BUTTONS register

	pop {r4, r10}
	pop {fp, lr}
	bx		lr
	
	
	
// return: r0 = state of B (NEITHER-0, TAPPED-1 or HELD-2)	
.global getState_B
getState_B:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =buttonStates
	ldr		r0, [r0] 
	
	pop {fp, lr}
	bx		lr
	
	
	
// return: r0 = state of Y (NEITHER-0, TAPPED-1 or HELD-2)	
.global getState_Y
getState_Y:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =buttonStates
	ldr		r0, [r0, #4] 
	
	pop {fp, lr}
	bx		lr	
	
	
	
// return: r0 = state of SELECT (NEITHER-0, TAPPED-1 or HELD-2)	
.global getState_SELECT
getState_SELECT:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =buttonStates
	ldr		r0, [r0, #8] 
	
	pop {fp, lr}
	bx		lr	
	
	
	
// return: r0 = state of START (NEITHER-0, TAPPED-1 or HELD-2)	
.global getState_START
getState_START:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =buttonStates
	ldr		r0, [r0, #12] 
	
	pop {fp, lr}
	bx		lr	
	
	
	
// return: r0 = state of UP (NEITHER-0, TAPPED-1 or HELD-2)	
.global getState_UP
getState_UP:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =buttonStates
	ldr		r0, [r0, #16] 
	
	pop {fp, lr}
	bx		lr	
	
	
	
// return: r0 = state of DOWN (NEITHER-0, TAPPED-1 or HELD-2)	
.global getState_DOWN
getState_DOWN:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =buttonStates
	ldr		r0, [r0, #20] 
	
	pop {fp, lr}
	bx		lr	
	
	
	
// return: r0 = state of LEFT (NEITHER-0, TAPPED-1 or HELD-2)	
.global getState_LEFT
getState_LEFT:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =buttonStates
	ldr		r0, [r0, #24] 
	
	pop {fp, lr}
	bx		lr	
	
	
	
// return: r0 = state of RIGHT (NEITHER-0, TAPPED-1 or HELD-2)	
.global getState_RIGHT
getState_RIGHT:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =buttonStates
	ldr		r0, [r0, #28] 
	
	pop {fp, lr}
	bx		lr	
		
	
	
// return: r0 = state of A (NEITHER-0, TAPPED-1 or HELD-2)	
.global getState_A
getState_A:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =buttonStates
	ldr		r0, [r0, #32] 
	
	pop {fp, lr}
	bx		lr
	
	
	
// return: r0 = state of X (NEITHER-0, TAPPED-1 or HELD-2)	
.global getState_X
getState_X:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =buttonStates
	ldr		r0, [r0, #36] 
	
	pop {fp, lr}
	bx		lr	
	
	
	
// return: r0 = state of L (NEITHER-0, TAPPED-1 or HELD-2)	
.global getState_L
getState_L:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =buttonStates
	ldr		r0, [r0, #40] 
	
	pop {fp, lr}
	bx		lr	
	
	
	
// return: r0 = state of R (NEITHER-0, TAPPED-1 or HELD-2)	
.global getState_R
getState_R:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =buttonStates
	ldr		r0, [r0, #44] 
	
	pop {fp, lr}
	bx		lr		
	
	

.data

	.global gpio_base_address
gpio_base_address:	
    .word 0 // stores the address to GPIOSET0 (base GPIO address)
	
	.global	pressedButtonsPrevious
pressedButtonsPrevious: // was button pressed in previous read?	
    .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
       // B  Y  Se St Up  Do  Le  Ri  A  X  L  R	
	
	.global pressedButtonsCurrent
pressedButtonsCurrent: // was button pressed in this read?
    .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
       // B  Y  Se St Up  Do  Le  Ri  A  X  L  R
	   
	.global buttonStates   
buttonStates: // as a result of this read, is button NEITHER, TAPPED or HELD?	   
	.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	   // B  Y  Se St Up  Do  Le  Ri  A  X  L  R	





