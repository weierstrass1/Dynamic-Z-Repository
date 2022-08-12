This sprites requires the pixi routine:

DisplayContactEffect.asm

On the top of the routine you must set up the PIXI ID of the Contact Effect in this line:

!ContactEffect = $00

If you don't want to use this contact effect change this line:

!UseDefaultStarEffect = 0 ;0 = DKC effect, 1 = smw effect

The contact effect uses "ContactEffect and Smoke Palette.pal" by default Palette A.

If you wanna edit the palette used, go to the line:

	LDA #$35
	STA $4F

the LDA #$35 is the YXPPCCCT property.

Y = Flip Y (use 0).
X = Flip X (use 0).
PP = Priority (use 10 or 11, by default 11)
CCC = Palette (by default is 010)
T = Graphic Page (use 1)
