.text

TRUE = 1
FALSE = 0

HARD = 3
MEDIUM = 2
SOFT = 1
BROKEN = 0

UNLOCKED = 0 // hp can change 
LOCKED = 1 // hp can't change (was just hit)


.global drawBricks
drawBricks:
	push {fp, lr}
	mov		fp, sp
	push {r4, r5, r6, r7}
	
	mov		r5, #0 // brick index (i)
	ldr		r6, =G_bricksCurrentType
	b		drawBricksCond1
drawBricksLoop1:
	mov		r0, r5 // numerator = i
	mov		r1, #11 // denominator = 11
	bl		Int_Div
	// r0 = quotient (i // 11) (row)
	// r1 = remainder (i % 11) (col)
	mov		r2, #64
	mul		r2, r1
	add		r2, #32 // x = 32 + 64*col
	
	mov		r3, #32
	mul		r3, r0
	add		r3, #256 // y = 256 + 32*row
	
	ldr		r7, [r6, r5, lsl #2] // r7 = brick type	
drawBricksIf1:
	cmp		r7, #HARD
	bne		drawBricksElseIf1a
	// if HARD...
	ldr		r0, =hardBrickMap
	mov		r1, r2 // x
	mov		r2, r3 // y
	mov		r3, #64 // width
	mov		r4, #32 // height
	bl		drawImage

	b		drawBricksEndIf1
drawBricksElseIf1a:
	cmp		r7, #MEDIUM
	bne		drawBricksElseIf1b
	// if MEDIUM...
	ldr		r0, =mediumBrickMap
	mov		r1, r2 // x
	mov		r2, r3 // y
	mov		r3, #64 // width
	mov		r4, #32 // height
	bl		drawImage

	b		drawBricksEndIf1
drawBricksElseIf1b:
	cmp		r7, #SOFT
	bne		drawBricksEndIf1
	// if SOFT...
	ldr		r0, =softBrickMap
	mov		r1, r2 // x
	mov		r2, r3 // y
	mov		r3, #64 // width
	mov		r4, #32 // height
	bl		drawImage
	
drawBricksEndIf1:	
	
	add		r5, #1 // i++
drawBricksCond1:
	cmp		r5, #33 // total number of bricks
	blt		drawBricksLoop1
	
	pop {r4, r5, r6, r7}
	pop {fp, lr}
	bx		lr


	
.global resetBricksType
resetBricksType:
	push {fp, lr}
	mov		fp, sp
	
	mov		r0, #0 // brick index (i)
	ldr		r1, =G_bricksCurrentType
	ldr		r2, =G_bricksInitType
	b		resetBricksTypeCond1
resetBricksTypeLoop1:
	ldr		r3, [r2, r0, lsl #2] // get init value for brick
	str		r3, [r1, r0, lsl #2] // reset current value to init value 
	
	add		r0, #1 // i++
resetBricksTypeCond1:
	cmp		r0, #33 // total number of bricks
	blt		resetBricksTypeLoop1
	
	pop {fp, lr}
	bx		lr
	
	
		
.global resetBricksStatus
resetBricksStatus:
	push {fp, lr}
	mov		fp, sp
	
	mov		r0, #0 // brick index (i)
	ldr		r1, =G_bricksCurrentStatus
	ldr		r2, =G_bricksInitStatus
	b		resetBricksStatusCond1
resetBricksStatusLoop1:
	ldr		r3, [r2, r0, lsl #2] // get init value for brick
	str		r3, [r1, r0, lsl #2] // reset current value to init value 
	
	add		r0, #1 // i++
resetBricksStatusCond1:
	cmp		r0, #33 // total number of bricks
	blt		resetBricksStatusLoop1
	
	pop {fp, lr}
	bx		lr
	


// assumes ONLY types of bricks are 0-3	
// return: r0 (TRUE/FALSE)	
.global are_AllBricksBroken	
are_AllBricksBroken:
	push {fp, lr}
	mov		fp, sp
	
	mov		r0, #TRUE // assume initially that all bricks are broken
	mov		r1, #0 // brick index (i)
	ldr		r2, =G_bricksCurrentType
	b		are_AllBricksBrokenCond1
are_AllBricksBrokenLoop1:
	ldr		r3, [r2, r1, lsl #2]
	cmp		r3, #BROKEN
	movne		r0, #FALSE // if a non-broken brick was found...
	bne		are_AllBricksBrokenEnd

	add		r1, #1 // i++
are_AllBricksBrokenCond1:
	cmp		r1, #33 // total number of bricks
	blt		are_AllBricksBrokenLoop1
	
are_AllBricksBrokenEnd:	
	
	pop {fp, lr}
	bx		lr
	
	
// param: r0 = x
// param: r1 = y	
// return: r0 = brick number (0-32) if a brick overlaps this pixel or -1 if none do 	
.global pixelToBrickNumber
pixelToBrickNumber:	
	push {fp, lr}
	mov		fp, sp
	push {r4, r5, r6, r7, r8}
	
	mov		r4, r0 // save x
	mov		r5, r1 // save y
	
	cmp		r4, #32 // lower bound of x
	movlt		r0, #-1
	blt		pixelToBrickNumberEnd
	ldr		r8, =735
	cmp		r4, r8 // upper bound of x
	movgt		r0, #-1
	bgt		pixelToBrickNumberEnd
	cmp		r5, #256 // lower bound of y
	movlt		r0, #-1
	blt		pixelToBrickNumberEnd
	ldr		r8, =351
	cmp		r5, r8 // upper bound of y
	movgt		r0, #-1
	bgt		pixelToBrickNumberEnd
	
	// otherwise, we know that some brick overlaps this pixel
	sub		r0, r4, #32 // numerator = x-32
	mov		r1, #64 // denominator = 64
	bl		Int_Div 
	mov		r6, r0 // col = (x-32) // 64
	
	sub		r0, r5, #256 // numerator = y-256
	mov		r1, #32 // denominator = 32
	bl		Int_Div
	mov		r7, r0 // row = (y-256) // 32
	
	mov		r0, #11 // r0 = 11
	mul		r0, r7 // r0 = 11*row
	add		r0, r6 // r0 = 11*row + col (brick #)
	
pixelToBrickNumberEnd:	
	
	pop {r4, r5, r6, r7, r8}
	pop {fp, lr}
	bx		lr
	
	
// param: r0 = brick # that was hit by ball	
.global damageBrick
damageBrick:
	push {fp, lr}
	mov		fp, sp
	push {r4}
	
	mov		r4, r0 // save brick #

	// if brick is locked, dont do damage
	ldr		r0, =G_bricksCurrentStatus
	ldr		r0, [r0, r4, lsl #2] // get brick's status
	cmp		r0, #LOCKED
	beq		damageBrick_End // if locked, branch over damage part

	// get here if brick is unlocked...
	ldr 		r1, =G_bricksCurrentType
	ldr		r2, [r1, r4, lsl #2] // get current hp
	sub		r2, #1 // hp--
	cmp		r2, #0
	movlt		r2, #0 // if hp went negative, set it to 0
	str		r2, [r1, r4, lsl #2] // set new hp	

	bl		incrementScoreBrick

	ldr		r0, =G_bricksCurrentStatus
	mov		r1, #LOCKED
	str		r1, [r0, r4, lsl #2] // set this brick LOCKED after it takes damage until it gets unlocked next frame

damageBrick_End:

	pop {r4}
	pop {fp, lr}
	bx		lr



// param: r0 = brick #
// return: r0 = brick status
.global getBrickStatus
getBrickStatus:
	push {fp, lr}
	mov		fp, sp

	ldr		r1, =G_bricksCurrentStatus
	ldr		r0, [r1, r0, lsl #2] // return brick status

	pop {fp, lr}
	bx		lr



// param: r0 = brick #
.global lockBrick
lockBrick:
	push {fp, lr}
	mov		fp, sp

	ldr		r1, =G_bricksCurrentStatus
	mov		r2, #LOCKED
	str		r2, [r1, r0, lsl #2] 

	pop {fp, lr}
	bx		lr



// param: r0 = brick # (from 0 to 32)
// return: r0 = brick.x
.global getBrickXPosition
getBrickXPosition:
	push {fp, lr}
	mov		fp, sp

	// x = 32 + 64*col
	// col = brick# % 11
	// r0 = brick # (numerator) - already set
	mov		r1, #11 // denominator
	bl		Int_Div
	// r1 = col
	lsl		r1, #6 // r1 *= 2^6 (64)		
	add		r0, r1, #32 // return x = 64*col + 32

	pop {fp, lr}
	bx		lr



// param: r0 = brick # (from 0 to 32)
// return: r0 = brick.y
.global getBrickYPosition
getBrickYPosition:
	push {fp, lr}
	mov		fp, sp

	// y = 256 + 32*row
	// row = brick # // 11
	// r0 = brick # (numerator) - already set
	mov		r1, #11 // denominator
	bl		Int_Div
	// r0 = row
	lsl		r0, #5 // r1 *= 2^5 (32)
	add		r0, #256 // return y = 32*row + 256

	pop {fp, lr}
	bx		lr



// param: r0 = brick # (0 to 32)
// return: TRUE/FALSE - is brick broken? 
.global isBrickBroken
isBrickBroken:
	push {fp, lr}
	mov		fp, sp

	ldr		r1, =G_bricksCurrentType
	ldr		r1, [r1, r0, lsl #2] // get brickType[i] 
	cmp		r1, #BROKEN
	moveq		r0, #TRUE
	movne		r0, #FALSE	

	pop {fp, lr}
	bx		lr
	



.data

G_bricksCurrentType:
	.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

G_bricksInitType:
	.word 3, 2, 1, 1, 3, 3, 3, 1, 1, 2, 3
	.word 2, 3, 2, 3, 2, 1, 2, 3, 2, 3, 2
	.word 1, 2, 3, 1, 1, 2, 1, 1, 3, 2, 1	 
	
G_bricksCurrentStatus:
	.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
	
G_bricksInitStatus:
	.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
	
	
