!SkipCarryTimer = $0D9C|!addr

!ThrowSpeed = $30

!ForceReleaseFlag = $192C|!addr
?ReleaseItem:
    LDA !ForceReleaseFlag
    BNE ?+
    LDA #$08                ; \ Disable collisions between Mario
    STA !SpriteDecTimer2,X
	STA !SkipCarryTimer
	STZ !ForceReleaseFlag
RTL
?+
    CMP #$01
    BNE ?.Drop
?.Throw
	STZ !ForceReleaseFlag

    LDA $76
    TAY

    LDA #$F0
    STA !SpriteYSpeed,x

	LDA !ButtonPressed_BYETUDLR
	AND #$08
	BEQ ?+
	LDA #$C0
	STA !SpriteYSpeed,x
?+
    PHB
    PHK
    PLB

    LDA ?.ThrowSpeed,y
    CLC
    ADC !PlayerXSpeed
    STA !SpriteXSpeed,x

    LDA #$0A
    STA !SpriteStatus,x

    LDA !SpriteDecTimer1,X             ; \ TODO - what is this?
    STA !SpriteMiscTable3,X     ; /    LDA 
    LDA #$08                ; \ Disable collisions between Mario
    STA !SpriteDecTimer2,X
	STA !SkipCarryTimer

    PLB
RTL
?.Drop
	STZ !ForceReleaseFlag

    LDA #$09
    STA !SpriteStatus,x

    LDA !SpriteDecTimer1,X             ; \ TODO - what is this?
    STA !SpriteMiscTable3,X     ; /    LDA 
    LDA #$08                ; \ Disable collisions between Mario
    STA !SpriteDecTimer2,X
	STA !SkipCarryTimer
RTL
?.ThrowSpeed:
    db -!ThrowSpeed,!ThrowSpeed