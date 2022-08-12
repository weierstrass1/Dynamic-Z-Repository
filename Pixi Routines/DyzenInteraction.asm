;HB 1
;$00 = Left
;$02 = Right
;$08 = Top
;$0C = Bottom

;HB 2
;$04 = X (16 bits)
;$0A = Y (16 bits)
;$8D = Hitboxes Data Table

?DyzenInteraction:

;$15,s = HitboxAdder
;$13,s = FrameHitboxesIndexer
;$11,s = FrameHitBoxes
;$0F,s = HitboxType
;$0D,s = HitboxXOffset
;$0B,s = HitboxYOffset
;$09,s = HitboxWidth
;$07,s = HitboxHeight
;$05,s = HitboxAction1
;$03,s = HitboxAction2
;$01,s = Actions
	PHX
	TYX

	STZ $50
	STZ $4F

	REP #$20

	LDA $04
	CLC
	ADC $51
	STA $04			;$04 = X offset + X position of sprite

	LDA $0A
	CLC
	ADC $53			
	STA $0A 		;$0A = X offset + X position of sprite

	LDY #$00
	LDA ($8D),y
	PHA 
	;dw HitboxAdder
	LDY #$02
	LDA ($8D),y
	PHA 
	;dw FrameHitboxesIndexer
	LDY #$04
	LDA ($8D),y
	PHA 
	;dw FrameHitBoxes
	LDY #$06
	LDA ($8D),y
	PHA 
	;dw HitboxType
	LDY #$08
	LDA ($8D),y
	PHA 
	;dw HitboxXOffset
	LDY #$0A
	LDA ($8D),y
	PHA 
	;dw HitboxYOffset
	LDY #$0C
	LDA ($8D),y
	PHA 
	;dw HitboxWidth
	LDY #$0E
	LDA ($8D),y
	PHA 
	;dw HitboxHeight
	LDY #$10
	LDA ($8D),y
	PHA 
	;dw HitboxAction1
	LDY #$12
	LDA ($8D),y
	PHA 
	;dw HitboxAction2
	LDY #$14
	LDA ($8D),y
	PHA 
	;dw Actions

	TXA	
	REP #$10
	ASL				;A = 2*Flip
	TAY				;Y = 2*Flip
	
	LDA $06
	ASL
	CLC
	ADC ($15,s),y		;A = HBAdder[Y]
	TAY					;Y = HBAdder[Y]

    LDA ($13,s),y		;X = FrameHitboxesIndexer[Y]
    TAX
    SEP #$20

?-
	STX $06
	TXY					;Y = FrameHitboxesIndexer[Y]
	LDA #$00
	XBA
	LDA ($11,s),y		;FrameHitBoxes[Y]
	CMP #$FF
	BNE ?+
	SEP #$10

	REP #$20
	TSC
	CLC
	ADC #$0016
	TCS
	SEP #$20
	PLX

	LDA $4F
	BEQ ?.clear
?.set
	SEC
RTL
?.clear
	CLC
RTL

?+
	REP #$20
	ASL
	TAY

	LDA ($0D,s),y		;Hitboxes[Y].XOffset
	CLC
	ADC $04				;A = Hitboxes[Y].XOffset + X
	STA $45				;$45 = Hitboxes[Y].XOffset + X

	LDA ($0B,s),y		;Hitboxes[Y].YOffset
	CLC
	ADC $0A				;A = Hitboxes[Y].YOffset + Y
	STA $47				;$47 = Hitboxes[Y].YOffset + Y

	LDA ($09,s),y		;Hitboxes+2[Y].Width
	CLC
	ADC $45				;A = Hitboxes+2[Y].XOffset + X + Hitboxes[Y].Width
	STA $49				;$49 = Hitboxes+2[Y].XOffset + X + Hitboxes+2[Y].Width

	LDA ($07,s),y		;Hitboxes[Y].Height
	CLC
	ADC $47				;A = Hitboxes[Y].YOffset + X + Hitboxes[Y].Height
	STA $4B				;$4B = Hitboxes[Y].YOffset + X + Hitboxes[Y].Height	

	;HB 1
	;$00 = Left
	;$02 = Right
	;$08 = Top
	;$0C = Bottom

	;HB 2
	;$45 = Left
	;$47 = Top
	;$49 = Right
	;$4B = Bottom
?.checkXAxys
	LDA $49
	CMP $00
	BCC ?.left			;if HB 2 is at the left of HB 1

	LDA $02
	CMP $45
	BCC ?.right			;if HB 2 is at the right of HB 1

?.touchingHorizontal		;HB2 is touching HB1 in X axys
	LDA #$0003
	BRA ?+
?.left
	LDA #$0002
	BRA ?+
?.right
	LDA #$0001
?+
	STA $4D

?.checkYAxys
	LDA $4B
	CMP $08
	BCC ?.up				;if HB 2 is above of HB 1

	LDA $0C
	CMP $47
	BCC ?.down			;if HB 2 is below of HB 1

?.touchingVertical		;HB 2 is touching HB2 in Y axys
	LDA #$000C
	BRA ?+
?.up
	LDA #$0008
	BRA ?+
?.down
	LDA #$0004
?+
	ORA $4D
	STA $4D

	PHY
?.contact				;HB 2 is touching HB 1
	LDA $4D
	CMP #$000F
	BNE ?.ThereIsntContact

?.ThereIsContact

	LDA ($07,s),y
	TAY 

	BRA ?.execRoutine

?.ThereIsntContact

	LDA ($05,s),y
	TAY

?.execRoutine
	LDA ($03,s),y
	STA $8A

	PLA
	LSR
	SEP #$30
	TAY						;Y = Hitbox ID

	LDA $17,s
	TAX						;X = load sprite index

	PHB
	PLA
	STA $8C

	PHK
	LDA.b #(?.returnRoutine-1)>>8
	PHA
	LDA.b #(?.returnRoutine-1)
	PHA
	JML [$008A|!dp]
?.returnRoutine

	REP #$10
	LDX $06
	INX
	JMP ?-