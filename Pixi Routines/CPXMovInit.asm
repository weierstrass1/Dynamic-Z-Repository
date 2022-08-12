?CPXMovInit:
    LDA #$00
	STA !AngleLow,x
	STA !AngleHigh,x
	STA !RatioIncreaseTimerX,x
	STA !RatioIncreaseTimerY,x

	LDA !SpriteXLow,x
	STA !PosXL,x
	LDA !SpriteXHigh,x
	STA !PosXH,x

	LDA !SpriteYLow,x
	STA !PosYL,x
	LDA !SpriteYHigh,x
	STA !PosYH,x

	%CPXMovSetMiscs()

	
	LDA !MovTypeX,x
	TAX
	LDA.l ?MustSetInitialAngle,x
	PHA
	LDX !SpriteIndex
	LDA !MovTypeY,x
	TAX
	PLA
	ORA.l ?MustSetInitialAngle,x
	BEQ ?+
	LDX !SpriteIndex
	LDA !PhaseLow,x
	STA !AngleLow,x
	LDA !PhaseHigh,x
	STA !AngleHigh,x
?+
	LDX !SpriteIndex

	LDA !MovTypeX,x
	TAX
	LDA.l ?HasConstSpeed,x
	BNE ?+
	LDX !SpriteIndex

	STZ !SpriteXSpeed,x
	BRA ?++
?+
	LDX !SpriteIndex

	LDA !MaxSpeedX,x
	STA !SpriteXSpeed,x
?++
	LDA !MovTypeY,x
	TAX
	LDA.l ?HasConstSpeed,x
	BNE ?+
	LDX !SpriteIndex
	STZ !SpriteYSpeed,x
	BRA ?++
?+
	LDX !SpriteIndex
	LDA !MaxSpeedY,x
	STA !SpriteYSpeed,x
?++
RTL

?HasConstSpeed:
	db $00,$01,$00,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00
?MustSetInitialAngle:
	db $00,$00,$00,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00