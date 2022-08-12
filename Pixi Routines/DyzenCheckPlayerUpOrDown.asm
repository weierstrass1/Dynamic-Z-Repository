;Carry Set = Player at the left, Carry Clear = Player at the right
?DyzenCheckPlayerUpOrDown:
	LDA !SpriteYHigh,x
	XBA
	LDA !SpriteYLow,x
	REP #$20
	CLC
	ADC $00
	CMP !PlayerY
	SEP #$20
RTL