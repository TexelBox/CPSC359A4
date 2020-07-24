/*

    Author: Aaron Hornby
    UCID: 10176084
    Latest Date: 04/01/2018

    Arkanoid Video Game

*/



.text


TRUE = 1
FALSE = 0

NEITHER = 0
TAPPED = 1
HELD = 2


.global main
main:
	ldr		r0, =frameBufferInfo
	bl		initFbInfo
	bl		initDriver

	b		scene_MainMenu_init // transition to MAIN MENU

/////////////////////////////

scene_MainMenu_init: // execute ONCE upon transition here from start of program or from QUIT (pause menu choice)
	ldr		r0, =useSNESData
	mov		r1, #FALSE
	str		r1, [r0] // useSNESData = FALSE (init)
	bl		resetMainMenuArrow // reset arrow to point to START GAME
	bl		renderMainMenu // initial render
	bl		updateFrameBuffer	

scene_MainMenu_input:
	ldr		r0, =useSNESData
	ldr		r0, [r0] // check if user input is enabled
	cmp		r0, #TRUE
	bne		scene_MainMenu_render
	
	// get here if user input is enabled...
	bl		getState_A
	cmp		r0, #TAPPED
	bne		scene_MainMenu_EndIf1
scene_MainMenu_If1:	
	ldr		r0, =MM_arrowCurrentYPosition
	ldr		r0, [r0] // get arrowYPos
	cmp		r0, #256
	beq		scene_Game_init // if TOP (START GAME), transition to GAME scene	
	b		main_END // if BOTTOM (QUIT GAME), transition to CLEAR scene
	
scene_MainMenu_EndIf1:	
	mov		r4, #0 // reset yDir = 0
	bl		getState_UP
	cmp		r0,	#TAPPED
	addeq		r4, #1 // if UP is tapped, yDir++
	bl		getState_DOWN
	cmp		r0, #TAPPED
	subeq		r4, #1 // if DOWN is tapped, yDir--
	// now decide where arrow should move to based on input
	cmp		r4, #1
	bleq		setMainMenuArrowTop
	beq		scene_MainMenu_render
	cmp		r4, #-1
	bleq		setMainMenuArrowBottom
	// otherwise, keep arrow in same position if neither UP/DOWN were tapped or if BOTH were (cancelled)

scene_MainMenu_render:
	bl		renderMainMenu // update render
	bl		updateFrameBuffer

scene_MainMenu_update:
	bl		processData
	ldr		r0, =useSNESData
	ldr		r0, [r0] // get current STATE of if we are using user input or not
	cmp		r0, #FALSE
	bne		scene_MainMenu_input
	// get here if FALSE and need to check for a reset
	bl		is_SNES_Reset
	ldr		r1, =useSNESData
	str		r0, [r1] 
	b		scene_MainMenu_input

/////////////////////////////

scene_Game_init:
	ldr		r0, =useSNESData
	mov		r1, #FALSE
	str		r1, [r0] // useSNESData = FALSE (init)
	bl		resetBricksType // reset bricks type
	bl		resetBricksStatus // reset bricks type 
	bl		resetPaddlePosition // reset paddle position
	bl		resetPaddleSpeed // reset paddle speed
	bl		resetPaddleWidth 
	bl		resetBallPositionAndMode // reset ball 
	bl		resetBallSpeedStatus
	bl		resetBallVelocity
	bl		resetScore 
	bl		resetLives
	bl		resetFlags // reset win/lose flags
	bl		resetBallValuePack
	bl		resetPaddleValuePack
	bl		renderGame // initial render
	bl		updateFrameBuffer

scene_Game_input:
	bl		resetPaddleSpeed // reset paddle speed every frame	

	bl		checkForWin
	bl		isGameWon
	cmp		r0, #TRUE
	beq		scene_GameWon_init
	
	bl		checkForLoss
	bl		isGameLost
	cmp		r0, #TRUE
	beq		scene_GameLost_init

	ldr		r0, =useSNESData
	ldr		r0, [r0] // check if user input is enabled
	cmp		r0, #TRUE
	bne		scene_Game_EndIf1
	
	// get here if user input is enabled...
	bl		getState_START
	cmp		r0, #TAPPED
	beq		scene_PauseMenu_init // is START is tapped, transition to pause menu
	
	bl		getState_B
	cmp		r0, #TAPPED
	bleq		setBallMode_FREE // if B is tapped, set ball free (has no effect if ball is already free)

	bl		getState_A
	cmp		r0, #HELD
	bleq		setPaddleSpeedFast // if A is held, update paddle speed to FAST (before moving)
	
	mov		r4, #0 // reset xDir = 0
	bl		getState_LEFT
	cmp		r0, #NEITHER
	subne		r4, #1 // if LEFT is TAPPED or HELD, xDir--
	bl		getState_RIGHT
	cmp		r0, #NEITHER
	addne		r4, #1 // if RIGHT is TAPPED or HELD, xDir++
	// now decide where paddle should move to based on input
	cmp		r4, #-1
	bleq		movePaddleLeft
	beq		scene_Game_EndIf1
	cmp		r4, #1
	bleq		movePaddleRight
	// otherwise, don't move paddle
	
scene_Game_EndIf1:	
	bl		moveBall

	bl		checkBallValuePackBrick
	bl		checkPaddleValuePackBrick

	bl		moveBallValuePack
	bl		checkBallValuePackPaddleCollision
	bl		checkBallValuePackBottom

	bl		movePaddleValuePack
	bl		checkPaddleValuePackPaddleCollision
	bl		checkPaddleValuePackBottom


scene_Game_render:
	bl		renderGame // update render
	bl		updateFrameBuffer

scene_Game_update:
	bl		processData
	ldr		r0, =useSNESData
	ldr		r0, [r0] // get current STATE of if we are using user input or not
	cmp		r0, #FALSE
	bne		scene_Game_input
	// get here if FALSE and need to check for a reset
	bl		is_SNES_Reset
	ldr		r1, =useSNESData
	str		r0, [r1] 
	b		scene_Game_input

/////////////////////////////

scene_GameWon_init:
	ldr		r0, =useSNESData
	mov		r1, #FALSE
	str		r1, [r0] // useSNESData = FALSE (init)
	bl		resetPaddlePosition
	bl		resetPaddleWidth	
	bl		resetBallPositionAndMode // reset ball 
	bl		resetBallSpeedStatus
	bl		resetBallVelocity
	bl		renderGameWon // initial render
	bl		updateFrameBuffer

scene_GameWon_input:	
	ldr		r0, =useSNESData
	ldr		r0, [r0] // check if user input is enabled
	cmp		r0, #TRUE
	bne		scene_GameWon_render
	
	// get here if user input is enabled...
	// check if any button was TAPPED

	bl		getState_B
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_Y
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_SELECT
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_START
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_SELECT
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_UP
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_DOWN
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_LEFT
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_RIGHT
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_A
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_X
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_L
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_R
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init


scene_GameWon_render:
	bl		renderGameWon
	bl		updateFrameBuffer

scene_GameWon_update:
	bl		processData
	ldr		r0, =useSNESData
	ldr		r0, [r0] // get current STATE of if we are using user input or not
	cmp		r0, #FALSE
	bne		scene_GameWon_input
	// get here if FALSE and need to check for a reset
	bl		is_SNES_Reset
	ldr		r1, =useSNESData
	str		r0, [r1] 
	b		scene_GameWon_input


/////////////////////////////
scene_GameLost_init:
	ldr		r0, =useSNESData
	mov		r1, #FALSE
	str		r1, [r0] // useSNESData = FALSE (init)
	bl		resetPaddlePosition // reset paddle position
	bl		resetPaddleWidth
	bl		resetBallPositionAndMode // reset ball 
	bl		resetBallSpeedStatus
	bl		resetBallVelocity
	bl		renderGameLost // initial render
	bl		updateFrameBuffer

scene_GameLost_input:	
	ldr		r0, =useSNESData
	ldr		r0, [r0] // check if user input is enabled
	cmp		r0, #TRUE
	bne		scene_GameLost_render
	
	// get here if user input is enabled...
	// check if any button was TAPPED

	bl		getState_B
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_Y
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_SELECT
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_START
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_SELECT
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_UP
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_DOWN
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_LEFT
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_RIGHT
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_A
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_X
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_L
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init

	bl		getState_R
	cmp		r0, #TAPPED
	beq		scene_MainMenu_init


scene_GameLost_render:
	bl		renderGameLost
	bl		updateFrameBuffer

scene_GameLost_update:
	bl		processData
	ldr		r0, =useSNESData
	ldr		r0, [r0] // get current STATE of if we are using user input or not
	cmp		r0, #FALSE
	bne		scene_GameLost_input
	// get here if FALSE and need to check for a reset
	bl		is_SNES_Reset
	ldr		r1, =useSNESData
	str		r0, [r1] 
	b		scene_GameLost_input

/////////////////////////////

scene_PauseMenu_init:
	ldr		r0, =useSNESData
	mov		r1, #FALSE
	str		r1, [r0] // useSNESData = FALSE (init)
	bl		resetPauseMenuArrow // reset arrow to point to RESTART
	bl		renderPauseMenu // initial render
	bl		updateFrameBuffer

scene_PauseMenu_input:
	ldr		r0, =useSNESData
	ldr		r0, [r0] // check if user input is enabled
	cmp		r0, #TRUE
	bne		scene_PauseMenu_render
	
	// get here if user input is enabled...
	bl		getState_START
	cmp		r0, #TAPPED
	bne		scene_PauseMenu_EndIf1
	
	// get here if START was TAPPED...
	ldr		r0, =useSNESData
	mov		r1, #FALSE
	str		r1, [r0] // useSNESData = FALSE (init)
	bl		renderGame // render to resume game at previous left state
	bl		updateFrameBuffer
	b		scene_Game_input // if START is tapped, resume game	
	
scene_PauseMenu_EndIf1:	
	
	bl		getState_A
	cmp		r0, #TAPPED
	bne		scene_PauseMenu_EndIf2
scene_PauseMenu_If2:	
	ldr		r0, =PM_arrowCurrentYPosition
	ldr		r0, [r0] // get arrowYPos
	cmp		r0, #320
	beq		scene_Game_init // if TOP (RESTART), transition to GAME scene (new game)	
	b		scene_MainMenu_init // if BOTTOM (QUIT), transition to MAIN MENU
	
scene_PauseMenu_EndIf2:	
	mov		r4, #0 // reset yDir = 0
	bl		getState_UP
	cmp		r0,	#TAPPED
	addeq		r4, #1 // if UP is tapped, yDir++
	bl		getState_DOWN
	cmp		r0, #TAPPED
	subeq		r4, #1 // if DOWN is tapped, yDir--
	// now decide where arrow should move to based on input
	cmp		r4, #1
	bleq		setPauseMenuArrowTop
	beq		scene_PauseMenu_render
	cmp		r4, #-1
	bleq		setPauseMenuArrowBottom
	// otherwise, keep arrow in same position if neither UP/DOWN were tapped or if BOTH were (cancelled)

scene_PauseMenu_render:
	bl		renderPauseMenu
	bl		updateFrameBuffer

scene_PauseMenu_update:
	//bl		wait
	bl		processData
	ldr		r0, =useSNESData
	ldr		r0, [r0] // get current STATE of if we are using user input or not
	cmp		r0, #FALSE
	bne		scene_PauseMenu_input
	// get here if FALSE and need to check for a reset
	bl		is_SNES_Reset
	ldr		r1, =useSNESData
	str		r0, [r1] 
	b		scene_PauseMenu_input

/////////////////////////////

main_END:
	bl		clearScreen
	bl		updateFrameBuffer

halt:	
	b		halt

/////////////////////////////
/////////////////////////////
/////////////////////////////

// SUBROUTINES:		
	
// param: r0 = image BMAP address
// param: r1 = x-pos (top left corner)
// param: r2 = y-pos (top left corner)
// param: r3 = width
// param: r4 = height	
.global drawImage	
drawImage:		
	push {fp, lr}
	mov		fp, sp
	push {r4, r5, r6, r7, r8, r9}
	
	mul		r4, r3, r4 // total number of pixels = width * height (init number of pixels left to draw)
	mov		r5, r0 // save image BMAP
	mov		r6, r1 // save image x-pos (top left corner)
	mov		r7, r2 // save image y-pos (top left corner) 
	mov		r8, r3 // save width
	add		r9, r6, r8 // r9 = x + width
	sub		r9, #1 // r9 = x + width - 1 (right bound of x)
	b		drawImage_Cond1
drawImage_Loop1:
	// draw:
	mov		r0, r6 // pixel-x
	mov		r1, r7 // pixel-y
	ldr		r2, [r5], #4
	bl		drawPixel
	
	// update:
	add		r6, #1 // x++
	cmp		r6, r9 // compare x to right bound
	subgt		r6, r8 // move to next row down
	addgt		r7, #1 // y++
	sub		r4, #1 // decrement number of pixels left to draw
drawImage_Cond1:
	cmp		r4, #0
	bgt		drawImage_Loop1
	
	pop {r4, r5, r6, r7, r8, r9}
	pop {fp, lr}
	bx		lr



// NEW REQUIREMENT: (x,y) must be within game area 
// r0 = x
// r1 = y
// r2 = colour (32-bit ARGB 0xAARRGGBB)
.global drawPixel
drawPixel:
	push {fp, lr}
	mov		fp, sp
	push {r4, r5}	

	// offset(x,y) = ((width*y)+x)*(bpp/8) 
	ldr 		r4, =768 // width of game area
	mul		r4, r1 // r4 = width*y
	add		r4, r0 // r4 = (width*y)+x
	lsl		r4, #2 // r4 = ((width*y)+x)*(bpp/8) - using 32 bpp (ARGB)

	// address(x,y) = base address + offset(x,y)
	ldr 		r5, =gameAreaColourMap // r5 = base address of game area colour map

	tst		r2, #0xFF000000
	strne		r2, [r5, r4] // store colour at base + offset

	pop {r4, r5}
	pop {fp, lr}
	bx		lr	



clearScreen:
	push {fp, lr}
	mov		fp, sp
	push {r4, r5, r6, r7}
	
	mov		r4, #0 // init pixel-x
	mov		r5, #0 // init pixel-y
	mov		r6, #0 // init number of pixels drawn
	ldr		r7, =767 // right bound on x
	b		clearScreenCond1
clearScreenLoop1:
	// draw
	mov		r0, r4 // pixel-x
	mov		r1, r5 // pixel-y
	ldr		r2, =0xFF000000 // black
	bl		drawPixel
	// update
	add		r4, #1 // x++
	cmp		r4, r7 // right bound
	movgt		r4, #0 // put x on next row down
	addgt		r5, #1 // y++
	add		r6, #1 // increment number of pixels drawn
clearScreenCond1:
	cmp		r6, #589824
	blt		clearScreenLoop1

	pop {r4, r5, r6, r8}
	pop {fp, lr}
	bx		lr	
		
		
	
// write every pixel of game area colour map into FB	
.global updateFrameBuffer
updateFrameBuffer:
	push {fp, lr}
	mov		fp, sp
	push {r4, r5, r6}	

	ldr		r5, =767
	ldr		r0, =frameBufferInfo
	ldr		r6, [r0, #4] // screen width in pixels
	sub		r6, r5 // width - 767 (pixel padding to right of game area)
	lsl		r6, #2 // area in bytes
	ldr		r0, [r0] // get base address of FB
	ldr		r1, =gameAreaColourMap // get base address of game area colour map
	ldr		r2, =589824 // init number of pixels left to copy
	mov		r4, #0 // column number
	b		updateFrameBufferCond1
updateFrameBufferLoop1:
	ldr		r3, [r1], #4 // get next colour value from map
	cmp		r4, r5
	streq		r3, [r0], r6 // write last pixel on game area row and then move to next row down
	moveq		r4, #0 // reset column number		
	strne		r3, [r0], #4 // otherwise, write to FB as usual
	addne		r4, #1
	
	sub		r2, #1 // decrement number of pixels left to draw
updateFrameBufferCond1:	
	cmp		r2, #0
	bgt		updateFrameBufferLoop1
	
	pop {r4, r5, r6}
	pop {fp, lr}
	bx		lr	


		
///////////////////////////////	
	

.data	


useSNESData: // set this to false on a state change (only use processed data if this is TRUE), it will be set to true at the first time all buttons are not pressed after a state change
	.word 0 

.align
.global frameBufferInfo
frameBufferInfo:
    .int 0			// frame buffer pointer
    .int 0			// screen width
    .int 0			// screen height

.align 4
.global font
font: .incbin "font.bin" // label font is used as base address of font map


gameAreaColourMap:
	.rept 589824
	.word 0
	.endr



