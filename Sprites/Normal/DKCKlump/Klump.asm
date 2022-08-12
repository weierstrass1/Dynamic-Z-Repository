;@Klump.bin,KlumpPal1.bin,KlumpPal2.bin
!ResourceIndex = $01
%GFXTabDef(!ResourceIndex)
%GFXDef(00)
%GFXDef(01)
%GFXDef(02)

;Constant
!KlumpGrenadeID = $00
!MaxResistTime = $30	
!ResistXSpeed = $20
!RecoilXSpeed = $38
!RecoilYSpeed = $C0
!WalkSpeed = $18
!DeadSFX = $40
!DeadSFXAddress = $1DFC|!addr
!HitSFX = $3C
!HitSFXAddress = $1DFC|!addr
;######################################
;############## Defines ###############
;######################################

!FrameIndex = !SpriteMiscTable1
!AnimationTimer = !SpriteMiscTable7
!AnimationIndex = !SpriteMiscTable2
!AnimationFrameIndex = !SpriteMiscTable3
!LocalFlip = !SpriteMiscTable4
!GlobalFlip = !SpriteMiscTable5
!LastFrameIndex = !SpriteMiscTable6
!ResistTimer = !SpriteDecTimer1
!State = !SpriteMiscTable8
!LoadPal = !SpriteLoadPal
!Pal = !SpritePal
!AnimSpeed = !SpriteMiscTable11
!XSpeed = !ExtraByte2
!Version = !SpriteMiscTable12
;######################################
;########### Init Routine #############
;######################################
print "INIT ",pc
	LDA.b #HitboxTables>>16
	STA !SpriteHitboxTableB,x
	LDA.b #HitboxTables>>8
	STA !SpriteHitboxTableH,x
	LDA.b #HitboxTables
	STA !SpriteHitboxTableL,x
	
	LDA !ExtraBits,x
	AND #$04
	EOR #$04
	LSR
	LSR
	STA !GlobalFlip,x
	LDA #$00
	STA !LocalFlip,x
	LDA #$00
	STA !ResistTimer,x
	STA !State,x
	STA !SpriteActionFlag,x

	LDA !GlobalFlip,x
	BNE +
	LDA !XSpeed,x
	BRA ++

+
	LDA !XSpeed,x
	EOR #$FF
	INC A
++
	STA !SpriteXSpeed,x

	JSL InitWrapperChangeAnimationFromStart
	LDA #$FF
	STA !LastFrameIndex,x

	%CheckSlotNormalSprite(#$0C, $00)

	LDA #$01
	STA !LoadPal,x

	LDA !ExtraByte1,x
	AND #$07
	ASL
	STA !Pal,x

	LDA !ExtraByte1,x
	LSR
	LSR
	LSR
	AND #$07
	STA !Version,x

	JSR SetWalkAnimationSpeed
    ;Here you can write your Init Code
    ;This will be excecuted when the sprite is spawned 

	LDA #$00
	STA !SpritePlayerIsAbove,x
	STA !SpriteDecTimer5,x
	STA !SpriteActionFlag,x
RTL

SetWalkAnimationSpeed:
	LDA #$04
	STA !AnimSpeed,x
	LDA !XSpeed,x
	CMP #$20
	BCC +
	LDA #$02
	STA !AnimSpeed,x
	CMP #$30
	BCC +
	STZ !AnimSpeed,x
+
RTS

;######################################
;########## Main Routine ##############
;######################################
print "MAIN ",pc
    PHB
    PHK
    PLB
    JSR SpriteCode
    PLB
RTL

VersionPal:
	dw !GFX01,!GFX02

VersionPalBNK:
	db !GFX01>>16,!GFX02>>16
;>Routine: SpriteCode
;>Description: This routine excecute the logic of the sprite
;>RoutineLength: Short
SpriteCode:
	JSR DynamicRoutine

	LDA DZ_DS_Loc_US_Normal,x
	TAX

	LDA DZ_DS_Loc_IsValid,x
	BNE +
	LDX !SpriteIndex
RTS
+
	LDX !SpriteIndex 

	LDA !LoadPal,x
	BEQ +

	LDA #$00
	STA !LoadPal,x

	LDA !Pal,x
	ASL
	ASL
	ASL
	CLC
	ADC #$81
	STA !Scratch0

	LDA !Version,x
	TAY 

	LDA VersionPalBNK,y
	STA !Scratch3

	LDA !Version,x
	ASL
	TAY

	LDA VersionPal,y
	STA !Scratch1

	LDA VersionPal+1,y
	STA !Scratch2

	%TransferToCGRAM(!Scratch0, !Scratch1, !Scratch3, #$001E)

+
	LDX !SpriteIndex 
    JSR GraphicRoutine                  ;Calls the graphic routine and updates sprite graphics

    ;Here you can put code that will be excecuted each frame even if the sprite is locked

    LDA !SpriteStatus,x			      
	CMP #$02
	BEQ +  
	CMP #$08                            ;if sprite dead return
	BNE Return	
+
	LDA !LockAnimationFlag				    
	BNE Return			                    ;if locked animation return.

    %SubOffScreen()

	;JSR InteractionWithWall

	%DyzenPrepareBounce()

    JSR InteractMarioSprite
    ;After this routine, if the sprite interact with mario, Carry is Set.

	%DyzenDetectPlayerIsAbove()
    ;After this routine, if the sprite interact with mario, Carry is Set.

+
	JSR ActionFlag
	JSR StateMachine
    ;Here you can write your sprite code routine
    ;This will be excecuted once per frame excepts when 
    ;the animation is locked or when sprite status is not #$08

    JSR AnimationRoutine                ;Calls animation routine and decides the next frame to draw
    
Return:
    RTS

;>EndRoutine

;######################################
;######## Sub Routine Space ###########
;######################################

ActionFlag:

	LDA !SpriteStatus,x
	CMP #$08
	BEQ +
RTS
+

	LDA !SpriteActionFlag,x
	AND #$01
	BEQ +

	LDA !SpriteActionFlag,x
	EOR #$01
	STA !SpriteActionFlag,x

	LDA #!DeadSFX
    %PlaySound()
	
	LDA #$B0
	STA !SpriteYSpeed,x 
	LDA #03
	STA !State,x	
	LDA #$02
	STA !SpriteStatus,x
RTS
+

	%FlipActionFlag()

	LDA !SpriteActionFlag,x
	AND #$02
	BEQ +

	LDA !SpriteActionFlag,x
	AND #$FD
	STA !SpriteActionFlag,x
	
	LDA #$01
	STA !State,x

+
RTS

StateMachine:
	LDA !State,x
	ASL
	TAY

	REP #$20
	LDA States,y
	STA !Scratch0
	SEP #$20

	LDX #$00
	JSR ($0000|!dp,x)
RTS

States:
	dw Idle
	dw Flip
	dw Resist
	dw Dead

StartIdle:
	STZ !State,x	
	LDA !GlobalFlip,x
	BEQ +

	LDA !XSpeed,x
	EOR #$FF
	INC A
	BRA ++
+
	LDA !XSpeed,x
++
	STA !SpriteXSpeed,x
RTS

Idle:
	LDX !SpriteIndex

	LDA !SpriteDecTimer5,x
	BNE +

	LDA !SpriteTweaker1686_DNCTSWYE,x
	AND #$F7
	STA !SpriteTweaker1686_DNCTSWYE,x

+

	LDA !AnimationIndex,x
	BEQ +

	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BEQ +

	JSR ChangeAnimationFromStart_Walk
+

	LDA !SpriteBlockedStatus_ASB0UDLR,x
	AND #$24
	BEQ +

	STZ !SpriteYSpeed,x

+

	LDA !SpriteBlockedStatus_ASB0UDLR,x
	AND #$04
	STA !Scratch45

	LDA !SpriteXLow,x
	STA !Scratch46

	LDA !SpriteXHigh,x
	STA !Scratch47

	LDA !SpriteYLow,x
	STA !Scratch48

	LDA !SpriteYHigh,x
	STA !Scratch49

	%UpdateNormalSpriteSpeedWithGravity()

	LDA !Scratch45
	BEQ +
	AND !SpriteBlockedStatus_ASB0UDLR,x
	BNE +

	LDA !Scratch46
	STA !SpriteXLow,x

	LDA !Scratch47
	STA !SpriteXHigh,x

	LDA !Scratch48
	STA !SpriteYLow,x

	LDA !Scratch49
	STA !SpriteYHigh,x

	STZ !SpriteYSpeed,x
	STZ !SpriteXSpeed,x
	JSR StartFlip
RTS

+

	LDA !SpriteBlockedStatus_ASB0UDLR,x
	AND #$03
	BEQ +

	STZ !SpriteXSpeed,x

	LDA !SpriteBlockedStatus_ASB0UDLR,x
	AND #$24
	BEQ +

	JSR StartFlip

+
RTS

StartFlip:
	LDA #$01
	STA !State,x
RTS

Flip:
	LDX !SpriteIndex

	LDA !SpriteBlockedStatus_ASB0UDLR,x
	AND #$24
	BEQ +

	STZ !SpriteYSpeed,x

+

	%UpdateNormalSpriteSpeedWithGravity()

	LDA !AnimationIndex,x
	CMP #$01
	BEQ +

	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BNE ++
RTS	
++

	JSR ChangeAnimationFromStart_Flip

	STZ !SpriteXSpeed,x

	LDA !SpriteTweaker1686_DNCTSWYE,x
	ORA #$08
	STA !SpriteTweaker1686_DNCTSWYE,x
+	
	LDA !AnimationFrameIndex,x
	BEQ +

	LDA !AnimationTimer,x
	BNE +

	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BEQ +

	LDA !GlobalFlip,x
	EOR #$01
	STA !GlobalFlip,x
	JSR StartIdle
	JSR ChangeAnimationFromStart_Walk

	LDA #$08
	STA !SpriteDecTimer5,x
+

RTS

SpawnGrenade:
	LDA !Version,x
	BNE +
RTS
+

	STZ !Scratch0
	LDA #$10
	STA !Scratch1

	LDA !GlobalFlip,x
	BEQ ++

	LDA #$10
	STA !Scratch2
	BRA +++
++
	LDA #$F0
	STA !Scratch2
+++
	STZ !Scratch3

	LDA #!KlumpGrenadeID
	CLC
	ADC #!ExtendedOffset
	%SpawnExtended()
	BCS +

	LDA !ExtraByte4,x
	PHA
	LDA !ExtraByte3,x
	PHA
	LDA !GlobalFlip,x
	PHA

	LDA !Pal,x
	PHA
	TYX
	LDA #$00
	STA !ExtendedStarted,x
	PLA
	STA !ExtendedPal,x
	PLA
	STA !ExtendedGlobalFlip,x
	PLA
	STA !ExtendedMiscTable3,x
	PLA
	STA !ExtendedMiscTable5,x

	LDX !SpriteIndex

+
RTS

ResistXSpeed:
	db -!ResistXSpeed,!ResistXSpeed
RecoilXSpeed:
	db !RecoilXSpeed,-!RecoilXSpeed
StartResist:
	LDA #!MaxResistTime
	STA !ResistTimer,x

	LDA !State,x
	CMP #$02
	BEQ +
	LDA #$02
	STA !State,x
	LDA !GlobalFlip,x
	TAY
	LDA ResistXSpeed,y
	STA !SpriteXSpeed,x
	LDA RecoilXSpeed,y
	STA !PlayerXSpeed
	LDA #!RecoilYSpeed
	STA !PlayerYSpeed
+
RTS

Resist:
	LDX !SpriteIndex

	LDA !SpriteTweaker1686_DNCTSWYE,x
	ORA #$08
	STA !SpriteTweaker1686_DNCTSWYE,x

	LDA !AnimationIndex,x
	CMP #$02
	BEQ +

	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BEQ +

	JSR ChangeAnimationFromStart_Resist
	JSR SpawnGrenade
+

	LDA !SpriteBlockedStatus_ASB0UDLR,x
	AND #$04
	BEQ ++
	LDA !SpriteXSpeed,x
	BMI +
	BEQ ++

	DEC A
	STA !SpriteXSpeed,x

	BRA ++
+
	INC A
	STA !SpriteXSpeed,x
++
	LDA !SpriteBlockedStatus_ASB0UDLR,x
	AND #$03
	BEQ +
	STZ !SpriteXSpeed,x
+

	LDA !SpriteBlockedStatus_ASB0UDLR,x
	AND #$24
	BEQ +

	STZ !SpriteYSpeed,x

+

	%UpdateNormalSpriteSpeedWithGravity()



	LDA !ResistTimer,x
	BNE +

	LDA !SpriteBlockedStatus_ASB0UDLR,x
	AND #$24
	BEQ +

	JSR StartIdle
+
RTS

StartDead:

	LDA #$03
	STA !State,x
	LDA #$02
	STA !SpriteStatus,x
	LDA #$B0
	STA !SpriteYSpeed,x

RTS

Dead:
	JSL !ClearSlot
	LDX !SpriteIndex

	LDA !AnimationIndex,x
	CMP #$03
	BCS +

	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BEQ +

	JSR ChangeAnimationFromStart_DeathLoop
+
	LDA !SpriteYSpeed,x
	BMI +

	LDA !AnimationIndex,x
	CMP #$03
	BNE +

	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BEQ +	

	JSR ChangeAnimationFromStart_Death
+
RTS



;>Section Dynamic
;######################################
;########## Animation Space ###########
;######################################
ResourceOffset:
Walk0_ResourceOffset:
	dw $0000,$0460
Walk1_ResourceOffset:
	dw $04A0,$0920
Walk2_ResourceOffset:
	dw $0960,$0E00
Walk3_ResourceOffset:
	dw $0E80,$1300
Walk4_ResourceOffset:
	dw $1380,$1800
Walk5_ResourceOffset:
	dw $1880,$1CE0
Walk6_ResourceOffset:
	dw $1CE0,$2140
Walk7_ResourceOffset:
	dw $2180,$2620
Flip0_ResourceOffset:
	dw $26A0,$2B00
Resist0_ResourceOffset:
	dw $2B40,$2FC0
Death0_ResourceOffset:
	dw $3000,$34E0
Death1_ResourceOffset:
	dw $35A0,$3A40
Death2_ResourceOffset:
	dw $3AC0,$3F80
Death3_ResourceOffset:
	dw $4040,$4500
Death4_ResourceOffset:
	dw $45C0,$49E0
Death5_ResourceOffset:
	dw $49E0,$4DE0
Death6_ResourceOffset:
	dw $4DE0,$51E0


ResourceSize:
Walk0_ResourceSize:
	db $23,$02
Walk1_ResourceSize:
	db $24,$02
Walk2_ResourceSize:
	db $25,$04
Walk3_ResourceSize:
	db $24,$04
Walk4_ResourceSize:
	db $24,$04
Walk5_ResourceSize:
	db $23,$00
Walk6_ResourceSize:
	db $23,$02
Walk7_ResourceSize:
	db $25,$04
Flip0_ResourceSize:
	db $23,$02
Resist0_ResourceSize:
	db $24,$02
Death0_ResourceSize:
	db $27,$06
Death1_ResourceSize:
	db $25,$04
Death2_ResourceSize:
	db $26,$06
Death3_ResourceSize:
	db $26,$06
Death4_ResourceSize:
	db $21,$00
Death5_ResourceSize:
	db $20,$00
Death6_ResourceSize:
	db $20,$00

DynamicRoutine:
	%EasyNormalSpriteDynamicRoutineFixedGFX("!FrameIndex,x", "!LastFrameIndex,x", !GFX00, "#ResourceOffset", "#ResourceSize", #$30)
RTS

;Don't Delete or write another >Section Graphics or >End Section
;All code between >Section Graphics and >End Graphics Section will be changed by Dyzen : Sprite Maker
;>Section Graphics
;######################################
;########## Graphics Space ############
;######################################

;This space is for routines used for graphics
;if you don't know enough about asm then
;don't edit them.

;>Routine: GraphicRoutine
;>Description: Updates tiles on the oam map
;results will be visible the next frame.
;>RoutineLength: Short

!maxtile_pointer_max        = $6180       ; 16 bytes
!maxtile_pointer_high       = $6190       ; 16 bytes
!maxtile_pointer_normal     = $61A0       ; 16 bytes
!maxtile_pointer_low        = $61B0       ; 16 bytes
GraphicRoutine:
	LDA !LastFrameIndex,x
	CMP #$FF
	BNE +
	LDA #$01
	STA !Scratch52
RTS
+

	STZ !Scratch52

	%DyzenNormalGetDrawInfo()

	PHX
	LDA #$00
	XBA
	LDA !GlobalFlip,x
	EOR !LocalFlip,x
	PHA
	CLC
	ROR
	ROR
	ROR
	STA !ScratchF

	PLA
	REP #$20
	ASL
	STA $47

if !sa1
	LDA !maxtile_pointer_normal
	STA $49
	LDA !maxtile_pointer_normal+2
	STA $4B
	LDA !maxtile_pointer_normal+8
	STA $4D
endif
	LDA.w #AnimationTables
	STA $65
	SEP #$20
	LDA.b #AnimationTables>>16
	STA $67

	STZ $46
	LDA !FrameIndex,x
	STA $45

	LDA #$21
	ORA !Pal,x
	STA $4F

	%GetVramDisp(DZ_DS_Loc_US_Normal)
	STA !ScratchE

	%DyzenDSGraphicRoutine()

	REP #$20

if !sa1
	LDA $49
	STA !maxtile_pointer_normal
	LDA $4B
	STA !maxtile_pointer_normal+2
endif
	SEP #$20
	PLX
if !sa1 == 0
	LDA $49
	STA $15EA|!addr,x
endif
	LDA $06
	STA $01
RTS

AnimationTables:
	dw FramesFlippers
	dw FramesLength
	dw FramesStartPosition
	dw FramesEndPosition
	dw Tiles
	dw XDisplacements
	dw YDisplacements
	dw Sizes
;>EndRoutine

;All words that starts with '@' and finish with '.' will be replaced by Dyzen

;>Table: FramesLengths
;>Description: How many tiles use each frame.
;>ValuesSize: 16
FramesLength:
    dw $0009,$000A,$000A,$0009,$0009,$000A,$0009,$000A,$0009,$000A,$000B,$000A,$000A,$000A,$0008,$000A
	dw $0007
	dw $0009,$000A,$000A,$0009,$0009,$000A,$0009,$000A,$0009,$000A,$000B,$000A,$000A,$000A,$0008,$000A
	dw $0007
;>EndTable


;>Table: FramesFlippers
;>Description: Values used to add values to FramesStartPosition and FramesEndPosition
;To use a flipped version of the frames.
;>ValuesSize: 16
FramesFlippers:
    dw $0000,$0022
;>EndTable


;>Table: FramesStartPosition
;>Description: Indicates the index where starts each frame
;>ValuesSize: 16
FramesStartPosition:
    dw $0009,$0014,$001F,$0029,$0033,$003E,$0048,$0053,$005D,$0068,$0074,$007F,$008A,$0095,$009E,$00A9
	dw $00B1
	dw $00BB,$00C6,$00D1,$00DB,$00E5,$00F0,$00FA,$0105,$010F,$011A,$0126,$0131,$013C,$0147,$0150,$015B
	dw $0163
;>EndTable

;>Table: FramesEndPosition
;>Description: Indicates the index where end each frame
;>ValuesSize: 16
FramesEndPosition:
    dw $0000,$000A,$0015,$0020,$002A,$0034,$003F,$0049,$0054,$005E,$0069,$0075,$0080,$008B,$0096,$009F
	dw $00AA
	dw $00B2,$00BC,$00C7,$00D2,$00DC,$00E6,$00F1,$00FB,$0106,$0110,$011B,$0127,$0132,$013D,$0148,$0151
	dw $015C
;>EndTable


;>Table: Tiles
;>Description: Tiles codes of each tile of each frame
;>ValuesSize: 8
Tiles:
    
Frame0_Walk0_Tiles:
	db $20,$0E,$0C,$0A,$08,$06,$04,$02,$00,$22
Frame1_Walk1_Tiles:
	db $23,$20,$0E,$22,$0C,$0A,$08,$06,$00,$04,$02
Frame2_Walk2_Tiles:
	db $22,$20,$0E,$0C,$0A,$08,$06,$04,$00,$02,$24
Frame3_Walk3_Tiles:
	db $22,$20,$0E,$0C,$0A,$08,$06,$00,$04,$02
Frame4_Walk4_Tiles:
	db $22,$20,$0E,$0C,$0A,$08,$06,$04,$02,$00
Frame5_Walk5_Tiles:
	db $0E,$22,$21,$0C,$0A,$08,$20,$06,$04,$02,$00
Frame6_Walk6_Tiles:
	db $20,$22,$0E,$0C,$0A,$08,$06,$04,$02,$00
Frame7_Walk7_Tiles:
	db $22,$20,$0E,$0C,$0A,$08,$06,$00,$04,$02,$24
Frame8_Flip0_Tiles:
	db $20,$0E,$0C,$0A,$08,$06,$04,$02,$00,$22
Frame9_Resist0_Tiles:
	db $23,$20,$0E,$22,$0C,$0A,$08,$02,$00,$06,$04
Frame10_Death0_Tiles:
	db $24,$22,$20,$26,$0E,$0C,$0A,$08,$06,$04,$02,$00
Frame11_Death1_Tiles:
	db $22,$20,$0E,$0C,$0A,$08,$06,$04,$02,$00,$24
Frame12_Death2_Tiles:
	db $24,$22,$20,$0E,$0C,$0A,$08,$06,$02,$00,$04
Frame13_Death3_Tiles:
	db $24,$22,$20,$0E,$0C,$0A,$00,$08,$06,$04,$02
Frame14_Death4_Tiles:
	db $0E,$0C,$0A,$20,$08,$06,$04,$02,$00
Frame15_Death5_Tiles:
	db $0C,$0A,$08,$1F,$06,$1E,$04,$02,$00,$0F,$0E
Frame16_Death6_Tiles:
	db $0E,$0C,$0A,$08,$06,$04,$02,$00
Frame0_Walk0_TilesFlipX:
	db $20,$0E,$0C,$0A,$08,$06,$04,$02,$00,$22
Frame1_Walk1_TilesFlipX:
	db $23,$20,$0E,$22,$0C,$0A,$08,$06,$00,$04,$02
Frame2_Walk2_TilesFlipX:
	db $22,$20,$0E,$0C,$0A,$08,$06,$04,$00,$02,$24
Frame3_Walk3_TilesFlipX:
	db $22,$20,$0E,$0C,$0A,$08,$06,$00,$04,$02
Frame4_Walk4_TilesFlipX:
	db $22,$20,$0E,$0C,$0A,$08,$06,$04,$02,$00
Frame5_Walk5_TilesFlipX:
	db $0E,$22,$21,$0C,$0A,$08,$20,$06,$04,$02,$00
Frame6_Walk6_TilesFlipX:
	db $20,$22,$0E,$0C,$0A,$08,$06,$04,$02,$00
Frame7_Walk7_TilesFlipX:
	db $22,$20,$0E,$0C,$0A,$08,$06,$00,$04,$02,$24
Frame8_Flip0_TilesFlipX:
	db $20,$0E,$0C,$0A,$08,$06,$04,$02,$00,$22
Frame9_Resist0_TilesFlipX:
	db $23,$20,$0E,$22,$0C,$0A,$08,$02,$00,$06,$04
Frame10_Death0_TilesFlipX:
	db $24,$22,$20,$26,$0E,$0C,$0A,$08,$06,$04,$02,$00
Frame11_Death1_TilesFlipX:
	db $22,$20,$0E,$0C,$0A,$08,$06,$04,$02,$00,$24
Frame12_Death2_TilesFlipX:
	db $24,$22,$20,$0E,$0C,$0A,$08,$06,$02,$00,$04
Frame13_Death3_TilesFlipX:
	db $24,$22,$20,$0E,$0C,$0A,$00,$08,$06,$04,$02
Frame14_Death4_TilesFlipX:
	db $0E,$0C,$0A,$20,$08,$06,$04,$02,$00
Frame15_Death5_TilesFlipX:
	db $0C,$0A,$08,$1F,$06,$1E,$04,$02,$00,$0F,$0E
Frame16_Death6_TilesFlipX:
	db $0E,$0C,$0A,$08,$06,$04,$02,$00
;>EndTable

;>Table: XDisplacements
;>Description: X Displacement of each tile of each frame
;>ValuesSize: 8
XDisplacements:
    
Frame0_Walk0_XDisp:
	db $F5,$F8,$F8,$01,$01,$05,$05,$0D,$0D,$11
Frame1_Walk1_XDisp:
	db $EC,$EF,$F4,$F7,$FE,$FF,$FF,$FF,$0C,$0E,$0E
Frame2_Walk2_XDisp:
	db $EB,$F2,$F6,$F6,$FE,$FF,$FF,$FF,$0C,$0D,$0F
Frame3_Walk3_XDisp:
	db $F5,$F6,$F6,$FF,$FF,$00,$00,$09,$0D,$0D
Frame4_Walk4_XDisp:
	db $F4,$F9,$F9,$FE,$FE,$04,$04,$0D,$0D,$0D
Frame5_Walk5_XDisp:
	db $F5,$FB,$FB,$FB,$FD,$FD,$05,$05,$0D,$0D,$11
Frame6_Walk6_XDisp:
	db $F3,$FB,$FB,$FB,$FD,$FD,$FD,$0B,$0B,$0B
Frame7_Walk7_XDisp:
	db $F2,$FA,$FA,$FF,$FF,$02,$02,$06,$0B,$0B,$0F
Frame8_Flip0_XDisp:
	db $F1,$F7,$F7,$FB,$FB,$FB,$07,$0B,$0B,$17
Frame9_Resist0_XDisp:
	db $E7,$EF,$F1,$F7,$FF,$FF,$01,$0B,$0B,$0E,$0E
Frame10_Death0_XDisp:
	db $EA,$F9,$FA,$FB,$FC,$FC,$03,$0A,$0C,$0C,$0C,$11
Frame11_Death1_XDisp:
	db $ED,$F8,$F8,$F8,$FD,$08,$08,$08,$0F,$11,$18
Frame12_Death2_XDisp:
	db $F4,$F5,$F8,$F9,$02,$04,$04,$04,$0F,$0F,$10
Frame13_Death3_XDisp:
	db $F0,$F0,$F6,$FD,$00,$00,$0A,$0D,$10,$10,$12
Frame14_Death4_XDisp:
	db $F0,$F0,$F9,$00,$00,$09,$0E,$0E,$16
Frame15_Death5_XDisp:
	db $EE,$F1,$FD,$FE,$FE,$0B,$0D,$0D,$1D,$1D,$27
Frame16_Death6_XDisp:
	db $EC,$F1,$FC,$01,$0C,$11,$16,$16
Frame0_Walk0_XDispFlipX:
	db $0B,$08,$08,$FF,$FF,$FB,$FB,$F3,$F3,$F7
Frame1_Walk1_XDispFlipX:
	db $1C,$11,$0C,$11,$02,$01,$01,$01,$F4,$F2,$F2
Frame2_Walk2_XDispFlipX:
	db $15,$0E,$0A,$0A,$02,$01,$01,$01,$F4,$F3,$F9
Frame3_Walk3_XDispFlipX:
	db $0B,$0A,$0A,$01,$01,$00,$00,$F7,$F3,$F3
Frame4_Walk4_XDispFlipX:
	db $0C,$07,$07,$02,$02,$FC,$FC,$F3,$F3,$F3
Frame5_Walk5_XDispFlipX:
	db $0B,$0D,$0D,$05,$03,$03,$03,$FB,$F3,$F3,$EF
Frame6_Walk6_XDispFlipX:
	db $0D,$0D,$05,$05,$03,$03,$03,$F5,$F5,$F5
Frame7_Walk7_XDispFlipX:
	db $0E,$06,$06,$01,$01,$FE,$FE,$FA,$F5,$F5,$F9
Frame8_Flip0_XDispFlipX:
	db $0F,$09,$09,$05,$05,$05,$F9,$F5,$F5,$F1
Frame9_Resist0_XDispFlipX:
	db $21,$11,$0F,$11,$01,$01,$FF,$F5,$F5,$F2,$F2
Frame10_Death0_XDispFlipX:
	db $16,$07,$06,$0D,$04,$04,$FD,$F6,$F4,$F4,$F4,$EF
Frame11_Death1_XDispFlipX:
	db $13,$08,$08,$08,$03,$F8,$F8,$F8,$F1,$EF,$F0
Frame12_Death2_XDispFlipX:
	db $0C,$0B,$08,$07,$FE,$FC,$FC,$FC,$F1,$F1,$F0
Frame13_Death3_XDispFlipX:
	db $10,$10,$0A,$03,$00,$00,$F6,$F3,$F0,$F0,$EE
Frame14_Death4_XDispFlipX:
	db $10,$10,$07,$08,$00,$F7,$F2,$F2,$EA
Frame15_Death5_XDispFlipX:
	db $12,$0F,$03,$0A,$02,$FD,$F3,$F3,$E3,$EB,$E1
Frame16_Death6_XDispFlipX:
	db $14,$0F,$04,$FF,$F4,$EF,$EA,$EA
;>EndTable
;>Table: YDisplacements
;>Description: Y Displacement of each tile of each frame
;>ValuesSize: 8
YDisplacements:
    
Frame0_Walk0_YDisp:
	db $10,$F0,$00,$E3,$F3,$03,$11,$F5,$05,$ED
Frame1_Walk1_YDisp:
	db $01,$F1,$01,$11,$11,$E3,$F3,$03,$08,$E8,$F8
Frame2_Walk2_YDisp:
	db $F9,$E9,$F9,$09,$12,$E2,$F2,$02,$04,$F4,$EC
Frame3_Walk3_YDisp:
	db $0F,$EF,$FF,$E3,$F3,$03,$13,$0D,$ED,$FD
Frame4_Walk4_YDisp:
	db $12,$F2,$02,$E3,$F3,$02,$12,$EE,$FE,$0E
Frame5_Walk5_YDisp:
	db $12,$F5,$FD,$05,$E5,$F5,$05,$0D,$F0,$00,$10
Frame6_Walk6_YDisp:
	db $12,$F7,$FF,$0F,$E6,$F6,$06,$F1,$01,$11
Frame7_Walk7_YDisp:
	db $13,$F3,$03,$E5,$F5,$05,$14,$13,$F3,$03,$EB
Frame8_Flip0_YDisp:
	db $F4,$04,$14,$E6,$F6,$06,$10,$F4,$00,$FE
Frame9_Resist0_YDisp:
	db $04,$FB,$0B,$1B,$EB,$FB,$09,$0B,$1B,$EB,$FB
Frame10_Death0_YDisp:
	db $03,$12,$0A,$02,$E5,$F5,$05,$15,$E7,$F7,$07,$FD
Frame11_Death1_YDisp:
	db $13,$E5,$F5,$05,$13,$EC,$FC,$0C,$14,$04,$FC
Frame12_Death2_YDisp:
	db $E7,$F7,$07,$11,$1E,$EE,$FE,$0E,$F8,$08,$12
Frame13_Death3_YDisp:
	db $EA,$FA,$0A,$0E,$F2,$02,$25,$10,$F6,$06,$15
Frame14_Death4_YDisp:
	db $F1,$01,$10,$F8,$00,$0F,$F9,$09,$10
Frame15_Death5_YDisp:
	db $F8,$08,$10,$FC,$04,$FD,$00,$10,$04,$14,$02
Frame16_Death6_YDisp:
	db $FC,$0A,$01,$10,$00,$0E,$F6,$06
Frame0_Walk0_YDispFlipX:
	db $10,$F0,$00,$E3,$F3,$03,$11,$F5,$05,$ED
Frame1_Walk1_YDispFlipX:
	db $01,$F1,$01,$11,$11,$E3,$F3,$03,$08,$E8,$F8
Frame2_Walk2_YDispFlipX:
	db $F9,$E9,$F9,$09,$12,$E2,$F2,$02,$04,$F4,$EC
Frame3_Walk3_YDispFlipX:
	db $0F,$EF,$FF,$E3,$F3,$03,$13,$0D,$ED,$FD
Frame4_Walk4_YDispFlipX:
	db $12,$F2,$02,$E3,$F3,$02,$12,$EE,$FE,$0E
Frame5_Walk5_YDispFlipX:
	db $12,$F5,$FD,$05,$E5,$F5,$05,$0D,$F0,$00,$10
Frame6_Walk6_YDispFlipX:
	db $12,$F7,$FF,$0F,$E6,$F6,$06,$F1,$01,$11
Frame7_Walk7_YDispFlipX:
	db $13,$F3,$03,$E5,$F5,$05,$14,$13,$F3,$03,$EB
Frame8_Flip0_YDispFlipX:
	db $F4,$04,$14,$E6,$F6,$06,$10,$F4,$00,$FE
Frame9_Resist0_YDispFlipX:
	db $04,$FB,$0B,$1B,$EB,$FB,$09,$0B,$1B,$EB,$FB
Frame10_Death0_YDispFlipX:
	db $03,$12,$0A,$02,$E5,$F5,$05,$15,$E7,$F7,$07,$FD
Frame11_Death1_YDispFlipX:
	db $13,$E5,$F5,$05,$13,$EC,$FC,$0C,$14,$04,$FC
Frame12_Death2_YDispFlipX:
	db $E7,$F7,$07,$11,$1E,$EE,$FE,$0E,$F8,$08,$12
Frame13_Death3_YDispFlipX:
	db $EA,$FA,$0A,$0E,$F2,$02,$25,$10,$F6,$06,$15
Frame14_Death4_YDispFlipX:
	db $F1,$01,$10,$F8,$00,$0F,$F9,$09,$10
Frame15_Death5_YDispFlipX:
	db $F8,$08,$10,$FC,$04,$FD,$00,$10,$04,$14,$02
Frame16_Death6_YDispFlipX:
	db $FC,$0A,$01,$10,$00,$0E,$F6,$06
;>EndTable
;>Table: Sizes.
;>Description: size of each tile of each frame
;>ValuesSize: 8
Sizes:
    
Frame0_Walk0_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame1_Walk1_Sizes:
	db $00,$02,$02,$00,$02,$02,$02,$02,$02,$02,$02
Frame2_Walk2_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame3_Walk3_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame4_Walk4_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame5_Walk5_Sizes:
	db $02,$00,$00,$02,$02,$02,$00,$02,$02,$02,$02
Frame6_Walk6_Sizes:
	db $02,$00,$02,$02,$02,$02,$02,$02,$02,$02
Frame7_Walk7_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame8_Flip0_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame9_Resist0_Sizes:
	db $00,$02,$02,$00,$02,$02,$02,$02,$02,$02,$02
Frame10_Death0_Sizes:
	db $02,$02,$02,$00,$02,$02,$02,$02,$02,$02,$02,$02
Frame11_Death1_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame12_Death2_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame13_Death3_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame14_Death4_Sizes:
	db $02,$02,$02,$00,$02,$02,$02,$02,$02
Frame15_Death5_Sizes:
	db $02,$02,$02,$00,$02,$00,$02,$02,$02,$00,$00
Frame16_Death6_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02
Frame0_Walk0_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame1_Walk1_SizesFlipX:
	db $00,$02,$02,$00,$02,$02,$02,$02,$02,$02,$02
Frame2_Walk2_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame3_Walk3_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame4_Walk4_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame5_Walk5_SizesFlipX:
	db $02,$00,$00,$02,$02,$02,$00,$02,$02,$02,$02
Frame6_Walk6_SizesFlipX:
	db $02,$00,$02,$02,$02,$02,$02,$02,$02,$02
Frame7_Walk7_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame8_Flip0_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame9_Resist0_SizesFlipX:
	db $00,$02,$02,$00,$02,$02,$02,$02,$02,$02,$02
Frame10_Death0_SizesFlipX:
	db $02,$02,$02,$00,$02,$02,$02,$02,$02,$02,$02,$02
Frame11_Death1_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame12_Death2_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame13_Death3_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame14_Death4_SizesFlipX:
	db $02,$02,$02,$00,$02,$02,$02,$02,$02
Frame15_Death5_SizesFlipX:
	db $02,$02,$02,$00,$02,$00,$02,$02,$02,$00,$00
Frame16_Death6_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02
;>EndTable

;>End Graphics Section

;Don't Delete or write another >Section Animation or >End Section
;All code between >Section Animations and >End Animations Section will be changed by Dyzen : Sprite Maker
;>Section Animations
;######################################
;########## Animation Space ###########
;######################################

;This space is for routines used for graphics
;if you don't know enough about asm then
;don't edit them.
InitWrapperChangeAnimationFromStart:
	PHB
    PHK
    PLB
	STZ !AnimationIndex,x
	JSR ChangeAnimationFromStart
	PLB
	RTL

ChangeAnimationFromStart_Walk:
	STZ !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_Flip:
	LDA #$01
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_Resist:
	LDA #$02
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_DeathLoop:
	LDA #$03
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_Death:
	LDA #$04
	STA !AnimationIndex,x


ChangeAnimationFromStart:
	STZ !AnimationFrameIndex,x

	STZ !Scratch1
	LDA !AnimationIndex,x
	STA !Scratch0					;$00 = Animation index in 16 bits

	STZ !Scratch3
	LDA !AnimationFrameIndex,x
	STA !Scratch2					;$02 = Animation Frame index in 16 bits

	STZ !Scratch5
	STX !Scratch4					;$04 = sprite index in 16 bits

	REP #$30						;A7X/Y of 16 bits
	LDX !Scratch4					;X = sprite index in 16 bits

	LDA !Scratch0
	ASL
	TAY								;Y = 2*Animation index

	LDA !Scratch2
	CLC
	ADC AnimationIndexer,y
	TAY								;Y = Position of the first frame of the animation + animation frame index

	SEP #$20						;A of 8 bits

	LDA Frames,y
	STA !FrameIndex,x				;New Frame = Frames[New Animation Frame Index]

	LDA Times,y
	STA !AnimationTimer,x			;Time = Times[New Animation Frame Index]

	LDA Flips,y
	STA !LocalFlip,x				;Flip = Flips[New Animation Frame Index]

	LDA !Scratch2
	STA !AnimationFrameIndex,x

	SEP #$10						;X/Y of 8 bits
	LDX !Scratch4					;X = sprite index in 8 bits
RTS
	

;>Routine: AnimationRoutine
;>Description: Decides what will be the next frame.
;>RoutineLength: Short
AnimationRoutine:
	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BNE +
RTS
+

    LDA !AnimationTimer,x
    BEQ +

	DEC A
	DEC A
	STA !AnimationTimer,x
	RTS

+
	STZ !Scratch1
	LDA !AnimationIndex,x
	STA !Scratch0					;$00 = Animation index in 16 bits

	STZ !Scratch3
	LDA !AnimationFrameIndex,x
	STA !Scratch2					;$02 = Animation Frame index in 16 bits

	STZ !Scratch5
	STX !Scratch4					;$04 = sprite index in 16 bits

	REP #$30						;A7X/Y of 16 bits
	LDX !Scratch4					;X = sprite index in 16 bits

	LDA !Scratch0
	ASL
	TAY								;Y = 2*Animation index

	INC !Scratch2					;New Animation Frame Index = Animation Frame Index + 1

	LDA !Scratch2			        ;if Animation Frame index < Animation Lenght then Animation Frame index++
	CMP AnimationLenght,y			;else go to the frame where start the loop.
	BCC +							

	LDA AnimationLastTransition,y
	STA !Scratch2					;New Animation Frame Index = first frame of the loop.

+
	LDA !Scratch2
	CLC
	ADC AnimationIndexer,y
	TAY								;Y = Position of the first frame of the animation + animation frame index

	SEP #$20						;A of 8 bits

	LDA Frames,y
	STA !FrameIndex,x				;New Frame = Frames[New Animation Frame Index]

	LDA !AnimationIndex,x
	CMP #$02
	BCS +
	LDA !AnimSpeed,x
	BRA ++
+
	LDA Times,y
++
	STA !AnimationTimer,x			;Time = Times[New Animation Frame Index]

	LDA Flips,y
	STA !LocalFlip,x				;Flip = Flips[New Animation Frame Index]

	LDA !Scratch2
	STA !AnimationFrameIndex,x

	SEP #$10						;X/Y of 8 bits
	LDX !Scratch4					;X = sprite index in 8 bits
RTS
;>EndRoutine

;All words that starts with '>' and finish with '.' will be replaced by Dyzen

AnimationLenght:
	dw $0008,$0002,$0001,$0002,$0005

AnimationLastTransition:
	dw $0000,$0001,$0000,$0001,$0004

AnimationIndexer:
	dw $0000,$0008,$000A,$000B,$000D

Frames:
	
Animation0_Walk_Frames:
	db $00,$01,$02,$03,$04,$05,$06,$07
Animation1_Flip_Frames:
	db $08,$08
Animation2_Resist_Frames:
	db $09
Animation3_DeathLoop_Frames:
	db $0A,$0B
Animation4_Death_Frames:
	db $0C,$0D,$0E,$0F,$10

Times:
	
Animation0_Walk_Times:
	db $04,$04,$04,$04,$04,$04,$04,$04
Animation1_Flip_Times:
	db $04,$04
Animation2_Resist_Times:
	db $04
Animation3_DeathLoop_Times:
	db $04,$04
Animation4_Death_Times:
	db $04,$04,$04,$04,$04

Flips:
	
Animation0_Walk_Flips:
	db $00,$00,$00,$00,$00,$00,$00,$00
Animation1_Flip_Flips:
	db $00,$01
Animation2_Resist_Flips:
	db $00
Animation3_DeathLoop_Flips:
	db $00,$00
Animation4_Death_Flips:
	db $00,$00,$00,$00,$00

;>End Animations Section

;Don't Delete or write another >Section Hitbox Interaction or >End Section
;All code between >Section Hitboxes Interaction and >End Hitboxes Interaction Section will be changed by Dyzen : Sprite Maker
;>Section Hitboxes Interaction
;######################################
;######## Interaction Space ###########
;######################################

InteractMarioSprite:
	LDA !SpriteYoshiTongueFlag,x
	BEQ +
RTS
+
	LDA.b #HitboxTables
	STA $8A
	LDA.b #HitboxTables>>8
	STA $8B
	LDA.b #HitboxTables>>16
	STA $8C

	LDA !GlobalFlip,x
    EOR !LocalFlip,x
	TAY                     ;Y = Flip Adder, used to jump to the frame with the current flip

	STZ $4A
    LDA !FrameIndex,x		;A 16 bits frame index
	STA $49

	%DyzenPlayerNormalSpriteInteraction()
	BCC +

	JSR DefaultAction
RTS
+
	LDA #$00
	STA !SpritePlayerIsAbove,x
RTS

HitboxTables:
	dw HitboxAdder
	dw FrameHitboxesIndexer
	dw FrameHitBoxes
	dw HitboxType
	dw HitboxXOffset
	dw HitboxYOffset
	dw HitboxWidth
	dw HitboxHeight
	dw HitboxAction1
	dw HitboxAction2
	dw Actions

HitboxAdder:
    dw $0000,$0022

FrameHitboxesIndexer:
    dw $0000,$0002,$0005,$0007,$0009,$000B,$000D,$000F,$0011,$0013,$0015,$0016,$0017,$0018,$0019,$001A
	dw $001B
	dw $001C,$001E,$0021,$0023,$0025,$0027,$0029,$002B,$002D,$002F,$0031,$0032,$0033,$0034,$0035,$0036
	dw $0037

FrameHitBoxes:
    db $00,$FF
	db $01,$02,$FF
	db $03,$FF
	db $04,$FF
	db $05,$FF
	db $06,$FF
	db $07,$FF
	db $08,$FF
	db $09,$FF
	db $0A,$FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	
	db $0B,$FF
	db $0C,$0D,$FF
	db $0E,$FF
	db $0F,$FF
	db $10,$FF
	db $11,$FF
	db $12,$FF
	db $13,$FF
	db $14,$FF
	db $15,$FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	
HitboxesStart:
    dw $0000,$000E,$001C,$002A,$0038,$0046,$0054,$0062,$0070,$007E,$008C,$009A,$00A8,$00B6,$00C4,$00D2
	dw $00E0,$00EE,$00FC,$010A,$0118,$0126

Hitboxes:
HitboxType: 
	dw $0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dw $0001,$0001,$0001,$0001,$0001,$0001
HitboxXOffset: 
	dw $0001,$0001,$0000,$FFFF,$FFFF,$FFFE,$FFFD,$FFFE,$FFFF,$FFFB,$0009,$0000,$0000,$0002,$0002,$0002
	dw $0003,$0004,$0003,$0002,$0006,$FFF8
HitboxYOffset: 
	dw $FFE8,$FFE8,$0011,$FFE8,$FFE8,$FFE8,$FFE8,$FFE8,$FFE8,$FFE8,$FFE8,$FFE8,$FFE8,$0011,$FFE8,$FFE8
	dw $FFE8,$FFE8,$FFE8,$FFE8,$FFE8,$FFE8
HitboxWidth: 
	dw $000F,$000F,$000E,$000F,$000F,$000F,$000F,$000F,$000F,$000F,$000F,$000F,$000F,$000E,$000F,$000F
	dw $000F,$000F,$000F,$000F,$000F,$000F
HitboxHeight: 
	dw $0037,$0037,$000F,$0037,$0037,$0037,$0037,$0037,$0037,$0037,$0037,$0037,$0037,$000F,$0037,$0037
	dw $0037,$0037,$0037,$0037,$0037,$0037
HitboxAction1: 
	dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw $0000,$0000,$0000,$0000,$0000,$0000
HitboxAction2: 
	dw $0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002
	dw $0002,$0002,$0002,$0002,$0002,$0002
	

;This routine will be executed when mario interact with a standar hitbox.
;It will be excecuted if $0E is 1 after execute Interaction routine
 
Actions:
	dw CheckBounce
	dw CheckPlayerIsAbove
	

;This routine will be executed when mario interact with a standar hitbox.
;It will be excecuted if $0E is 1 after execute Interaction routine
DefaultAction:
	LDA $1490|!addr	;if player is using the star
	BEQ +			;kill the sprite

	%Star()
	JSR StartDead
RTS
+

	LDA !SpritePlayerIsAbove,x
	BNE +

	%DyzenPrepareContactEffect()
	LDA #$01
	%DisplayContactEffect()
	%DamagePlayer()

RTS
+	

	REP #$20
	LDA $6A
	SEC
	SBC $0C
	CLC
	ADC !PlayerY
	STA !PlayerY
	SEP #$20

    JSL $01AA33|!rom    ;Do the player boost its Y Speed 

	%DyzenPrepareContactEffect()
	LDA #$00
	%DisplayContactEffect();JSL $01AB99|!rom    ;Display White Star             

	LDA !State,x
	CMP #$02
	BEQ +

	LDA !RidingYoshi
	BNE .kill

	LDA !PowerUp
	BEQ +

	LDA !SpinJumpFlag
	BEQ +
.kill

	LDA #!DeadSFX
	%PlaySound()
	JSR StartDead
RTS
+
    LDA #!HitSFX
    %PlaySound()
 
    JSR StartResist

RTS                 ;Return


;$65		;Hitbox Direction
;$66		;Top
;$68		;Distance
;$6A		;Bounce Top
CheckBounce:
	%DyzenCheckBounce()
RTL

CheckPlayerIsAbove:
	%DyzenCheckPlayerIsAbove()
RTL
