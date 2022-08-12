;@Klaptrap.bin,KlaptrapPal1.bin,KlaptrapPal2.bin,KlaptrapPal3.bin,KlaptrapPal4.bin,KlaptrapPal5.bin
!ResourceIndex = $00
%GFXTabDef(!ResourceIndex)
%GFXDef(00)
%GFXDef(01)
%GFXDef(02)
%GFXDef(03)
%GFXDef(04)
%GFXDef(05)

!MunchSFX = $02
!MunchSFXAddress = $1DF9|!addr

!DeathSFX = $02
!DeathSFXAddress = $1DF9|!addr

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
!State = !SpriteMiscTable8
!LoadPal = !SpriteLoadPal
!Pal = !SpritePal
!Version = !SpriteMiscTable11
!XSpeed = !ExtraByte2
!Hitpoints = !ExtraByte3
!AfterDamageTime = !ExtraByte4
!JumpSpeed = !SpriteMiscTable12
!FlashTimer = !SpriteDecTimer1
!SpawnedSprite = !SpriteMiscTable13
!WalkSpeed = !SpriteMiscTable14
!OneUpFlag = !SpriteMiscTable15
!GhostDispTime = !SpriteMiscTable16

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
	LSR
	LSR
	AND #$01
	EOR #$01
	STA !GlobalFlip,x
	LDA #$00
	STA !LocalFlip,x
	STA !SpriteActionFlag,x

	STZ !State,x 

	LDA #$FF
	STA !SpawnedSprite,x
	STA !LastFrameIndex,x
	JSL InitWrapperChangeAnimationFromStart
    ;Here you can write your Init Code
    ;This will be excecuted when the sprite is spawned 
	
	%CheckSlotNormalSprite(#$04, $00)

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

	LDA !ExtraByte2,x
	AND #$0F
	ASL
	ASL
	ASL
	EOR #$FF
	INC A
	STA !JumpSpeed,x

	LDA !ExtraByte2,x
	AND #$F0
	LSR
	AND #$7F
	STA !XSpeed,x

	LDA !XSpeed,x
	STA !SpriteXSpeed,x

	LDA !GlobalFlip,x
	BEQ ++
	LDA !SpriteXSpeed,x
	EOR #$FF
	INC A
	STA !SpriteXSpeed,x
++
	JSR SetWalkAnimationSpeed
    ;Here you can write your Init Code
    ;This will be excecuted when the sprite is spawned 

	LDA #$00
	STA !SpritePlayerIsAbove,x
	STA !SpriteDecTimer5,x
	STA !SpriteActionFlag,x

	STZ !FlashTimer

	STZ !OneUpFlag,x

	LDA !ExtraByte3,x
	AND #$F0
	STA !GhostDispTime,x

	LDA !ExtraByte3,x
	AND #$0F
	STA !Hitpoints,x
	BEQ +
	INC !OneUpFlag,x
+

	LDA !Version,x
	CMP #$03
	BCS +

	LDA !SpriteTweaker1686_DNCTSWYE,x
	ORA #$18
	STA !SpriteTweaker1686_DNCTSWYE,x
+
RTL

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
	dl !GFX01,!GFX02,!GFX03,!GFX04,!GFX05
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
	ASL
	CLC 
	ADC !Version,x
	TAY

	LDA VersionPal,y
	STA !Scratch1
	LDA VersionPal+$01,y
	STA !Scratch2
	LDA VersionPal+$02,y
	STA !Scratch3


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

	%DyzenPrepareBounce()

    JSR InteractMarioSprite
    ;After this routine, if the sprite interact with mario, Carry is Set.

	%DyzenDetectPlayerIsAbove()

	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BEQ +								;/

	LDA !FrameIndex,x
	CMP #$08
	BNE +

	LDA !AnimationTimer,x
	BNE +

	LDA #!MunchSFX
	STA !MunchSFXAddress

+
	JSR ActionFlag
	JSR StateMachine
    ;Here you can write your sprite code routine
    ;This will be excecuted once per frame excepts when 
    ;the animation is locked or when sprite status is not #$08

    JSR AnimationRoutine                ;Calls animation routine and decides the next frame to draw
    ;JSR changeframe

Return:
    RTS

;>EndRoutine

;######################################
;######## Sub Routine Space ###########
;######################################
;Here you can write routines or tables
ActionFlag:
	LDA !SpriteStatus,x
	CMP #$08
	BEQ +
RTS
+
	LDA !SpriteActionFlag,x
	AND #$01
	BEQ +

	LDA #$03
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

SetWalkAnimationSpeed:
	LDA #$04
	STA !WalkSpeed,x
	LDA !XSpeed,x
	CMP #$30
	BCC +
	STZ !WalkSpeed,x
RTS
+
	CMP #$20
	BCC +
	LDA #$02
	STA !WalkSpeed,x
+
RTS

XOffset:
	db $07,$F9
SpawnPowerUp:

	LDA !OneUpFlag,x
	BEQ +

	LDA !GlobalFlip,x
	TAY
	LDA XOffset,y
	STA !Scratch0
	STZ !Scratch1
	STZ !Scratch2
	LDA #$C0
	STA !Scratch3

	LDA #$78
	CLC
	%SpawnSpriteBehind()
	BCS +

	PHY
	LDA !GlobalFlip,x
	PLX
	STA !SpriteDirection,x

	LDX !SpriteIndex
+
RTS

StateMachine:
	LDA !State,x
	ASL
	TAX

	JSR (States,x)
RTS

States:
	dw Walk0
	dw Flip1
	dw Hurt2
	dw Dead3

Jump:
	LDA !Version,x
	BEQ +
	CMP #$04
	BEQ +
	
	LDA !SpriteBlockedStatus_ASB0UDLR,x
	AND #$24
	BEQ +

	LDA !ButtonDown_AXLR0000
	ORA !ButtonDown_BYETUDLR
	AND #$80
	BEQ +

	LDA !JumpSpeed,x
	STA !SpriteYSpeed,x

	LDA !SpriteBlockedStatus_ASB0UDLR,x
	AND #$DB
	STA !SpriteBlockedStatus_ASB0UDLR,x
+
RTS

Jump2:
	LDA !Version,x
	CMP #$04
	BCS +
RTS
+
	LDA !SpriteBlockedStatus_ASB0UDLR,x
	AND #$24
	BNE +
RTS
+
	LDA !ButtonDown_AXLR0000
	ORA !ButtonDown_BYETUDLR
	AND #$80
	BNE +
RTS
+
	LDA #$A0
	STA !SpriteYSpeed,x

	LDA #$00
	%CalculateXYSpeedForAimedJumpBasedOnJumpForce()

	LDA !SpriteBlockedStatus_ASB0UDLR,x
	AND #$DB
	STA !SpriteBlockedStatus_ASB0UDLR,x
RTS

Walk0:
	LDX !SpriteIndex

	LDA !Version,x
	CMP #$04
	BEQ +
	LDA !SpriteDecTimer5,x
	BNE +

	LDA !SpriteTweaker1686_DNCTSWYE,x
	AND #$F7
	STA !SpriteTweaker1686_DNCTSWYE,x

+

	LDA !AnimationIndex,x
	BEQ .StateLoop

	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BEQ +

.StateStart
	LDA !XSpeed,x
	STA !SpriteXSpeed,x

	LDA !GlobalFlip,x
	BEQ ++
	LDA !XSpeed,x
	EOR #$FF
	INC A
	STA !SpriteXSpeed,x
++
	JSR SetWalkAnimationSpeed

	JSR ChangeAnimationFromStart_walk	
	%UpdateNormalSpriteSpeedWithGravityAndFloorCheck()
+
RTS
.StateLoop

	%UpdateNormalSpriteSpeedWithGravityAndFloorCheck()
	BCS ++

	LDA !SpriteBlockedStatus_ASB0UDLR,x
	AND #$43
	BEQ +
++
	LDA #$01
	STA !State,x
	STZ !SpriteXSpeed,x
+

	LDA !Version,x
	CMP #$04
	BCC +

	STZ $01
	LDA #$00
	STA $00
	%DyzenCheckPlayerSide()
	PHP
	PLA
	AND #$01
	CMP !GlobalFlip,x
	BEQ +

	LDA #$01
	STA !State,x
RTS
+

	JSR Jump
	JSR Jump2
RTS

FlipStartFrame:
	db $06,$01,$02,$03,$04,$05,$05,$05,$05,$05
	db $05,$05,$05,$05,$05,$05,$05
Flip1:
	LDX !SpriteIndex

	LDA !SpriteBlockedStatus_ASB0UDLR,x
	AND #$43
	BEQ +
	STZ !SpriteXSpeed,x
+

	%UpdateNormalSpriteSpeedWithGravityAndFloorCheck()

	LDA !AnimationIndex,x
	CMP #$01
	BEQ .StateLoop
.StateStart
	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BEQ +


	LDA !Version,x
	CMP #$04
	BEQ ++
	STZ !SpriteXSpeed,x
++

	LDA !SpriteTweaker1686_DNCTSWYE,x
	ORA #$08
	STA !SpriteTweaker1686_DNCTSWYE,x

	LDA !FrameIndex,x
	TAY

	LDA FlipStartFrame,y
	STA !AnimationFrameIndex,x
	TAY 
	LDA Animation1_flip_Frames,y
	STA !FrameIndex,x
	LDA Animation1_flip_Times,y
	STA !AnimationTimer,x
	LDA Animation1_flip_Flips,y
	STA !LocalFlip,x

	LDA #$01
	STA !AnimationIndex,x

	LDA !SpriteBlockedStatus_ASB0UDLR,x
	AND #$24
	BEQ +

	STZ !SpriteXSpeed,x

	LDA #$08
	STA !SpriteDecTimer5,x
+	
RTS
.StateLoop

	LDA !AnimationFrameIndex,x
	CMP #$09
	BCC +

	LDA !AnimationTimer,x
	BNE +

	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BEQ +

	LDA !GlobalFlip,x
	EOR #$01
	STA !GlobalFlip,x
	JSR Walk0_StateStart
	STZ !State,x

+
	JSR Jump
RTS

Hurt2:
	LDX !SpriteIndex
	%UpdateNormalSpriteSpeedWithGravityAndFloorCheck()
	LDA !AnimationIndex,x
	CMP #$02
	BEQ .StateLoop
.StateStart
	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BEQ +

	JSR ChangeAnimationFromStart_damage
	LDA !AfterDamageTime,x
	STA !FlashTimer,x
+
RTS
.StateLoop

	LDA !AnimationFrameIndex,x
	CMP #$0A
	BNE +

	LDA !AnimationTimer,x
	BNE +

	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BEQ +

	JSR SpawnPowerUp

+
	LDA !AnimationFrameIndex,x
	CMP #$16
	BCC +

	LDA !AnimationTimer,x
	BNE +

	LDA !Hitpoints,x
	DEC A
	STA !Hitpoints,x
	BNE ++

	STZ !SpriteStatus,x
RTS
++
	STZ !State,x
	LDA !XSpeed,x
	CLC
	ADC #$08
	CMP #$80
	BCC ++
	LDA #$7F
++
	STA !XSpeed,x

+
RTS

Dead3:
	LDX !SpriteIndex
	LDA !AnimationIndex,x
	CMP #$03
	BEQ .StateLoop
.StateStart
	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BEQ +

	JSR ChangeAnimationFromStart_death

	LDA #$02
	STA !SpriteStatus,x

	LDA #$C0
	STA !SpriteYSpeed,x
+
RTS
.StateLoop
RTS


;######################################
;######### Dynamic Routine ############
;######################################
;######################################
ResourceOffset:
Frame0_ResourceOffset:
	dw $0000,$00A0
Frame1_ResourceOffset:
	dw $0120,$0200
Frame2_ResourceOffset:
	dw $02C0,$03A0
Frame3_ResourceOffset:
	dw $0460,$0520
Frame4_ResourceOffset:
	dw $05E0,$06C0
Frame5_ResourceOffset:
	dw $0740,$0840
Frame6_ResourceOffset:
	dw $0900,$0A00
Frame7_ResourceOffset:
	dw $0AC0,$0BC0
Frame8_ResourceOffset:
	dw $0C80,$0D60
Frame9_ResourceOffset:
	dw $0E20,$0F00
Frame10_ResourceOffset:
	dw $0FC0,$1080
Frame11_ResourceOffset:
	dw $1100,$11C0
Frame12_ResourceOffset:
	dw $1240,$1300
Frame13_ResourceOffset:
	dw $1380,$1440
Frame14_ResourceOffset:
	dw $14C0,$1580
Frame15_ResourceOffset:
	dw $1600,$1700
Frame16_ResourceOffset:
	dw $1800,$18C0


ResourceSize:
Frame0_ResourceSize:
	db $05,$04
Frame1_ResourceSize:
	db $07,$06
Frame2_ResourceSize:
	db $07,$06
Frame3_ResourceSize:
	db $06,$06
Frame4_ResourceSize:
	db $07,$04
Frame5_ResourceSize:
	db $08,$06
Frame6_ResourceSize:
	db $08,$06
Frame7_ResourceSize:
	db $08,$06
Frame8_ResourceSize:
	db $07,$06
Frame9_ResourceSize:
	db $07,$06
Frame10_ResourceSize:
	db $06,$04
Frame11_ResourceSize:
	db $06,$04
Frame12_ResourceSize:
	db $06,$04
Frame13_ResourceSize:
	db $06,$04
Frame14_ResourceSize:
	db $06,$04
Frame15_ResourceSize:
	db $08,$08
Frame16_ResourceSize:
	db $06,$04


DynamicRoutine:
    
	%EasyNormalSpriteDynamicRoutineFixedGFX("!FrameIndex,x", "!LastFrameIndex,x", !GFX00, "#ResourceOffset", "#ResourceSize", #$10)
RTS
;Here you can write routines or tables

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
	LDA !Version,x
	CMP #$03
	BNE +

	LDA !GhostDispTime,x
	%GetGhostGraphicState()
	BCS +
	LDA #$01
	STA !Scratch52
RTS
+

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
    dw $0002,$0003,$0003,$0002,$0004,$0004,$0004,$0004,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dw $0003
	dw $0002,$0003,$0003,$0002,$0004,$0004,$0004,$0004,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dw $0003
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
    dw $0002,$0006,$000A,$000D,$0012,$0017,$001C,$0021,$0025,$0029,$002D,$0031,$0035,$0039,$003D,$0041
	dw $0045
	dw $0048,$004C,$0050,$0053,$0058,$005D,$0062,$0067,$006B,$006F,$0073,$0077,$007B,$007F,$0083,$0087
	dw $008B
;>EndTable

;>Table: FramesEndPosition
;>Description: Indicates the index where end each frame
;>ValuesSize: 16
FramesEndPosition:
    dw $0000,$0003,$0007,$000B,$000E,$0013,$0018,$001D,$0022,$0026,$002A,$002E,$0032,$0036,$003A,$003E
	dw $0042
	dw $0046,$0049,$004D,$0051,$0054,$0059,$005E,$0063,$0068,$006C,$0070,$0074,$0078,$007C,$0080,$0084
	dw $0088
;>EndTable


;>Table: Tiles
;>Description: Tiles codes of each tile of each frame
;>ValuesSize: 8
Tiles:
    
Frame0_Frame0_Tiles:
	db $04,$02,$00
Frame1_Frame1_Tiles:
	db $04,$02,$06,$00
Frame2_Frame2_Tiles:
	db $04,$02,$06,$00
Frame3_Frame3_Tiles:
	db $04,$02,$00
Frame4_Frame4_Tiles:
	db $06,$02,$05,$00,$04
Frame5_Frame5_Tiles:
	db $07,$04,$06,$02,$00
Frame6_Frame6_Tiles:
	db $07,$04,$06,$00,$02
Frame7_Frame7_Tiles:
	db $07,$04,$06,$02,$00
Frame8_Frame8_Tiles:
	db $04,$02,$06,$00
Frame9_Frame9_Tiles:
	db $04,$02,$06,$00
Frame10_Frame10_Tiles:
	db $05,$02,$00,$04
Frame11_Frame11_Tiles:
	db $05,$02,$00,$04
Frame12_Frame12_Tiles:
	db $05,$02,$00,$04
Frame13_Frame13_Tiles:
	db $05,$02,$00,$04
Frame14_Frame14_Tiles:
	db $05,$02,$00,$04
Frame15_Frame15_Tiles:
	db $06,$04,$02,$00
Frame16_Frame16_Tiles:
	db $02,$05,$00,$04
Frame0_Frame0_TilesFlipX:
	db $04,$02,$00
Frame1_Frame1_TilesFlipX:
	db $04,$02,$06,$00
Frame2_Frame2_TilesFlipX:
	db $04,$02,$06,$00
Frame3_Frame3_TilesFlipX:
	db $04,$02,$00
Frame4_Frame4_TilesFlipX:
	db $06,$02,$05,$00,$04
Frame5_Frame5_TilesFlipX:
	db $07,$04,$06,$02,$00
Frame6_Frame6_TilesFlipX:
	db $07,$04,$06,$00,$02
Frame7_Frame7_TilesFlipX:
	db $07,$04,$06,$02,$00
Frame8_Frame8_TilesFlipX:
	db $04,$02,$06,$00
Frame9_Frame9_TilesFlipX:
	db $04,$02,$06,$00
Frame10_Frame10_TilesFlipX:
	db $05,$02,$00,$04
Frame11_Frame11_TilesFlipX:
	db $05,$02,$00,$04
Frame12_Frame12_TilesFlipX:
	db $05,$02,$00,$04
Frame13_Frame13_TilesFlipX:
	db $05,$02,$00,$04
Frame14_Frame14_TilesFlipX:
	db $05,$02,$00,$04
Frame15_Frame15_TilesFlipX:
	db $06,$04,$02,$00
Frame16_Frame16_TilesFlipX:
	db $02,$05,$00,$04
;>EndTable

;>Table: XDisplacements
;>Description: X Displacement of each tile of each frame
;>ValuesSize: 8
XDisplacements:
    
Frame0_Frame0_XDisp:
	db $00,$05,$06
Frame1_Frame1_XDisp:
	db $F8,$08,$0A,$12
Frame2_Frame2_XDisp:
	db $F7,$07,$0E,$12
Frame3_Frame3_XDisp:
	db $F7,$07,$12
Frame4_Frame4_XDisp:
	db $FB,$01,$0D,$11,$1B
Frame5_Frame5_XDisp:
	db $FC,$01,$09,$11,$11
Frame6_Frame6_XDisp:
	db $FE,$02,$08,$10,$10
Frame7_Frame7_XDisp:
	db $FD,$01,$0C,$11,$13
Frame8_Frame8_XDisp:
	db $FB,$0B,$0E,$13
Frame9_Frame9_XDisp:
	db $FC,$0C,$0C,$14
Frame10_Frame10_XDisp:
	db $F9,$01,$0E,$1C
Frame11_Frame11_XDisp:
	db $F9,$00,$0F,$1D
Frame12_Frame12_XDisp:
	db $FA,$FF,$0F,$1D
Frame13_Frame13_XDisp:
	db $FB,$FE,$0E,$1D
Frame14_Frame14_XDisp:
	db $FD,$FE,$0E,$1C
Frame15_Frame15_XDisp:
	db $F5,$05,$0D,$12
Frame16_Frame16_XDisp:
	db $FB,$0A,$0B,$1A
Frame0_Frame0_XDispFlipX:
	db $08,$FB,$FA
Frame1_Frame1_XDispFlipX:
	db $08,$F8,$FE,$EE
Frame2_Frame2_XDispFlipX:
	db $09,$F9,$FA,$EE
Frame3_Frame3_XDispFlipX:
	db $09,$F9,$EE
Frame4_Frame4_XDispFlipX:
	db $0D,$FF,$FB,$EF,$ED
Frame5_Frame5_XDispFlipX:
	db $0C,$FF,$FF,$EF,$EF
Frame6_Frame6_XDispFlipX:
	db $0A,$FE,$00,$F0,$F0
Frame7_Frame7_XDispFlipX:
	db $0B,$FF,$FC,$EF,$ED
Frame8_Frame8_XDispFlipX:
	db $05,$F5,$FA,$ED
Frame9_Frame9_XDispFlipX:
	db $04,$F4,$FC,$EC
Frame10_Frame10_XDispFlipX:
	db $0F,$FF,$F2,$EC
Frame11_Frame11_XDispFlipX:
	db $0F,$00,$F1,$EB
Frame12_Frame12_XDispFlipX:
	db $0E,$01,$F1,$EB
Frame13_Frame13_XDispFlipX:
	db $0D,$02,$F2,$EB
Frame14_Frame14_XDispFlipX:
	db $0B,$02,$F2,$EC
Frame15_Frame15_XDispFlipX:
	db $0B,$FB,$F3,$EE
Frame16_Frame16_XDispFlipX:
	db $05,$FE,$F5,$EE
;>EndTable
;>Table: YDisplacements
;>Description: Y Displacement of each tile of each frame
;>ValuesSize: 8
YDisplacements:
    
Frame0_Frame0_YDisp:
	db $09,$FB,$0B
Frame1_Frame1_YDisp:
	db $07,$02,$0D,$09
Frame2_Frame2_YDisp:
	db $07,$04,$01,$08
Frame3_Frame3_YDisp:
	db $06,$01,$07
Frame4_Frame4_YDisp:
	db $09,$03,$FE,$03,$02
Frame5_Frame5_YDisp:
	db $09,$FD,$0D,$F9,$09
Frame6_Frame6_YDisp:
	db $09,$FE,$0E,$FA,$08
Frame7_Frame7_YDisp:
	db $0A,$03,$FF,$06,$FF
Frame8_Frame8_YDisp:
	db $07,$00,$10,$04
Frame9_Frame9_YDisp:
	db $05,$00,$0B,$06
Frame10_Frame10_YDisp:
	db $09,$04,$00,$06
Frame11_Frame11_YDisp:
	db $07,$04,$01,$06
Frame12_Frame12_YDisp:
	db $02,$05,$01,$04
Frame13_Frame13_YDisp:
	db $FF,$06,$02,$04
Frame14_Frame14_YDisp:
	db $FE,$05,$04,$04
Frame15_Frame15_YDisp:
	db $03,$05,$02,$05
Frame16_Frame16_YDisp:
	db $01,$00,$04,$09
Frame0_Frame0_YDispFlipX:
	db $09,$FB,$0B
Frame1_Frame1_YDispFlipX:
	db $07,$02,$0D,$09
Frame2_Frame2_YDispFlipX:
	db $07,$04,$01,$08
Frame3_Frame3_YDispFlipX:
	db $06,$01,$07
Frame4_Frame4_YDispFlipX:
	db $09,$03,$FE,$03,$02
Frame5_Frame5_YDispFlipX:
	db $09,$FD,$0D,$F9,$09
Frame6_Frame6_YDispFlipX:
	db $09,$FE,$0E,$FA,$08
Frame7_Frame7_YDispFlipX:
	db $0A,$03,$FF,$06,$FF
Frame8_Frame8_YDispFlipX:
	db $07,$00,$10,$04
Frame9_Frame9_YDispFlipX:
	db $05,$00,$0B,$06
Frame10_Frame10_YDispFlipX:
	db $09,$04,$00,$06
Frame11_Frame11_YDispFlipX:
	db $07,$04,$01,$06
Frame12_Frame12_YDispFlipX:
	db $02,$05,$01,$04
Frame13_Frame13_YDispFlipX:
	db $FF,$06,$02,$04
Frame14_Frame14_YDispFlipX:
	db $FE,$05,$04,$04
Frame15_Frame15_YDispFlipX:
	db $03,$05,$02,$05
Frame16_Frame16_YDispFlipX:
	db $01,$00,$04,$09
;>EndTable
;>Table: Sizes.
;>Description: size of each tile of each frame
;>ValuesSize: 8
Sizes:
    
Frame0_Frame0_Sizes:
	db $00,$02,$02
Frame1_Frame1_Sizes:
	db $02,$02,$00,$02
Frame2_Frame2_Sizes:
	db $02,$02,$00,$02
Frame3_Frame3_Sizes:
	db $02,$02,$02
Frame4_Frame4_Sizes:
	db $00,$02,$00,$02,$00
Frame5_Frame5_Sizes:
	db $00,$02,$00,$02,$02
Frame6_Frame6_Sizes:
	db $00,$02,$00,$02,$02
Frame7_Frame7_Sizes:
	db $00,$02,$00,$02,$02
Frame8_Frame8_Sizes:
	db $02,$02,$00,$02
Frame9_Frame9_Sizes:
	db $02,$02,$00,$02
Frame10_Frame10_Sizes:
	db $00,$02,$02,$00
Frame11_Frame11_Sizes:
	db $00,$02,$02,$00
Frame12_Frame12_Sizes:
	db $00,$02,$02,$00
Frame13_Frame13_Sizes:
	db $00,$02,$02,$00
Frame14_Frame14_Sizes:
	db $00,$02,$02,$00
Frame15_Frame15_Sizes:
	db $02,$02,$02,$02
Frame16_Frame16_Sizes:
	db $02,$00,$02,$00
Frame0_Frame0_SizesFlipX:
	db $00,$02,$02
Frame1_Frame1_SizesFlipX:
	db $02,$02,$00,$02
Frame2_Frame2_SizesFlipX:
	db $02,$02,$00,$02
Frame3_Frame3_SizesFlipX:
	db $02,$02,$02
Frame4_Frame4_SizesFlipX:
	db $00,$02,$00,$02,$00
Frame5_Frame5_SizesFlipX:
	db $00,$02,$00,$02,$02
Frame6_Frame6_SizesFlipX:
	db $00,$02,$00,$02,$02
Frame7_Frame7_SizesFlipX:
	db $00,$02,$00,$02,$02
Frame8_Frame8_SizesFlipX:
	db $02,$02,$00,$02
Frame9_Frame9_SizesFlipX:
	db $02,$02,$00,$02
Frame10_Frame10_SizesFlipX:
	db $00,$02,$02,$00
Frame11_Frame11_SizesFlipX:
	db $00,$02,$02,$00
Frame12_Frame12_SizesFlipX:
	db $00,$02,$02,$00
Frame13_Frame13_SizesFlipX:
	db $00,$02,$02,$00
Frame14_Frame14_SizesFlipX:
	db $00,$02,$02,$00
Frame15_Frame15_SizesFlipX:
	db $02,$02,$02,$02
Frame16_Frame16_SizesFlipX:
	db $02,$00,$02,$00
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

ChangeAnimationFromStart_walk:
	STZ !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_flip:
	LDA #$01
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_damage:
	LDA #$02
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_death:
	LDA #$03
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

	LDA !AnimationIndex,x
	BNE +
	LDA !WalkSpeed,x
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
	BNE +
	LDA !WalkSpeed,x
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
	dw $0008,$000A,$0017,$0002

AnimationLastTransition:
	dw $0000,$0009,$0016,$0001

AnimationIndexer:
	dw $0000,$0008,$0012,$0029

Frames:
	
Animation0_walk_Frames:
	db $01,$02,$03,$04,$05,$06,$07,$08
Animation1_flip_Frames:
	db $01,$02,$03,$04,$05,$00,$00,$06,$07,$08
Animation2_damage_Frames:
	db $09,$0A,$0B,$0C,$0D,$0E,$0D,$0C,$0B,$0A,$09,$00,$06,$07,$08,$01,$02,$03,$02,$01,$02,$03,$02
Animation3_death_Frames:
	db $0F,$10

Times:
	
Animation0_walk_Times:
	db $04,$04,$04,$04,$04,$04,$04,$04
Animation1_flip_Times:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Animation2_damage_Times:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Animation3_death_Times:
	db $10,$04

Flips:
	
Animation0_walk_Flips:
	db $00,$00,$00,$00,$00,$00,$00,$00
Animation1_flip_Flips:
	db $00,$00,$00,$00,$00,$00,$01,$01,$01,$01
Animation2_damage_Flips:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
Animation3_death_Flips:
	db $00,$00

;>End Animations Section

;Don't Delete or write another >Section Hitbox Interaction or >End Section
;All code between >Section Hitboxes Interaction and >End Hitboxes Interaction Section will be changed by Dyzen : Sprite Maker
;>Section Hitboxes Interaction
InteractMarioSprite:
	LDA !SpriteYoshiTongueFlag,x
	BEQ +
RTS
+

	LDA !State,x
	CMP #$02
	BCC +
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
    dw $0000,$0002,$0004,$0006,$0008,$000A,$000D,$0010,$0013,$0015,$0017,$0018,$0019,$001A,$001B,$001C
	dw $001D
	dw $001E,$0020,$0022,$0024,$0026,$0028,$002B,$002E,$0031,$0033,$0035,$0036,$0037,$0038,$0039,$003A
	dw $003B

FrameHitBoxes:
    db $00,$FF
	db $01,$FF
	db $01,$FF
	db $02,$FF
	db $03,$FF
	db $04,$05,$FF
	db $04,$06,$FF
	db $07,$08,$FF
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
	db $0C,$FF
	db $0C,$FF
	db $0D,$FF
	db $0E,$FF
	db $0F,$10,$FF
	db $0F,$11,$FF
	db $12,$13,$FF
	db $14,$FF
	db $15,$FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF

Hitboxes:
HitboxType: 
	dw $0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dw $0001,$0001,$0001,$0001,$0001,$0001
HitboxXOffset: 
	dw $0004,$0000,$0000,$0000,$0001,$0010,$0010,$0001,$0011,$0000,$0001,$FFFC,$FFF2,$FFF2,$FFF0,$0000
	dw $FFF2,$FFF1,$FFFF,$FFEF,$FFEF,$FFEF
HitboxYOffset: 
	dw $0001,$0004,$0004,$0005,$0006,$FFFB,$FFFB,$0006,$FFFC,$0007,$0006,$0001,$0008,$0006,$0005,$0006
	dw $FFFB,$FFFB,$0006,$FFFC,$0007,$0006
HitboxWidth: 
	dw $0010,$001E,$001E,$0020,$000F,$000E,$000F,$0010,$0010,$0021,$0020,$0010,$001E,$001E,$0020,$000F
	dw $000E,$000F,$0010,$0010,$0021,$0020
HitboxHeight: 
	dw $000F,$000C,$000A,$0008,$0008,$0013,$0013,$0008,$0012,$0008,$0007,$000F,$0008,$0008,$0008,$0008
	dw $0013,$0013,$0008,$0012,$0008,$0007
HitboxAction1: 
	dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw $0000,$0000,$0000,$0000,$0000,$0000
HitboxAction2: 
	dw $0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002
	dw $0002,$0002,$0002,$0002,$0002,$0002

Actions:
	dw CheckBounce
	dw CheckPlayerIsAbove
	

;This routine will be executed when mario interact with a standar hitbox.
;It will be excecuted if $0E is 1 after execute Interaction routine
DefaultAction:
	LDA !FlashTimer,x
	BEQ +
RTS
+
	LDA !Version,x
	CMP #$03
	BNE +

	LDA !GhostDispTime,x
	%GetGhostState()
	BIT #$01
	BNE +
RTS
+
	LDA $1490|!addr	;if player is using the star
	BEQ +			;kill the sprite

	%Star()
	LDA #$03
	STA !State,x
RTS
+

	LDA !SpritePlayerIsAbove,x
	BNE +

-
	%DyzenPrepareContactEffect()
	LDA #$01
	%DisplayContactEffect()

	%DamagePlayer()

RTS
+	
	LDA !Version,x
	CMP #$03
	BNE +

	LDA !SpinJumpFlag
	BEQ -

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

	LDA !Version,x
	CMP #$03
	BNE +
	LDA #!DeathSFX
	STA !DeathSFXAddress
RTS
+

	LDA !Hitpoints,x
	BEQ +

	STZ !SpriteXSpeed,x
	LDA #$02
	BRA ++
+
	LDA #$03
++	
	STA !State,x
RTS


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
