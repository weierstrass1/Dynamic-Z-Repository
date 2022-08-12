incsrc "DKCVerticalSmokeGFXs.asm"

;######################################
;############## Defines ###############
;######################################

!Started = !ClusterMiscTable1
!FrameIndex = !ClusterMiscTable2
!AnimationTimer = !ClusterMiscTable3
!AnimationIndex = !ClusterMiscTable4
!AnimationFrameIndex = !ClusterMiscTable5
!LocalFlip = !ClusterMiscTable6
!GlobalFlip = !ClusterMiscTable7
!LastFrameIndex = !ClusterMiscTable9

!TimeSpanLow = DZ_DS_Loc_SharedPropertyPerSprite1_Cluster
!TimeSpanHigh = DZ_DS_Loc_SharedPropertyPerSprite2_Cluster

!LastOAM200Slot = $0DDB|!addr

;######################################
;########### Init Routine #############
;######################################
print "INIT ",pc
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

StartRoutine:

	STZ !GlobalFlip,x
	STZ !LocalFlip,x
	LDA #$01
	STA !Started,x
	LDA #$FF
	STA !LastFrameIndex,x

	LDA $1489|!addr
	STA !TimeSpanLow,x
	LDA $1489|!addr+1
	STA !TimeSpanHigh,x

	JSL !CheckClusterSharedDynamicExisted
	BCS +

	JSL InitWrapperChangeAnimationFromStart

	%CheckSlot(#$00, #$07, "!ClusterNumber,x", $A0, DZ_DS_Loc_US_Cluster)

	LDA !ClusterNumber,x
	BEQ ++

	PHX

	LDA DZ_DS_Loc_SharedPropertyPerSprite1_Cluster,x
	PHA
	LDA DZ_DS_Loc_SharedPropertyPerSprite2_Cluster,x
	PHA

	LDA DZ_DS_Loc_US_Cluster,x
	STX $00
	TAX
	LDA #$A0
	ORA $00
	STA DZ_DS_Loc_UsedBy,x
	
	PLA 
	STA DZ_DS_Loc_SharedProperty2,x
	PLA 
	STA DZ_DS_Loc_SharedProperty1,x

	PLX
++
RTS
+
	TAX
	LDA.l DZ_DS_Loc_UsedBy,x
	AND #$1F
	TAY

	LDX !SpriteIndex

	LDA !AnimationIndex,y
	STA !AnimationIndex,x

	LDA !LastFrameIndex,y
	STA !LastFrameIndex,x

	LDA !AnimationTimer,y
	STA !AnimationTimer,x

	LDA !AnimationFrameIndex,y
	STA !AnimationFrameIndex,x

	LDA !FrameIndex,y
	STA !FrameIndex,x
RTS

Return:
	PHX
	LDA.l DZ_DS_Loc_US_Cluster,x
	TAX

	LDA.l DZ_DS_Loc_SharedUpdated,x
	BNE +

	LDA #$01
	STA.l DZ_DS_Loc_SharedUpdated,x

	LDA #$A0
	ORA $01,s
	STA.l DZ_DS_Loc_UsedBy,x
	PLX

	%BroadcastSharedAnimationCluster()
RTS
+
	PLY

	LDX !SpriteIndex
RTS
SpriteCode:

	LDA !Started,x
	BNE +

	JSR StartRoutine
+

	JSR DynamicRoutine

	PHX
	LDA DZ_DS_Loc_US_Cluster,x
	TAX

	LDA DZ_DS_Loc_IsValid,x
	BNE +
	PLX
RTS
+
	PLX
    JSR GraphicRoutine                  ;Calls the graphic routine and updates sprite graphics

    ;Here you can put code that will be excecuted each frame even if the sprite is locked
	LDA !LockAnimationFlag		
	BEQ +		    
	JMP Return

+		
    ;JSR InteractMarioSprite
    ;After this routine, if the sprite interact with mario, Carry is Set.

	LDA !AnimationFrameIndex,x
	CMP #$07
	BCC +

	LDA !AnimationTimer,x
	BNE +

	%CheckEvenOrOdd("DZ_DS_Loc_US_Cluster")
	BEQ +

	STZ !ClusterNumber,x

+
	PHX
	LDA.l DZ_DS_Loc_US_Cluster,x
	TAX

	LDA.l DZ_DS_Loc_SharedUpdated,x
	BNE +

	LDA #$01
	STA.l DZ_DS_Loc_SharedUpdated,x

	LDA #$A0
	ORA $01,s
	STA.l DZ_DS_Loc_UsedBy,x
	PLX

    JSR AnimationRoutine                ;Calls animation routine and decides the next frame to draw
    
	%BroadcastSharedAnimationCluster()
RTS
+
	PLY

	LDX !SpriteIndex

RTS

;>EndRoutine

;######################################
;######## Sub Routine Space ###########
;######################################

;Here you can write routines or tables

;>Section Dynamic
;######################################
;########## Animation Space ###########
;######################################
ResourceOffset:
Frame0_ResourceOffset:
	dw $0000,$0060
Frame1_ResourceOffset:
	dw $00A0,$0160
Frame2_ResourceOffset:
	dw $01E0,$02E0
Frame3_ResourceOffset:
	dw $03E0,$0520
Frame4_ResourceOffset:
	dw $0660,$07E0
Frame5_ResourceOffset:
	dw $0960,$0AE0
Frame6_ResourceOffset:
	dw $0C60,$0DE0
Frame7_ResourceOffset:
	dw $0F20,$0FE0


ResourceSize:
    Frame0_ResourceSize:
	db $03,$02
Frame1_ResourceSize:
	db $06,$04
Frame2_ResourceSize:
	db $08,$08
Frame3_ResourceSize:
	db $0A,$0A
Frame4_ResourceSize:
	db $0C,$0C
Frame5_ResourceSize:
	db $0C,$0C
Frame6_ResourceSize:
	db $0C,$0A
Frame7_ResourceSize:
	db $06,$04

DynamicRoutine:
	PHX
	LDA.l DZ_DS_Loc_US_Cluster,x
	TAX

	LDA DZ_DS_Loc_SharedUpdated,x
	BEQ +
	PLX
RTS
+
	PLX
	%EasySpriteDynamicRoutineFixedGFX("DZ_DS_Loc_US_Cluster,x","!FrameIndex,x", "!LastFrameIndex,x", !GFX00, "#ResourceOffset", "#ResourceSize", #$10)
	PHX
	LDA !LastFrameIndex,x
	PHA
	LDA DZ_DS_Loc_US_Cluster,x
	STX $00
	TAX
	LDA #$A0
	ORA $00
	STA DZ_DS_Loc_UsedBy,x
	PLA
	STA DZ_DS_Loc_SharedFrame,x 

	PLX
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
	LDA !LastFrameIndex,x
	CMP #$FF
	BNE +
	LDA #$01
	STA !Scratch52
RTS
+

	STZ !Scratch52

	%DyzenClusterGetDrawInfo()

	PHX
	LDA #$00
	XBA
	LDA #$00
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
	LDA !maxtile_pointer_high
	STA $49
	LDA !maxtile_pointer_high+2
	STA $4B
	LDA !maxtile_pointer_high+8
	STA $4D
endif
	LDA.w #AnimationTables
	STA $65
	SEP #$20
	LDA.b #AnimationTables>>16
	STA $67

	STZ $46
	PHX
	LDA.l DZ_DS_Loc_US_Cluster,x
	TAX
	LDA.l DZ_DS_Loc_SharedFrame,x
    STA $45                      ;$06 = Frame Index but in 16bits
	PLX

	LDA #$35
	STA $4F

	%GetVramDisp(DZ_DS_Loc_US_Cluster)
	STA !ScratchE

	%DyzenDSGraphicRoutine()

	REP #$20

if !sa1
	LDA $49
	STA !maxtile_pointer_high
	LDA $4B
	STA !maxtile_pointer_high+2
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
    dw $0001,$0003,$0003,$0004,$0005,$0005,$0006,$0003
	dw $0001,$0003,$0003,$0004,$0005,$0005,$0006,$0003
;>EndTable


;>Table: FramesFlippers
;>Description: Values used to add values to FramesStartPosition and FramesEndPosition
;To use a flipped version of the frames.
;>ValuesSize: 16
FramesFlippers:
    dw $0000,$0000,$0010
;>EndTable


;>Table: FramesStartPosition
;>Description: Indicates the index where starts each frame
;>ValuesSize: 16
FramesStartPosition:
    dw $0001,$0005,$0009,$000E,$0014,$001A,$0021,$0025
	dw $0027,$002B,$002F,$0034,$003A,$0040,$0047,$004B
;>EndTable

;>Table: FramesEndPosition
;>Description: Indicates the index where end each frame
;>ValuesSize: 16
FramesEndPosition:
    dw $0000,$0002,$0006,$000A,$000F,$0015,$001B,$0022
	dw $0026,$0028,$002C,$0030,$0035,$003B,$0041,$0048
;>EndTable


;>Table: Tiles
;>Description: Tiles codes of each tile of each frame
;>ValuesSize: 8
Tiles:
    
Frame0_Frame0_Tiles:
	db $02,$00
Frame1_Frame1_Tiles:
	db $02,$05,$00,$04
Frame2_Frame2_Tiles:
	db $06,$04,$02,$00
Frame3_Frame3_Tiles:
	db $08,$06,$04,$02,$00
Frame4_Frame4_Tiles:
	db $0A,$08,$06,$04,$02,$00
Frame5_Frame5_Tiles:
	db $0A,$08,$04,$06,$02,$00
Frame6_Frame6_Tiles:
	db $0B,$08,$06,$04,$02,$00,$0A
Frame7_Frame7_Tiles:
	db $02,$00,$05,$04
Frame0_Frame0_TilesFlipY:
	db $02,$00
Frame1_Frame1_TilesFlipY:
	db $02,$05,$00,$04
Frame2_Frame2_TilesFlipY:
	db $06,$04,$02,$00
Frame3_Frame3_TilesFlipY:
	db $08,$06,$04,$02,$00
Frame4_Frame4_TilesFlipY:
	db $0A,$08,$06,$04,$02,$00
Frame5_Frame5_TilesFlipY:
	db $0A,$08,$04,$06,$02,$00
Frame6_Frame6_TilesFlipY:
	db $0B,$08,$06,$04,$02,$00,$0A
Frame7_Frame7_TilesFlipY:
	db $02,$00,$05,$04
;>EndTable

;>Table: XDisplacements
;>Description: X Displacement of each tile of each frame
;>ValuesSize: 8
XDisplacements:
    
Frame0_Frame0_XDisp:
	db $FE,$03
Frame1_Frame1_XDisp:
	db $FA,$01,$0A,$0B
Frame2_Frame2_XDisp:
	db $F7,$FF,$07,$0F
Frame3_Frame3_XDisp:
	db $F6,$F7,$06,$07,$16
Frame4_Frame4_XDisp:
	db $F2,$F3,$02,$03,$12,$13
Frame5_Frame5_XDisp:
	db $F0,$F0,$00,$00,$10,$10
Frame6_Frame6_XDisp:
	db $EF,$F0,$F7,$00,$07,$16,$16
Frame7_Frame7_XDisp:
	db $EF,$FF,$0F,$1A
Frame0_Frame0_XDispFlipY:
	db $FE,$03
Frame1_Frame1_XDispFlipY:
	db $FA,$01,$0A,$0B
Frame2_Frame2_XDispFlipY:
	db $F7,$FF,$07,$0F
Frame3_Frame3_XDispFlipY:
	db $F6,$F7,$06,$07,$16
Frame4_Frame4_XDispFlipY:
	db $F2,$F3,$02,$03,$12,$13
Frame5_Frame5_XDispFlipY:
	db $F0,$F0,$00,$00,$10,$10
Frame6_Frame6_XDispFlipY:
	db $EF,$F0,$F7,$00,$07,$16,$16
Frame7_Frame7_XDispFlipY:
	db $EF,$FF,$0F,$1A
;>EndTable
;>Table: YDisplacements
;>Description: Y Displacement of each tile of each frame
;>ValuesSize: 8
YDisplacements:
    
Frame0_Frame0_YDisp:
	db $04,$01
Frame1_Frame1_YDisp:
	db $FF,$0F,$FF,$0F
Frame2_Frame2_YDisp:
	db $FD,$05,$FD,$05
Frame3_Frame3_YDisp:
	db $06,$FB,$08,$FD,$05
Frame4_Frame4_YDisp:
	db $06,$FA,$09,$F9,$08,$FB
Frame5_Frame5_YDisp:
	db $F9,$09,$F9,$09,$FD,$0D
Frame6_Frame6_YDisp:
	db $00,$08,$FA,$09,$FB,$04,$14
Frame7_Frame7_YDisp:
	db $04,$FE,$00,$0B
Frame0_Frame0_YDispFlipY:
	db $04,$FF
Frame1_Frame1_YDispFlipY:
	db $01,$F9,$01,$F9
Frame2_Frame2_YDispFlipY:
	db $03,$FB,$03,$FB
Frame3_Frame3_YDispFlipY:
	db $FA,$05,$F8,$03,$FB
Frame4_Frame4_YDispFlipY:
	db $FA,$06,$F7,$07,$F8,$05
Frame5_Frame5_YDispFlipY:
	db $07,$F7,$07,$F7,$03,$F3
Frame6_Frame6_YDispFlipY:
	db $08,$F8,$06,$F7,$05,$FC,$F4
Frame7_Frame7_YDispFlipY:
	db $FC,$02,$08,$FD
;>EndTable
;>Table: Sizes.
;>Description: size of each tile of each frame
;>ValuesSize: 8
Sizes:
    
Frame0_Frame0_Sizes:
	db $00,$02
Frame1_Frame1_Sizes:
	db $02,$00,$02,$00
Frame2_Frame2_Sizes:
	db $02,$02,$02,$02
Frame3_Frame3_Sizes:
	db $02,$02,$02,$02,$02
Frame4_Frame4_Sizes:
	db $02,$02,$02,$02,$02,$02
Frame5_Frame5_Sizes:
	db $02,$02,$02,$02,$02,$02
Frame6_Frame6_Sizes:
	db $00,$02,$02,$02,$02,$02,$00
Frame7_Frame7_Sizes:
	db $02,$02,$00,$00
Frame0_Frame0_SizesFlipY:
	db $00,$02
Frame1_Frame1_SizesFlipY:
	db $02,$00,$02,$00
Frame2_Frame2_SizesFlipY:
	db $02,$02,$02,$02
Frame3_Frame3_SizesFlipY:
	db $02,$02,$02,$02,$02
Frame4_Frame4_SizesFlipY:
	db $02,$02,$02,$02,$02,$02
Frame5_Frame5_SizesFlipY:
	db $02,$02,$02,$02,$02,$02
Frame6_Frame6_SizesFlipY:
	db $00,$02,$02,$02,$02,$02,$00
Frame7_Frame7_SizesFlipY:
	db $02,$02,$00,$00
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

ChangeAnimationFromStart_Animation0:
	STZ !AnimationIndex,x
	JMP ChangeAnimationFromStart


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

	LDA !Scratch2
	STA !AnimationFrameIndex,x

	SEP #$10						;X/Y of 8 bits
	LDX !Scratch4					;X = sprite index in 8 bits
RTS
	

;>Routine: AnimationRoutine
;>Description: Decides what will be the next frame.
;>RoutineLength: Short
AnimationRoutine:
	%CheckEvenOrOdd("DZ_DS_Loc_US_Cluster")
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

	LDA !Scratch2
	STA !AnimationFrameIndex,x

	SEP #$10						;X/Y of 8 bits
	LDX !Scratch4					;X = sprite index in 8 bits
RTS
;>EndRoutine

;All words that starts with '>' and finish with '.' will be replaced by Dyzen

AnimationLenght:
	dw $0008

AnimationLastTransition:
	dw $0000

AnimationIndexer:
	dw $0000

Frames:
	
Animation0_Animation0_Frames:
	db $00,$01,$02,$03,$04,$05,$06,$07

Times:
	
Animation0_Animation0_Times:
	db $02,$02,$02,$02,$02,$02,$02,$02
;>End Animations Section

;Don't Delete or write another >Section Hitbox Interaction or >End Section
;All code between >Section Hitboxes Interaction and >End Hitboxes Interaction Section will be changed by Dyzen : Sprite Maker
;>Section Hitboxes Interaction
;>End Hitboxes Interaction Section













































