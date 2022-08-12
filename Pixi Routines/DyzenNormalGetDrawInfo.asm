!XPos = $00
!YPos = $06

!XOff = $00
!YOff = $06
?DyzenNormalGetDrawInfo:
    LDA !SpriteXHigh,x
    STA $01
    LDA !SpriteXLow,x
    STA $00
    LDA !SpriteYHigh,x
    STA $07
    LDA !SpriteYLow,x
    STA $06

	PHY
	STZ !SpriteHOffScreenFlag,x
	STZ !SpriteVOffScreenFlag,x

	LDY #$00

	REP #$20
	LDA !XPos
	SEC
	SBC !Layer1X
	STA !XOff
	BMI ?+

	CMP #$010F
	BCC ?++

	LDY #$01
	BRA ?++
?+
	CMP #$FEF2
	BCS ?++

	LDY #$01

?++
	SEP #$20

	TYA
	STA !SpriteHOffScreenFlag,x

	LDY #$00

	REP #$20
	LDA !YPos
	SEC
	SBC !Layer1Y
	STA !YOff
	BMI ?+

	CMP #$00EF
	BCC ?++

	LDY #$01
	BRA ?++

?+
	CMP #$FF12
	BCS ?++

	LDY #$01
?++

	SEP #$20
	TYA
	STA !SpriteVOffScreenFlag,x
	PLY
RTL