?DyzenSpriteSpriteInteraction:
    JSR (?.singleSpriteInteraction,x)
RTL

?.singleSpriteInteraction:
	dw ?.NoInteraction
	dw ?.VanillaInteraction
	dw ?.Custom1HitboxInteraction
	dw ?.DyzenInteraction

?.NoInteraction
	LDX $00
RTS

?.VanillaInteraction
	LDX $00

    JSL $03B6E5|!rom				; MarioClipping

    %DyzenFixClippingForInteraction()

	JMP ?.CallSpriteInteraction

?.Custom1HitboxInteraction
	LDX $00

	STZ $01
	LDA !SpriteHitboxXOffset,x
	STA $00
	BPL ?+
	LDA #$FF
	STA $01
?+

	LDA !SpriteXHigh,x
	XBA
	LDA !SpriteXLow,x
	REP #$20
	CLC
	ADC $00
	SEP #$20
	STA $00
	XBA
	STA $08

	STZ $02
	LDA !SpriteHitboxYOffset,x
	STA $01
	BPL ?+
	LDA #$FF
	STA $02
?+

	LDA !SpriteYHigh,x
	XBA
	LDA !SpriteYLow,x
	REP #$20
	CLC
	ADC $01
	SEP #$20
	STA $01
	XBA
	STA $09
	
	LDA !SpriteHitboxWidth,x
	STA $02
	BNE +
	CLC
RTS
+
	
	LDA !SpriteHitboxHeight,x
	STA $03

    %DyzenFixClippingForInteraction()

	JMP ?.CallSpriteInteraction

?.DyzenInteraction
	LDX $00

	LDA #$00
?..Loop
	PHX
	PHA
	LDA !SpriteXHigh,x
	STA $46
	LDA !SpriteXLow,x
	STA $45

	LDA !SpriteYHigh,x
	STA $48
	LDA !SpriteYLow,x
	STA $47

	STZ $4A
	LDA !FrameIndex,X
	STA $49

	LDA !GlobalFlip,x
    EOR !LocalFlip,x
	TAY    

	LDA !SpriteHitboxTableL,x
	STA $8D
	LDA !SpriteHitboxTableH,x
	STA $8E
	LDA !SpriteHitboxTableB,x
	STA $8F                

	PLA
	PHA
	%DyzenGetHitBoxClippingB()
	BCC ?+

	JSR ?.CallSpriteInteraction
	BCS ?++

	PLA
	INC A
	PLX
	BRA ?..Loop
?+
	PLA
	PLX
	CLC
RTS
?++
	PLA
	PLX
	SEC
RTS

?.CallSpriteInteraction
	PHX
	LDX !SpriteIndex

	LDA !SpriteHitboxTableL,x
	STA $8A
	LDA !SpriteHitboxTableH,x
	STA $8B
	LDA !SpriteHitboxTableB,x
	STA $8C

	LDA !GlobalFlip,x
    EOR !LocalFlip,x
	TAY                     ;Y = Flip Adder, used to jump to the frame with the current flip

	STZ $4A
    LDA !FrameIndex,x		;A 16 bits frame index
	STA $49

	%DyzenNormalSpriteInteraction()
	BCC ?+
	PLX
	SEC
RTS
?+
	PLX
	CLC
RTS