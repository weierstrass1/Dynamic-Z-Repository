?Custom1HitboxInteractionWithPlayer:

	STZ $05
	LDA !SpriteHitboxXOffset,x
	STA $04
    BPL ?+
    LDA #$FF
    STA $05
?+
	LDA !SpriteXHigh,x
	XBA
	LDA !SpriteXLow,x
	REP #$20
	CLC
	ADC $04
	SEP #$20
	STA $04
	XBA
	STA $0A

    STZ $06
	LDA !SpriteHitboxYOffset,x
	STA $05
    BPL ?+
    LDA #$FF
    STA $06
?+

	LDA !SpriteYHigh,x
	XBA
	LDA !SpriteYLow,x
	REP #$20
	CLC
	ADC $05
	SEP #$20
	STA $05
	XBA
	STA $0B

	LDA !SpriteHitboxWidth,x
	STA $06

	LDA !SpriteHitboxHeight,x
	STA $07

	JSL $03B664|!rom
	JSL $03B72B|!rom
RTL