?MovementState:
    PHB
    PHK
    PLB

	LDA !MovTypeX,x
	TAY
	LDA.w ?.ApplyAngleSpeed,y
	PHA
	LDA !MovTypeY,x
	TAY
	PLA
	ORA.w ?.ApplyAngleSpeed,y
	BEQ ?+

	STZ !Scratch1
	LDA !AngleSpeed,x
	STA !Scratch0
	BPL ?++
	LDA #$FF
	STA !Scratch1
?++

	LDA !AngleHigh,x
	XBA
	LDA !AngleLow,x
	REP #$20
	CLC
	ADC !Scratch0
	STA !Scratch0
	CMP #$02D0
	BCC ?++
	SEC
	SBC #$02D0
	STA !Scratch0
?++
	SEP #$20
	LDA !Scratch0
	STA !AngleLow,x
	LDA !Scratch1
	STA !AngleHigh,x
?+

	LDA !MovTypeX,x
	ASL
	TAX
	
	JSR (?.MoveX,x)

	LDA !MovTypeY,x
	ASL
	TAX
	
	JSR (?.MoveY,x)

    PLB
RTL

?.ApplyAngleSpeed
	db $00,$00,$00,$01,$01,$01,$01,$01,$01,$00

?.MoveX
	dw ?.NoMovement
	dw ?.ConstantX
	dw ?.FollowX
	dw ?.SinX
	dw ?.CosX
	dw ?.SinSinX
	dw ?.SinCosX
	dw ?.CosSinX
	dw ?.CosCosX

?.MoveY
	dw ?.NoMovement
	dw ?.ConstantY
	dw ?.FollowY
	dw ?.SinY
	dw ?.CosY
	dw ?.SinSinY
	dw ?.SinCosY
	dw ?.CosSinY
	dw ?.CosCosY

?.NoMovement
	LDX !SpriteIndex
RTS

?.ConstantX
	LDX !SpriteIndex

	LDA !MaxSpeedX,x
	STA !SpriteXSpeed,x

	JSL $018022|!rom
RTS

?.ConstantY
	LDX !SpriteIndex

	LDA !MaxSpeedY,x
	STA !SpriteYSpeed,x

	JSL $01801A|!rom
RTS

?.FollowX
	LDX !SpriteIndex

	LDA !SpriteXHigh,x
	XBA
	LDA !SpriteXLow,x
	REP #$20
	CLC
	ADC #$000C
	CMP !PlayerX
	SEP #$20
	BCC ?+

	LDA !MaxSpeedX,x
	EOR #$FF
	INC A
	STA !Scratch0

	LDA !SpriteXSpeed,x
	SEC
	SBC !AccelX,x
	STA !SpriteXSpeed,x
	BPL ?++
	CMP !Scratch0
	BCS ?++
	LDA !Scratch0
	STA !SpriteXSpeed,x
	JSL $018022|!rom
RTS
?+
	LDA !SpriteXSpeed,x
	CLC
	ADC !AccelX,x
	STA !SpriteXSpeed,x
	BMI ?++
	CMP !MaxSpeedX,x
	BCC ?++
	LDA !MaxSpeedX,x
	STA !SpriteXSpeed,x
?++
	JSL $018022|!rom
RTS

?.FollowY
	LDX !SpriteIndex

	LDA !SpriteYHigh,x
	XBA
	LDA !SpriteYLow,x
	REP #$20
	SEC
	SBC #$0008
	CMP !PlayerY
	SEP #$20
	BCC ?+

	LDA !MaxSpeedY,x
	EOR #$FF
	INC A
	STA !Scratch0

	LDA !SpriteYSpeed,x
	SEC
	SBC !AccelY,x
	STA !SpriteYSpeed,x
	BPL ?++
	CMP !Scratch0
	BCS ?++
	LDA !Scratch0
	STA !SpriteYSpeed,x
	JSL $01801A|!rom
RTS
?+
	LDA !SpriteYSpeed,x
	CLC
	ADC !AccelY,x
	STA !SpriteYSpeed,x
	BMI ?++
	CMP !MaxSpeedY,x
	BCC ?++
	LDA !MaxSpeedY,x
	STA !SpriteYSpeed,x
?++
	JSL $01801A|!rom
RTS

?.SinX
	JSR ?.ApplyRatioXIncrease
	JSR ?.Follow2X
	JSR ?.SinCosXStart
	%Sin()
	JSR ?.SinCosXEnd

RTS

?.SinY
	JSR ?.ApplyRatioYIncrease
	JSR ?.Follow2Y
	JSR ?.SinCosYStart
	%Sin()
	JSR ?.SinCosYEnd

RTS

?.CosX
	JSR ?.ApplyRatioXIncrease
	JSR ?.Follow2X
	JSR ?.SinCosXStart
	%Cos()
	JSR ?.SinCosXEnd
RTS

?.CosY
	JSR ?.ApplyRatioYIncrease
	JSR ?.Follow2Y
	JSR ?.SinCosYStart
	%Cos()
	JSR ?.SinCosYEnd

RTS

?.SinSinX
	JSR ?.ApplyRatioXIncrease
	JSR ?.Follow2X
	JSR ?.SSSCCSCCXStart
	%Sin()
	JSR ?.SSSCCSCCMiddle
	%Sin()
	JSR ?.SinCosXEnd

RTS

?.SinSinY
	JSR ?.ApplyRatioYIncrease
	JSR ?.Follow2Y
	JSR ?.SSSCCSCCYStart
	%Sin()
	JSR ?.SSSCCSCCMiddle
	%Sin()
	JSR ?.SinCosYEnd

RTS

?.SinCosX
	JSR ?.ApplyRatioXIncrease
	JSR ?.Follow2X
	JSR ?.SSSCCSCCXStart
	%Cos()
	JSR ?.SSSCCSCCMiddle
	%Sin()
	JSR ?.SinCosXEnd

RTS

?.SinCosY
	JSR ?.ApplyRatioYIncrease
	JSR ?.Follow2Y
	JSR ?.SSSCCSCCYStart
	%Cos()
	JSR ?.SSSCCSCCMiddle
	%Sin()
	JSR ?.SinCosYEnd

RTS

?.CosSinX
	JSR ?.ApplyRatioXIncrease
	JSR ?.Follow2X
	JSR ?.SSSCCSCCXStart
	%Sin()
	JSR ?.SSSCCSCCMiddle
	%Cos()
	JSR ?.SinCosXEnd

RTS

?.CosSinY
	JSR ?.ApplyRatioYIncrease
	JSR ?.Follow2Y
	JSR ?.SSSCCSCCYStart
	%Sin()
	JSR ?.SSSCCSCCMiddle
	%Cos()
	JSR ?.SinCosYEnd

RTS

?.CosCosX
	JSR ?.ApplyRatioXIncrease
	JSR ?.Follow2X
	JSR ?.SSSCCSCCXStart
	%Cos()
	JSR ?.SSSCCSCCMiddle
	%Cos()
	JSR ?.SinCosXEnd

RTS

?.CosCosY
	JSR ?.ApplyRatioYIncrease
	JSR ?.Follow2Y
	JSR ?.SSSCCSCCYStart
	%Cos()
	JSR ?.SSSCCSCCMiddle
	%Cos()
	JSR ?.SinCosYEnd

RTS

?.SinCosXStart

	LDA !PosXL,x
	STA !SpriteXLow,x
	LDA !PosXH,x
	STA !SpriteXHigh,x

	JSL $018022|!rom

	LDA !SpriteXLow,x
	STA !PosXL,x
	STA !ScratchC
	LDA !SpriteXHigh,x
	STA !PosXH,x
	STA !ScratchD

	LDA !RatioX,x
	PHA

	%MulW(" !AngleHigh,x", " !AmplitudeX,x")

	LDA !MultiplicationResult
	XBA
	LDA #$00
	REP #$20
	PHA
	SEP #$20

	%MulW(" !AngleLow,x", " !AmplitudeX,x")
	REP #$20
	PLA
	CLC
	ADC !MultiplicationResult

?-
	CMP #$02D0
	BCC ?..exit

	CMP #$8000
	BCS ?..neg

?..pos
	SEC
	SBC #$02D0
	BRA ?-

?..neg
	CLC
	ADC #$02D0
	BRA ?-
?..exit

	REP #$10
	TAX
	SEP #$20
	PLA
RTS

?.SinCosXEnd
	CLC
	ADC !ScratchC
	STA !ScratchC
	SEP #$30
	LDX !SpriteIndex

	LDA !ScratchC
	STA !SpriteXLow,x
	LDA !ScratchD
	STA !SpriteXHigh,x

RTS

?.SinCosYStart

	LDA !PosYL,x
	STA !SpriteYLow,x
	LDA !PosYH,x
	STA !SpriteYHigh,x

	JSL $01801A|!rom

	LDA !SpriteYLow,x
	STA !PosYL,x
	STA !ScratchC
	LDA !SpriteYHigh,x
	STA !PosYH,x
	STA !ScratchD

	LDA !RatioY,x
	PHA

	%MulW(" !AngleHigh,x", " !AmplitudeY,x")

	LDA !MultiplicationResult
	XBA
	LDA #$00
	REP #$20
	PHA
	SEP #$20

	%MulW(" !AngleLow,x", " !AmplitudeY,x")
	REP #$20
	PLA
	CLC
	ADC !MultiplicationResult

?-
	CMP #$02D0
	BCC ?..exit

	CMP #$8000
	BCS ?..neg

?..pos
	SEC
	SBC #$02D0
	BRA ?-

?..neg
	CLC
	ADC #$02D0
	BRA ?-
?..exit

	REP #$10
	TAX
	SEP #$20
	PLA
RTS

?.SinCosYEnd
	CLC
	ADC !ScratchC
	STA !ScratchC
	SEP #$30
	LDX !SpriteIndex

	LDA !ScratchC
	STA !SpriteYLow,x
	LDA !ScratchD
	STA !SpriteYHigh,x

RTS

?.SSSCCSCCXStart

	LDA !PosXL,x
	STA !SpriteXLow,x
	LDA !PosXH,x
	STA !SpriteXHigh,x

	JSL $018022|!rom

	LDA !SpriteXLow,x
	STA !PosXL,x
	STA !ScratchC
	LDA !SpriteXHigh,x
	STA !PosXH,x
	STA !ScratchD

	LDA !RatioX,x
	STA !Scratch9

	LDA !PhaseHigh,x
	STA !ScratchB
	LDA !PhaseLow,x
	STA !ScratchA

	LDA !AmplitudeX,x
	TAY

	LDA.w ?.XPi,y
	PHA
	LDA !AngleHigh,x
	XBA
	LDA !AngleLow,x
	REP #$10
	TAX
	LDA #$00
	XBA
	PLA
RTS

?.XPi
	db $12,$24,$36,$48,$5A,$6C,$7E,$90,$A2,$B4,$C6,$D8,$EA,$FC,$FC,$FC

?.SSSCCSCCMiddle
	BPL ?+
	EOR #$FFFF
	INC A

	STA !Scratch51
	ASL
	ASL
	CLC
	ADC !Scratch51

	LSR ;/2
	LSR ;/4

	EOR #$FFFF
	INC A
	BRA ?++
?+
	STA !Scratch51
	ASL
	ASL
	CLC
	ADC !Scratch51

	LSR ;/2
	LSR ;/4

?++
	CLC
	ADC !ScratchA

?-
	CMP #$02D0
	BCC ?..exit

	CMP #$8000
	BCS ?..neg

?..pos
	SEC
	SBC #$02D0
	BRA ?-

?..neg
	CLC
	ADC #$02D0
	BRA ?-

?..exit

	TAX
	LDA #$0000
	SEP #$20
	LDA !Scratch9
RTS

?.SSSCCSCCYStart
	LDA !PosYL,x
	STA !SpriteYLow,x
	LDA !PosYH,x
	STA !SpriteYHigh,x

	JSL $01801A|!rom

	LDA !SpriteYLow,x
	STA !PosYL,x
	STA !ScratchC
	LDA !SpriteYHigh,x
	STA !PosYH,x
	STA !ScratchD

	LDA !RatioY,x
	STA !Scratch9

	LDA !PhaseHigh,x
	STA !ScratchB
	LDA !PhaseLow,x
	STA !ScratchA

	LDA !AmplitudeY,x
	TAY

	LDA.w ?.XPi,y
	PHA
	LDA !AngleHigh,x
	XBA
	LDA !AngleLow,x
	REP #$10
	TAX
	LDA #$00
	XBA
	PLA
RTS

?.ApplyRatioXIncrease
	LDX !SpriteIndex

	LDA !RatioIncreaseX,x
	BNE ?+
RTS
?+
	LDY #$00
	LDA !RatioIncreaseTimerX,x
	CLC
	ADC !RatioIncreaseX,x
	STA !RatioIncreaseTimerX,x			;Ratio += Ratio Increase
	BPL ?+
	LDY #$01
	EOR #$FF
	INC A
?+
	LSR
	LSR
	LSR
	LSR
	STA !Scratch0
	BNE ?+
RTS
?+
	CPY #$01
	BNE ?+
	EOR #$FF
	INC A
	STA !Scratch0
	LDA !RatioIncreaseTimerX,x
	CLC
	ADC #$10
	STA !RatioIncreaseTimerX,x
	BRA ?++
?+
	LDA !RatioIncreaseTimerX,x
	CLC
	ADC #$F0
	STA !RatioIncreaseTimerX,x	
?++

	LDA !RatioX,x
	PHP
	CLC
	ADC !Scratch0
	STA !RatioX,x			;Ratio += Ratio Increase
	PLA
	BMI ?+

	LDA !RatioIncreaseX,x
	BPL ?+

	LDA !RatioX,x
	BPL ?+

	LDA !RatioIncreaseX,x

	LDA #$00
	STA !RatioX,x
	LDA !RatioIncreaseX,x
	EOR #$FF
	INC A
	STA !RatioIncreaseX,x
RTS

?+

	LDA !RatioMaxX,x
	CMP !RatioX,x
	BCS ?+

	STA !RatioX,x
	
	LDA !RatioIncreaseX,x
	EOR #$FF
	INC A
	STA !RatioIncreaseX,x

?+

RTS

?.ApplyRatioYIncrease
	LDX !SpriteIndex

	LDA !RatioIncreaseY,x
	BNE ?+
RTS
?+
	LDY #$00
	LDA !RatioIncreaseTimerY,x
	CLC
	ADC !RatioIncreaseY,x
	STA !RatioIncreaseTimerY,x			;Ratio += Ratio Increase
	BPL ?+
	LDY #$01
	EOR #$FF
	INC A
?+
	LSR
	LSR
	LSR
	LSR
	STA !Scratch0
	BNE ?+
RTS
?+
	CPY #$01
	BNE ?+
	EOR #$FF
	INC A
	STA !Scratch0
	LDA !RatioIncreaseTimerY,x
	CLC
	ADC #$10
	STA !RatioIncreaseTimerY,x
	BRA ?++
?+
	LDA !RatioIncreaseTimerY,x
	CLC
	ADC #$F0
	STA !RatioIncreaseTimerY,x	
?++
	LDA !RatioY,x
	PHP
	CLC
	ADC !Scratch0
	STA !RatioY,x			;Ratio += Ratio Increase
	PLA
	BMI ?+

	LDA !RatioIncreaseY,x
	BPL ?+

	LDA !RatioY,x
	BPL ?+

	LDA #$00
	STA !RatioY,x
	LDA !RatioIncreaseY,x
	EOR #$FF
	INC A
	STA !RatioIncreaseY,x
RTS

?+

	LDA !RatioMaxY,x
	CMP !RatioY,x
	BCS ?+

	STA !RatioY,x
	
	LDA !RatioIncreaseY,x
	EOR #$FF
	INC A
	STA !RatioIncreaseY,x

?+
RTS

?.Follow2X
	LDA !AccelX,x
	BNE ?+
RTS
?+

	LDA !PosXH,x
	XBA
	LDA !PosXL,x
	REP #$20
	CLC
	ADC #$000C
	CMP !PlayerX
	SEP #$20
	BCC ?+

	LDA !MaxSpeedX,x
	EOR #$FF
	INC A
	STA !Scratch0

	LDA !SpriteXSpeed,x
	SEC
	SBC !AccelX,x
	STA !SpriteXSpeed,x
	BPL ?++
	CMP !Scratch0
	BCS ?++
	LDA !Scratch0
	STA !SpriteXSpeed,x
RTS
?+
	LDA !SpriteXSpeed,x
	CLC
	ADC !AccelX,x
	STA !SpriteXSpeed,x
	BMI ?++
	CMP !MaxSpeedX,x
	BCC ?++
	LDA !MaxSpeedX,x
	STA !SpriteXSpeed,x
?++
RTS

?.Follow2Y
	LDA !AccelY,x
	BNE ?+
RTS
?+

	LDA !PosYH,x
	XBA
	LDA !PosYL,x
	REP #$20
	SEC
	SBC #$0008
	CMP !PlayerY
	SEP #$20
	BCC ?+

	LDA !MaxSpeedY,x
	EOR #$FF
	INC A
	STA !Scratch0

	LDA !SpriteYSpeed,x
	SEC
	SBC !AccelY,x
	STA !SpriteYSpeed,x
	BPL ?++
	CMP !Scratch0
	BCS ?++
	LDA !Scratch0
	STA !SpriteYSpeed,x
RTS
?+
	LDA !SpriteYSpeed,x
	CLC
	ADC !AccelY,x
	STA !SpriteYSpeed,x
	BMI ?++
	CMP !MaxSpeedY,x
	BCC ?++
	LDA !MaxSpeedY,x
	STA !SpriteYSpeed,x
?++
RTS