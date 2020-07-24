
.text


SPEED_FAST = 15
SPEED_NORMAL = 10


.global drawPaddle
drawPaddle:
	push {fp, lr}
	mov		fp, sp
	push {r4}
	
	ldr		r0, =G_paddleCurrentWidth
	ldr		r0, [r0] // get width
	cmp		r0, #128 
	ldreq		r0, =smallPaddleMap
	ldrne		r0, =bigPaddleMap
	ldr		r1, =G_paddleCurrentXPosition
	ldr		r1, [r1] // x
	mov		r2, #704 // y (constant)
	moveq		r3, #128 // width (small)
	movne		r3, #160 // width (big)
	mov		r4, #32 // height
	bl		drawImage
	
	pop {r4}
	pop {fp, lr}
	bx		lr



.global resetPaddlePosition
resetPaddlePosition:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =G_paddleCurrentXPosition
	ldr		r1, =G_paddleInitXPosition
	ldr		r1, [r1] // get init xpos
	str		r1, [r0] // reset current xpos to init value
	
	pop {fp, lr}
	bx		lr

	
	
.global movePaddleLeft
movePaddleLeft:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =G_paddleCurrentXPosition
	ldr		r1, =G_paddleCurrentSpeed
	ldr		r1, [r1] // get the speed constant
	ldr		r2, [r0] // get current xpos
	sub		r2, r1 // xpos -= speed
	cmp		r2, #32 // left wall bound
	movlt		r2, #32 // if paddle went into left wall, move it right to be flush with wall
	str		r2, [r0] // update the xpos
	
	pop {fp, lr}
	bx		lr
	
	
	
.global movePaddleRight
movePaddleRight:	
	push {fp, lr}
	mov		fp, sp
	push {r4}	

	ldr		r0, =G_paddleCurrentXPosition
	ldr		r1, =G_paddleCurrentSpeed
	ldr		r1, [r1] // get the speed constant
	ldr		r2, [r0] // get current xpos
	add		r2, r1 // xpos += speed
	ldr		r3, =G_paddleCurrentWidth
	ldr		r3, [r3] // get width
	ldr		r4, =736 // right wall bound
	sub		r4, r3 // r4 = 736-width
	
	cmp		r2, r4 // compare new xpos to right bound for paddle left side
	movgt		r2, r4 // if paddle went into right wall, move it left to be flush with wall
	str		r2, [r0] // update the xpos
	
	pop {r4}
	pop {fp, lr}
	bx		lr

	
.global	resetPaddleSpeed
resetPaddleSpeed:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_paddleCurrentSpeed
	ldr		r1, =G_paddleInitSpeed
	ldr		r1, [r1] // get init value (NORMAL)
	str		r1, [r0] // reset current value to init value

	pop {fp, lr}	
	bx		lr


.global setPaddleSpeedFast
setPaddleSpeedFast:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_paddleCurrentSpeed
	mov		r1, #SPEED_FAST
	str		r1, [r0] //set current speed = FAST

	pop {fp, lr}
	bx		lr


.global resetPaddleWidth
resetPaddleWidth:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_paddleCurrentWidth
	ldr		r1, =G_paddleInitWidth
	ldr		r1, [r1] // get init size
	str		r1, [r0] // reset size back to init value

	pop {fp, lr}
	bx		lr



.global setPaddleBig
setPaddleBig:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_paddleCurrentWidth
	ldr		r1, [r0] // get current width
	cmp		r1, #128
	bne		setPaddleBigEnd // if paddle is not currently small, dont do anything

	// get here if going from small paddle to big paddle...

	mov		r1, #160
	str		r1, [r0] // update width to BIG

	ldr		r0, =G_paddleCurrentXPosition
	ldr		r1, [r0] // get xpos
	sub		r1, #16 // need to update xpos to accomodate new size
	str		r1, [r0] // update xpos

setPaddleBigEnd:

	pop {fp, lr}
	bx		lr




.data

G_paddleCurrentSpeed:
	.word 0

G_paddleInitSpeed:
	.word 10 // normal = 10, fast = 15

.global G_paddleCurrentXPosition
G_paddleCurrentXPosition:
	.word 0
	
G_paddleInitXPosition:
	.word 320
	
	
.global G_paddleCurrentWidth
G_paddleCurrentWidth:
	.word 0


G_paddleInitWidth:
	.word 128	
	




	
