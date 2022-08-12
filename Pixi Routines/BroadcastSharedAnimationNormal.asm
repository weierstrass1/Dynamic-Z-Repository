!FrameIndex = !SpriteMiscTable1
!AnimationTimer = !SpriteMiscTable7
!AnimationIndex = !SpriteMiscTable2
!AnimationFrameIndex = !SpriteMiscTable3
!LocalFlip = !SpriteMiscTable4
!LastFrameIndex = !SpriteMiscTable6

?BroadcastSharedAnimationNormal:

	LDA !AnimationIndex,x
	STA $00

	LDA !FrameIndex,x
	STA $01

	LDA !AnimationTimer,x
	STA $02

	LDA !AnimationFrameIndex,x
	STA $03

    LDA !LocalFlip,x
    STA $08

    LDA.l DZ_DS_Loc_US_Normal,x
	TAX
    LDA.l DZ_DS_Loc_SharedFrame,x
    STA $04

    LDA.l DZ_DS_Loc_SpriteNumber,x
    STA $05

    LDA.l DZ_DS_Loc_SharedProperty1,x
    STA $06

    LDA.l DZ_DS_Loc_SharedProperty2,x
    STA $07

    LDX #!MaxSprites-1
?.loop

    LDA !SpriteStatus,x
    BEQ ?.next

    LDA !CustomSpriteNumber,x
    CMP $05
    BNE ?.next

    LDA.l DZ_DS_Loc_SharedPropertyPerSprite1_Normal,x
    CMP $06
    BNE ?.next

    LDA.l DZ_DS_Loc_SharedPropertyPerSprite2_Normal,x
    CMP $07
    BNE ?.next

	LDA $00
	STA !AnimationIndex,x

	LDA $01
	STA !FrameIndex,x

	LDA $02
	STA !AnimationTimer,x

	LDA $03
	STA !AnimationFrameIndex,x

    LDA $04
    STA !LastFrameIndex,x

    LDA $08
    STA !LocalFlip,x

?.next
    DEX
    BPL ?.loop

    LDX !SpriteIndex
RTL