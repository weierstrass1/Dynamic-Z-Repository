;@DKCExplosion.bin,DKCExplosionPal.bin
!ResourceIndex = $21
%GFXTabDef(!ResourceIndex)
%GFXDef(00)
%GFXDef(01)

!ExplosionSFX = $38
!ExplosionSFXAddress = $1DFC|!addr

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
!Pal = !ClusterPal
!LoadPal = !ClusterLoadPal
!ExplosionCounter = !ClusterMiscTable10
!ExplosionFlag = !ClusterMiscTable11

!TimeSpanLow = DZ_DS_Loc_SharedPropertyPerSprite1_Cluster
!TimeSpanHigh = DZ_DS_Loc_SharedPropertyPerSprite2_Cluster

!LastOAM200Slot = $0DDB|!addr


;######################################
;########### Init Routine #############
;######################################
StartRoutine:
	LDA #$01
	STA !LoadPal,x
	STA !Started,x
	LDA !Pal,x
	ASL
	STA !Pal,x


	LDA #$FF
	STA !LastFrameIndex,x

	LDA #$00
	STA !GlobalFlip,x

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

    ;Here you can write your Init Code
    ;This will be excecuted when the sprite is spawned 
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

;######################################
;########## Main Routine ##############
;######################################
print "INIT ",pc
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

RTS
+
	PHX
	JSR DynamicRoutine

	LDA DZ_DS_Loc_US_Cluster,x
	TAX

	LDA DZ_DS_Loc_IsValid,x
	BNE +
	PLX
RTS
+
	PLX
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

	LDA.b #!GFX01
	STA !Scratch1
	LDA.b #!GFX01>>8
	STA !Scratch2
	LDA.b #!GFX01>>16
	STA !Scratch3

	LDA #!ExplosionSFX
	%PlaySound()

	PHX
	%TransferToCGRAM(!Scratch0, !Scratch1, !Scratch3, #$001E)
	PLX
+
    JSR GraphicRoutine                  ;Calls the graphic routine and updates sprite graphics

    ;Here you can put code that will be excecuted each frame even if the sprite is locked

	LDA !LockAnimationFlag				    
	BEQ +
	JMP Return			                    ;if locked animation return.
+
	JSR InteractionSpriteClusterSprite
    JSR InteractMarioSprite
    ;After this routine, if the sprite interact with mario, Carry is Set.

	LDA !AnimationFrameIndex,x
	CMP #$0E
	BCC +

	LDA !AnimationTimer,x
	BNE +

	%CheckEvenOrOdd("DZ_DS_Loc_US_Cluster")
	BEQ +								;/

	STZ !ClusterNumber,x
RTS
+

	JSR SpawnExplosion
    ;Here you can write your sprite code routine
    ;This will be excecuted once per frame excepts when 
    ;the animation is locked or when sprite status is not #$08

	PHX
	LDA.l DZ_DS_Loc_US_Cluster,x
	TAX

	LDA.l DZ_DS_Loc_SharedUpdated,x
	BNE +

	LDA #$01
	STA.l DZ_DS_Loc_SharedUpdated,x

	LDA.l DZ_DS_Loc_UsedBy,x
	AND #$E0
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
SpawnExplosion:

	LDA !TrueFrameCounter
	AND #$0F
	BEQ +
RTS
+
	LDA !ExplosionCounter,x
	BNE +
RTS
+
	LDA !ExplosionFlag,x
	AND #$01
	BEQ +
RTS
+
	LDA #$00
	XBA
	LDA DZ_DS_TotalDataSentOdd
	CLC
	ADC #$1C
	REP #$20
	ASL
	ASL
	ASL
	ASL
	ASL
	CMP DZ_MaxDataPerFrame
	SEP #$20
	BEQ +
	BCC +

	LDA #$00
	XBA
	LDA DZ_DS_TotalDataSentEven
	CLC
	ADC #$1C
	REP #$20
	ASL
	ASL
	ASL
	ASL
	ASL
	CMP DZ_MaxDataPerFrame
	SEP #$20
	BEQ +
	BCC +
RTS
+
	LDA #$20
	%Random()
	SEC 
	SBC #$10
	PHA 

	LDA #$20
	%Random()
	SEC 
	SBC #$10
	PHA 

	LDA !ClusterXLow,x
	STA $00
	LDA !ClusterXHigh,x
	STA $01

	LDA !ClusterYLow,x
	STA $02
	LDA !ClusterYHigh,x
	STA $03

	PLA
	STA $04

	PLA
	STA $05

	LDA !ClusterNumber,x
	%SpawnCluster()
	BCC +

	PHX

	LDA !Pal,x
	LSR
	PHA

	LDA !ExplosionFlag,x
	PHA
	ORA #$01
	STA !ExplosionFlag,x

	LDA !ExplosionCounter,x
	DEC A
	STA !ExplosionCounter,x
	TYX
	STA !ExplosionCounter,x

	LDA $1489|!addr
	STA !TimeSpanLow,x
	LDA $1489|!addr+1
	STA !TimeSpanHigh,x

	PLA
	STA !ExplosionFlag,x

	PLA
	STA !Pal,x

	LDA #$00
	STA !Started,x

	PLX

+
RTS

;>Section Dynamic
;######################################
;########## Animation Space ###########
;######################################
ResourceOffset:
Frame0_ResourceOffset:
	dw $0000,$0040
Frame1_ResourceOffset:
	dw $0080,$0140
Frame2_ResourceOffset:
	dw $0200,$02E0
Frame3_ResourceOffset:
	dw $03A0,$04A0
Frame4_ResourceOffset:
	dw $05A0,$06A0
Frame5_ResourceOffset:
	dw $07A0,$08C0
Frame6_ResourceOffset:
	dw $09C0,$0B20
Frame7_ResourceOffset:
	dw $0C60,$0DC0
Frame8_ResourceOffset:
	dw $0F00,$10A0
Frame9_ResourceOffset:
	dw $1220,$13E0
Frame10_ResourceOffset:
	dw $1560,$1720
Frame11_ResourceOffset:
	dw $18A0,$1A20
Frame12_ResourceOffset:
	dw $1BA0,$1D00
Frame13_ResourceOffset:
	dw $1E40,$1F40
Frame14_ResourceOffset:
	dw $2040,$2120


ResourceSize:
Frame0_ResourceSize:
	db $02,$02
Frame1_ResourceSize:
	db $06,$06
Frame2_ResourceSize:
	db $07,$06
Frame3_ResourceSize:
	db $08,$08
Frame4_ResourceSize:
	db $08,$08
Frame5_ResourceSize:
	db $09,$08
Frame6_ResourceSize:
	db $0B,$0A
Frame7_ResourceSize:
	db $0B,$0A
Frame8_ResourceSize:
	db $0D,$0C
Frame9_ResourceSize:
	db $0E,$0C
Frame10_ResourceSize:
	db $0E,$0C
Frame11_ResourceSize:
	db $0C,$0C
Frame12_ResourceSize:
	db $0B,$0A
Frame13_ResourceSize:
	db $08,$08
Frame14_ResourceSize:
	db $07,$06


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
	PHX
	LDA.l DZ_DS_Loc_US_Cluster,x
	TAX
	LDA.l DZ_DS_Loc_SharedFrame,x
    STA $45                      ;$06 = Frame Index but in 16bits
	PLX

	LDA #$21
	ORA !Pal,x
	STA $4F

	%GetVramDisp(DZ_DS_Loc_US_Cluster)
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

;All words that starts with '@' and finish with '.' will be replaced by Dyzen
FramesFlippers:
	dw $0000,$0000,$0000,$0000
;>Table: FramesLengths
;>Description: How many tiles use each frame.
;>ValuesSize: 16
FramesLength:
    dw $0000,$0002,$0003,$0003,$0003,$0004,$0005,$0005,$0006,$0007,$0007,$0005,$0005,$0003,$0003
;>EndTable


;>Table: FramesStartPosition
;>Description: Indicates the index where starts each frame
;>ValuesSize: 16
FramesStartPosition:
    dw $0000,$0003,$0007,$000B,$000F,$0014,$001A,$0020,$0027,$002F,$0037,$003D,$0043,$0047,$004B
;>EndTable

;>Table: FramesEndPosition
;>Description: Indicates the index where end each frame
;>ValuesSize: 16
FramesEndPosition:
    dw $0000,$0001,$0004,$0008,$000C,$0010,$0015,$001B,$0021,$0028,$0030,$0038,$003E,$0044,$0048
;>EndTable


;>Table: Tiles
;>Description: Tiles codes of each tile of each frame
;>ValuesSize: 8
Tiles:
    
Frame0_Frame0_Tiles:
	db $00
Frame1_Frame1_Tiles:
	db $04,$02,$00
Frame2_Frame2_Tiles:
	db $04,$06,$02,$00
Frame3_Frame3_Tiles:
	db $06,$04,$00,$02
Frame4_Frame4_Tiles:
	db $06,$04,$02,$00
Frame5_Frame5_Tiles:
	db $06,$04,$02,$00,$08
Frame6_Frame6_Tiles:
	db $0A,$08,$06,$04,$02,$00
Frame7_Frame7_Tiles:
	db $08,$0A,$06,$04,$00,$02
Frame8_Frame8_Tiles:
	db $0A,$08,$06,$04,$0C,$02,$00
Frame9_Frame9_Tiles:
	db $0A,$08,$0D,$06,$04,$0C,$00,$02
Frame10_Frame10_Tiles:
	db $0A,$08,$0D,$06,$04,$0C,$00,$02
Frame11_Frame11_Tiles:
	db $0A,$08,$06,$04,$00,$02
Frame12_Frame12_Tiles:
	db $0A,$08,$06,$04,$00,$02
Frame13_Frame13_Tiles:
	db $06,$04,$00,$02
Frame14_Frame14_Tiles:
	db $04,$06,$02,$00
;>EndTable

;>Table: XDisplacements
;>Description: X Displacement of each tile of each frame
;>ValuesSize: 8
XDisplacements:
    
Frame0_Frame0_XDisp:
	db $00
Frame1_Frame1_XDisp:
	db $FD,$01,$04
Frame2_Frame2_XDisp:
	db $FC,$FE,$04,$05
Frame3_Frame3_XDisp:
	db $FA,$FC,$04,$06
Frame4_Frame4_XDisp:
	db $F9,$FB,$08,$08
Frame5_Frame5_XDisp:
	db $F7,$FA,$07,$0A,$12
Frame6_Frame6_XDisp:
	db $F4,$F5,$F7,$05,$07,$0C
Frame7_Frame7_XDisp:
	db $F4,$F5,$FD,$04,$0C,$0C
Frame8_Frame8_XDisp:
	db $F3,$F4,$FF,$03,$03,$0B,$0D
Frame9_Frame9_XDisp:
	db $F2,$F2,$FD,$02,$02,$09,$0C,$0F
Frame10_Frame10_XDisp:
	db $F1,$F4,$FF,$01,$01,$0B,$0C,$10
Frame11_Frame11_XDisp:
	db $F2,$F5,$02,$02,$0D,$0F
Frame12_Frame12_XDisp:
	db $F2,$F5,$04,$05,$0E,$0F
Frame13_Frame13_XDisp:
	db $FA,$FB,$04,$07
Frame14_Frame14_XDisp:
	db $FA,$FB,$03,$06
;>EndTable
;>Table: YDisplacements
;>Description: Y Displacement of each tile of each frame
;>ValuesSize: 8
YDisplacements:
    
Frame0_Frame0_YDisp:
	db $01
Frame1_Frame1_YDisp:
	db $FD,$05,$01
Frame2_Frame2_YDisp:
	db $FB,$0B,$07,$01
Frame3_Frame3_YDisp:
	db $FB,$07,$0D,$FD
Frame4_Frame4_YDisp:
	db $FA,$08,$FC,$0C
Frame5_Frame5_YDisp:
	db $F9,$09,$FA,$09,$02
Frame6_Frame6_YDisp:
	db $04,$F9,$09,$F9,$09,$FC
Frame7_Frame7_YDisp:
	db $F9,$09,$09,$F9,$FB,$09
Frame8_Frame8_YDisp:
	db $F8,$08,$0B,$F8,$08,$08,$F9
Frame9_Frame9_YDisp:
	db $F7,$07,$13,$F7,$07,$12,$07,$F7
Frame10_Frame10_YDisp:
	db $F8,$08,$13,$F7,$07,$12,$07,$F7
Frame11_Frame11_YDisp:
	db $FA,$0A,$F8,$08,$08,$F8
Frame12_Frame12_YDisp:
	db $00,$03,$FB,$06,$0B,$FB
Frame13_Frame13_YDisp:
	db $FC,$07,$0D,$FD
Frame14_Frame14_YDisp:
	db $FF,$0C,$07,$FA
;>EndTable
;>Table: Sizes.
;>Description: size of each tile of each frame
;>ValuesSize: 8
Sizes:
    
Frame0_Frame0_Sizes:
	db $02
Frame1_Frame1_Sizes:
	db $02,$02,$02
Frame2_Frame2_Sizes:
	db $02,$00,$02,$02
Frame3_Frame3_Sizes:
	db $02,$02,$02,$02
Frame4_Frame4_Sizes:
	db $02,$02,$02,$02
Frame5_Frame5_Sizes:
	db $02,$02,$02,$02,$00
Frame6_Frame6_Sizes:
	db $00,$02,$02,$02,$02,$02
Frame7_Frame7_Sizes:
	db $02,$00,$02,$02,$02,$02
Frame8_Frame8_Sizes:
	db $02,$02,$02,$02,$00,$02,$02
Frame9_Frame9_Sizes:
	db $02,$02,$00,$02,$02,$00,$02,$02
Frame10_Frame10_Sizes:
	db $02,$02,$00,$02,$02,$00,$02,$02
Frame11_Frame11_Sizes:
	db $02,$02,$02,$02,$02,$02
Frame12_Frame12_Sizes:
	db $00,$02,$02,$02,$02,$02
Frame13_Frame13_Sizes:
	db $02,$02,$02,$02
Frame14_Frame14_Sizes:
	db $02,$00,$02,$02
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

ChangeAnimationFromStart_Explosion:
	STZ !AnimationIndex,x


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
	dw $000F

AnimationLastTransition:
	dw $000E

AnimationIndexer:
	dw $0000

Frames:
	
Animation0_Explosion_Frames:
	db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E

Times:
	
Animation0_Explosion_Times:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;>End Animations Section

;Don't Delete or write another >Section Hitbox Interaction or >End Section
;All code between >Section Hitboxes Interaction and >End Hitboxes Interaction Section will be changed by Dyzen : Sprite Maker
;>Section Hitboxes Interaction
;######################################
;######## Interaction Space ###########
;######################################

InteractionSpriteClusterSprite:
	LDA !ExplosionFlag,x
	AND #$02
	BNE +
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

	LDX #!MaxSprites-1
-
	LDA !SpriteStatus,x
	CMP #$08
	BNE .next

	PHX

	STZ $6A

	LDA.b #HitboxTables
	STA $8A
	LDA.b #HitboxTables>>8
	STA $8B
	LDA.b #HitboxTables>>16
	STA $8C

	%DyzenClusterSpriteNormalSpriteInteraction()
	BCC +

	JSR DefaultSPRInteraction
	PLX
	LDX !SpriteIndex
RTS
+
    LDX !SpriteIndex
	STZ $4A
    LDA !FrameIndex,x		;A 16 bits frame index
	STA $49
	PLX
.next 
	DEX
	BPL -

	LDX !SpriteIndex
RTS

DefaultSPRInteraction:

	LDA $03,s
	TAX

	LDA !SpriteActionFlag,x
	ORA #$09
	STA !SpriteActionFlag,x

	LDX !SpriteIndex
	%DyzenPrepareContactEffect()
	LDA #$01
	%DisplayContactEffect()
RTS

InteractMarioSprite:
	LDA !ExplosionFlag,x
	AND #$04
	BNE +
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

	%DyzenPlayerClusterSpriteInteraction()
	BCC +

	JSR DefaultAction
+
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
    dw $0000,$0002,$0004,$0007,$000A,$000D,$0010,$0013,$0016,$0019,$001C,$001E,$0020,$0022,$0024
	dw $0025,$0027,$0029,$002C,$002F,$0032,$0035,$0038,$003B,$003E,$0041,$0043,$0045,$0047,$0049

FrameHitBoxes:
    db $00,$FF
	db $01,$FF
	db $02,$03,$FF
	db $04,$05,$FF
	db $06,$07,$FF
	db $08,$09,$FF
	db $0A,$0B,$FF
	db $0C,$0D,$FF
	db $0E,$0F,$FF
	db $10,$11,$FF
	db $12,$FF
	db $13,$FF
	db $14,$FF
	db $15,$FF
	db $FF
	
	db $16,$FF
	db $17,$FF
	db $18,$19,$FF
	db $1A,$1B,$FF
	db $1C,$1D,$FF
	db $1E,$1F,$FF
	db $20,$21,$FF
	db $22,$23,$FF
	db $24,$25,$FF
	db $26,$27,$FF
	db $28,$FF
	db $29,$FF
	db $2A,$FF
	db $2B,$FF
	db $FF
	
Hitboxes:
HitboxType: 
	dw $0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dw $0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dw $0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
HitboxXOffset: 
	dw $0002,$0002,$FFFD,$0004,$FFFD,$0002,$FFFC,$0002,$FFFA,$0000,$FFF8,$FFFE,$FFF8,$FFFF,$FFF7,$FFFE
	dw $FFF5,$FFFD,$FFF6,$FFFB,$0007,$FFFE,$0003,$0003,$0008,$FFFE,$0008,$FFFE,$0008,$FFFD,$0007,$FFFF
	dw $FFFB,$0002,$FFF8,$0001,$FFF8,$0002,$FFF8,$0003,$FFF6,$FFF6,$FFF7,$FFFF
HitboxYOffset: 
	dw $0002,$FFFF,$FFFD,$0004,$FFFC,$0003,$FFFB,$0002,$FFFB,$0000,$FFFD,$0010,$FFFC,$000F,$FFFB,$000E
	dw $FFF9,$000C,$FFFA,$FFFD,$FFFF,$0000,$0002,$FFFF,$FFFD,$0004,$FFFC,$0003,$FFFB,$0002,$FFFB,$0000
	dw $FFFD,$0010,$FFFC,$000F,$FFFB,$000E,$FFF9,$000C,$FFFA,$FFFD,$FFFF,$0000
HitboxWidth: 
	dw $000B,$000B,$000B,$000E,$000B,$0010,$000C,$0011,$000F,$0011,$001D,$0010,$0020,$0010,$0021,$0010
	dw $0023,$0010,$0024,$001F,$0012,$0013,$000B,$000B,$000B,$000E,$000B,$0010,$000C,$0011,$000F,$0011
	dw $001D,$0010,$0020,$0010,$0021,$0010,$0023,$0010,$0024,$001F,$0012,$0013
HitboxHeight: 
	dw $000D,$0013,$000E,$0010,$0013,$0010,$0015,$0015,$0015,$0017,$0013,$0008,$0013,$0009,$0013,$000A
	dw $0013,$000D,$0013,$0013,$0013,$0013,$000D,$0013,$000E,$0010,$0013,$0010,$0015,$0015,$0015,$0017
	dw $0013,$0008,$0013,$0009,$0013,$000A,$0013,$000D,$0013,$0013,$0013,$0013
HitboxAction1: 
	dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
HitboxAction2: 
	dw $0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002
	dw $0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002
	dw $0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002
	

;This routine will be executed when mario interact with a standar hitbox.
;It will be excecuted if $0E is 1 after execute Interaction routine
Actions:
	dw CheckBounce
	dw Nothing
	

;This routine will be executed when mario interact with a standar hitbox.
;It will be excecuted if $0E is 1 after execute Interaction routine
DefaultAction:

	%DyzenPrepareContactEffect()
	LDA #$01
	%DisplayContactEffect()
	%DamagePlayer()

RTS                 ;Return


;$65		;Hitbox Direction
;$66		;Top
;$68		;Distance
;$6A		;Bounce Top
CheckBounce:
	%DyzenCheckBounce()
RTL

Nothing:
RTL
