
.text


.global renderPauseMenu
renderPauseMenu:
	push {fp, lr}
	mov		fp, sp
	
	bl		renderGame
	bl		drawPauseMenuBackground
	bl		drawPauseMenuArrow	
	
	pop {fp, lr}
	bx		lr
	
	

.global drawPauseMenuBackground
drawPauseMenuBackground:
	push {fp, lr}
	mov		fp, sp
	push {r4}
	
	ldr		r0, =pauseMenuBackgroundMap
	mov		r1, #160 // x
	mov		r2, #256 // y
	mov		r3, #448 // width
	mov		r4, #352 // height
	bl		drawImage
	
	pop {r4}
	pop {fp, lr}
	bx		lr		
	
	
	
.global drawPauseMenuArrow
drawPauseMenuArrow:
	push {fp, lr}
	mov		fp, sp
	push {r4}
	
	ldr		r0, =arrowMap
	mov		r1, #192 // x (CONSTANT)
	ldr		r2, =PM_arrowCurrentYPosition
	ldr		r2, [r2] // y 
	mov		r3, #32 // width
	mov		r4, #32 // height
	bl		drawImage
	
	pop {r4}
	pop {fp, lr}
	bx		lr	
	
	
	
.global resetPauseMenuArrow
resetPauseMenuArrow:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =PM_arrowCurrentYPosition
	ldr		r1, =PM_arrowInitYPosition
	ldr		r1, [r1] // get init ypos
	str		r1, [r0] // reset current ypos to init value
	
	pop {fp, lr}
	bx		lr



.global setPauseMenuArrowTop
setPauseMenuArrowTop:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =PM_arrowCurrentYPosition
	mov		r1, #320 // on RESTART
	str		r1, [r0] 
	
	pop {fp, lr}
	bx		lr
	
	
	
.global setPauseMenuArrowBottom
setPauseMenuArrowBottom:
	push {fp, lr}
	mov		fp, sp
	
	ldr		r0, =PM_arrowCurrentYPosition
	mov		r1, #416 // on QUIT
	str		r1, [r0] 
	
	pop {fp, lr}
	bx		lr	
	
	
	
.data


.global PM_arrowCurrentYPosition
PM_arrowCurrentYPosition:
	.word 0

PM_arrowInitYPosition:
	.word 320	
	
	
	
	
	
	
	
	
	
	
