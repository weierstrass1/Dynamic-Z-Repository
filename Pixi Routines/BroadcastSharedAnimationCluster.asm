!FrameIndex = !ClusterMiscTable2
!AnimationTimer = !ClusterMiscTable3
!AnimationIndex = !ClusterMiscTable4
!AnimationFrameIndex = !ClusterMiscTable5
!LocalFlip = !ClusterMiscTable6
!GlobalFlip = !ClusterMiscTable7
!LastFrameIndex = !ClusterMiscTable9

?BroadcastSharedAnimationCluster:

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

    LDA.l DZ_DS_Loc_US_Cluster,x
	TAX
    LDA.l DZ_DS_Loc_SharedFrame,x
    STA $04

    LDA.l DZ_DS_Loc_SpriteNumber,x
    STA $05

    LDA.l DZ_DS_Loc_SharedProperty1,x
    STA $06

    LDA.l DZ_DS_Loc_SharedProperty2,x
    STA $07

    PHX

    LDX #$13
?.loop

    LDA !ClusterNumber,x
    CMP $05
    BNE ?.next

    LDA.l DZ_DS_Loc_SharedPropertyPerSprite1_Cluster,x
    CMP $06
    BNE ?.next

    LDA.l DZ_DS_Loc_SharedPropertyPerSprite2_Cluster,x
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

    PLX
RTL