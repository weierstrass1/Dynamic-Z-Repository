!XPos = $00
!YPos = $06

!XOff = $00
!YOff = $06

?DyzenGenericGetDrawInfo:

	REP #$20
	LDA !XPos
	SEC
	SBC !Layer1X
	STA !XOff

	LDA !YPos
	SEC
	SBC !Layer1Y
	STA !YOff
	SEP #$20
RTL