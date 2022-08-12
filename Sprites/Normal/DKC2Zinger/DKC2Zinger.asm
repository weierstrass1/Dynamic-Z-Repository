;@DKC2Zinger.bin,DKC2ZingerPal1.bin,DKC2ZingerPal2.bin,DKC2ZingerPal3.bin,DKC2ZingerPal4.bin,DKC2ZingerPal5.bin
!ResourceIndex = $1A
%GFXTabDef(!ResourceIndex)
%GFXDef(00)
%GFXDef(01)
%GFXDef(02)
%GFXDef(03)
%GFXDef(04)
%GFXDef(05)

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

!Pal = !SpritePal
!LoadPal = !SpriteLoadPal
!GhostDispTime = !SpriteMiscTable9
!State = !SpriteMiscTable8

!PivotXH = !SpriteMiscTable10
!PivotXL = !SpriteMiscTable12
!PivotYH = !SpriteMiscTable13
!PivotYL = !SpriteMiscTable14

!BaseMovAngle1 = !SpriteMiscTable15
!BaseMovAngle2 = !SpriteMiscTable16

!GreenTimer = !SpriteDecTimer1

!GreenMaxTime = !SpriteMiscTable17

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
	LSR
	LSR
	STA !GlobalFlip,x
	JSL InitWrapperChangeAnimationFromStart

	%CPXMovInit()

	LDA [$00],y
	AND #$F0
	LSR
	LSR
	STA !GreenMaxTime,x

	LDA #$FF
	STA !LastFrameIndex,x

	%CheckSlotNormalSprite(#$08, $00)
    ;Here you can write your Init Code
    ;This will be excecuted when the sprite is spawned 

	LDA #$00
	STA !State,x
	STA !GreenTimer,x
	STA !SpritePlayerIsAbove,x
	STA !SpriteActionFlag,x
	STA !BaseMovAngle1,x
	STA !BaseMovAngle2,x

	LDA #$01
	STA !LoadPal,x


	%CPXMovLoop()
	JSR BaseMovement
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

;>Routine: SpriteCode
;>Description: This routine excecute the logic of the sprite
;>RoutineLength: Short
VersionPal:
	dl !GFX01,!GFX02,!GFX03,!GFX04,!GFX05
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
	ASL #3
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
	BEQ	+	        
	CMP #$08                            ;if sprite dead return
	BNE Return	
+
	LDA !LockAnimationFlag				    
	BNE Return			                    ;if locked animation return.

    %SubOffScreen()

	LDA !SpriteStatus,x			        
	CMP #$02
	BEQ +

	%DyzenPrepareBounce()

    JSR InteractMarioSprite
    ;After this routine, if the sprite interact with mario, Carry is Set.

	%DyzenDetectPlayerIsAbove()
    ;After this routine, if the sprite interact with mario, Carry is Set.

	JSR ActionFlag
	JSR BaseMovement

+
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

GreenTimer:
	LDA !GreenTimer,x
	BEQ +

	LDA !PosYH,x
	XBA
	LDA !PosYL,x
	REP #$20
	DEC A
	SEP #$20
	STA !PosYL,x
	XBA
	STA !PosYH,x

+
RTS

BaseMovement:

	LDA !PosXH,x
	STA $03
	LDA !PosXL,x
	STA $02
	LDA !PosYH,x
	STA $05
	LDA !PosYL,x
	STA $04

	%Mul(" #$2D"," !BaseMovAngle1,x")

	REP #$30

	LDA !MultiplicationResult
	LSR
	LSR
	LSR
	LSR
	STA $00

	SEP #$30

	LDA !MovTypeX,x
	BNE +

	JSR .ApplyX

+

	%Mul(" #$2D"," !BaseMovAngle2,x")

	REP #$30

	LDA !MultiplicationResult
	LSR
	LSR
	LSR
	LSR
	STA $00

	SEP #$30

	LDA !MovTypeY,x
	BNE +

	JSR .ApplyY

+

	LDA !BaseMovAngle1,x
	CLC
	ADC #$04
	STA !BaseMovAngle1,x

	LDA !BaseMovAngle2,x
	CLC
	ADC #$05
	STA !BaseMovAngle2,x

RTS

.ApplyX
	REP #$10
	LDX $00

	LDA #$04
	%Sin()

	CLC
	ADC $02
	SEP #$30
	LDX !SpriteIndex
	STA !SpriteXLow,x
	XBA
	STA !SpriteXHigh,x
RTS
.ApplyY
	REP #$10
	LDX $00
	
	LDA #$04
	%Cos()

	CLC
	ADC $04
	SEP #$30
	LDX !SpriteIndex
	STA !SpriteYLow,x
	XBA
	STA !SpriteYHigh,x
RTS

ActionFlagCheck:
	db $09,$08,$09,$00,$00

ActionFlag:
	LDA !SpriteStatus,x
	CMP #$08
	BEQ +
RTS
+

	LDA !Version,x
	TAY

	LDA !SpriteActionFlag,x
	AND ActionFlagCheck,y
	BEQ +

	LDA !SpriteActionFlag,x
	AND #$F6
	STA !SpriteActionFlag,x

    LDA #$02
	STA !State,x

+
RTS

;Here you can write routines or tables
StateMachine:

	STZ $8A

    LDA !State,x
    CMP #$02
    BEQ +
    LDA !SpriteStatus,x
    CMP #$08
    BEQ +
RTS
+

	LDA !AnimationIndex,x
	CMP !State,x
	BEQ .StateLoop

	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BNE .StateStart
	RTS
.StateStart
	LDA !State,x
	STA !AnimationIndex,x
	JSR ChangeAnimationFromStart

	LDA !State,x
	ASL
	TAX

	JMP (States_Init,x)

.StateLoop

	LDA !State,x
	ASL
	TAX

	JMP (States_Loop,x)

States_Init:
	dw fly_Init
	dw flip_Init
	dw dead_Init

States_Loop:
	dw fly_Loop
	dw flip_Loop
	dw dead_Loop

fly:
.Init
.Loop
	LDX !SpriteIndex

	%CPXMovLoop()

	JSR GreenTimer

	STZ $00
	STZ $01
	%DyzenCheckPlayerSide()
	BCS ..left
..right
	LDA !GlobalFlip,x
	BNE +
	BRA ++
..left
	LDA !GlobalFlip,x
	BEQ +
	BRA ++
++
	INC !State,x
+
RTS

flip:
.Init
.Loop
	LDX !SpriteIndex

	%CPXMovLoop()

	JSR GreenTimer

	LDA !AnimationFrameIndex,x
	CMP #$03
	BCC +

	LDA !AnimationTimer,x
	BNE +

	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BEQ +

	STZ !State,x

	LDA !GlobalFlip,x
	EOR #$01
	STA !GlobalFlip,x

	JSR ChangeAnimationFromStart_fly

+
RTS

dead:
.Init
	LDX !SpriteIndex

	LDA #$02
	STA !SpriteStatus,x

	LDA #$B0
	STA !SpriteYSpeed,x
.Loop
	LDX !SpriteIndex

	LDA !SpriteYSpeed,x
	BPL +

	LDA #$00
	STA !AnimationFrameIndex,x

	LDA #$02
	STA !AnimationTimer,x

+
RTS

;>Section Dynamic
;######################################
;########## Animation Space ###########
;######################################
ResourceOffset:
    Frame0_ResourceOffset:
	dw $0000,$0160
Frame1_ResourceOffset:
	dw $02A0,$0460
Frame2_ResourceOffset:
	dw $0620,$07E0
Frame3_ResourceOffset:
	dw $0960,$0B40
Frame4_ResourceOffset:
	dw $0D00,$0E80
Frame5_ResourceOffset:
	dw $1000,$11E0
Frame6_ResourceOffset:
	dw $13A0,$1560
Frame7_ResourceOffset:
	dw $16E0,$1880
Frame8_ResourceOffset:
	dw $19C0,$1B80
Frame9_ResourceOffset:
	dw $1D40,$1E80
Frame10_ResourceOffset:
	dw $1FC0,$2160
Frame11_ResourceOffset:
	dw $22E0,$2480
Frame12_ResourceOffset:
	dw $2600,$27C0
Frame13_ResourceOffset:
	dw $2940,$2AE0
Frame14_ResourceOffset:
	dw $2C60,$2DC0


ResourceSize:
    Frame0_ResourceSize:
	db $0B,$0A
Frame1_ResourceSize:
	db $0E,$0E
Frame2_ResourceSize:
	db $0E,$0C
Frame3_ResourceSize:
	db $0F,$0E
Frame4_ResourceSize:
	db $0C,$0C
Frame5_ResourceSize:
	db $0F,$0E
Frame6_ResourceSize:
	db $0E,$0C
Frame7_ResourceSize:
	db $0D,$0A
Frame8_ResourceSize:
	db $0E,$0E
Frame9_ResourceSize:
	db $0A,$0A
Frame10_ResourceSize:
	db $0D,$0C
Frame11_ResourceSize:
	db $0D,$0C
Frame12_ResourceSize:
	db $0E,$0C
Frame13_ResourceSize:
	db $0D,$0C
Frame14_ResourceSize:
	db $0B,$0A


DynamicRoutine:
    
	%EasyNormalSpriteDynamicRoutineFixedGFX("!FrameIndex,x", "!LastFrameIndex,x", !GFX00, "#ResourceOffset", "#ResourceSize", #$10)
RTS
;>End Dynamic Section

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
    dw $0005,$0006,$0007,$0007,$0005,$0007,$0007,$0007,$0006,$0004,$0006,$0006,$0007,$0006,$0005
	dw $0005,$0006,$0007,$0007,$0005,$0007,$0007,$0007,$0006,$0004,$0006,$0006,$0007,$0006,$0005
;>EndTable


;>Table: FramesFlippers
;>Description: Values used to add values to FramesStartPosition and FramesEndPosition
;To use a flipped version of the frames.
;>ValuesSize: 16
FramesFlippers:
    dw $0000,$001E
;>EndTable


;>Table: FramesStartPosition
;>Description: Indicates the index where starts each frame
;>ValuesSize: 16
FramesStartPosition:
    dw $0005,$000C,$0014,$001C,$0022,$002A,$0032,$003A,$0041,$0046,$004D,$0054,$005C,$0063,$0069
	dw $006F,$0076,$007E,$0086,$008C,$0094,$009C,$00A4,$00AB,$00B0,$00B7,$00BE,$00C6,$00CD,$00D3
;>EndTable

;>Table: FramesEndPosition
;>Description: Indicates the index where end each frame
;>ValuesSize: 16
FramesEndPosition:
    dw $0000,$0006,$000D,$0015,$001D,$0023,$002B,$0033,$003B,$0042,$0047,$004E,$0055,$005D,$0064
	dw $006A,$0070,$0077,$007F,$0087,$008D,$0095,$009D,$00A5,$00AC,$00B1,$00B8,$00BF,$00C7,$00CE
;>EndTable


;>Table: Tiles
;>Description: Tiles codes of each tile of each frame
;>ValuesSize: 8
Tiles:
    
Frame0_Frame0_Tiles:
	db $08,$06,$04,$02,$00,$0A
Frame1_Frame1_Tiles:
	db $0C,$0A,$08,$06,$04,$02,$00
Frame2_Frame2_Tiles:
	db $0A,$08,$06,$04,$02,$0D,$00,$0C
Frame3_Frame3_Tiles:
	db $0C,$0A,$0E,$08,$06,$04,$02,$00
Frame4_Frame4_Tiles:
	db $0A,$08,$06,$04,$02,$00
Frame5_Frame5_Tiles:
	db $0C,$0A,$0E,$08,$06,$04,$02,$00
Frame6_Frame6_Tiles:
	db $0A,$08,$06,$04,$02,$00,$0D,$0C
Frame7_Frame7_Tiles:
	db $08,$0C,$06,$04,$0B,$02,$00,$0A
Frame8_Frame8_Tiles:
	db $0C,$0A,$08,$06,$04,$02,$00
Frame9_Frame9_Tiles:
	db $08,$06,$04,$02,$00
Frame10_Frame10_Tiles:
	db $0C,$0A,$08,$06,$04,$02,$00
Frame11_Frame11_Tiles:
	db $0A,$08,$06,$04,$02,$0C,$00
Frame12_Frame12_Tiles:
	db $0D,$0A,$08,$0C,$06,$04,$02,$00
Frame13_Frame13_Tiles:
	db $0A,$08,$06,$04,$02,$00,$0C
Frame14_Frame14_Tiles:
	db $08,$06,$04,$02,$0A,$00
Frame0_Frame0_TilesFlipX:
	db $08,$06,$04,$02,$00,$0A
Frame1_Frame1_TilesFlipX:
	db $0C,$0A,$08,$06,$04,$02,$00
Frame2_Frame2_TilesFlipX:
	db $0A,$08,$06,$04,$02,$0D,$00,$0C
Frame3_Frame3_TilesFlipX:
	db $0C,$0A,$0E,$08,$06,$04,$02,$00
Frame4_Frame4_TilesFlipX:
	db $0A,$08,$06,$04,$02,$00
Frame5_Frame5_TilesFlipX:
	db $0C,$0A,$0E,$08,$06,$04,$02,$00
Frame6_Frame6_TilesFlipX:
	db $0A,$08,$06,$04,$02,$00,$0D,$0C
Frame7_Frame7_TilesFlipX:
	db $08,$0C,$06,$04,$0B,$02,$00,$0A
Frame8_Frame8_TilesFlipX:
	db $0C,$0A,$08,$06,$04,$02,$00
Frame9_Frame9_TilesFlipX:
	db $08,$06,$04,$02,$00
Frame10_Frame10_TilesFlipX:
	db $0C,$0A,$08,$06,$04,$02,$00
Frame11_Frame11_TilesFlipX:
	db $0A,$08,$06,$04,$02,$0C,$00
Frame12_Frame12_TilesFlipX:
	db $0D,$0A,$08,$0C,$06,$04,$02,$00
Frame13_Frame13_TilesFlipX:
	db $0A,$08,$06,$04,$02,$00,$0C
Frame14_Frame14_TilesFlipX:
	db $08,$06,$04,$02,$0A,$00
;>EndTable

;>Table: XDisplacements
;>Description: X Displacement of each tile of each frame
;>ValuesSize: 8
XDisplacements:
    
Frame0_Frame0_XDisp:
	db $E3,$F0,$F3,$00,$03,$07
Frame1_Frame1_XDisp:
	db $E3,$F0,$F0,$F3,$00,$00,$03
Frame2_Frame2_XDisp:
	db $E4,$F1,$F4,$F5,$01,$03,$04,$08
Frame3_Frame3_XDisp:
	db $E4,$F0,$F1,$F4,$FA,$00,$04,$04
Frame4_Frame4_XDisp:
	db $E4,$F1,$F4,$01,$02,$04
Frame5_Frame5_XDisp:
	db $E4,$F0,$F1,$F4,$FA,$00,$04,$04
Frame6_Frame6_XDisp:
	db $E3,$F1,$F3,$F5,$01,$03,$03,$11
Frame7_Frame7_XDisp:
	db $E3,$F1,$F1,$F3,$00,$01,$03,$03
Frame8_Frame8_XDisp:
	db $EA,$F2,$F4,$FA,$03,$04,$0A
Frame9_Frame9_XDisp:
	db $F3,$FD,$FF,$01,$11
Frame10_Frame10_XDisp:
	db $F1,$F4,$F5,$FA,$04,$05,$0A
Frame11_Frame11_XDisp:
	db $F4,$02,$02,$03,$12,$12,$12
Frame12_Frame12_XDisp:
	db $F6,$FB,$FE,$05,$07,$0B,$0E,$1E
Frame13_Frame13_XDisp:
	db $FD,$02,$0B,$0D,$0D,$1B,$1D
Frame14_Frame14_XDisp:
	db $FF,$00,$0F,$0F,$1F,$1F
Frame0_Frame0_XDispFlipX:
	db $1D,$10,$0D,$00,$FD,$01
Frame1_Frame1_XDispFlipX:
	db $1D,$10,$10,$0D,$00,$00,$FD
Frame2_Frame2_XDispFlipX:
	db $1C,$0F,$0C,$0B,$FF,$05,$FC,$00
Frame3_Frame3_XDispFlipX:
	db $1C,$10,$17,$0C,$06,$00,$FC,$FC
Frame4_Frame4_XDispFlipX:
	db $1C,$0F,$0C,$FF,$FE,$FC
Frame5_Frame5_XDispFlipX:
	db $1C,$10,$17,$0C,$06,$00,$FC,$FC
Frame6_Frame6_XDispFlipX:
	db $1D,$0F,$0D,$0B,$FF,$FD,$05,$F7
Frame7_Frame7_XDispFlipX:
	db $1D,$17,$0F,$0D,$08,$FF,$FD,$05
Frame8_Frame8_XDispFlipX:
	db $16,$0E,$0C,$06,$FD,$FC,$F6
Frame9_Frame9_XDispFlipX:
	db $0D,$03,$01,$FF,$EF
Frame10_Frame10_XDispFlipX:
	db $17,$0C,$0B,$06,$FC,$FB,$F6
Frame11_Frame11_XDispFlipX:
	db $0C,$FE,$FE,$FD,$EE,$F6,$EE
Frame12_Frame12_XDispFlipX:
	db $12,$05,$02,$03,$F9,$F5,$F2,$E2
Frame13_Frame13_XDispFlipX:
	db $03,$FE,$F5,$F3,$F3,$E5,$EB
Frame14_Frame14_XDispFlipX:
	db $01,$00,$F1,$F1,$E9,$E1
;>EndTable
;>Table: YDisplacements
;>Description: Y Displacement of each tile of each frame
;>ValuesSize: 8
YDisplacements:
    
Frame0_Frame0_YDisp:
	db $F8,$07,$FA,$0A,$FA,$F7
Frame1_Frame1_YDisp:
	db $FA,$EF,$08,$FA,$F0,$0A,$00
Frame2_Frame2_YDisp:
	db $00,$07,$F8,$EA,$08,$18,$F9,$F7
Frame3_Frame3_YDisp:
	db $FF,$F0,$0E,$FE,$0B,$F0,$F9,$09
Frame4_Frame4_YDisp:
	db $F8,$06,$FB,$0B,$F6,$00
Frame5_Frame5_YDisp:
	db $01,$EF,$0E,$FE,$0B,$F0,$F9,$09
Frame6_Frame6_YDisp:
	db $02,$07,$F7,$EA,$07,$F7,$17,$08
Frame7_Frame7_YDisp:
	db $02,$EF,$07,$F7,$F0,$07,$F7,$17
Frame8_Frame8_YDisp:
	db $F7,$05,$EC,$FC,$0A,$ED,$FD
Frame9_Frame9_YDisp:
	db $03,$EB,$0A,$FB,$04
Frame10_Frame10_YDisp:
	db $0C,$FD,$EF,$0C,$FF,$F0,$0F
Frame11_Frame11_YDisp:
	db $01,$FD,$0D,$F0,$F6,$06,$0E
Frame12_Frame12_YDisp:
	db $02,$0C,$FD,$1A,$ED,$0D,$FD,$00
Frame13_Frame13_YDisp:
	db $03,$13,$00,$F1,$0E,$06,$FD
Frame14_Frame14_YDisp:
	db $04,$14,$FE,$0E,$00,$09
Frame0_Frame0_YDispFlipX:
	db $F8,$07,$FA,$0A,$FA,$F7
Frame1_Frame1_YDispFlipX:
	db $FA,$EF,$08,$FA,$F0,$0A,$00
Frame2_Frame2_YDispFlipX:
	db $00,$07,$F8,$EA,$08,$18,$F9,$F7
Frame3_Frame3_YDispFlipX:
	db $FF,$F0,$0E,$FE,$0B,$F0,$F9,$09
Frame4_Frame4_YDispFlipX:
	db $F8,$06,$FB,$0B,$F6,$00
Frame5_Frame5_YDispFlipX:
	db $01,$EF,$0E,$FE,$0B,$F0,$F9,$09
Frame6_Frame6_YDispFlipX:
	db $02,$07,$F7,$EA,$07,$F7,$17,$08
Frame7_Frame7_YDispFlipX:
	db $02,$EF,$07,$F7,$F0,$07,$F7,$17
Frame8_Frame8_YDispFlipX:
	db $F7,$05,$EC,$FC,$0A,$ED,$FD
Frame9_Frame9_YDispFlipX:
	db $03,$EB,$0A,$FB,$04
Frame10_Frame10_YDispFlipX:
	db $0C,$FD,$EF,$0C,$FF,$F0,$0F
Frame11_Frame11_YDispFlipX:
	db $01,$FD,$0D,$F0,$F6,$06,$0E
Frame12_Frame12_YDispFlipX:
	db $02,$0C,$FD,$1A,$ED,$0D,$FD,$00
Frame13_Frame13_YDispFlipX:
	db $03,$13,$00,$F1,$0E,$06,$FD
Frame14_Frame14_YDispFlipX:
	db $04,$14,$FE,$0E,$00,$09
;>EndTable
;>Table: Sizes.
;>Description: size of each tile of each frame
;>ValuesSize: 8
Sizes:
    
Frame0_Frame0_Sizes:
	db $02,$02,$02,$02,$02,$00
Frame1_Frame1_Sizes:
	db $02,$02,$02,$02,$02,$02,$02
Frame2_Frame2_Sizes:
	db $02,$02,$02,$02,$02,$00,$02,$00
Frame3_Frame3_Sizes:
	db $02,$02,$00,$02,$02,$02,$02,$02
Frame4_Frame4_Sizes:
	db $02,$02,$02,$02,$02,$02
Frame5_Frame5_Sizes:
	db $02,$02,$00,$02,$02,$02,$02,$02
Frame6_Frame6_Sizes:
	db $02,$02,$02,$02,$02,$02,$00,$00
Frame7_Frame7_Sizes:
	db $02,$00,$02,$02,$00,$02,$02,$00
Frame8_Frame8_Sizes:
	db $02,$02,$02,$02,$02,$02,$02
Frame9_Frame9_Sizes:
	db $02,$02,$02,$02,$02
Frame10_Frame10_Sizes:
	db $00,$02,$02,$02,$02,$02,$02
Frame11_Frame11_Sizes:
	db $02,$02,$02,$02,$02,$00,$02
Frame12_Frame12_Sizes:
	db $00,$02,$02,$00,$02,$02,$02,$02
Frame13_Frame13_Sizes:
	db $02,$02,$02,$02,$02,$02,$00
Frame14_Frame14_Sizes:
	db $02,$02,$02,$02,$00,$02
Frame0_Frame0_SizesFlipX:
	db $02,$02,$02,$02,$02,$00
Frame1_Frame1_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02
Frame2_Frame2_SizesFlipX:
	db $02,$02,$02,$02,$02,$00,$02,$00
Frame3_Frame3_SizesFlipX:
	db $02,$02,$00,$02,$02,$02,$02,$02
Frame4_Frame4_SizesFlipX:
	db $02,$02,$02,$02,$02,$02
Frame5_Frame5_SizesFlipX:
	db $02,$02,$00,$02,$02,$02,$02,$02
Frame6_Frame6_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$00,$00
Frame7_Frame7_SizesFlipX:
	db $02,$00,$02,$02,$00,$02,$02,$00
Frame8_Frame8_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02
Frame9_Frame9_SizesFlipX:
	db $02,$02,$02,$02,$02
Frame10_Frame10_SizesFlipX:
	db $00,$02,$02,$02,$02,$02,$02
Frame11_Frame11_SizesFlipX:
	db $02,$02,$02,$02,$02,$00,$02
Frame12_Frame12_SizesFlipX:
	db $00,$02,$02,$00,$02,$02,$02,$02
Frame13_Frame13_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$00
Frame14_Frame14_SizesFlipX:
	db $02,$02,$02,$02,$00,$02
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

ChangeAnimationFromStart_fly:
	STZ !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_flip:
	LDA #$01
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_dead:
	LDA #$02
	STA !AnimationIndex,x


ChangeAnimationFromStart:
	STZ !AnimationFrameIndex,x

	LDA #$01
	STA $8A

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
	LDA $8A
	BEQ +
RTS
+
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

	LDA Times,y
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
	dw $0008,$0004,$0005

AnimationLastTransition:
	dw $0000,$0003,$0004

AnimationIndexer:
	dw $0000,$0008,$000C

Frames:
	
Animation0_fly_Frames:
	db $00,$01,$02,$03,$04,$05,$06,$07
Animation1_flip_Frames:
	db $08,$09,$09,$08
Animation2_dead_Frames:
	db $0A,$0B,$0C,$0D,$0E

Times:
	
Animation0_fly_Times:
	db $02,$02,$02,$02,$02,$02,$02,$02
Animation1_flip_Times:
	db $02,$02,$02,$02
Animation2_dead_Times:
	db $02,$02,$02,$02,$02

Flips:
	
Animation0_fly_Flips:
	db $00,$00,$00,$00,$00,$00,$00,$00
Animation1_flip_Flips:
	db $00,$00,$01,$01
Animation2_dead_Flips:
	db $00,$00,$00,$00,$00

;>End Animations Section

;Don't Delete or write another >Section Hitbox Interaction or >End Section
;All code between >Section Hitboxes Interaction and >End Hitboxes Interaction Section will be changed by Dyzen : Sprite Maker
;>Section Hitboxes Interaction
;######################################
;######## Interaction Space ###########
;######################################

InteractMarioSprite:

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
    dw $0000,$001E

FrameHitboxesIndexer:
    dw $0000,$0002,$0004,$0006,$0008,$000A,$000C,$000E,$0010,$0012,$0014,$0015,$0016,$0017,$0018
	dw $0019,$001B,$001D,$001F,$0021,$0023,$0025,$0027,$0029,$002B,$002D,$002E,$002F,$0030,$0031

FrameHitBoxes:
    db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $01,$FF
	db $02,$FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	
	db $03,$FF
	db $03,$FF
	db $03,$FF
	db $03,$FF
	db $03,$FF
	db $03,$FF
	db $03,$FF
	db $03,$FF
	db $04,$FF
	db $05,$FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	
Hitboxes:
HitboxType: 
	dw $0001,$0001,$0001,$0001,$0001,$0001
HitboxXOffset: 
	dw $FFF0,$FFF7,$FFFF,$0002,$0002,$0002
HitboxYOffset: 
	dw $0002,$0002,$0002,$0002,$0002,$0002
HitboxWidth: 
	dw $001E,$0017,$000F,$001E,$0017,$000F
HitboxHeight: 
	dw $000E,$000E,$000E,$000E,$000E,$000E
HitboxAction1: 
	dw $0000,$0000,$0000,$0000,$0000,$0000
HitboxAction2: 
	dw $0002,$0002,$0002,$0002,$0002,$0002
	
Actions:
	dw CheckBounce
	dw CheckPlayerIsAbove
	

;This routine will be executed when mario interact with a standar hitbox.
;It will be excecuted if $0E is 1 after execute Interaction routine
DefaultAction:

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

	LDA #$02
	STA !SpriteStatus,x
RTS
+
	LDA !Version,x
	CMP #$04
	BEQ .hurt
	LDA !SpritePlayerIsAbove,x
	BNE +
.hurt
	%DyzenPrepareContactEffect()
	LDA #$01
	%DisplayContactEffect()

	LDA !Version,x
	CMP #$04
	BNE ++
	JSL $00F606|!rom
RTS
++
	%DamagePlayer()
RTS
+	

	LDA !SpinJumpFlag
	BEQ .hurt

	REP #$20
	LDA $6A
	SEC
	SBC $0C
	CLC
	ADC !PlayerY
	STA !PlayerY
	SEP #$20

	%DyzenPrepareContactEffect()
	LDA #$00
	%DisplayContactEffect();JSL $01AB99|!rom    ;Display White Star

	JSL $01AA33|!rom    ;Do the player boost its Y Speed  

	LDA !Version,x
	CMP #$02
	BNE .return

	LDA !GreenMaxTime,x
	STA !GreenTimer,x

.return
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
    
;>End Hitboxes Interaction Section
