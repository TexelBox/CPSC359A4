
.text


.global renderMainMenu
renderMainMenu:
	push {fp, lr}
	mov		fp, sp
	
	bl 		drawMainMenuBackground
	bl		drawMainMenuArrow
	
	pop {fp, lr}
	bx		lr
	

.global drawMainMenuBackground
drawMainMenuBackground:
	push {fp, lr}
	mov		fp, sp
	push {r4}
	
	ldr		r0, =mainMenuBackgroundMap
	mov		r1, #0 // x
	mov		r2, #0 // y
	mov		r3, #768 // width
	mov		r4, #768 // height
	bl		drawImage
	
	pop {r4}
	pop {fp, lr}
	bx		lr	
	
	
.global drawMainMenuArrow
drawMainMenuArrow:
	push {fp, lr}
	mov		fp, sp
	push {r4}
	
	ldr		r0, =arrowMap
	mov		r1, #128 // x (CONSTANT)
	ldr		r2, =MM_arrowCurrentYPosition
	ldr		r2, [r2] // y 
	mov		r3, #32 // width
	mov		r4, #32 // height
	bl		drawImage
	
	pop {r4}
	pop {fp, lr}
	bx		lr

	
	
.global resetMainMenuArrow
resetMainMenuArrow:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =MM_arrowCurrentYPosition
	ldr		r1, =MM_arrowInitYPosition
	ldr		r1, [r1] // get init ypos
	str		r1, [r0] // reset current ypos to init value
	
	pop {fp, lr}
	bx		lr
	
	
	
.global setMainMenuArrowTop
setMainMenuArrowTop:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =MM_arrowCurrentYPosition
	mov		r1, #256 // on START GAME
	str		r1, [r0] 
	
	pop {fp, lr}
	bx		lr
	
	
	
.global setMainMenuArrowBottom
setMainMenuArrowBottom:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =MM_arrowCurrentYPosition
	mov		r1, #384 // on QUIT GAME
	str		r1, [r0] 
	
	pop {fp, lr}
	bx		lr	
	


.data

.global MM_arrowCurrentYPosition
MM_arrowCurrentYPosition:
	.word 0

MM_arrowInitYPosition:
	.word 256









