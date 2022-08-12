!FrameIndex = !SpriteMiscTable1
!AnimationTimer = !SpriteMiscTable7
!AnimationIndex = !SpriteMiscTable2
!AnimationFrameIndex = !SpriteMiscTable3
!LocalFlip = !SpriteMiscTable4
!GlobalFlip = !SpriteMiscTable5
!LastFrameIndex = !SpriteMiscTable6
!ChangeSD = !SpriteMiscTable12

?DyzenSharedDynamicChange:
    PHB 
    PHK
    PLB
    LDA !ChangeSD,x
	BEQ ?+

	LDA DZ_DS_Loc_US_Normal,x
	TAX
	LDA DZ_DS_Loc_UsedBy,x
	LDX !SpriteIndex
	AND #$80
	BEQ ?.dyn

	JSR ?.ChangeToDynamic
	BCC ?+
	LDA #$00
	STA !ChangeSD,x
	BRA ?+
?.dyn

	JSR ?.ChangeToSharedDynamic
	BCC ?+
	LDA #$00
	STA !ChangeSD,x
	
?+
    PLB
RTL

?.ExtraByteTab
	db $40,$80
?.ChangeToDynamic

	LDA DZ_DS_Loc_US_Normal,x
	TAX
	LDA DZ_Timer
	CMP DZ_DS_Loc_SafeFrame,x
	BNE ?+
	LDX !SpriteIndex
	CLC
RTS
?+
	LDA DZ_DS_Loc_UsedBy,x
	LDX !SpriteIndex
	AND #$80
	BNE ?+
	CLC
RTS
?+

	LDA DZ_Timer
	AND #$01
	TAY
	LDA !ExtraByte1,x
	PHA
	LDA ?.ExtraByteTab,y
	STA !ExtraByte1,x

	LDA DZ_DS_Loc_US_Normal,x
	PHA
	LDA #$FF
	STA DZ_DS_Loc_US_Normal,x
	%CheckSlotNormalSpriteNoRemove(#$08, $00)
	PLA
	BCS ?+
	STA DZ_DS_Loc_US_Normal,x
	PLA
	STA !ExtraByte1,x 
	CLC
RTS
?+
	PLA
	LDA #$FF
	STA !LastFrameIndex,x
	LDA DZ_DS_Loc_US_Normal,x
	TAX
	LDA DZ_DS_Loc_SafeFrame,x
	DEC A
	STA DZ_DS_Loc_SafeFrame,x
	LDX !SpriteIndex
	
	SEC
RTS

?.ChangeToSharedDynamic
	LDA DZ_DS_Loc_US_Normal,x
	TAX
	LDA DZ_DS_Loc_UsedBy,x
	LDX !SpriteIndex
	AND #$80
	BEQ +
	CLC
RTS
+
	LDA DZ_DS_Loc_US_Normal,x
	STA !Scratch0

	JSL !CheckNormalSharedDynamicExisted
	BCS ?+

	LDA DZ_DS_Loc_US_Normal,x
	TAX
	LDA DZ_DS_Loc_UsedBy,x
	ORA #$80
	STA DZ_DS_Loc_UsedBy,x
	LDA #$00
	STA DZ_DS_Loc_SharedUpdated,x

	LDA DZ_DS_Loc_SharedFrame,x
	LDX !SpriteIndex
	STA !LastFrameIndex,x

	JSL !ClearSlot

	LDA #$01
	SEC
RTS
?+
	PHX
	LDX !Scratch0
	LDA #$FF
	STA DZ_DS_Loc_UsedBy,x
	PLX
	LDA DZ_DS_Loc_US_Normal,x
	TAX
	LDA.l DZ_DS_Loc_UsedBy,x
	AND #$1F
	TAY

	LDX !SpriteIndex

	LDA !AnimationIndex,y
	STA !AnimationIndex,x

	LDA !AnimationTimer,y
	STA !AnimationTimer,x

	LDA !AnimationFrameIndex,y
	STA !AnimationFrameIndex,x

	LDA !FrameIndex,y
	STA !FrameIndex,x

	LDA !LastFrameIndex,y
	STA !LastFrameIndex,x

	TYX
	LDA !ExtraByte1,x
	LDX !SpriteIndex
	STA !ExtraByte1,x

	JSL !ClearSlot

	LDA #$00
	SEC
RTS