?CPXMovSetMiscs:
	LDA !ExtraByte1,x
	STA !Scratch0
	LDA !ExtraByte2,x
	STA !Scratch1
	LDA !ExtraByte3,x
	STA !Scratch2

	LDY #$00
	LDA [!Scratch0],y
	AND #$E0
	STA !ExtraByte1,x

	LDA [!Scratch0],y
	AND #$07
	ASL
	STA !Pal,x

	LDA [!Scratch0],y
	LSR
	LSR
	LSR
	AND #$07
	STA !Version,x
	INY 

	;Mov Type
	LDA [!Scratch0],y
	LSR
	LSR
	LSR
	LSR
	STA !MovTypeX,x
	LDA [!Scratch0],y
	AND #$0F
	STA !MovTypeY,x
	INY 

	;Max Speed
	LDA [!Scratch0],y
	AND #$F0
	STA !MaxSpeedX,x
	LDA [!Scratch0],y
	AND #$0F
	ASL
	ASL
	ASL
	ASL
	STA !MaxSpeedY,x
	INY 

	;Accel
	LDA [!Scratch0],y
	LSR
	LSR
	LSR
	LSR
	STA !AccelX,x
	LDA [!Scratch0],y
	AND #$0F
	STA !AccelY,x
	INY 

	;Initial Angle
	LDA #$00
	XBA
	LDA [!Scratch0],y
	CLC
	REP #$20
	ASL
	ASL
	STA !Scratch3
	SEP #$20

	LDA !Scratch3
	STA !PhaseLow,x
	LDA !Scratch4
	STA !PhaseHigh,x
	INY

	;Angle Speed
	LDA [!Scratch0],y
	STA !AngleSpeed,x
	INY

	;Amplitude
	LDA [!Scratch0],y
	LSR
	LSR
	LSR
	LSR
	STA !AmplitudeX,x
	LDA [!Scratch0],y
	AND #$0F
	STA !AmplitudeY,x
	INY

	LDA [!Scratch0],y
	AND #$F0
	STA !RatioX,x
	LDA [!Scratch0],y
	AND #$0F
	ASL
	ASL
	ASL
	ASL
	STA !RatioY,x
	INY

	LDA [!Scratch0],y
	LSR
	LSR
	LSR
	LSR
	STA !RatioIncreaseX,x
	LDA [!Scratch0],y
	AND #$0F
	STA !RatioIncreaseY,x
	INY

	LDA [!Scratch0],y
	AND #$F0
	STA !RatioMaxX,x
	LDA [!Scratch0],y
	AND #$0F
	CLC
	ASL
	ASL
	ASL
	ASL
	STA !RatioMaxY,x
	INY
	
RTL