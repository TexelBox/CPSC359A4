
.text


FALSE = 0
TRUE = 1


.global renderGame
renderGame:
	push {fp, lr}
	mov		fp, sp
	
	bl		drawGameBackground
	bl		drawScore
	bl		drawLives
	bl		drawBricks
	bl		drawBallValuePack
	bl		drawPaddleValuePack
	bl		drawPaddle
	bl		drawBall
	
	pop {fp, lr}
	bx		lr

	

.global renderGameWon
renderGameWon:
	push {fp, lr}
	mov		fp, sp

	bl		renderGame

	bl		drawGameWon
	bl		drawContinue

	pop {fp, lr}
	bx		lr



.global drawGameWon
drawGameWon:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =gameWonMap
	mov		r1, #64 // x
	mov		r2, #385 // y
	mov		r3, #640 // width
	mov		r4, #96 // height
	bl		drawImage

	pop {fp, lr}
	bx		lr



.global renderGameLost
renderGameLost:
	push {fp, lr}
	mov		fp, sp

	bl		renderGame

	bl		drawGameLost
	bl		drawContinue

	pop {fp, lr}
	bx		lr



.global drawGameLost
drawGameLost:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =gameLostMap
	mov		r1, #64 // x
	mov		r2, #384 // y
	mov		r3, #640 // width
	mov		r4, #96 // height
	bl		drawImage

	pop {fp, lr}
	bx		lr



.global drawContinue
drawContinue:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =continueMap
	mov		r1, #128 // x
	mov		r2, #512 // y
	mov		r3, #512 // width
	mov		r4, #32 // height
	bl		drawImage

	pop {fp, lr}
	bx		lr



.global drawScore
drawScore:
	push {fp, lr}
	mov		fp, sp
	push {r4, r5, r6, r7}

	ldr		r5, =G_currentScore
	ldr		r5, [r5] 

	cmp		r5, #0
	blt		drawScore_End

	// get here if >= 0
	// draw first digit
	
	mov		r0, r5 // set 1st arg (numerator)
	mov		r1, #10 // denominator
	bl		Int_Div

	mov		r6, r0 // save quotient
	mov		r0, r1	// set 1st arg
	bl		getDigitMap
	
	// 1st arg already set - address (r0)
	mov		r1, #384 // x
	mov		r2, #64 // y
	mov		r3, #32 // width
	mov		r4, #32 // height
	bl		drawImage

	cmp		r5, #10
	blt		drawScore_End

	// get here if >= 10
	// draw second digit

	mov		r0, r6 // set 1st arg (numerator)
	mov		r1, #10 // denominator
	bl		Int_Div

	mov		r6, r0 // save quotient
	mov		r0, r1 // set 1st arg
	bl		getDigitMap

	// 1st arg already set - address (r0)
	mov		r1, #352 // x
	mov		r2, #64 // y
	mov		r3, #32 // width
	mov		r4, #32 // height
	bl		drawImage

	cmp		r5, #100
	blt		drawScore_End

	// get here if >= 100
	// draw third digit
	
	mov		r0, r6 // set 1st arg (numerator)
	mov		r1, #10 // denominator
	bl		Int_Div

	mov		r6, r0 // save quotient
	mov		r0, r1 // set 1st arg
	bl		getDigitMap

	// 1st arg already set - address (r0)
	mov		r1, #320 // x
	mov		r2, #64 // y
	mov		r3, #32 // width
	mov		r4, #32 // height
	bl		drawImage

	cmp		r5, #1000
	blt		drawScore_End

	// get here if >= 1000
	// draw fourth digit

	mov		r0, r6 // set 1st arg (numerator)
	mov		r1, #10 // denominator
	bl		Int_Div

	mov		r6, r0 // save quotient
	mov		r0, r1 // set 1st arg
	bl		getDigitMap

	// 1st arg already set - address (r0)
	mov		r1, #288 // x
	mov		r2, #64 // y
	mov		r3, #32 // width
	mov		r4, #32 // height
	bl		drawImage

	ldr		r7, =10000
	cmp		r5, r7
	blt		drawScore_End

	// get here if >= 10000
	// draw fifth digit

	mov		r0, r6 // set 1st arg (numerator)
	mov		r1, #10 // denominator
	bl		Int_Div

	mov		r6, r0 // save quotient
	mov		r0, r1 // set 1st arg
	bl		getDigitMap

	// 1st arg already set - address (r0)
	mov		r1, #256 // x
	mov		r2, #64 // y
	mov		r3, #32 // width
	mov		r4, #32 // height
	bl		drawImage

	ldr		r7, =100000
	cmp		r5, r7
	blt		drawScore_End

	// get here if >= 100000
	// draw sixth digit

	mov		r0, r6 // set 1st arg (numerator)
	mov		r1, #10 // denominator
	bl		Int_Div

	mov		r6, r0 // save quotient
	mov		r0, r1 // set 1st arg
	bl		getDigitMap

	// 1st arg already set - address (r0)
	mov		r1, #224 // x
	mov		r2, #64 // y
	mov		r3, #32 // width
	mov		r4, #32 // height
	bl		drawImage

drawScore_End:

	pop {r4, r5, r6, r7}
	pop {fp, lr}
	bx		lr



// param: r0 = a digit from 0-9
// return: address of corresponding map for digit
.global getDigitMap
getDigitMap:
	push {fp, lr}
	mov		fp, sp

	cmp		r0, #0
	ldreq		r0, =zeroMap
	beq		getDigitMap_End

	cmp		r0, #1
	ldreq		r0, =oneMap
	beq		getDigitMap_End

	cmp		r0, #2
	ldreq		r0, =twoMap
	beq		getDigitMap_End

	cmp		r0, #3
	ldreq		r0, =threeMap
	beq		getDigitMap_End

	cmp		r0, #4
	ldreq		r0, =fourMap
	beq		getDigitMap_End

	cmp		r0, #5
	ldreq		r0, =fiveMap
	beq		getDigitMap_End

	cmp		r0, #6
	ldreq		r0, =sixMap
	beq		getDigitMap_End

	cmp		r0, #7
	ldreq		r0, =sevenMap
	beq		getDigitMap_End

	cmp		r0, #8
	ldreq		r0, =eightMap
	beq		getDigitMap_End

	ldr		r0, =nineMap

getDigitMap_End:

	pop {fp, lr}
	bx		lr





	
drawGameBackground:
	push {fp, lr}
	mov		fp, sp
	push {r4}
	
	ldr		r0, =gameBackgroundMap
	mov		r1, #0 // x
	mov		r2, #0 // y
	mov		r3, #768 // width
	mov		r4, #768 // height
	bl		drawImage
	
	pop {r4}
	pop {fp, lr}
	bx		lr



drawLives:
	push {fp, lr}
	mov		fp, sp
	push {r5}

	ldr		r5, =G_currentLives
	ldr		r5, [r5] // get lives
	
	cmp		r5, #1
	blt		drawLives_End
	// get here if at least 1 life left:
	// draw right heart
	ldr		r0, =heartMap
	mov		r1, #673 // x
	mov		r2, #65 // y
	mov		r3, #30 // width
	mov		r4, #30 // height
	bl		drawImage

	cmp		r5, #2
	blt		drawLives_End
	// get here if at least 2 lives left:
	// draw centre heart
	ldr		r0, =heartMap
	mov		r1, #641 // x
	mov		r2, #65 // y
	mov		r3, #30 // width
	mov		r4, #30 // height
	bl		drawImage

	cmp		r5, #3
	blt		drawLives_End
	// get here if at least 3 lives left:
	// draw left heart
	ldr		r0, =heartMap
	mov		r1, #609 // x
	mov		r2, #65 // y
	mov		r3, #30 // width
	mov		r4, #30 // height	
	bl		drawImage

drawLives_End:

	pop {r5}
	pop {fp, lr}
	bx		lr








.global resetLives
resetLives:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_currentLives
	ldr		r1, =G_initLives
	ldr		r1, [r1] // get init value
	str		r1, [r0] // reset current value to init value

	pop {fp, lr}
	bx		lr


.global resetScore
resetScore:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_currentScore
	ldr		r1, =G_initScore
	ldr		r1, [r1] // get init value
	str		r1, [r0] // reset current value to init value

	pop {fp, lr}
	bx		lr




.global decrementLives
decrementLives:	
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_currentLives
	ldr		r1, [r0] // get current value
	sub		r1, #1 // lives--
	cmp		r1, #0
	movlt		r1, #0 // prevent a negative lives value (safety)
	str		r1, [r0] // update lives

	pop {fp, lr}
	bx		lr


.global incrementScoreBrick // 1000
incrementScoreBrick:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_currentScore
	ldr		r1, [r0] // get current value
	add		r1, #1000 // +1000 every hit of a brick
	str		r1, [r0] // update score

	pop {fp, lr}
	bx		lr

.global incrementScoreValuePack // 17000
incrementScoreValuePack:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_currentScore
	ldr		r1, [r0] // get current value
	ldr		r2, =17000
	add		r1, r2 // +17000 on collection of value pack
	str		r1, [r0] // update score

	pop {fp, lr}
	bx		lr




.global resetFlags
resetFlags:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_currentWinFlag
	ldr		r1, =G_initWinFlag
	ldr		r1, [r1] // get init value
	str		r1, [r0] // reset current value back to init value

	ldr		r0, =G_currentLoseFlag
	ldr		r1, =G_initLoseFlag
	ldr		r1, [r1] // get init value
	str		r1, [r0] // reset current value back to init value

	pop {fp, lr}
	bx		lr



.global setWinFlag
setWinFlag:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_currentWinFlag
	mov		r1, #TRUE
	str		r1, [r0] 

	pop {fp, lr}
	bx		lr



.global setLoseFlag
setLoseFlag:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_currentLoseFlag
	mov		r1, #TRUE
	str		r1, [r0]

	pop {fp, lr}
	bx		lr



// return: r0 = TRUE/FALSE
.global isGameWon
isGameWon:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_currentWinFlag
	ldr		r0, [r0] 
	// return value set

	pop {fp, lr}
	bx		lr



// return: r0 = TRUE/FALSE
.global isGameLost
isGameLost:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_currentLoseFlag
	ldr		r0, [r0]
	// return value set	

	pop {fp, lr}
	bx		lr



.global checkForWin
checkForWin:
	push {fp, lr}
	mov		fp, sp

	bl		are_AllBricksBroken
	cmp		r0, #TRUE
	bleq		setWinFlag

	pop {fp, lr}
	bx		lr


.global checkForLoss
checkForLoss:
	push {fp, lr}
	mov		fp, sp

	ldr		r0, =G_currentLives
	ldr		r0, [r0] 
	cmp		r0, #0
	blle		setLoseFlag

	pop {fp, lr}
	bx		lr



.data


.global G_currentLives
G_currentLives:
	.word 0 // from 0-3

.global G_initLives
G_initLives:
	.word 3 // start at 3 lives


.global G_currentScore
G_currentScore:
	.word 0


.global G_initScore
G_initScore:
	.word 0 // start at 0 score



.global	G_currentWinFlag
G_currentWinFlag:
	.word 0 


.global G_initWinFlag
G_initWinFlag:
	.word 0 // initially false



.global G_currentLoseFlag
G_currentLoseFlag:
	.word 0

.global G_initLoseFlag
G_initLoseFlag:
	.word 0 // initially false








