
.text

TRUE = 1
FALSE = 0

MODE_STUCK = 0
MODE_FREE = 1

SPEED_SLOW = 0
SPEED_FAST = 1


.global drawBall
drawBall:
	push {fp, lr}
	mov		fp, sp
	push {r4}
	
	ldr		r0, =ballMap
	ldr		r1, =G_ballCurrentXPosition
	ldr		r1, [r1] // x
	ldr		r2, =G_ballCurrentYPosition
	ldr		r2, [r2] // y
	mov		r3, #16 // width
	mov		r4, #16 // height
	bl		drawImage
	
	pop {r4}
	pop {fp, lr}
	bx		lr

	
	
.global resetBallPositionAndMode
resetBallPositionAndMode:
	push {fp, lr}
	mov		fp, sp

	// reset xpos
	ldr		r0, =G_ballCurrentXPosition
	ldr		r1, =G_ballInitXPosition
	ldr		r1, [r1] // get init xpos
	str		r1, [r0] // reset current xpos to init value
	
	// reset ypos
	ldr		r0, =G_ballCurrentYPosition
	ldr		r1, =G_ballInitYPosition
	ldr		r1, [r1] // get init ypos
	str		r1, [r0] // reset current ypos to init value
	
	// reset mode
	ldr		r0, =G_ballCurrentMode
	ldr		r1, =G_ballInitMode
	ldr		r1, [r1] // get init mode
	str		r1, [r0] // reset current mode to init value
	
	pop {fp, lr}
	bx		lr



// normally call this after resetting speed status
.global resetBallVelocity
resetBallVelocity:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_ballCurrentSpeedStatus
	ldr		r0, [r0] // get speed status

	cmp		r0, #SPEED_FAST
	bne		resetBallVelocitySlow

	// get here if ball is in FAST status...

	ldr		r0, =G_ballCurrentXVelocity
	ldr		r1, =G_ballInitXVelocityFast
	ldr		r1, [r1] // get fast value
	str		r1, [r0] // reset value

	ldr		r0, =G_ballCurrentYVelocity
	ldr		r1, =G_ballInitYVelocityFast
	ldr		r1, [r1] // get fast value
	str		r1, [r0] // reset value

	b		resetBallVelocityEnd

resetBallVelocitySlow:

	// get here if ball is in SLOW status...

	ldr		r0, =G_ballCurrentXVelocity
	ldr		r1, =G_ballInitXVelocitySlow
	ldr		r1, [r1] // get slow value
	str		r1, [r0] // reset value

	ldr		r0, =G_ballCurrentYVelocity
	ldr		r1, =G_ballInitYVelocitySlow
	ldr		r1, [r1] // get slow value
	str		r1, [r0] // reset value

resetBallVelocityEnd:	

	pop {fp, lr}
	bx		lr



	
// ASSUME BALL MOVES AFTER PADDLE	
.global moveBall
moveBall:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_ballCurrentMode
	ldr		r0, [r0] // get mode	
	cmp		r0, #MODE_STUCK
	bne		moveBall_Free
moveBall_Stuck:
	// if ball is stuck to paddle...

	ldr		r0, =G_paddleCurrentWidth
	ldr		r0, [r0] // paddle width (numerator)
	mov		r1, #2 // denominator
	bl		Int_Div
	// r0 = width / 2
	sub		r0, #8 // take off half the width of ball to get offset of ball.x from paddle.x

	ldr		r1, =G_paddleCurrentXPosition
	ldr		r1, [r1] // paddle xpos

	add		r1, r0 // add offset from paddle left side to ball left side to get xpos of ball
	ldr		r2, =G_ballCurrentXPosition
	str		r1, [r2] // set xpos to match paddle movement
	
	mov		r0, #688
	ldr		r1, =G_ballCurrentYPosition
	str		r0, [r1] // set ypos to be stuck on top of paddle (init ypos value)

	b		moveBall_End
moveBall_Free:	
	// otherwise, if ball is moving aroung game area...
	ldr		r0, =G_ballCurrentXPosition
	ldr		r1, =G_ballCurrentXVelocity
	ldr		r1, [r1] // get xvel
	ldr		r2, [r0] // get xpos
	add		r2, r1 // xpos += xvel
	str		r2, [r0] // update xpos
	
	ldr		r0, =G_ballCurrentYPosition
	ldr		r1, =G_ballCurrentYVelocity
	ldr		r1, [r1] // get yvel
	ldr		r2, [r0] // get ypos
	add		r2, r1 // ypos += yvel
	str		r2, [r0] // update ypos

moveBall_End:

	// after ball has been just moved, check if any collision needs to change it's position/velocity (before next render)
	bl		checkCollision_Paddle // check collision with paddle 
	bl		resetBricksStatus // reset status of bricks before checking collisions
	bl	 	checkCollision_Bricks // check collision with bricks (overlap inside brick area)
	bl		checkCollision_Walls // need to do this after brick check, check collision with walls (position out of bounds)
	
	pop {fp, lr}
	bx		lr



	
.global setBallMode_FREE	
setBallMode_FREE:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =G_ballCurrentMode
	mov		r1, #MODE_FREE
	str		r1, [r0] // set ball free
	
	pop {fp, lr}
	bx		lr



.global reboundRight
reboundRight:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_ballCurrentXVelocity
	ldr		r1, [r0]
	cmp		r1, #0
	movlt		r2, #-1
	mullt		r2, r1 // get positive value of xvel
	strlt		r2, [r0]

	pop {fp, lr}
	bx		lr



.global reboundLeft
reboundLeft:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_ballCurrentXVelocity
	ldr		r1, [r0]
	cmp		r1, #0
	movgt		r2, #-1
	mulgt		r2, r1 // get negative value of xvel
	strgt		r2, [r0]

	pop {fp, lr}
	bx		lr



.global reboundDown
reboundDown:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_ballCurrentYVelocity
	ldr		r1, [r0]
	cmp		r1, #0
	movlt		r2, #-1
	mullt		r2, r1 // get positive value of yvel
	strlt		r2, [r0]		

	pop {fp, lr}
	bx		lr



.global reboundUp
reboundUp:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_ballCurrentYVelocity
	ldr		r1, [r0]
	cmp		r1, #0
	movgt		r2, #-1
	mulgt		r2, r1 // get negative value of yvel
	strgt		r2, [r0] 

	pop {fp, lr}
	bx		lr





.global	checkCollision_Walls
checkCollision_Walls:
	push {fp, lr}
	mov		fp, sp
	push {r4, r5, r6}

	ldr		r4, =G_ballCurrentXPosition
	ldr		r5, [r4] 
	
	// check for left wall collision...
	cmp		r5, #32 // left bound
	bllt		reboundRight
	movlt		r5, #32
	strlt		r5, [r4]

	// check for right wall collision...
	ldr		r6, =720
	cmp		r5, r6 // right bound
	blgt		reboundLeft
	movgt		r5, r6
	strgt		r5, [r4]


	ldr		r4, =G_ballCurrentYPosition
	ldr		r5, [r4]

	// check for top wall collision...
	cmp		r5, #160 // 
	bllt		reboundDown
	movlt		r5, #160
	strlt		r5, [r4]

	// check for bottom "wall" collision... 
	ldr		r6, =752
	cmp		r5, r6
	blgt		reboundUp
	movgt		r5, r6
	strgt		r5, [r4]	
	blgt		decrementLives
	blgt		resetBallPositionAndMode
	blgt		resetBallVelocity

	pop {r4, r5, r6}
	pop {fp, lr}
	bx		lr



.global paddleReboundLeftSide
paddleReboundLeftSide:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_ballCurrentSpeedStatus
	ldr		r0, [r0] // get speed status
	cmp		r0, #SPEED_FAST
	bne		paddleReboundLeftSideSlow

	// get here if FAST...

	ldr		r0, =G_ballCurrentXVelocity
	mov		r1, #-10
	str		r1, [r0] // set xvel = -10

	ldr		r0, =G_ballCurrentYVelocity
	mov		r1, #-10
	str		r1, [r0] // set yvel = -10

	b		paddleReboundLeftSideEnd

paddleReboundLeftSideSlow:
	// get here if SLOW...

	ldr		r0, =G_ballCurrentXVelocity
	mov		r1, #-5
	str		r1, [r0] // set xvel = -5

	ldr		r0, =G_ballCurrentYVelocity
	mov		r1, #-5
	str		r1, [r0] // set yvel = -5

paddleReboundLeftSideEnd:

	pop {fp, lr}
	bx		lr



.global paddleReboundRightSide
paddleReboundRightSide:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_ballCurrentSpeedStatus
	ldr		r0, [r0] // get speed status
	cmp		r0, #SPEED_FAST
	bne		paddleReboundRightSideSlow

	// get here if FAST...

	ldr		r0, =G_ballCurrentXVelocity
	mov		r1, #10
	str		r1, [r0] // set xvel = 10

	ldr		r0, =G_ballCurrentYVelocity
	mov		r1, #-10
	str		r1, [r0] // set yvel = -10

	b		paddleReboundRightSideEnd

paddleReboundRightSideSlow:
	// get here if SLOW...

	ldr		r0, =G_ballCurrentXVelocity
	mov		r1, #5
	str		r1, [r0] // set xvel = 5

	ldr		r0, =G_ballCurrentYVelocity
	mov		r1, #-5
	str		r1, [r0] // set yvel = -5

paddleReboundRightSideEnd:

	pop {fp, lr}
	bx		lr



.global paddleReboundMiddle
paddleReboundMiddle:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_ballCurrentSpeedStatus
	ldr		r0, [r0] // get speed status
	cmp		r0, #SPEED_FAST
	bne		paddleReboundMiddleSlow

	// get here if FAST...

	ldr		r0, =G_ballCurrentXVelocity
	ldr		r1, [r0] // get xvel
	cmp		r1, #0
	movlt		r1, #-6 // ball moving left
	movge		r1, #6 // ball moving right or straight down
	str		r1, [r0] // set xvel

	ldr		r0, =G_ballCurrentYVelocity
	mov		r1, #-12
	str		r1, [r0] 

	b		paddleReboundMiddleEnd

paddleReboundMiddleSlow:
	// get here if SLOW...

	ldr		r0, =G_ballCurrentXVelocity
	ldr		r1, [r0] // get xvel
	cmp		r1, #0
	movlt		r1, #-3 // ball moving left
	movge		r1, #3 // ball moving right or straight down
	str		r1, [r0] // set xvel

	ldr		r0, =G_ballCurrentYVelocity
	mov		r1, #-6
	str		r1, [r0] 

paddleReboundMiddleEnd:

	pop {fp, lr}
	bx		lr




.global checkCollision_Paddle
checkCollision_Paddle:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_ballCurrentMode
	ldr		r0, [r0] // get mode
	cmp		r0, #MODE_FREE
	bne		checkCollision_PaddleEnd // only collide with paddle when ball is free

	ldr		r0, =G_ballCurrentYPosition
	ldr		r0, [r0] // get ball ypos
	ldr		r1, =688
	cmp		r0, r1 // only check for paddle collision when ball is at a certain y range (688 to 704)
	blt		checkCollision_PaddleEnd
	ldr		r1, =704
	cmp		r0, r1 
	bgt		checkCollision_PaddleEnd	

	// get here if ball is in y-range...

	ldr		r0, =G_ballCurrentXPosition
	ldr		r0, [r0] // get ball xpos
	ldr		r1, =G_paddleCurrentXPosition
	ldr		r1, [r1] // get paddle xpos

	sub		r2, r1, #16 // paddle.x - 16
	cmp		r0, r2
	blt		checkCollision_PaddleEnd // ball is too far left of paddle

	add		r2, r1, #24 // paddle.x + 24
	cmp		r0, r2
	blle		paddleReboundLeftSide
	ble		checkCollision_PaddleEnd

	ldr		r2, =G_paddleCurrentWidth
	ldr		r2, [r2] // width
	sub		r3, r2, #40 // r3 = width - 40
	
	add		r3, r1 // r3 = paddle.x + (width - 40)
	cmp		r0, r3
	blle		paddleReboundMiddle
	ble		checkCollision_PaddleEnd

	add		r3, r2, r1 // r3 = paddle.x + width
	cmp		r0, r3
	blle		paddleReboundRightSide
	
	// otherwise, ball is too far right of paddle
	
checkCollision_PaddleEnd:

	pop {fp, lr}
	bx		lr



.global checkCollision_Bricks
checkCollision_Bricks:
	push {fp, lr}
	mov		fp, sp
	push {r4, r5, r6, r7, r8, r9}

	ldr		r4, =G_ballCurrentXPosition
	ldr		r4, [r4] // get ball.x
	ldr		r5, =G_ballCurrentYPosition
	ldr		r5, [r5] // get ball.y

	// get "centre position" of ball (r4,r5)
	add		r4, #8 // r4 = x+8
	add		r5, #8 // r5 = y+8

	/*
		1 2 3
                8 * 4    - adjacent bricks
                7 6 5
	*/

	// first check if centre is not located inside of a brick:

	mov		r0, r4 // set 1st arg (x)
	mov		r1, r5 // set 2nd arg (y)
	bl		pixelToBrickNumber
	cmp		r0, #-1 // see if a valid brick was returned
	beq		checkCollision_Bricks_Cross // if -1 (not inside a brick), can check normally the adjacent squares

	// get here if inside a brick's area (now check if brick is broken or not)
	
	// 1st arg already set (r0 = brick #)
	bl		isBrickBroken
	cmp		r0, #TRUE
	beq		checkCollision_Bricks_Cross

	mov		r9, #-1

	// get here if centre is overlapping a brick:
	// step the ball back the way it came until it's centre is no longer overlapping a brick (recursive call)
	// first get the velocity step and move the ball back
	ldr		r6, =G_ballCurrentXVelocity
	ldr		r6, [r6] // get xvel
	ldr		r7, =G_ballCurrentYVelocity
	ldr		r7, [r7] // get yvel
	// get absolute values of xvel and yvel
	cmp		r6, #0
	mullt		r6, r9
	cmp		r7, #0
	mullt		r7, r9
	cmp		r6, r7 // compare |xvel| vs |yvel|
	movlt		r8, r6 // set r2 = |xvel| if lower
	movge		r8, r7 // set r2 = |yvel| if lower (or equal)
	// get step velocities (absolute values)
	// could break if one velocity is 0 (but that shouldn't occur)
	
	mov		r0, r6 // set 1st arg (|xvel|)
	mov		r1, r8 // set 2nd arg (denominator)
	bl		Int_Div
	// r0 = quotient (|xvel|.step)
	ldr		r1, =G_ballCurrentXVelocity
	ldr		r1, [r1]
	cmp		r1, #0
	mulgt		r0, r9 // negate step value
	ldr		r2, =G_ballCurrentXPosition
	ldr		r3, [r2]
	add		r3, r0 // step xpos back
	str		r3, [r2] // update xpos
	
	mov		r0, r7 // set 1st arg (|yvel|)
	mov		r1, r8 // set 2nd arg (denominator)
	bl		Int_Div
	// r0 = quotient (|yvel|.step)
	ldr		r1, =G_ballCurrentYVelocity
	ldr		r1, [r1]
	cmp		r1, #0
	mulgt		r0, r9 // negate step value
	ldr		r2, =G_ballCurrentYPosition
	ldr		r3, [r2]
	add		r3, r0 // step ypos back
	str		r3, [r2] // update ypos
	
	bl		checkCollision_Bricks // recursive call
	
	b		checkCollision_Bricks_End

checkCollision_Bricks_Cross:
	// check 2, 4, 6, 8	
	// 2 overlaps pixel at (r4, r5-32)
	// 4 overlaps pixel at (r4+64, r5)	
	// 6 overlaps pixel at (r4, r5+32)
	// 8 overlaps pixel at (r4-64, r5)

	// actions for 2:
	mov		r0, r4 // set 1st arg (x)
	sub		r1, r5, #32 // set 2nd arg (y)
	bl		pixelToBrickNumber

	// r0 = brick # (1st arg) - already set
	bl		checkBCollision // check for bottom collision on 2
	mov		r6, r0 // save flag of if a collision occurred or not

	// actions for 4:
	add		r0, r4, #64 // set 1st arg (x)
	mov		r1, r5 // set 2nd arg (y)
	bl		pixelToBrickNumber

	// r0 = brick # (1st arg) - already set
	bl		checkLCollision // check for left collision on 4
	mov		r7, r0 // save flag of if a collision occurred or not

	// actions for 6:
	mov		r0, r4 // set 1st arg (x)
	add		r1, r5, #32 // set 2nd arg (y)
	bl		pixelToBrickNumber

	// r0 = brick # (1st arg) - already set
	bl		checkTCollision // check for top collision on 6
	mov		r8, r0 // save flag of if a collision occurred or not

	// actions for 8:
	sub		r0, r4, #64 // set 1st arg (x)
	mov		r1, r5 // set 2nd arg (y)
	bl		pixelToBrickNumber

	// r0 = brick # (1st arg) - already set
	bl		checkRCollision // check for right collision on 8
	mov		r9, r0 // save flag of if a collision occurred or not

checkCollision_Bricks_Corners:
	// check (3) - if NOT 2 && NOT 4
	// check (5) - if NOT 4 && NOT 6
	// check (7) - if NOT 6 && NOT 8
	// check (1) - if NOT 8 && NOT 2

checkCollision_Bricks_3:
	cmp		r6, #TRUE
	beq		checkCollision_Bricks_5
	cmp		r7, #TRUE
	beq		checkCollision_Bricks_5

	// get here if neither 2 nor 4 had collisions
	// check 3:
	// 3 overlaps pixel at (r4+64, r5-32)

	// actions for 3:
	add		r0, r4, #64 // set 1st arg (x)
	sub		r1, r5, #32 // set 2nd arg (y)
	bl		pixelToBrickNumber

	push {r0}	// save brick #
	// r0 = brick # (1st arg) - already set
	bl		checkBCollision // check for bottom collision on 3
	pop {r0} 	// set 1st arg (restore brick #)
	bl		checkLCollision // check for left collision on 3

checkCollision_Bricks_5:
	cmp		r7, #TRUE
	beq		checkCollision_Bricks_7
	cmp		r8, #TRUE
	beq		checkCollision_Bricks_7

	// get here if neither 4 nor 6 had collisions
	// check 5
	// 5 overlaps pixel at (r4+64, r5+32)

	// actions for 5:
	add		r0, r4, #64 // set 1st arg (x)
	add		r1, r5, #32 // set 2nd arg (y)
	bl		pixelToBrickNumber

	push {r0}       // save brick #
	// r0 = brick # (1st arg) - already set
	bl		checkTCollision // check for top collision on 5
	pop {r0} 	// set 1st arg (restore brick #)
	bl		checkLCollision // check for left collision on 5

checkCollision_Bricks_7:
	cmp		r8, #TRUE
	beq		checkCollision_Bricks_1
	cmp		r9, #TRUE
	beq		checkCollision_Bricks_1

	// get here if neither 6 nor 8 had collisions
	// check 7
	// 7 overlaps pixel at (r4-64, r5+32)

	// actions for 7:
	sub		r0, r4, #64 // set 1st arg (x)
	add		r1, r5, #32 // set 2nd arg (y)
	bl		pixelToBrickNumber

	push {r0}	// save brick #
	// r0 = brick # (1st arg) - already set
	bl		checkTCollision // check for top collision on 7
	pop {r0} 	// set 1st arg (restore brick #)
	bl		checkRCollision // check for right collision on 7

checkCollision_Bricks_1:
	cmp		r9, #TRUE
	beq		checkCollision_Bricks_End
	cmp		r6, #TRUE
	beq		checkCollision_Bricks_End

	// get here if neither 8 nor 2 had collisions
	// check 1
	// 1 overlaps pixel at (r4-64, r5-32)

	// actions for 1:
	sub		r0, r4, #64 // set 1st arg (x)
	sub		r1, r5, #32 // set 2nd arg (y)
	bl		pixelToBrickNumber

	push {r0}	 // save brick #
	// r0 = brick # (1st arg) - already set
	bl		checkBCollision // check for bottom collision on 1
	pop {r0} 	// set 1st arg (restore brick #)
	bl		checkRCollision // check for right collision on 1

checkCollision_Bricks_End:

	pop {r4, r5, r6, r7, r8, r9}
	pop {fp, lr}
	bx		lr




// check if ball has collided with the left side of the specified brick
// param: r0 = brick #
// return: r0 = TRUE/FALSE (did a collision occur and the reaction take place?)
.global checkLCollision
checkLCollision:
	push {fp, lr}
	mov		fp, sp
	push {r4, r5, r6, r7, r8, r9}

	cmp		r0, #0
	movlt		r0, #FALSE // if brick # is invalid... (no collision)
	blt		checkLCollisionEnd
	cmp		r0, #32
	movgt		r0, #FALSE // if brick # is invalid... (no collision)
	bgt		checkLCollisionEnd 

	mov		r4, r0 // save brick #

	// r0 = brick number (1st arg already set)
	bl		isBrickBroken
	cmp		r0, #TRUE
	moveq		r0, #FALSE // if brick is broken... (no collision)
	beq		checkLCollisionEnd // can't collide with a broken brick

	// get here if brick is not broken...
	ldr		r5, =G_ballCurrentXPosition
	ldr		r5, [r5] // get ball.x
	ldr		r6, =G_ballCurrentYPosition
	ldr		r6, [r6] // get ball.y

	mov		r0, r4 // set 1st arg
	bl		getBrickXPosition 
	// r0 = brick.x
	mov		r7, r0 // save brick.x

	mov		r0, r4 // set 1st arg
	bl		getBrickYPosition
	// r0 = brick.y
	mov		r8, r0 // save brick.y

	// now check if right side of ball has overlapped left side of brick:
	// x range is [brick.x - 16, brick.x - 5]
	// y range is [brick.y - 16, brick.y + 32]
	sub		r9, r7, #16 // r9 = brick.x - 16
	cmp		r5, r9 
	movlt		r0, #FALSE
	blt		checkLCollisionEnd

	sub		r9, r7, #5 // r9 = brick.x - 5
 	cmp		r5, r9
	movgt		r0, #FALSE
	bgt		checkLCollisionEnd

	sub		r9, r8, #16 // r9 = brick.y - 16
	cmp		r6, r9 
	movlt		r0, #FALSE
	blt		checkLCollisionEnd

	add		r9, r8, #32 // r9 = brick.y + 32
	cmp		r6, r9
	movgt		r0, #FALSE
	bgt		checkLCollisionEnd

	// get here if a left side collision occurred...
	bl		reboundLeft // ball rebounds to the left
	mov		r0, r4 // set 1st arg (brick #)	
	bl		damageBrick // brick hp decreases
	// set ball.x = brick.x - 16
	ldr		r0, =G_ballCurrentXPosition
	sub		r1, r7, #16 
	str		r1, [r0] 
	mov		r0, #TRUE // a collision occurred and reaction took place	

checkLCollisionEnd: 

	pop {r4, r5, r6, r7, r8, r9}
	pop {fp, lr}
	bx		lr





// check if ball has collided with the right side of the specified brick
// param: r0 = brick #
// return: r0 = TRUE/FALSE (did a collision occur and the reaction take place?)
.global checkRCollision
checkRCollision:
	push {fp, lr}
	mov		fp, sp
	push {r4, r5, r6, r7, r8, r9}

	cmp		r0, #0
	movlt		r0, #FALSE // if brick # is invalid... (no collision)
	blt		checkRCollisionEnd
	cmp		r0, #32
	movgt		r0, #FALSE // if brick # is invalid... (no collision)
	bgt		checkRCollisionEnd 

	mov		r4, r0 // save brick #

	// r0 = brick number (1st arg already set)
	bl		isBrickBroken
	cmp		r0, #TRUE
	moveq		r0, #FALSE // if brick is broken... (no collision)
	beq		checkRCollisionEnd // can't collide with a broken brick

	// get here if brick is not broken...
	ldr		r5, =G_ballCurrentXPosition
	ldr		r5, [r5] // get ball.x
	ldr		r6, =G_ballCurrentYPosition
	ldr		r6, [r6] // get ball.y

	mov		r0, r4 // set 1st arg
	bl		getBrickXPosition 
	// r0 = brick.x
	mov		r7, r0 // save brick.x

	mov		r0, r4 // set 1st arg
	bl		getBrickYPosition
	// r0 = brick.y
	mov		r8, r0 // save brick.y

	// now check if left side of ball has overlapped right side of brick:
	// x range is [brick.x + 53, brick.x + 64]
	// y range is [brick.y - 16, brick.y + 32]
	add		r9, r7, #53 // r9 = brick.x + 53
	cmp		r5, r9 
	movlt		r0, #FALSE
	blt		checkRCollisionEnd

	add		r9, r7, #64 // r9 = brick.x + 64
 	cmp		r5, r9
	movgt		r0, #FALSE
	bgt		checkRCollisionEnd

	sub		r9, r8, #16 // r9 = brick.y - 16
	cmp		r6, r9 
	movlt		r0, #FALSE
	blt		checkRCollisionEnd

	add		r9, r8, #32 // r9 = brick.y + 32
	cmp		r6, r9
	movgt		r0, #FALSE
	bgt		checkRCollisionEnd


	// get here if a right side collision occurred...
	bl		reboundRight // ball rebounds to the right
	mov		r0, r4 // set 1st arg (brick #)	
	bl		damageBrick // brick hp decreases
	// set ball.x = brick.x + 64
	ldr		r0, =G_ballCurrentXPosition
	add		r1, r7, #64 
	str		r1, [r0] 


	mov		r0, #TRUE // a collision occurred and reaction took place	

checkRCollisionEnd: 

	pop {r4, r5, r6, r7, r8, r9}
	pop {fp, lr}
	bx		lr



// check if ball has collided with the top side of the specified brick
// param: r0 = brick #
// return: r0 = TRUE/FALSE (did a collision occur and the reaction take place?)
.global checkTCollision
checkTCollision:
	push {fp, lr}
	mov		fp, sp
	push {r4, r5, r6, r7, r8, r9}

	cmp		r0, #0
	movlt		r0, #FALSE // if brick # is invalid... (no collision)
	blt		checkTCollisionEnd
	cmp		r0, #32
	movgt		r0, #FALSE // if brick # is invalid... (no collision)
	bgt		checkTCollisionEnd 

	mov		r4, r0 // save brick #

	// r0 = brick number (1st arg already set)
	bl		isBrickBroken
	cmp		r0, #TRUE
	moveq		r0, #FALSE // if brick is broken... (no collision)
	beq		checkTCollisionEnd // can't collide with a broken brick

	// get here if brick is not broken...
	ldr		r5, =G_ballCurrentXPosition
	ldr		r5, [r5] // get ball.x
	ldr		r6, =G_ballCurrentYPosition
	ldr		r6, [r6] // get ball.y

	mov		r0, r4 // set 1st arg
	bl		getBrickXPosition 
	// r0 = brick.x
	mov		r7, r0 // save brick.x

	mov		r0, r4 // set 1st arg
	bl		getBrickYPosition
	// r0 = brick.y
	mov		r8, r0 // save brick.y



	// now check if bottom side of ball has overlapped top side of brick:
	// x range is [brick.x - 16, brick.x + 64]
	// y range is [brick.y - 16, brick.y - 5]
	sub		r9, r7, #16 // r9 = brick.x - 16
	cmp		r5, r9 
	movlt		r0, #FALSE
	blt		checkTCollisionEnd

	add		r9, r7, #64 // r9 = brick.x + 64
 	cmp		r5, r9
	movgt		r0, #FALSE
	bgt		checkTCollisionEnd

	sub		r9, r8, #16 // r9 = brick.y - 16
	cmp		r6, r9 
	movlt		r0, #FALSE
	blt		checkTCollisionEnd

	sub		r9, r8, #5 // r9 = brick.y - 5
	cmp		r6, r9
	movgt		r0, #FALSE
	bgt		checkTCollisionEnd

	// get here if a top side collision occurred...
	bl		reboundUp // ball rebounds upwards
	mov		r0, r4 // set 1st arg (brick #)	
	bl		damageBrick // brick hp decreases
	// set ball.y = brick.y - 16
	ldr		r0, =G_ballCurrentYPosition
	sub		r1, r8, #16 
	str		r1, [r0] 


	mov		r0, #TRUE // a collision occurred and reaction took place	

checkTCollisionEnd: 

	pop {r4, r5, r6, r7, r8, r9}
	pop {fp, lr}
	bx		lr




// check if ball has collided with the bottom side of the specified brick
// param: r0 = brick #
// return: r0 = TRUE/FALSE (did a collision occur and the reaction take place?)
.global checkBCollision
checkBCollision:
	push {fp, lr}
	mov		fp, sp
	push {r4, r5, r6, r7, r8, r9}

	cmp		r0, #0
	movlt		r0, #FALSE // if brick # is invalid... (no collision)
	blt		checkBCollisionEnd
	cmp		r0, #32
	movgt		r0, #FALSE // if brick # is invalid... (no collision)
	bgt		checkBCollisionEnd 

	mov		r4, r0 // save brick #

	// r0 = brick number (1st arg already set)
	bl		isBrickBroken
	cmp		r0, #TRUE
	moveq		r0, #FALSE // if brick is broken... (no collision)
	beq		checkBCollisionEnd // can't collide with a broken brick

	// get here if brick is not broken...
	ldr		r5, =G_ballCurrentXPosition
	ldr		r5, [r5] // get ball.x
	ldr		r6, =G_ballCurrentYPosition
	ldr		r6, [r6] // get ball.y

	mov		r0, r4 // set 1st arg
	bl		getBrickXPosition 
	// r0 = brick.x
	mov		r7, r0 // save brick.x

	mov		r0, r4 // set 1st arg
	bl		getBrickYPosition
	// r0 = brick.y
	mov		r8, r0 // save brick.y



	// now check if top side of ball has overlapped bottom side of brick:
	// x range is [brick.x - 16, brick.x + 64]
	// y range is [brick.y + 21, brick.y + 32]
	sub		r9, r7, #16 // r9 = brick.x - 16
	cmp		r5, r9 
	movlt		r0, #FALSE
	blt		checkBCollisionEnd

	add		r9, r7, #64 // r9 = brick.x + 64
 	cmp		r5, r9
	movgt		r0, #FALSE
	bgt		checkBCollisionEnd

	add		r9, r8, #21 // r9 = brick.y + 21
	cmp		r6, r9 
	movlt		r0, #FALSE
	blt		checkBCollisionEnd

	add		r9, r8, #32 // r9 = brick.y + 32
	cmp		r6, r9
	movgt		r0, #FALSE
	bgt		checkBCollisionEnd


	// get here if a bottom side collision occurred...
	bl		reboundDown // ball rebounds downwards
	mov		r0, r4 // set 1st arg (brick #)	
	bl		damageBrick // brick hp decreases

	// set ball.y = brick.y + 32
	ldr		r0, =G_ballCurrentYPosition
	add		r1, r8, #32 
	str		r1, [r0] 


	mov		r0, #TRUE // a collision occurred and reaction took place	

checkBCollisionEnd: 

	pop {r4, r5, r6, r7, r8, r9}
	pop {fp, lr}
	bx		lr





.global resetBallSpeedStatus
resetBallSpeedStatus:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_ballCurrentSpeedStatus
	ldr		r1, =G_ballInitSpeedStatus
	ldr		r1, [r1] // get init value
	str		r1, [r0] // reset speed status to in value

	pop {fp, lr}
	bx		lr



.global setBallSpeedSlow
setBallSpeedSlow:
	push {fp, lr}
	mov		fp, sp
	push {r4, r8}

	ldr		r0, =G_ballCurrentSpeedStatus
	ldr		r1, [r0] // get current speed status
	cmp		r1, #SPEED_FAST
	bne		setBallSpeedSlowEnd // only set speed slow if going from fast to slow

	// get here if going from FAST to SLOW...

	mov		r1, #SPEED_SLOW
	str		r1, [r0] // update speed status to SLOW

	// now change the speed (halve it)

	mov		r8, #-1

	// xvel:
	ldr		r4, =G_ballCurrentXVelocity
	ldr		r0, [r4] // get xvel
	cmp		r0, #0
	mullt		r0, r8 // xvel *= -1 (get absolute value)
	// r0 = numerator
	mov		r1, #2 // set 2nd arg (denominator)
	bl		Int_Div // divide speed by 2
	// r0 = |xvel| // 2
	ldr		r1, [r4] // get xvel
	cmp		r1, #0
	mullt		r0, r8 // r0 = -|xvel| // 2 (set proper direction)
	str		r0, [r4] // update xvel
	
	// yvel:
	ldr		r4, =G_ballCurrentYVelocity
	ldr		r0, [r4] // get yvel
	cmp		r0, #0
	mullt		r0, r8 // yvel *= -1 (get absolute value)
	// r0 = numerator
	mov		r1, #2 // set 2nd arg (denominator)
	bl		Int_Div // divide speed by 2
	// r0 = |yvel| // 2
	ldr		r1, [r4] // get yvel
	cmp		r1, #0
	mullt		r0, r8 // r0 = -|yvel| // 2 (set proper direction)
	str		r0, [r4] // update yvel

setBallSpeedSlowEnd:

	pop {r4, r8}
	pop {fp, lr}	
	bx		lr



.data

G_ballCurrentXPosition:
	.word 0
	
G_ballInitXPosition:
	.word 376
	
G_ballCurrentYPosition:
	.word 0
	
G_ballInitYPosition:
	.word 687 // just above paddle to avoid collision at start
	
G_ballCurrentXVelocity:
	.word 0
	
G_ballInitXVelocityFast:
	.word 10

G_ballInitXVelocitySlow:
	.word 5
	
G_ballCurrentYVelocity:
	.word 0
	
G_ballInitYVelocityFast:
	.word -10

G_ballInitYVelocitySlow:
	.word -5
	
G_ballCurrentMode:
	.word 0 // 0 (STUCK) or 1 (FREE) ONLY
	
G_ballInitMode:
	.word 0  // initially ball is stuck to paddle


G_ballCurrentSpeedStatus:
	.word 0


G_ballInitSpeedStatus:
	.word 1 // init speed as FAST





	
	
	
	
	
	
	
	
	
