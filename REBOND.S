

; rebond

	DATA

bouncedata	incbin 'rebond1.tab'
		incbin 'rebond2.tab'
		incbin 'rebond3.tab'
	BSS
bouncenbetape		ds.w 1
posX		ds.l nbpts
refbouncepts	ds.l nbpts
	TEXT

initbounce
	jsr calcpospoint (anciennement  majpoint)
	move.w #199,bouncenbetape
	rts

	
calcpospoint
;	lea refs1,a6
;	move angle1,d0
;	add d0,a6
;	move.l (a6),a0

;	lea refs2,a6
;	move angle2,d0
;	add d0,a6
;	move.l (a6),a1

;	lea refs3,a6
;	move angle3,d0
;	add d0,a6
;	move.l (a6),a2


	lea bufferAdresse,a4
	movem.l (a4)+,a0-a2
	lea 12(a4),a4
	move.w #NBbar,cpt

	lea convX+offconvx,a6
	;	move.l #convY+offconvy,d7	
	;	move.l #code1+nbpts*4,d5

	lea posX,a5		; tout les ref bset x 
	*lea bufferAdresse,a4
.bigloop:
	rept TLbar/4
	movem (a0)+,d0-d3
	add (a1)+,d0
	add (a1)+,d1
	add (a1)+,d2
	add (a1)+,d3

	add (a2)+,d0
	add (a2)+,d1
	add (a2)+,d2
	add (a2)+,d3

	;lea convx,a6
	
	move.l (a6,d0),d0	bset dn,dep(a0)
	move.l (a6,d1),d1
	move.l (a6,d2),d2
	move.l (a6,d3),d3

	movem.l d0-d3,(a5)	
	lea 16(a5),a5

	endr
	
	;	*lea bufferAdresse,a4
	movem.l (a4)+,a0-a2
	lea 12(a4),a4

	subq #1,cpt
	bne .bigloop

;dans posX: tout les bset correspondand au x de chaque point

	move.w #NBbar,cpt
;	lea refs4,a6
;	move angle4,d0
;	add d0,a6
;	move.l (a6),a0
;
;	lea refs5,a6
;	move angle5,d0
;	add d0,a6
;	move.l (a6),a1

;	lea refs6,a6
;	move angle6,d0
;	add d0,a6
;	move.l (a6),a2

	lea bufferAdresse+12,a6
	movem.l (a6)+,a0-a2
	lea 12(a6),a6
	
	move.l #bouncedata,d5
	lea refbouncepts,a5
	*lea bufferAdresse+12,a6
	move.w #NBbar,cpt
.bigloop2
	move.w #TLbar-1,d0
.loopnbbar
	move.w (a0)+,d4
	add (a1)+,d4
	add (a2)+,d4

; d4=y*2*4
	;move (a6,d4),d4		; d4 = yresultat*160
	;lea bouncedata,a6
	;bouncedate+(y*400 octet)	
	; le y de d4 est en fait (y.yy*4)*4

	ext.l d4
	add.l #offconvy,d4
	lsr.l #2,d4		; y*2*4/4
	and.b #%11111110,d4

	

	;mulu #200,d4	; a optimiser
	lsl.l #3,d4
	move.l d4,d1
	lsl.l #3,d4
	move.l d4,d2
	add.l d2,d2
	add.l d2,d4
	add.l d1,d4


	add.l d5,d4		; #bouncedata,d4
	move.l d4,(a5)+		; a3

	dbra.w d0,.loopnbbar	

	;lea bufferAdresse,a6
	movem.l (a6)+,a0-a2
	lea 12(a6),a6

	subq #1,cpt
	bne .bigloop2

	; dans posX	les bsetcode
	; dans refboucepts:	les pointeur dans la table rebond	

	rts


; parametre: a1 = code1 ou code2
;		a0=scr1
bounceit
	cmp #3,modeEFFET
	beq.s .fin2
	move.w bouncenbetape,d0
	subq #1,d0
	beq.w .fin2
	move.w d0,bouncenbetape

; a0	=scr1 ou scr2
; a1	= code1 ou code2

	lea nbpts*4(a1),a2
	movem.l a0/a1,-(sp)
;  a2 = code1 ou code2  + nbpts*4
	lea posX,a0
	lea refbouncepts,a1
	move.w #nbpts/4-1,d4
.loop
	movem.l (a0)+,d0-3		; bset dn,dep(a0)
	movem.l (a1)+,a3-a6		
	add (a3)+,d0
	add (a4)+,d1
	add (a5)+,d2
	add (a6)+,d3
	movem.l a3-a6,-16(a1)	; maj des pointeur bounce

	movem.l d0-d3,-(a2)	code
	dbra.w d4,.loop

	movem.l (sp)+,a0/a1
	move.w #motifd0,d0
	move.w #motifd1,d1
	move.w #motifd2,d2
	move.w #motifd3,d3
	move.w #motifd4,d4
	move.w #motifd5,d5
	move.w #motifd6,d6
	move.w #motifd7,d7
	*illegal
	jsr (a1)	code1 ou code2
.fin	rts
.fin2	move.w #3,modeEFFET
	rts