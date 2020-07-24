
.text

HIDDEN = 0 // underneath brick
VISIBLE = 1 // brick broken 
INVISIBLE = 2 // paddle collected VP or VP fell off screen 

TRUE = 1
FALSE = 0



.global checkPaddleValuePackPaddleCollision
checkPaddleValuePackPaddleCollision:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_paddleValuePackCurrentStatus
	ldr		r0, [r0]
	cmp		r0, #VISIBLE // only check for collision when VP is visible
	bne		checkPaddleValuePackPaddleCollisionEnd

	// get here if VP is visible...

	// check y-range:
	ldr		r0, =G_paddleValuePackCurrentYPosition		
	ldr		r0, [r0] // get ypos
	
	cmp		r0, #672
	blt		checkPaddleValuePackPaddleCollisionEnd

	ldr		r1, =735
	cmp		r0, r1
	bgt		checkPaddleValuePackPaddleCollisionEnd

	// get here if VP is in y-range for possible collision		

	// check x-range:
	// VP is at x = 352
	ldr		r0, =G_paddleCurrentXPosition
	ldr		r0, [r0] // get paddle.x
	
	ldr		r1, =G_paddleCurrentWidth
	ldr		r1, [r1] // get paddle width
	mov		r2, #352
	sub		r2, r1 // r2 = 352 - width
	cmp		r0, r2 // left bound
	blt		checkPaddleValuePackPaddleCollisionEnd

	ldr		r1, =416
	cmp		r0, r1 // right bound
	bgt		checkPaddleValuePackPaddleCollisionEnd

	// get here if Paddle VP has collided with paddle
	bl		incrementScoreValuePack
	bl		setPaddleBig
	bl		setPaddleValuePackInvisible
	ldr		r0, =G_paddleValuePackCurrentYPosition
	mov		r1, #736
	str		r1, [r0] // update ypos of VP to be at bottom of screen

checkPaddleValuePackPaddleCollisionEnd:

	pop {fp, lr}
	bx		lr



.global checkBallValuePackPaddleCollision
checkBallValuePackPaddleCollision:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_ballValuePackCurrentStatus
	ldr		r0, [r0]
	cmp		r0, #VISIBLE // only check for collision when VP is visible
	bne		checkBallValuePackPaddleCollisionEnd

	// get here if VP is visible...

	// check y-range:
	ldr		r0, =G_ballValuePackCurrentYPosition		
	ldr		r0, [r0] // get ypos
	
	cmp		r0, #672
	blt		checkBallValuePackPaddleCollisionEnd

	ldr		r1, =735
	cmp		r0, r1
	bgt		checkBallValuePackPaddleCollisionEnd

	// get here if VP is in y-range for possible collision		

	// check x-range:
	// VP is at x = 96
	ldr		r0, =G_paddleCurrentXPosition
	ldr		r0, [r0] // get paddle.x
	
	ldr		r1, =G_paddleCurrentWidth
	ldr		r1, [r1] // get paddle width
	mov		r2, #96
	sub		r2, r1 // r2 = 96 - width
	cmp		r0, r2 // left bound
	blt		checkBallValuePackPaddleCollisionEnd

	ldr		r1, =160
	cmp		r0, r1 // right bound
	bgt		checkBallValuePackPaddleCollisionEnd

	// get here if Ball VP has collided with paddle
	bl		incrementScoreValuePack
	bl		setBallSpeedSlow
	bl		setBallValuePackInvisible
	ldr		r0, =G_ballValuePackCurrentYPosition
	mov		r1, #736
	str		r1, [r0] // update ypos of VP to be at bottom of screen

checkBallValuePackPaddleCollisionEnd:

	pop {fp, lr}
	bx		lr






// call this every frame
.global checkBallValuePackBrick
checkBallValuePackBrick:
	push {fp, lr}
	mov 		fp, sp

	// underneath brick #23

	ldr		r0, =G_ballValuePackCurrentStatus
	ldr		r0, [r0]
	cmp		r0, #HIDDEN // only check for broken brick if HIDDEN
	bne		checkBallValuePackBrickEnd

	// get here if VP is hidden...

	mov		r0, #23
	bl		isBrickBroken // check if brick has broken yet
	cmp		r0, #TRUE
	bne		checkBallValuePackBrickEnd 

	// get here if brick was broken...

	bl		setBallValuePackVisible // flag VP as visible

checkBallValuePackBrickEnd:

	pop {fp, lr}
	bx		lr




// call this every frame
.global checkPaddleValuePackBrick
checkPaddleValuePackBrick:
	push {fp, lr}
	mov 		fp, sp

	// underneath brick #5

	ldr		r0, =G_paddleValuePackCurrentStatus
	ldr		r0, [r0]
	cmp		r0, #HIDDEN // only check for broken brick if HIDDEN
	bne		checkPaddleValuePackBrickEnd

	// get here if VP is hidden...

	mov		r0, #5
	bl		isBrickBroken // check if brick has broken yet
	cmp		r0, #TRUE
	bne		checkPaddleValuePackBrickEnd 

	// get here if brick was broken...

	bl		setPaddleValuePackVisible // flag VP as visible

checkPaddleValuePackBrickEnd:

	pop {fp, lr}
	bx		lr












// call this after moving VP
.global checkBallValuePackBottom
checkBallValuePackBottom:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_ballValuePackCurrentStatus
	ldr		r0, [r0]
	cmp		r0, #VISIBLE
	bne		checkBallValuePackBottomEnd // only check for bottom collision if VP is visible

	// get here if VP is visible...
	ldr		r0, =G_ballValuePackCurrentYPosition
	ldr		r1, [r0] // get ypos
	cmp		r1, #736 // bottom of map
	blt		checkBallValuePackBottomEnd // no collision if above lower bound
	
	// get here if VP has collided with bottom...
	mov		r1, #736
	str		r1, [r0] // clamp ypos to not go offscreen
	bl		setBallValuePackInvisible 		

checkBallValuePackBottomEnd:

	pop {fp, lr}
	bx		lr




// call this after moving VP
.global checkPaddleValuePackBottom
checkPaddleValuePackBottom:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_paddleValuePackCurrentStatus
	ldr		r0, [r0]
	cmp		r0, #VISIBLE
	bne		checkPaddleValuePackBottomEnd // only check for bottom collision if VP is visible

	// get here if VP is visible...
	ldr		r0, =G_paddleValuePackCurrentYPosition
	ldr		r1, [r0] // get ypos
	cmp		r1, #736 // bottom of map
	blt		checkPaddleValuePackBottomEnd // no collision if above lower bound
	
	// get here if VP has collided with bottom...
	mov		r1, #736
	str		r1, [r0] // clamp ypos to not go offscreen
	bl		setPaddleValuePackInvisible 		

checkPaddleValuePackBottomEnd:

	pop {fp, lr}
	bx		lr



.global moveBallValuePack
moveBallValuePack:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_ballValuePackCurrentStatus
	ldr		r0, [r0]
	cmp		r0, #VISIBLE
	bne		moveBallValuePackEnd // only move pack if visible

	// get here if VP is visible...

	ldr		r0, =G_ballValuePackCurrentYPosition
	ldr		r1, =G_ballValuePackYVelocity
	ldr		r1, [r1] // get yvel
	ldr		r2, [r0] // get current ypos
	add		r2, r1 // ypos += yvel
	str		r2, [r0] // update ypos

moveBallValuePackEnd:

	pop {fp, lr}
	bx		lr




.global movePaddleValuePack
movePaddleValuePack:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_paddleValuePackCurrentStatus
	ldr		r0, [r0]
	cmp		r0, #VISIBLE
	bne		movePaddleValuePackEnd // only move pack if visible

	// get here if VP is visible...

	ldr		r0, =G_paddleValuePackCurrentYPosition
	ldr		r1, =G_paddleValuePackYVelocity
	ldr		r1, [r1] // get yvel
	ldr		r2, [r0] // get current ypos
	add		r2, r1 // ypos += yvel
	str		r2, [r0] // update ypos

movePaddleValuePackEnd:

	pop {fp, lr}
	bx		lr



// call this after checking for collisions
.global drawBallValuePack
drawBallValuePack:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_ballValuePackCurrentStatus
	ldr		r0, [r0] 
	cmp		r0, #VISIBLE
	bne		drawBallValuePackEnd // don't draw VP if not visible

	// get here if VP is visible...

	ldr		r0, =ballValuePackMap
	mov		r1, #96 // x (constant)	
	ldr		r2, =G_ballValuePackCurrentYPosition
	ldr		r2, [r2] // y
	mov		r3, #64 // width
	mov		r4, #32 // height
	bl		drawImage	

drawBallValuePackEnd:

	pop {fp, lr}
	bx		lr




.global drawPaddleValuePack
drawPaddleValuePack:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_paddleValuePackCurrentStatus
	ldr		r0, [r0] 
	cmp		r0, #VISIBLE
	bne		drawPaddleValuePackEnd // don't draw VP if not visible

	// get here if VP is visible...

	ldr		r0, =paddleValuePackMap
	mov		r1, #352 // x (constant)	
	ldr		r2, =G_paddleValuePackCurrentYPosition
	ldr		r2, [r2] // y
	mov		r3, #64 // width
	mov		r4, #32 // height
	bl		drawImage	

drawPaddleValuePackEnd:

	pop {fp, lr}
	bx		lr



.global setBallValuePackVisible
setBallValuePackVisible:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_ballValuePackCurrentStatus
	mov		r1, #VISIBLE
	str		r1, [r0]

	pop {fp, lr}
	bx		lr




.global setBallValuePackInvisible
setBallValuePackInvisible:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_ballValuePackCurrentStatus
	mov		r1, #INVISIBLE
	str		r1, [r0]

	pop {fp, lr}
	bx		lr




.global setPaddleValuePackVisible
setPaddleValuePackVisible:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_paddleValuePackCurrentStatus
	mov		r1, #VISIBLE
	str		r1, [r0]

	pop {fp, lr}
	bx		lr




.global setPaddleValuePackInvisible
setPaddleValuePackInvisible:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_paddleValuePackCurrentStatus
	mov		r1, #INVISIBLE
	str		r1, [r0]

	pop {fp, lr}
	bx		lr






.global resetBallValuePack
resetBallValuePack:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_ballValuePackCurrentYPosition
	ldr		r1, =G_ballValuePackInitYPosition
	ldr		r1, [r1] // get init value
	str		r1, [r0] // reset value

	ldr		r0, =G_ballValuePackCurrentStatus
	ldr		r1, =G_ballValuePackInitStatus
	ldr		r1, [r1] // get init value
	str		r1, [r0] // reset value

	pop {fp, lr}
	bx		lr



.global resetPaddleValuePack
resetPaddleValuePack:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_paddleValuePackCurrentYPosition
	ldr		r1, =G_paddleValuePackInitYPosition
	ldr		r1, [r1] // get init value
	str		r1, [r0] // reset value

	ldr		r0, =G_paddleValuePackCurrentStatus
	ldr		r1, =G_paddleValuePackInitStatus
	ldr		r1, [r1] // get init value
	str		r1, [r0] // reset value

	pop {fp, lr}
	bx		lr






.data

G_ballValuePackYVelocity:
	.word 5

G_ballValuePackCurrentYPosition:
	.word 0

G_ballValuePackInitYPosition:
	.word 320

G_ballValuePackCurrentStatus:
	.word 0

G_ballValuePackInitStatus:
	.word 0 // inititally hidden



G_paddleValuePackYVelocity:
	.word 5

G_paddleValuePackCurrentYPosition:
	.word 0

G_paddleValuePackInitYPosition:
	.word 256

G_paddleValuePackCurrentStatus:
	.word 0

G_paddleValuePackInitStatus:
	.word 0 // initially hidden




