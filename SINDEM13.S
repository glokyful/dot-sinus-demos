
;*********************************************
;
; EFFET dot (x,y)=(sin+sin+sin,sin+sin+sin) 1plan
;	sur 2 ecran
;
;(c) vincent guesdon aka gloky
;
;*********************************************

;  35*28 = 980 dot, absolument toute la vbl
;  reduire NBbar mais pas TLbar

; 25*36 =900 points + sid sound


notextradot	equ 1
sampledotx2	equ 0
sampledotx4	equ 0
dureefonction	equ 650		*2 vbl par fonction
colfxpoint	equ 14  4		10 = vert
colfxscroll	equ 11

tmachine	equ 0 1
true	equ 1
false 	equ 0


;	16*64 = 1024 points
; ou 	8*132 = 1056 points

; pour les meujiji:
; NBbar		= nombre de point en hauteur
; TLbar		= nombre de point en largeur, doit etre multiple de 4
;  (tlbar=16)*(nbbar=20) ne prend pas le meme temps machine que (nbbar=20)*(tlbar=16)  
; il y'a nbbar*tlbar point sur l'ecran
; 
;
NBbar	equ 12	;21; 35 bloc de 28 dot
TLbar	equ 72 ; on tape dans 16valeur a la suite max
nbpts	equ TLbar*NBbar

doscroller	equ 0 1 false true scroller bugg‚
modifcouleurs	equ	false true false true

nopic	equ true	;false
pleinouvide	equ false	true	; *false

	ifne pleinouvide
andorinst	equ $C128	$c128 : and.b d0,dep(a0) ou $8128: or.b d0,dep(a0)

motifd0	equ %01111111
motifd1	equ %10111111
motifd2	equ %11011111
motifd3	equ %11101111
motifd4	equ %11110111
motifd5	equ %11111011
motifd6	equ %11111101
motifd7 equ %11111110
	endc

	ifeq pleinouvide
	
andorinst	equ	$8128	;or		; 
motifd0	equ %10000000
motifd1	equ %01000000
motifd2	equ %00100000
motifd3	equ %00010000
motifd4	equ %00001000
motifd5	equ %00000100
motifd6	equ %00000010
motifd7	equ %00000001
	endc


cstCPT1	equ NBbar

selplan	equ 0*2
enablesound	equ 1 true false ftrue

DOUBLESIZE	equ false
CLEARPLANE	EQU true    ; CETTE OPTION DETERMINE LE TYPE D'EFFACEMENT:
			    ;  A TRUE, L'EFFACEMENT EST UN CLS DE 1 PLAN
 			    ;  A FALSE C'EST UN EFFACEMENT PAR POINT

	TEXT
savereg	macro
	movem.l d0-a6,-(sp)
	endm
loadreg	macro
	movem.l (sp)+,d0-a6
	endm
START
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp

	jsr createCGmajpoint


	move.w #150*4,d0
	lea sinx1,a0
	jsr createSinTab

	move.w #50*4,d0
	lea sinx2,a0
	jsr createSinTab

	move.w #100*4,d0
	lea sinx3,a0
	jsr createSinTab

	; 150+100+50 = 300 pixel

 	move.w #50*4,d0
	lea siny1,a0
	jsr createSinTab

	move.w #100*4,d0
	lea siny2,a0
	jsr createSinTab

	move.w #50*4,d0
	lea siny3,a0
	jsr createSinTab

	lea sinx1,a0
	jsr mulby4buffer
	lea sinx2,a0
	jsr mulby4buffer
	lea sinx3,a0
	jsr mulby4buffer

	lea siny1,a0
	jsr mulby2buffer
	lea siny2,a0
	jsr mulby2buffer
	lea siny3,a0
	jsr mulby2buffer





	jsr wvbl
	
		*move.b #0,$ffff8260.w
	
	

		*move.w #0,-(sp)

	clr.w d0
	move.b $ffff8260.w,d0
	move.w d0,-(sp)

	move.w #0,-(sp)
	move.l $44e.w,d0
	move.l d0,-(sp)
	move.l d0,-(sp)
	move.w #5,-(sp)		;setscren
	trap #14
	lea 12(sp),sp



	move.l $70.w,oldvbl
	move.l #vbl,$70.w

	
	;bsr MUSIC+0
	;move.l a6,-(sp)
	;lea bufferREG,a6
;	
	;movem.l d0-d7/a0-a5,(a6)
	;move.l (sp)+,8*4+6*4(a6)

	

;	move.w #$2300,sr


	jsr init

	move.l ptrfct,a0
	move.l (a0)+,curfct
	move.l a0,ptrfct
	*move.l #fct25,curfct
	jsr initfonction
	jsr initfonction
;suite1
	move.l scr1,d0
	move.l scr2,d1
	move.l d0,scrmemory
	move.l d1,scrmemory+4
	ifne doscroller
	jsr initscroll
	endc

	
	
	move.l scr2,d0
	jsr set8200
	
	lea pal,a0
	lea $ffff8240.w,a1
	movem.l (a0),d0-d7
	movem.l d0-d7,(a1)

;	not $ffff8240
;	rept 50
;	not $ffff8240.w
;	jsr wvbl
;	endr

;	;not $ffff8240



	ifne enablesound
	jsr SOUND
	endc


	jmp main

	ifne doscroller
	include 'scr4.s'
	endc
	ifeq doscroller
scrmemory	ds.l 2

	endc
	include 'sinlib.s'
	include 'rebond.s'
	*include 'chunky1.s'
	
*	... suite?

	; a0 = tabflag
	; a1 = buffer resultat (a transmetre)
	; a2 = sin512
	; 

*createSinTab:
*
*;clear all flag 
*	lea tabflag,a0		
*	move.w #511,d0
*.l0	clr.w (a0)+
*	dbra.w d0,.l0
*	lea -1024(a0),a0
*
*	move.l sin512,a6
*	lea tmpsin512,a2
*	move.w valmul,d0
*	move.w #512-1,d7
*.bclmul
*	move.w (a6)+,d1
*	lsl d0,d1
*	move.w d1,(a2)+
*	dbra d7,.bclmul
*	lea -1024(a2),a2
*
*
*	move.w step1,d0
*	add d0,d0
*	tst d0
*	beq.w .TrivialCase
*
*
*	;lea tmpsin512,a2
*	move.w #511,d7
*	move.w #1022,d6
*	moveq #0,d5
*	moveq #0,d3
*
*.loop
*	tst (a0,d5)	; test flag correspondant
*	beq.s .ok1
*	
*	move.w d5,-(sp)
*	move.w #TLbar-1,d4		; tlbar-1 valeur suplementaire
*.bcl	move.w (a2,d5),(a1)+
*	add d0,d5
*	and d6,d5
*	add #2,d3	* ???
*	dbra.w d4,.bcl
*	move.w (sp)+,d5	
*	addq #2,d5
*	and.w d6,d5
*	tst (a0,d5)
*	bne.s .fin
*.ok1		
* 	move.w (a2,d5),(a1)+
*
*	add d5,d5
*	move.l d3,(a3,d5)	; table reference
*	lsr #1,d5
*
*	move.w #-1,(a0,d5)	; positione flag index utilisé
*	addq #2,d3
*	
*	add d0,d5
*	and d6,d5
*	dbra.w d7,.loop
*
*	move.w #TLbar-1,d4
*.bcl2	move.w (a2,d5),(a1)+
*	add d0,d5
*	and d6,d5
*	dbra.w d4,.bcl2
*
*.fin	rts
*.TrivialCase
*	illegal
*	move.w #511,d7
*	move.w #1022,d6
*	moveq #0,d5
*	moveq #0,d3
*
*	move.w #511,d7		; 	
*.loop1	move.w (a2)+,d4
*	move.w #TLbar-1,d0
*.loop0	move.w d4,(a1)+
*	dbra.w d0,.loop0
*	dbra.w d7,.loop1
*
**, 	
**,
**	,add d5,d5
**	m,ove.l d3,(a3,d5)	; table reference
**	lsr #1,d5
**,
**	,*move.w #-1,(a0,d5)	; positione flag index utilisé
**	,
**	a,ddq #2,d3
**	ad,d d0,d5
**	and, d6,d5
**,
**
*
*	rts


	
*createSpecialSin
; a0 = table sinus de n element
; a1 = reftablesinus
; a2 = buffer resultat
; d0 = pas interne
; d1 = nombre de copie de valeur
; d2 = nombre n d'element de la table sinus
; retour = d1 : nombre de memoire occupé sur buffer resultat

lstsintable3x	dc.l sinx1,refs1
		dc.l sinx2,refs2
		dc.l sinx3,refs3
		dc.l siny1,refs4
		dc.l siny2,refs5
		dc.l siny3,refs6
		dc.l bufsin1

curfct	ds.l 1		; adresse parametre fonction
initfonction

	move.l #bufsin1,a2
	move.l curfct,a6
	lea lstsintable3x,a5
	lea refTableSin,a4
	move.w #6-1,d7
.loop
	move.l (a5)+,a0
	move.l (a5)+,a1
	
	*	lea sinx1,a0
	*	lea refs1,a1
	*	lea bufsin1,a2
	
	move (a6)+,d0			step1

	move.w #512,d2
	move.w #TLbar,d1
		*lea refs1,a3

	move.l a2,(a4)+		retableSIn

	movem.l d7/a4/a5/a6,-(sp)
	jsr createSpecialSin
	movem.l (sp)+,d7/a4/a5/a6

	dbra.w d7,.loop


;	move.w #(511-3)*4,ajoutangle1
;	move.w #12*4,ajoutangle2	
;	move.w #14*4,ajoutangle3
;	move.w #13*4,ajoutangle4
;	move.w #(511-11)*4,ajoutangle5
;	move.w #(511-7)*4,ajoutangle6
	
	move.l curfct,a6
	movem.w 12(a6),d0-d5
	lsl #2,d0
	lsl #2,d1
	lsl #2,d2
	lsl #2,d3
	lsl #2,d4
	lsl #2,d5
	movem.w d0-d5,ajoutangle1	; ajoutangle123456 doit etre a la suite
	
	; modif majAngleT
	movem.w 24(a6),d0-d5
	lsl #2,d0
	lsl #2,d1
	lsl #2,d2
	lsl #2,d3
	lsl #2,d4
	lsl #2,d5

	lea majauto1+2,a0
	move d0,(a0)
	move d1,4(a0)
	move d2,8(a0)
	move d3,12(a0)
	move d4,16(a0)
	move d5,20(a0)

	rts

; initDERIVE:
; avec d0 nombre d'etape
; et curfct contenant adresse parametre fonction
; calcule la position des point x et y a l'instant d0
; et la derive x et y associ‚
; et stoque le resultat
;
;initDERIVE			; D0 = nombre d'etape
;	move.l curfct,a0
;	lea 12(a0),a1
;	lea 24(a0),a2
;	; a0 pointe sur pas 1 (28 point)
;	; a1 pointe sur pas 2 (*30 point)
;	; a2 pointe sur ajout dans le temp
;
;	movem (a2),d1-d3
;	mulu d0,d1
;	mulu d0,d2
;	mulu d0,d3
;	move #511,d7
;	and d7,d1
;	and d7,d2
;	and d7,d3
;
;	movem (a0),d4-d6	; pas px
;
;	*lea tablepx,a3
;	*lea 
;
;
;	


initSYS
	rts


tab48	dc.w 0,48*4,48*4*2,48*4*3

	ifeq notextradot
gensampledot
; d0 = 0..7
; d1 = 0..3
;
; 16*48: 1 tout les 16
	

	and.w #4,d0		; par securit‚
	lsl #2,d0		; *4
	add.w d0,a0

	and.w #3,d1	; par securit‚
	add d1,d1
	lea tab48,a2
	move.w (a2,d1),d1
	add.w d1,a0

	lea extradot,a1

	move.w #4-1,d0		; 4*3=12+0..3=12..15
	ifne sampledotx4
	addq.w #4,d0
	endc
.loop
	
	move.l (a0),(a1)+
	move.l 4*4(a0),(a1)+
	move.l 4*8(a0),(a1)+
	move.l 4*12(a0),(a1)+
	move.l 4*16(a0),(a1)+
	move.l 4*20(a0),(a1)+
	move.l 4*24(a0),(a1)+
	move.l 4*28(a0),(a1)+
	move.l 4*32(a0),(a1)+
	move.l 4*36(a0),(a1)+
	move.l 4*40(a0),(a1)+
	move.l 4*44(a0),(a1)+

	ifne sampledotx2
	move.l 2*4(a0),(a1)+
	move.l 4*4+8(a0),(a1)+
	move.l 4*8+8(a0),(a1)+
	move.l 4*12+8(a0),(a1)+
	move.l 4*16+8(a0),(a1)+
	move.l 4*20+8(a0),(a1)+
	move.l 4*24+8(a0),(a1)+
	move.l 4*28+8(a0),(a1)+
	move.l 4*32+8(a0),(a1)+
	move.l 4*36+8(a0),(a1)+
	move.l 4*40+8(a0),(a1)+
	move.l 4*44+8(a0),(a1)+

	endc

	ifeq sampledotx4
	lea (4*48)*4(a0),a0
	endc
	ifne sampledotx4
	lea (4*48)*2(a0),a0
	endc
	dbra.w d0,.loop
	
	move.w #$4e75,(a1)+	; rts
	rts
	endc
	
	ifeq notextradot
clearoldsampledot
	lea extradot,a1
	move.l ptrsequence1,a6
	move.l -14(a6),a0		; prend l'ecran d'avant = la ou il faut effacer
	move.l (a0),a0
	addq.l #6,a0
	moveq #0,d0
	move.w #12*5-1,d1
	lea extradot,a1
.loop
	move.l (a1)+,d2
	move.b d0,(a0,d2.w)
	ifne sampledotx2
	move.l (a1)+,d2
	move.b d0,(a0,d2.w)
	endc
	ifne sampledotx4
	move.l (a1)+,d2
	move.b d0,(a0,d2.w)
	move.l (a1)+,d2
	move.b d0,(a0,d2.w)
	
	endc
	dbra d1,.loop
	rts

	endc
init1

;	move.w #7,step1
;	lea bufsin1,a1
;	lea refs1,a2
;	;jsr createSinTab
	
majAngleT

		move.w #1022*2,d6
		movem.w angle1,d0-d5
majauto1	add #5*4,d0			
majauto2	add #3*4,d1
majauto3	add #(511-2)*4,d2
majauto4	add #6*4,d3
majauto5	add #(511-2)*4,d4
majauto6	add #1*4,d5
		and d6,d0
		and d6,d1
		and d6,d2
		and d6,d3
		and d6,d4
		and d6,d5
		movem.w d0-d5,angle1

		rts


offconvx	equ 8*10	140*8
offconvy	equ 0	8*10


; DEMO= APPEL majpoint avec les bon parametres
demo

	*not.b $ffff8240.W
; d0 = code1
	move.l d0,-(sp)


;	lea refs1,a6
;	move angle1,d0
;	add d0,a6
;	move.l (a6),a0

	move.w #NBbar,cpt
	move.l #convX+offconvx,d6
	move.l #convY+offconvy,d7
	;sub.l offsetapparition/160*8,d7	; 0 = normal 32000= 1 'ecran' au dessus' (effet cachet)	
	add.l offsetapparition,d7
	move.l (sp)+,d0
	move.l d0,d5
	add.l #nbpts*4,d5
	move.l d0,-(sp)
	;move.l #code1+nbpts*4,d5
; positionner a0-a5
	jsr majpoint
	*move.l #bufferAdresse,auto1+2
	move #motifd0,d0
	moveq #motifd1,d1
	moveq #motifd2,d2
	moveq #motifd3,d3
	moveq #motifd4,d4
	moveq #motifd5,d5
	moveq #motifd6,d6
	moveq #motifd7,d7
	  * move.l scr1,a0
	
	move.l ptrsequence1,a6
	move.l (a6),a0
	move.l (a0),a0
	add.w 12(a6),a0

	*lea selplan(a0),a0
	move.l (sp)+,a6		; code1
	move.l a6,-(sp)
	jsr (a6)	jsr code1

	ifeq notextradot
	jsr clearoldsampledot
	endc


	move.l (sp)+,a0	;
	ifeq notextradot
	move.w #4,d0
	move.w #1,d1
	jsr gensampledot
	

	move.l ptrsequence1,a6
	move.l (a6),a0
	move.l (a0),a0
	addq.l #6,a0
	
	moveq #motifd0,d0
	moveq #motifd1,d1
	moveq #motifd2,d2
	jsr extradot
	endc
*jsr clearoldsampledot

	*not.b $ffff8240.w
	rts

createCGmajpoint
	lea cgmajpoint,a0
	lea majpointProto,a1
	lea majpointProtofin,a3
	move.w #TLbar/4-1,d0
.cpy
	move.w #(majpointProtofin-majpointProto)/2-1,d1
	move.l a1,a2
.loop	move.w (a2)+,(a0)+
	dbra.w d1,.loop
	dbra.w d0,.cpy
	move.w #$4e75,(a0)+
	rts


majpointProto

	move.l (a0)+,d0
	move.l (a0)+,d2
	add.l (a1)+,d0
	add.l (a2)+,d0
	add.l (a1)+,d2
	add.l (a2)+,d2

	move.l d6,a6
	move.l (a6,d0.w),d1
	swap d0
	move.l (a6,d0.w),d0
	move.l (a6,d2.w),d3
	swap d2
	move.l (a6,d2.w),d2


	;lea convy,a6
	move.l d7,a6


; meme temp machine...   (sauf sur falcon)
	move.l (a3)+,d4
	add.l (a4)+,d4
	add.l (a5)+,d4
	add (a6,d4.w),d1
	swap d4
	add (a6,d4.w),d0
	move.l (a3)+,d4
	add.l (a4)+,d4
	add.l (a5)+,d4
	add (a6,d4.w),d3
	swap d4
	add (a6,d4.w),d2

	move.l d5,a6		; d5=code+768*4 au debut
	movem.l d0-d3,-(a6)
	move.l a6,d5

majpointProtofin
tlcgmajpoint	equ majpointProtofin-majpointProto

	
alt	set 1
majpoint
	*move.w cpt,d6
	*move.w #$430,$fffff8242.w
	pea bufferAdresse
bigloop:

*auto1	equ *+2	;         lea bufferAdresse,a6

	move.l (sp)+,a6
	movem.l (a6)+,a0-a5
	move.l a6,-(sp)
	



	jsr cgmajpoint

; que ca:
*	move.w (a3)+,d4
*	add.w (a4)+,d4
*	add.w (a5)+,d4
*
*	add (a6,d4),d0
*	
*	move (a3)+,d4
*	add (a4)+,d4
*	add (a5)+,d4
*	add (a6,d4),d1
*
*	move.w (a3)+,d4
*	add.w (a4)+,d4
*	add.w (a5)+,d4
*	add (a6,d4),d2
*	
*	move.w (a3)+,d4
*	add (a4)+,d4
*	add (a5)+,d4
*	add (a6,d4),d3
*
	subq #1,cpt
	bne bigloop
	addq.l #4,sp
	rts
;
;demoOLD
;
;	*not.b $ffff8240.W
;; d0 = code1
;	move.l d0,-(sp)
;
;
;;	lea refs1,a6
;;	move angle1,d0
;;	add d0,a6
;;	move.l (a6),a0
;
;	move.w #NBbar,cpt
;		*move.l #convX+offconvx,d6
;	move.l #convY+offconvy,d7
;	;sub.l offsetapparition/160*8,d7	; 0 = normal 32000= 1 'ecran' au dessus' (effet caché)	
;	add.l offsetapparition,d7
;	
;	move.l (sp)+,d0
;	move.l d0,d5
;	add.l #nbpts*4,d5
;	move.l d0,-(sp)
;
;	move.l d5,adrcodebset
;	move.l d7,adrconvy
;
;	;move.l #code1+nbpts*4,d5
;; positionner a0-a5
;
;***********************
;	jsr variante1	majpoint
;***********************
;
;
;
;	*move.l #bufferAdresse,auto1+2
;	move #motifd0,d0
;	moveq #motifd1,d1
;	moveq #motifd2,d2
;	moveq #motifd3,d3
;	moveq #motifd4,d4
;	moveq #motifd5,d5
;	moveq #motifd6,d6
;	moveq #motifd7,d7
;	  * move.l scr1,a0
;	
;	move.l ptrsequence1,a6
;	move.l (a6),a0
;	move.l (a0),a0
;	add.w 12(a6),a0
;
;	*lea selplan(a0),a0
;	move.l (sp)+,a6		; code1
;	move.l a6,-(sp)
;	jsr (a6)	jsr code1
;
;	ifeq notextradot
;	jsr clearoldsampledot
;	endc
;
;
;	move.l (sp)+,a0	;
;	ifeq notextradot
;	move.w #4,d0
;	move.w #1,d1
;	jsr gensampledot
;	
;
;	move.l ptrsequence1,a6
;	move.l (a6),a0
;	move.l (a0),a0
;	addq.l #6,a0
;	
;	moveq #motifd0,d0
;	moveq #motifd1,d1
;	moveq #motifd2,d2
;	jsr extradot
;	endc
;	*jsr clearoldsampledot
;
;	*not.b $ffff8240.w
;	rts
;

;adrcodebset	dc.l 0
;adrconvy	dc.l 0
;variante1: 			;pour les y
;	lea bufferOperation,a3		; buffer de TLbar*2*nbbar octet
;	lea bufferAdresse,a6
;.loop
;	movem.l (a6)+,a0/a1/a2
;	rept TLbar/16
;	movem.l (a0)+,d0-d7
;	add.l (a1)+,d0
;	add.l (a1)+,d1
;	add.l (a1)+,d2
;	add.l (a1)+,d3
;	add.l (a1)+,d4
;	add.l (a1)+,d5
;	add.l (a1)+,d6
;	add.l (a1)+,d7
;
;	add.l (a2)+,d0
;	add.l (a2)+,d1
;	add.l (a2)+,d2
;	add.l (a2)+,d3
;	add.l (a2)+,d4
;	add.l (a2)+,d5
;	add.l (a2)+,d6
;	add.l (a2)+,d7
;
;	movem.l d0-d7,(a3)
;	lea 32(a3),a3
;	endr
;.variante1bis
;	subq #1,cpt
;	bne.w .loop
;
;	move.w #NBbar,cpt
;	move.l #convX+offconvx,a3
;	move.l adrconvy,a5
;					*a3 = convx + offsetconvx
;	lea bufferOperation,a4		 
;.loop2
;	movem.l (a6)+,a0/a1/a2
;	move.l a6,-(sp)
;	move.l adrcodebset(pc),a6
;.variante2  			;*4 pour les x
;
;	rept TLbar/4
;	movem.w (a0)+,d0-d3
;	add.w (a1)+,d0
;	add.w (a1)+,d1
;	add.w (a1)+,d2
;	add.w (a1)+,d3
;	add.w (a2)+,d0
;	add.w (a2)+,d1
;	add.w (a2)+,d2
;	add.w (a2)+,d3
;
;	move.l (a3,d0),d0
;	move.l (a3,d1),d1
;	move.l (a3,d2),d2
;	move.l (a3,d3),d3
;	
;	movem.w (a4)+,d4-d7		buffer les y calcul‚
;	add (a5,d4),d0			; a5 = convy
;	add (a5,d5),d1
;	add (a5,d6),d2
;	add (a5,d7),d3
;	movem.l d0-d3,-(a6)		; a6 = code bset
;	endr
;.variante2bis
;		*move.l (sp)+,a6
;		*movem.l (a6)+,a0-a2
;		*move.l a6,-(sp)
;
;	move.l a6,adrcodebset
;	move.l (sp)+,a6
;
;	subq #1,cpt
;	bne.w .loop2
;	rts
;
;prepbufferAdresseOLD			; nouvelle version
;	*not $ffff8240
;	lea bufferAdresse+NBbar*12,a6
;	;lea angle,a5
;	
;	lea refs1,a2
;	lea refs2,a3
;	lea refs3,a4
;
;	move.w #1022*2,d7
;
;	move angle1,d0
;	move angle2,d1
;	move angle3,d2
;	
;	move ajoutangle1,d3
;	move ajoutangle2,d4
;	move ajoutangle3,d5
;
;	move.w #NBbar-1,d6
;.loop0
;	move.l (a2,d0),(a6)+
;	move.l (a3,d1),(a6)+
;	move.l (a4,d2),(a6)+
;	*lea 12(a6),a6
;	
;	add d3,d0
;	add d4,d1
;	add d5,d2
;	and d7,d0
;	and d7,d1
;	and d7,d2
;	dbra d6,.loop0
;
;	lea bufferAdresse,a6 		
;
;	lea refs4,a2
;	lea refs5,a3
;	lea refs6,a4
;	move angle4,d0
;	move angle5,d1
;	move angle6,d2
;	move ajoutangle4,d3
;	move ajoutangle5,d4
;	move ajoutangle6,d5
;	move #NBbar-1,d6
;.loop1
;	move.l (a2,d0),(a6)+
;	move.l (a3,d1),(a6)+
;	move.l (a4,d2),(a6)+
;	*lea 12(a6),a6
;
;	add d3,d0
;	add d4,d1
;	add d5,d2
;	and d7,d0
;	and d7,d1
;	and d7,d2
;	dbra d6,.loop1
;
;	*not $ffff8240
;	rts

prepbufferAdresse			; nouvelle version
	*not $ffff8240
	lea bufferAdresse,a6
	;lea angle,a5
	
	lea refs1,a2
	lea refs2,a3
	lea refs3,a4

	move.w #1022*2,d7

	move angle1,d0
	move angle2,d1
	move angle3,d2
	
	move ajoutangle1,d3
	move ajoutangle2,d4
	move ajoutangle3,d5

	move.w #NBbar-1,d6
.loop0
	move.l (a2,d0),(a6)+
	move.l (a3,d1),(a6)+
	move.l (a4,d2),(a6)+
	lea 12(a6),a6
	
	add d3,d0
	add d4,d1
	add d5,d2
	and d7,d0
	and d7,d1
	and d7,d2
	dbra d6,.loop0

	lea bufferAdresse+12,a6 		

	lea refs4,a2
	lea refs5,a3
	lea refs6,a4
	move angle4,d0
	move angle5,d1
	move angle6,d2
	move ajoutangle4,d3
	move ajoutangle5,d4
	move ajoutangle6,d5
	move #NBbar-1,d6
.loop1
	move.l (a2,d0),(a6)+
	move.l (a3,d1),(a6)+
	move.l (a4,d2),(a6)+
	lea 12(a6),a6

	add d3,d0
	add d4,d1
	add d5,d2
	and d7,d0
	and d7,d1
	and d7,d2
	dbra d6,.loop1

	*not $ffff8240
	rts

;disposecolor
colorp123	dc.w $466,$355,$244
*colorp1	equ $755
*colorp2	equ $733
*colorp3	equ $711

colorp1	equ $750  $017  $732
colorp2	equ $640   $170    $631
colorp3	equ $530 $710


;disposecolor1
;	;  sel pal1 
;	move.l a0,-(sp)
;	move.l $ffff8240.w,a0
;	
;	move.w d0,(a0)+
;	move.w d1,(a0)+
;	move.w d3,(a0)+
;	move.w d1,(a0)+
;	move.w d2,(a0)+
;	move.w d1,(a0)+
;	move.w d2,(a0)+
;	move.w d1,(a0)+
;	move.l (sp)+,a0
;	rts
;
;disposecolor2
;	lea pal2,a0
;	move.w d0,(a0)+
;	move.w d2,(a0)+
;	move.w d1,(a0)+
;	move.w d1,(a0)+
;	move.w d3,(a0)+
;	move.w d2,(a0)+
;	move.w d1,(a0)+
;	move.w d1,(a0)+
;	rts
;disposecolor3
;	move.l a0,-(sp)
;	move.l $ffff8240.w,a0
;	move d0,(a0)+
;	move d3,(a0)+
;	move d2,(a0)+
;	move d2,(a0)+
;	move d1,(a0)+
;	move d1,(a0)+
;	move d1,(a0)+
;	move d1,(a0)+
;	move.l (sp)+,a0
;	rts
;
color0	equ $800 $121
pal1	dc.w color0,colorp1,colorp3,colorp1,colorp2,colorp1,colorp2,colorp1
pal2	dc.w color0,colorp2,colorp1,colorp1,colorp3,colorp2,colorp1,colorp1
pal3	dc.w color0,colorp3,colorp2,colorp2,colorp1,colorp1,colorp1,colorp1
init

*	lea pal1,a0
*	jsr disposecolor
*	lea pal2,a0
*	jsr disposecolor
*	lea pal3,a0
*	jsr disposecolor
*

	clr.l offsetapparition


	ifeq notextradot
	lea extradot,a0
	move.w #12*5-1,d0
	clr.l d1
.loopclr
	move.l d1,(a0)+
	ifne sampledotx2
	move.l d1,(a0)+
	endc
	ifne sampledotx4
	move.l d1,(a0)+
	move.l d1,(a0)+
	endc
	dbra.w d0,.loopclr
	endc

; valeur negative de convy:
	lea convY-200*8,a0
	move.w #-160,d0
	move.w #200*4-1,d1
.loopneg
	move.w d0,(a0)+
	dbra.w d1,.loopneg

	lea convY,a0
	moveq #0,d0
	move #160,d1
	move.w #199,d2
.loop	move d0,(a0)+
	move d0,(a0)+
	move d0,(a0)+
	move d0,(a0)+
	add d1,d0
	dbra d2,.loop

	move.w #$4e75,d2

	move.w d2,code1+nbpts*4
	move.w d2,code2+nbpts*4

	move.w d2,code3+nbpts*4
	move.w d2,code4+nbpts*4

	move.w d2,code5+nbpts*4
	move.w d2,code6+nbpts*4

	move.w d2,code7+nbpts*4
	move.w d2,code8+nbpts*4
	move.w d2,code9+nbpts*4

	move.w d2,code10+nbpts*4
	move.w d2,code11+nbpts*4
	move.w d2,code12+nbpts*4


;_mkconvx
	lea convX,a0
	;move.w #$8128,d0	8128= or.b d0,dep(a0)
	
	moveq #0,d1
	move.w #$0200,d2	+0200= or.b d1,dep(a0) puis or.b d2,dep(a0), etc..

.0	move #andorinst,d0
.1	
	rept 4
	move.w d0,(a0)+
	move.w d1,(a0)+
	endr
	add d2,d0
	cmp.w #andorinst+8*$200,d0
	bne.s .1
	
	addq #1,d1
	move.w #andorinst,d0
.2	rept 4
	move.w d0,(a0)+
	move.w d1,(a0)+
	endr
	add d2,d0
	cmp.w #andorinst+8*$200,d0
	bne.s .2
	addq #7,d1
	
	cmp.w #8*20,d1
	bne.s .0
;_mkconvx fin

	move.l #ECRAN+160+256,d0
	clr.b d0
	move.l d0,scr1
 	*move.l d0,curscr
	add.l #32000+160+256,d0
	clr.b d0
	move.l d0,scr2
	add.l #32000+160+256,d0
	clr.b d0
	move.l d0,scr3
	add.l #32000+160+256,d0
	clr.b d0
	move.l d0,scr4

	lea PICTURE1+2,a0
	movem.l (a0)+,d0-d7
	movem.l d0-d7,$ffff8240.w
 
;926
	IFNE modifcouleurs

	lea PICTURE1+34,a0
	lea bssbuffer,a1

	jsr converttochunky 	choosecolorforfxandplane

	move.w #14,d0
	move.w #colfxpoint,d1
	lea bssbuffer,a0
	move.l a0,a1
	jsr swap2regcolor


	move.w #13,d0
	move.w #colfxscroll,d1
	lea bssbuffer,a0
	move.l a0,a1
	jsr swap2regcolor



	lea bssbuffer,a0
	lea PICTURE1+34,a1
	jsr converttoplanar

	lea $ffff8240.w,a0
	move.w #colfxpoint*2,d0
	move.w (a0,d0),d2
	move.w 14*2(a0),d3
	move d2,14*2(a0)
	move d3,(a0,d0)

	move.w #colfxscroll*2,d0
	move (a0,d0),d2
	move 13*2(a0),d3
	move d3,(a0,d0)
	move d2,13*2(a0)

	endc

	ifeq nopic

	lea PICTURE1+34,a0
	move.l scr1,a1
	move.l scr2,a2
	move.w #7999,d1
.loopcopypic
	move.l (a0)+,d0
	move.l d0,(a1)+
	move.l d0,(a2)+
	dbra d1,.loopcopypic	

	endc

; preparer code effacement

	move.w #nbpts/8-1,d0
	lea cgEFF,a0
	move.l #$4CDE02FE,d2	; movem.l (a6)+,d0-d7

	ifne pleinouvide
	move.w #$1180,d1	; clr.b (a0,d0)
	endc
	ifeq pleinouvide
	move.w #$4230,d1	;  
	endc

.loopcgeff	
	move.l d2,(a0)+
	move d1,(a0)+
	move.w #$1000,(a0)+
	move d1,(a0)+
	move.w #$2000,(a0)+
	move d1,(a0)+
	move.w #$3000,(a0)+
	move d1,(a0)+
	move.w #$4000,(a0)+
	move d1,(a0)+
	move.w #$5000,(a0)+
	move d1,(a0)+
	move.w #$6000,(a0)+
	move d1,(a0)+
	move.w #$7000,(a0)+

	move d1,(a0)+
	move.w #$9000,(a0)+


	ifne DOUBLESIZE
	; deprecated
	addq #1,d1
	move d1,(a0)+
	move.w #0,(a0)+
	move d1,(a0)+
	move.w #$1000,(a0)+
	move d1,(a0)+
	move.w #$2000,(a0)+
	move d1,(a0)+
	move.w #$3000,(a0)+
	move d1,(a0)+
	move.w #$4000,(a0)+
	move d1,(a0)+
	move.w #$5000,(a0)+
	move d1,(a0)+
	move.w #$6000,(a0)+
	move d1,(a0)+
	move.w #$7000,(a0)+
	subq #1,d1
	endc

	dbra d0,.loopcgeff
	move.w #$4e75,(a0)+

	lea code1,a0
	lea code2,a1
	lea code3,a2
	lea code4,a3
	LEA code5,a4
	move.w #nbpts-1,d0
	moveq.l #16,d1
.bcldebug
	move.l d1,(a0)+
	move.l d1,(a1)+
	move.l d1,(a2)+
	move.l d1,(a3)+
	move.l d1,(a4)+
	dbra.w d0,.bcldebug

	lea code6,a0
	lea code7,a1
	lea code8,a2
	lea code9,a3
	move.w #nbpts-1,d0
	moveq.l #16,d1
.bcldebug2
	move.l d1,(a0)+
	move.l d1,(a1)+
	move.l d1,(a2)+
	move.l d1,(a3)+
	dbra d0,.bcldebug2

	lea code10,a0
	lea code11,a1
	lea code12,a2
	move.w #nbpts-1,d0

.bcldebug3
	move.l d1,(a0)+
	move.l d1,(a1)+
	move.l d1,(a2)+
	dbra d0,.bcldebug3
	rts


wvbl
;	move.w #$25,-(sp)
;	trap #14
;	addq.l #2,sp

	ifne tmachine
	not $ffff8240.w
	not $ffff8240.w
	endc

	move.l $466.w,d0
.test	cmp.l $466.w,d0
	beq.s .test
	rts

set8200
	; d0 = adresse ecran physique de la vbl suivante
	*move.l $44e.w,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w
	rts

modeEFFET	dc.w 0

ptrsequence1	dc.l sequence1

;		dc.l scr3,code9,pal3
;		dc.w 4
;
;sequence1	dc.l scr1,code1,pal3
;		dc.w 0
;		dc.l scr2,code2,pal1
;		dc.w 0
;		dc.l scr3,code3,pal1
;		dc.w 0
;		dc.l scr1,code4,pal1
;		dc.w 2
;		dc.l scr2,code5,pal2
;		dc.w 2
;		dc.l scr3,code6,pal2
;		DC.W 2
;		dc.l scr1,code7,pal2
;		dc.w 4
;		dc.l scr2,code8,pal3
;		dc.w 4
;		dc.l scr3,code9,pal3
;		dc.w 4
;
;finsequence1	dc.w $4e71		  
;



		dc.l scr4,code12,pal3
		dc.w 4


sequence1
		dc.l scr1,code1,pal3
		dc.w 0
		dc.l scr2,code2,pal1
		dc.w 0
		dc.l scr3,code3,pal1
		dc.w 0
		dc.l scr4,code4,pal1
		dc.w 0

		dc.l scr1,code5,pal1
		dc.w 2
		dc.l scr2,code6,pal2
		dc.w 2
		dc.l scr3,code7,pal2
		DC.W 2
		dc.l scr4,code8,pal2
		dc.w 2

		dc.l scr1,code9,pal2
		dc.w 4
		dc.l scr2,code10,pal3
		dc.w 4
		dc.l scr3,code11,pal3
		dc.w 4
		dc.l scr4,code12,pal3
		dc.w 4

finsequence1	dc.w $4e71		  


*takelogscrtoa0
*	movem.l d0-d7/a1-a6,-(sp)
*	
	move.l ptrsequence1,a0






demoloop
	jsr wvbl

	move.l ptrsequence1,a6  
	*lea sequence1,a6
	
	movem.l (a6)+,a0-a2		; scr, code, pal
	move.l (a0),a0			; scr = est un pointeur
	move.l a0,d0
	move.w (a6)+,d7
	add.w d7,a0		; selection plan
	;move.l scr1,d0
	move.l d0,curscr
	jsr set8200
	
;setpalette	
	lea $ffff8240.w,a3
	rept 4
	move.l (a2)+,(a3)+
	endr
	
	move.l a1,a6		; lea code1,a6
	;move.l scr1,a0
	*lea selplan(a0),a0	; sel plan ne peut plus quetre egale a 0 ou 2
	moveq #$FF,d0
	jsr cgEFF
	
	

	 ifne doscroller
	 jsr doscroll
	 endc
	jsr majAngleT
	jsr prepbufferAdresse

	move.l ptrsequence1,a6
	move.l 4(a6),d0			; codeX
	jsr demo


	move.l ptrsequence1,a6
	lea 14(a6),a6

	move.l a6,d0
	cmp.l #finsequence1,d0
	bne.s .ok
	move.l #sequence1,a6
.ok	move.l a6,ptrsequence1


	rts
demoloop2		; bounce sequence
	jsr wvbl
*	move.l scr1,d0
*	move.l scr2,d1
*	move.l d1,scr1
*	move.l d0,scr2	
*
*	move.l scr1,d0
*	jsr set8200


	move.l ptrsequence1,a6  
	*lea sequence1,a6
	
	movem.l (a6)+,a0-a2		; scr, code, pal
	move.l (a0),a0			; scr = est un pointeur
	move.l a0,d0
	move.w (a6)+,d7
	add.w d7,a0		; selection plan
	
	move.l d0,curscr
	jsr set8200

;setpalette	
	lea $ffff8240.w,a3
	rept 4
	move.l (a2)+,(a3)+
	endr



	move.l a1,a6
	*move.l scr1,a0
	*lea selplan(a0),a0
	moveq #$ff,d0	; $ff
	jsr cgEFF

	ifne doscroller 
	jsr doscroll
	endc
	*not $ffff8240.w



	move.l ptrsequence1,a6  
	*lea sequence1,a6
	
	movem.l (a6)+,a0-a2		; scr, code, pal
	move.l (a0),a0			; scr = est un pointeur
	move.l a0,d0
	move.w (a6)+,d7
	add.w d7,a0		; selection plan
	;move.l scr1,d0
	move.l d0,curscr
	


		*move.l scr1,a0
		*move.l #code1,a1
		*lea selplan(a0),a0
	jsr bounceit
		*not $ffff8240.w

	
	move.l ptrsequence1,a6
	lea 14(a6),a6

	move.l a6,d0
	cmp.l #finsequence1,d0
	bne.s .ok
	move.l #sequence1,a6
.ok	move.l a6,ptrsequence1


	rts

ptrtableauoffset	dc.l tableapparition
tableapparition		incbin 'appar2.tab'
			dc.w 2,2		; seul nb positif
demoloop3		; ajuste offsetapparition: de 32000 a 0
	clr.l d0
	move.l ptrtableauoffset,a0
	;;move.l a0,d0
	;tst d0
	
	move.l (a0),d1
	tst.l d1
	bmi.s .1
	move.w #0,modeEFFET
	move.l #tableapparition,ptrtableauoffset
	move.w #dureefonction,timervbl
	bra .2
.1
	move.w (a0)+,d0


;	divs #160,d0
;	ext.l d0
;	asl #3,d0


	ext.l d0
	move.l d0,offsetapparition
	move.l a0,ptrtableauoffset


	jsr wvbl

	move.l ptrsequence1,a6  
	*lea sequence1,a6
	
	movem.l (a6)+,a0-a2		; scr, code, pal
	move.l (a0),a0			; scr = est un pointeur
	move.l a0,d0
	move.w (a6)+,d7
	add.w d7,a0		; selection plan
	
	move.l d0,curscr
	jsr set8200

;setpalette	
	lea $ffff8240.w,a3
	rept 4
	move.l (a2)+,(a3)+
	endr





*	move.l scr1,d0
*	move.l scr2,d1
*	move.l d1,scr1
*	move.l d0,scr2	

*	move.l scr1,d0
*	jsr set8200

	move.l a1,a6
	*move.l scr1,a0
	*lea selplan(a0),a0
	moveq #$FF,d0
	jsr cgEFF

	ifne doscroller
	 jsr doscroll
	endc
	jsr majAngleT
	jsr prepbufferAdresse


	move.l ptrsequence1,a6  
	*lea sequence1,a6
	
	movem.l (a6)+,a0-a2		; scr, code, pal
	move.l (a0),a0			; scr = est un pointeur
	move.l a0,d0
	move.w (a6)+,d7
	add.w d7,a0		; selection plan



	move.l a1,d0
	jsr demo


	
	move.l ptrsequence1,a6
	lea 14(a6),a6

	move.l a6,d0
	cmp.l #finsequence1,d0
	bne.s .ok
	move.l #sequence1,a6
.ok	move.l a6,ptrsequence1




.2	rts


sequence	dc.l normalseq,preparebounce,bouncebounce,chgfct,transappar

testEXIT
	cmp.b #$b9,$fffffc02.w
	bne.s .1
	addq.l #4,sp
	jmp finmain
.1	rts

main
	*move.w #$201,$ffff8240.w
; selection de la demoloop en fonction de modeEFFET

	;move.w modeEFFET,d0
	;tst.w d0
	;beq.s normalseq
	;cmp.w #1,d0
	;beq.w chgfct

	move.w #$216,$ffff825C.w

	move.w #$763,$ffff825a.w



	move.w modeEFFET,d0
	lsl #2,d0
	lea sequence,a0
	move.l (a0,d0),a0
	jmp (a0)


normalseq
	bsr demoloop 
	bsr testEXIT
	subq #1,timervbl
	bne.s .okok 		bne.s .okok
	ifeq notextradot
	jsr clearoldsampledot
	endc
	move.w #dureefonction,timervbl
	move.W #1,modeEFFET	
.okok
	bra main


.normaleffect	
	subq #1,timervbl	
	*addq #1,timervbl
	beq .toto

	bsr demoloop 
	bsr testEXIT
	*addq #1,timervbl
	bra main

.toto			; ici modeEFFET passe de 0 a 1 et execution de initbounce
	move.w #dureefonction,timervbl
	move.w #1,modeEFFET	; 

	********jsr initbounce
	bsr demoloop
	bsr testEXIT
	bra main

.rebond

	*jsr takelogscrtoa0
	move.l scr1,a0
	
	lea code1,a1
	jsr bounceit
	bsr demoloop
	bsr testEXIT
	
	bra main

	jsr prepbufferAdresse
	move.l #code1,d0
	jsr demo
	jsr wvbl
	move.l scr1,d0
	move.l scr2,d1
	move.l d1,scr1
	move.l d0,scr2	
	move.l scr1,d0
	jsr set8200
	lea code2,a6
	move.l scr1,a0
	lea selplan(a0),a0
	moveq #-1,d0
	jsr cgEFF

	ifne doscroller
	 jsr doscroll
	endc
	*jsr majAngleT
	jsr prepbufferAdresse

	move.l #code2,d0
	jsr demo
	
	nop
	bra.w main


preparebounce
	jsr initbounce
	move.w #2,modeEFFET
	move.w #200,timervbl
	bra main




chgfct
	ifne doscroller
	 jsr doscroll
	endc
	jsr wvbl
	
	move.l ptrfct,a0
	move.l (a0)+,d0
	bpl.s .ok0

	move.l #lstfct,ptrfct
	move.l ptrfct,a0
	move.l (a0)+,d0
.ok0
	move.l a0,ptrfct
	move.l d0,curfct
	jsr initfonction
	
	lea angle1,a6
	move.w #128*4,d6
	moveq #0,d7
	move d6,(a6)+
	move d6,(a6)+
	move d6,(a6)+
	move d7,(a6)+
	move d7,(a6)+
	move d7,(a6)+
	
	move.w #4,modeEFFET
	move.l #tableapparition,ptrtableauoffset
	jsr initbounce

;	jsr ifne doscroller jsr doscroll

	bsr testEXIT
	bra main

itvbl2



	movem.l d0-a6,-(sp)
	ifne enablesound

	jsr SOUND+8

	endc
	
	ifne doscroller
	 jsr doscroll
	endc
	*move.l scr1,d0
	*move.l scr2,d1
	*move.l d1,scr1
	*move.l d0,scr2	

	*move.l scr1,d0
	*jsr set8200



	movem.l (sp)+,d0-a6
	addq.l #1,$466.w
	rte



bouncebounce
	bsr demoloop2 
	bsr testEXIT
	subq #1,timervbl
	bne.s .okok
	move.w #dureefonction,timervbl
	move.W #3,modeEFFET	
.okok
	bra main



transappar
	bsr demoloop3
	bsr testEXIT
	bra main

.ok
	jsr wvbl
	move.l scr1,d0
	move.l scr2,d1
	move.l d1,scr1
	move.l d0,scr2	

	move.l scr1,d0
	jsr set8200
; now on travail sur scr1

	*not $ffff8240.w

	lea code1,a6
	move.l scr1,a0
	lea selplan(a0),a0
	moveq #$FF,d0
	jsr cgEFF

	ifne doscroller 
	jsr doscroll
	endc
	jsr majAngleT
	jsr prepbufferAdresse

	move.l #code1,d0
	jsr demo


	jsr wvbl
	move.l scr1,d0
	move.l scr2,d1
	move.l d1,scr1
	move.l d0,scr2	

	move.l scr1,d0
	jsr set8200

	lea code2,a6
	move.l scr1,a0
	lea selplan(a0),a0
	move #$FFFF,d0
	jsr cgEFF

	ifne doscroller 
	jsr doscroll
	endc
	jsr majAngleT
	jsr prepbufferAdresse
	move.l #code2,d0
	jsr demo

	cmp.b #$b9,$fffffc02.w
	beq.s .1
	jmp main
.1
finmain	
	lea normalpal,a0
	movem.l (a0)+,d0-d7
	movem.l d0-d7,$ffff8240.w
	jsr wvbl

;	movem.l (sp)+,d0-d7/a0-a6
;	jsr dezinitZIK

	*ifne enablesound
	move.l oldvbl,$70.w
	*endc
	;jsr ssd_driver+8
	ifne enablesound

	jsr SOUND+4
	
	endc
*	move.l $44e.w,d0
*	jsr set8200

	*move #$777,$ffff8240.w
	jsr wvbl
	*move.w #1,-(sp)
	move.l $44e.w,d0
	move.l d0,-(sp)
	move.l d0,-(sp)
	move.w #5,-(sp)		;setscren
	trap #14
	lea 12(sp),sp


	*move.b #1,$ffff8260.w

	move.l oldusp,-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp

	clr.w -(sp)
	trap #1

;	VBL replayer for unpacked SNDH files;
;       Special example for Tobe and Gloky/MJJ;;	gwEm 2005;

;initZIK
;	move.l	$70.w,oldvbl		; store old VBL
;	move.l	#vbl,$70.w		; steal VBL
;	bsr	MUSIC+0			; init music
;	rts
;dezinitZIK
;
;	
;	lea bufferREG,a6
;	movem.l (a6)+,d0-d7/a0-a5
;	move.l (a6),a6
		
;	bsr	MUSIC+4			; de-init music
;	move.l	oldvbl,$70.w		; restore VBL

;	rts
;	move.l	oldusp(pc),-(sp)	
; user mode
;	move.w	#$20,-(sp)
;	trap	#1			;
;	addq.l	#6,sp			;
;	clr.w   -(sp)                   ; pterm()
;	move.w	#$4c,-(sp)		;
;	trap    #1      		;
;................................................................
vbl:


	movem.l d0-a6,-(sp)
	ifne enablesound
	jsr SOUND+8
	endc
	movem.l (sp)+,d0-a6
	addq.l #1,$466.w
	rte


;	move.l a6,-(sp);
;	lea bufferREG,a6
;	movem.l d0-d7/a0-a5,(a6)
;	move.l (sp)+,8*4+6*4(a6)

;        move.l  oldvbl(pc),-(sp)	; go to old vector (system friendly ;) )
;	;addq.l #1,$466.w
;	rts
;	; rts
oldvbl:	ds.l	1
oldusp:	ds.l	1
;......................................................


;MUSIC:	incbin	test_ste.snd		; SNDH file to include


;superwvbl
;	move.l $468.w,d7
;	cmp.w $468.w,d7
;	beq.s .1
;	rts
;.1
;	; code avec test regulier de d7 a 468.w
;
;;	rept 128
;;	nop
;;	nop		; code faisant 3scanline de cycle si on veut une granularite de 3 scanline
;;	nop
;;	endr
;;
;;	jsr test468		; test si vbl
;;
;;	;code
;;
;;	jsr test468
;;
;;	; code
;;
;;	; etc...
;
;
;	; a la fin: on attend la vbl
;.bra
;
;
;	cmp $468.w,d7
;	beq.s .bra
;	rts
;
;test468
;	cmp.w $468.w,d7
;	bne.s .1
;	rts
;.1
;	move.l (sp)+,d7
;	rts	; fin de la routine superwvbl
;
;
; itvblworking
;:             tst.w process
;             bne.s .suite
;             rte
; .suite:     ;  1 programme est en cours d'execution
;             lea process_stack,a0
 ;            move.l program_counter,a1
  ;           movem.l a1,-(sp)
   ;          movem.l (a0)+,d0-d7/a0-a7
    ;         rts ; pb jamais de rte
;
;
;
;c;reateSinTab2:

;clear all flag
;	lea tabflag,a0
;	move.w #511,d0
;.l0	clr.w (a0)+
;	dbra.w d0,.l0
;	lea -1024(a0),a0
;
;	move.l sin512,a6
;	lea tmpsin512,a2
;	move.w valmul,d0
;	move.w #512-1,d7
;.bclmul
;	move.w (a6)+,d1
;	lsl d0,d1
;	move.w d1,(a2)+
;	dbra d7,.bclmul
;	lea -1024(a2),a2
;
;
;	move.w step1,d0
;	add d0,d0
;	tst d0
;	beq.w .TrivialCase
;
;
;	;lea tmpsin512,a2
;	move.w #511,d7
;	move.w #1022,d6
;	moveq #0,d5
;	moveq #0,d3
;
;.loop
;	tst (a0,d5)	; test flag correspondant
;	beq.s .ok1
;	
;	move.w d5,-(sp)
;	move.w #TLbar-2,d4		; tlbar-1 valeur suplementaire
;.bcl	move.w (a2,d5),(a1)+
;	add d0,d5
;	and d6,d5
;	add #2,d3	* ???
;	dbra.w d4,.bcl
;	move.w (sp)+,d5	
;	addq #2,d5
;	and.w d6,d5
;	tst (a0,d5)
;	bne.s .fin
;.ok1		
; 	move.w (a2,d5),(a1)+
;
;	add d5,d5
;	move.l d3,(a3,d5)	; table reference
;	lsr #1,d5
;
;	move.w #-1,(a0,d5)	; positione flag index utilisé
;	addq #2,d3
;	
;	add d0,d5
;	and d6,d5
;	dbra.w d7,.loop
;
;	move.w #TLbar-2,d4
;.bcl2	move.w (a2,d5),(a1)+
;	add d0,d5
;	and d6,d5
;	dbra.w d4,.bcl2
;
;.fin	rts
;.TrivialCase
;	illegal
;	move.w #511,d7
;	move.w #1022,d6
;	moveq #0,d5
;	moveq #0,d3
;
;	move.w #511,d7		; 	
;.loop1	move.w (a2)+,d4
;	move.w #TLbar-1,d0
;.loop0	move.w d4,(a1)+
;	dbra.w d0,.loop0
;	dbra.w d7,.loop1
;
*, 	
*,
*	,add d5,d5
*	m,ove.l d3,(a3,d5)	; table reference
*	lsr #1,d5
*,
*	,*move.w #-1,(a0,d5)	; positione flag index utilisé
*	,
*	a,ddq #2,d3
*	ad,d d0,d5
*	and, d6,d5
*,
*
;	rts

		BSS


;timervbl	ds.w 1

curscr	ds.l 1
convX	ds.l 320*4	; pas de cliping pour l'instant


	ds.w 200*4
convY	ds.w 200*4

cpt	ds.w 1
CPT1	ds.w 1
angle1	ds.w 1
angle2	ds.w 1
angle3	ds.w 1
angle4	ds.w 1
angle5	ds.w 1
angle6	ds.w 1

ajoutangle1	ds.w 1
ajoutangle2	ds.w 1
ajoutangle3	ds.w 1
ajoutangle4	ds.w 1
ajoutangle5	ds.w 1
ajoutangle6	ds.w 1

step1	ds.w 1
sin512	ds.l 1

valmul	ds.w 1
tmpsin512	ds.w 512

tabflag	ds.w 512


cgEFF
	IFEQ DOUBLESIZE	
	ds.b (nbpts/8)*36+2
	ENDC
	IFNE DOUBLESIZE
	ds.b 4+(nbpts/8)*70+2
	ENDC

refTableSin	ds.l 6
refs1	ds.l 512
refs2	ds.l 512
refs3	ds.l 512
refs4	ds.l 512
refs5 	ds.l 512
refs6	ds.l 512

refs7	ds.l 512
refs8	ds.l 512

code1	ds.l nbpts
	ds.w 2	; rts
code2	ds.l nbpts
	ds.w 2
code3	ds.l nbpts
	ds.w 2
code4	ds.l nbpts
	ds.w 2
code5	ds.l nbpts
	ds.w 2
code6	ds.l nbpts
	ds.w 2
code7	ds.l nbpts
	ds.w 2
code8	ds.l nbpts
	ds.w 2
code9	ds.l nbpts
	ds.w 2
code10	ds.l nbpts
	ds.w 2
code11	ds.l nbpts
	ds.w 2
code12	ds.l nbpts
	ds.w 2




ECRAN	ds.b 32160
	ds.b 256
	ds.b 32160
	ds.b 256
	ds.b 32160
	ds.b 256
	ds.b 32160
	ds.b 256
; 3 ecran 


bufferOperation	ds.l nbpts


	
	ifeq notextradot
extradot
	endc
		ifeq notextradot
		ds.l 12*5+1
		endc

		ifne sampledotx2
		ds.l 12*5
		endc
		ifne sampledotx4
		ds.l 12*5*2
		endc
	
offsetapparition	ds.l 1
scr
scr1	ds.l 1
scr2 	ds.l 1
scr3	ds.l 1
scr4	ds.l 1
*curscr	ds.l 1

bssbuffer	ds.w 32000

bufferAdresse
	ds.l 6*NBbar

	ds.l 10000
topstack ds.l 1

bufferREG	ds.l 64

bufsin1	ds.l 1
bf2	ds.b 6354*11
	ds.w 64000
nopnop	ds.w 1
	ds.w 64000
	ds.w 64000
	even

sinx1	ds.w 512
sinx2	ds.w 512
sinx3	ds.w 512
sinx4	ds.w 512
siny1	ds.w 512
siny2	ds.w 512
siny3	ds.w 512
siny4	ds.w 512


cgmajpoint	ds.b 2+tlcgmajpoint*(TLbar/4)


	DATA

fct1
	dc.w 511-4
	dc.w 12
	dc.w 1
	dc.w 511-2
	dc.w 4
	dc.w 11
	dc.w 511-3	move.w #(511-3)*4,ajoutangle1
	dc.w 2		move.w #12*4,ajoutangle2	
	dc.w 4		move.w #14*4,ajoutangle3
	dc.w 3		move.w #13*4,ajoutangle4
	dc.w 511-11	move.w #(511-11)*4,ajoutangle5
	dc.w 511-7	move.w #(511-7)*4,ajoutangle6
	
	dc.w 5,3,511-2,6,511-3,511-1	; majT
	;add #5*4,d0			; *4 ou *2 ?????
	;add #3*4,d1
	;add #(511-2)*4,d2
	;add #6*4,d3
	;add #(511-2)*4,d4
	;add #1*4,d5


fct0	dc.w 7,511-11,12,5,4,5
	dc.w 5,12,4,3,15,511-7
	dc.w 6,2,511-2,4,3,511-1


fct2	dc.w 10,20,511-15,17,511-9,22
	dc.w 15,23,511-12,18,24,511-19
	dc.w 7,2,5,511-3,511-6,3

fct3
	dc.w 20,511-49,34,17,45,43
	dc.w 22,32,511-23,19,23,24
	dc.w 6,5,4,4,3,511-2

fct4
	dc.w 4,6,5,6,511-5,511-7
	dc.w 6,8,10,511-14,13,7
	dc.w 5,6,511-4,7,511-6,3

fct5	dc.w 14,511-40,4,14,24,44		; belle fonction !
	dc.w 15,511-15,15,15,15,15
	dc.w 2,3,511-0,511-5,4,1

fct6	dc.w 126+3,8,119,116,122,12
	dc.w 122,1,511-114,115,138,15
	dc.w 3,9,1,3,1,7


fct7
	dc.w 511-17
	dc.w 10
	dc.w 1
	dc.w 511-12
	dc.w 4
	dc.w 11
	dc.w 511-3	move.w #(511-3)*4,ajoutangle1
	dc.w 2		move.w #12*4,ajoutangle2	
	dc.w 4		move.w #14*4,ajoutangle3
	dc.w 3		move.w #13*4,ajoutangle4
	dc.w 511-11	move.w #(511-11)*4,ajoutangle5
	dc.w 511-7	move.w #(511-7)*4,ajoutangle6

	dc.w 5,3,511-2,2,511-3,511-1	; majT

fct8	dc.w 9,511-9,7,511-6,9,9
	dc.w 4,30,12,18,27,33
	dc.w 1,2,7,3,9,1

fct9	dc.w 45,62,38,47,63,40
	dc.w 50,51,40,52,60,39
	dc.w 511-3,2,1,1,4,5


fct10	dc.w 1,2,3,4,5,6,7
	dc.w 7,9,15,14,3,2
	dc.w 5,2,511-2,511-2,2,4


fct11	dc.w 14,15,511-14,14,15,14
	dc.w 16,14,18,511-17,20,13
	dc.w 4,3,511-2,2,511-5,3


fct12	dc.w 10,4,6,8,2,12
	dc.w 14,22,18,20,16,24
	dc.w 3,2,4,511-2,3,1

fct13	dc.w 10,12,11,10,11,12
	dc.w 4,9,7,7,4,9
	dc.w 1,2,3,1,2,3

fct14	dc.w 10,9,8,11,10,9
		dc.w 7,12,11,6,13,4
		dc.w 2,4,5,5,3,1
	
fct15	dc.w 22,511-23,27,18,26,21
		dc.w 17,15,13,16,14,511-12
		dc.w 511-3,2,7,4,511-1,5
		
fct16	dc.w 17,18,15,19,24,14
	dc.w 20,21,22,22,21,20
	dc.w 4,2,3,5,3,4


fct17	dc.w 121,110,140,130,131,127
	dc.w 122,120,124,137,108,109
	dc.w 1,2,3,1,2,3

	
fct18	dc.w 3,4,511-3,4,5,1
	dc.w 7,9,22,12,13,511-6
	dc.w 3,511-1,2,2,511-5,4

fct19	dc.w 50,51,52,53,511-50,511-25
	dc.w 49,47,46,51,511-36,511-65
	dc.w 511-3,1,5,1,511-5,2

fct20	dc.w 12,18,20,13,21,17
	dc.w 15,11,17,18,10,9
	dc.w 3,511-2,6,6,3,1

fct21	dc.w 10,11,512-250,5,7,6
	dc.w 15,13,3,8,12,511-5
	dc.w 252,3,259,512-3,511-5,1


fct22	dc.w 21,23,24,29,19,10
	dc.w 20,20,14,12,25,17
	dc.w 3,511,2,3,510,4



fct23	dc.w 127,6,5,512-12,512-7,2
	dc.w 125,5,512-6,8,511,1
	dc.w 131,512-3,1,510,4,2 


fct24	dc.w 127,2,3,131,4,3
	dc.w 2,1,4,5,3,2
	dc.w 1,7,5,3,9,512-4


fct25	dc.w 102,5,9,512-107,8,512-6
	dc.w 7,9,512-12,10,12,512-8
	dc.w 511,510,4,6,9,13


fct26	dc.w 1,2,3,4,5,6
	dc.W 2+1,3+2,4+3,5+4,6+5,7+6
	dc.w 2,5,3,6,4,7

fct27	dc.w 22,5,6,28,7,9
	dc.w 3,9,8,7,5,13
	dc.w 5,1,510,6,3,4

;
;	schema de fonction:
;	dc.w a,b,c,d,e,f
;	dc.w g,h,i,j,k,l
;	dc.w m,n,o,p,q,r	a-r valeur comprise entre 0 et 511
;
; mainloop:
;  for zy=0 to NBbar-1		
;  for zx=0 to TLbar-1
;    x=sin(a*zx+g*zy+m*t)+sin(b*zx+h*zy+n*t)+sin(c*zx+i*zy+o*t)
;    y=sin(d*zx+j*zy+p*t)+sin(e*zx+k*zy+q*t)+sin(f*zx+l*zy+r*t)
;    plot x,y
;  next zx
; next zy
; wait vbl
; t=t+1
;finmainloop
;
; changer la fonction:
;  move.l fctx,curfct
;  jsr initfonction (met un certain temps (5vbl??))
;
; les sinus on 512 element
; pour faire un angle negatif: 511-angle


fctA	dc.w 3,12,22,34,15,1
	dc.w 4,17,25,13,8,2
	dc.w 1,2,3,4,5,6

fctB	dc.w 6,511-24,46,13,511-25,8

	dc.w 7,12,511-2,9,10,6
	dc.w 3,1,5,511-1,3,511-6
 
fctC	dc.w 3,6,6,6,5,5
	dc.w 511-4,511-5,7,511-7,4,3
	dc.w 2,1,3,3,511-1,2

fctD	dc.w 29,28,29,27,25,24
	dc.w 17,23,44,36,12,1
	dc.w 2,2,3,1,511-3,5

fctE	dc.w 511-5,511-5,5,511-5,5,5
	dc.W 1,3,5,2,6,7
	dc.w 2,4,6,7,6,511-5
fctF
	dc.w 5,4,2,2,1,6
	dc.w 2,3,4,5,6,8
	dc.w 1,1,10,3,5,9	

fctG	dc.w 20,30,40,30,511-20,511-10
	dc.w 33,45,29,18,12,17
	dc.w 511,511-1,2,511-3,4,2

fctH	dc.w 17,35,7,15,34,8
	dc.w 19,33,511-6,12,37
	dc.w 3,2,511-1,511-4,2,1

*lstfct	dc.l fctF,fctG,fctD,fctE,fctC,fctC,fctA,fctB,fct21,fct18,fct19,fct20,fct14,fct15,fct16,fct17,fct13,fct12,fct1,fct2,fct3,fct4,fct5,fct6,fct7,fct8
*	dc.l fct9,fct10,fct11,fct12
*	dc.l -1
lstfct	dc.l fct27,fct26,fct25,fct24,fct23,fct0,fct1,fct2,fct3,fct4,fct5,fct6,fct7,fct8,fct9,fct10,fct11,fct12,fct13,fct14,fct15,fct16,fct17,fct18,fct19,fct20,fct21,fctA,fctB,fctC,fctD,fctE,fctF,fctG,fctH
		dc.l -1
		
ptrfct	dc.l lstfct

timervbl	dc.w dureefonction

totocolor	equ $621
pal	dcb.w 8,0
	dcb.w 8,totocolor

normalpal	dc.w $0,$111,$222,$333,$444,$555,$666,$777
		dcb.w 8,$777
	
;sin100	;incbin sin30.tab

*sin60	*incbin sin25.tab
*sin80
*sin100	incbin sin25.tab
*sin120	incbin sin20.tab
*sin80	incbin sin25.tab

PICTURE1
	ifeq nopic
	incbin 'trsi.pi1'
	incbin 'aviat3.pi1'
	endc
SOUND	*incbin 'test0000.SND'
	incbin 'pourglky.snd' ;metalpla.snd'
	*incbin 'metalpla2.snd'
		*include 'scr1.s'


