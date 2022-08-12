?DyzenDetectPlayerIsAbove:
	LDA $65
	AND #$0C
	CMP #$0C
	BNE ?+

	LDA !SpritePlayerIsAbove,x
	BEQ ?++

	LDA #$01
	STA !SpritePlayerIsAbove,x

?++
RTL
?+
	
	AND #$04
	BEQ ?+

	LDA #$01
	STA !SpritePlayerIsAbove,x

?+
RTL