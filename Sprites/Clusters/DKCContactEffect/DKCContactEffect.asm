;@DKCContactEffect.bin	
!ResourceIndex = $20
%GFXTabDef(!ResourceIndex)
%GFXDef(00)

;Constant
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
	LDA #$00
	STA !GlobalFlip,x
	JSL InitWrapperChangeAnimationFromStart

	STX $00

	LDY #$13
-

	LDA !ClusterNumber,x
	CMP !ClusterNumber,y
	BNE .next

	CPY $0000|!dp
	BEQ .next

	LDA #$00
	STA !ClusterNumber,y

.next
	DEY
	BPL -

	LDA #$01
	STA !Started,x
	LDA #$FF
	STA !LastFrameIndex,x

	%CheckSlot(#$00, #$07, "!ClusterNumber,x", $20, DZ_DS_Loc_US_Cluster)
    ;Here you can write your Init Code
    ;This will be excecuted when the sprite is spawned 
RTS

;>Routine: SpriteCode
;>Description: This routine excecute the logic of the sprite
;>RoutineLength: Short
SpriteCode:
	LDA !Started,x
	BNE +

	JSR StartRoutine

RTS
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
    ;JSR InteractMarioSprite
    ;After this routine, if the sprite interact with mario, Carry is Set.

	LDA !AnimationFrameIndex,x
	CMP #$0B
	BNE +

	LDA !AnimationTimer,x
	BNE +

	%CheckEvenOrOdd("DZ_DS_Loc_US_Cluster")
	BEQ +

	STZ !ClusterNumber,x

+
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

;Here you can write routines or tables

;>Section Dynamic
;######################################
;########## Animation Space ###########
;######################################
ResourceOffset:
Frame0_ResourceOffset:
	dw $0000,$0080
Frame1_ResourceOffset:
	dw $0100,$0180
Frame2_ResourceOffset:
	dw $0200,$02C0
Frame3_ResourceOffset:
	dw $0340,$0420
Frame4_ResourceOffset:
	dw $04E0,$05E0
Frame5_ResourceOffset:
	dw $06E0,$0820
Frame6_ResourceOffset:
	dw $0920,$0AA0
Frame7_ResourceOffset:
	dw $0BE0,$0D60
Frame8_ResourceOffset:
	dw $0EA0,$1060
Frame9_ResourceOffset:
	dw $1220,$13E0
Frame10_ResourceOffset:
	dw $15A0,$1740
Frame11_ResourceOffset:
	dw $1880,$1A20


ResourceSize:
    Frame0_ResourceSize:
	db $04,$04
Frame1_ResourceSize:
	db $04,$04
Frame2_ResourceSize:
	db $06,$04
Frame3_ResourceSize:
	db $07,$06
Frame4_ResourceSize:
	db $08,$08
Frame5_ResourceSize:
	db $0A,$08
Frame6_ResourceSize:
	db $0C,$0A
Frame7_ResourceSize:
	db $0C,$0A
Frame8_ResourceSize:
	db $0E,$0E
Frame9_ResourceSize:
	db $0E,$0E
Frame10_ResourceSize:
	db $0D,$0A
Frame11_ResourceSize:
	db $0D,$0A


DynamicRoutine:
    
	%EasySpriteDynamicRoutineFixedGFX("DZ_DS_Loc_US_Cluster,x","!FrameIndex,x", "!LastFrameIndex,x", !GFX00, "#ResourceOffset", "#ResourceSize", #$10)
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
	LDA !FrameIndex,x
    STA $45                      ;$06 = Frame Index but in 16bits

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
FramesFlippers:
	dw $0000,$0000

;All words that starts with '@' and finish with '.' will be replaced by Dyzen

;>Table: FramesLengths
;>Description: How many tiles use each frame.
;>ValuesSize: 16
FramesLength:
    dw $0001,$0001,$0003,$0003,$0003,$0005,$0006,$0006,$0006,$0006,$0007,$0007
;>EndTable


;>Table: FramesStartPosition
;>Description: Indicates the index where starts each frame
;>ValuesSize: 16
FramesStartPosition:
    dw $0001,$0003,$0007,$000B,$000F,$0015,$001C,$0023,$002A,$0031,$0039,$0041
;>EndTable

;>Table: FramesEndPosition
;>Description: Indicates the index where end each frame
;>ValuesSize: 16
FramesEndPosition:
    dw $0000,$0002,$0004,$0008,$000C,$0010,$0016,$001D,$0024,$002B,$0032,$003A
;>EndTable


;>Table: Tiles
;>Description: Tiles codes of each tile of each frame
;>ValuesSize: 8
Tiles:
    
Frame0_Frame0_Tiles:
	db $02,$00
Frame1_Frame1_Tiles:
	db $02,$00
Frame2_Frame2_Tiles:
	db $02,$05,$04,$00
Frame3_Frame3_Tiles:
	db $04,$02,$00,$06
Frame4_Frame4_Tiles:
	db $06,$04,$02,$00
Frame5_Frame5_Tiles:
	db $09,$06,$08,$04,$02,$00
Frame6_Frame6_Tiles:
	db $0B,$08,$06,$04,$02,$00,$0A
Frame7_Frame7_Tiles:
	db $08,$0B,$06,$04,$02,$0A,$00
Frame8_Frame8_Tiles:
	db $0C,$0A,$08,$06,$04,$02,$00
Frame9_Frame9_Tiles:
	db $0C,$0A,$08,$06,$04,$02,$00
Frame10_Frame10_Tiles:
	db $0C,$08,$0B,$06,$0A,$04,$02,$00
Frame11_Frame11_Tiles:
	db $08,$0C,$06,$0B,$04,$0A,$02,$00
;>EndTable

;>Table: XDisplacements
;>Description: X Displacement of each tile of each frame
;>ValuesSize: 8
XDisplacements:
    
Frame0_Frame0_XDisp:
	db $03,$FD
Frame1_Frame1_XDisp:
	db $01,$FF
Frame2_Frame2_XDisp:
	db $00,$10,$00,$01
Frame3_Frame3_XDisp:
	db $FD,$0D,$FE,$0C
Frame4_Frame4_XDisp:
	db $F9,$09,$FC,$06
Frame5_Frame5_XDisp:
	db $F6,$FC,$06,$0C,$FA,$07
Frame6_Frame6_XDisp:
	db $F5,$FB,$FD,$0D,$F8,$07,$08
Frame7_Frame7_XDisp:
	db $F5,$FB,$05,$0F,$F9,$09,$09
Frame8_Frame8_XDisp:
	db $F2,$F9,$09,$10,$F7,$07,$0A
Frame9_Frame9_XDisp:
	db $F2,$F9,$09,$13,$F6,$06,$0C
Frame10_Frame10_XDisp:
	db $F1,$F6,$06,$0A,$1A,$F2,$FF,$0F
Frame11_Frame11_XDisp:
	db $F6,$06,$0D,$21,$F1,$FE,$06,$11
;>EndTable
;>Table: YDisplacements
;>Description: Y Displacement of each tile of each frame
;>ValuesSize: 8
YDisplacements:
    
Frame0_Frame0_YDisp:
	db $FD,$05
Frame1_Frame1_YDisp:
	db $08,$01
Frame2_Frame2_YDisp:
	db $08,$02,$00,$FF
Frame3_Frame3_YDisp:
	db $07,$01,$FD,$01
Frame4_Frame4_YDisp:
	db $07,$07,$FB,$FB
Frame5_Frame5_YDisp:
	db $06,$06,$10,$04,$FA,$F6
Frame6_Frame6_YDisp:
	db $06,$0A,$04,$05,$FA,$FD,$F5
Frame7_Frame7_YDisp:
	db $06,$10,$09,$06,$F9,$F4,$FC
Frame8_Frame8_YDisp:
	db $06,$0B,$0B,$06,$F8,$F3,$FB
Frame9_Frame9_YDisp:
	db $06,$13,$0B,$06,$F7,$F3,$FB
Frame10_Frame10_YDisp:
	db $07,$0C,$16,$09,$02,$F7,$EE,$F9
Frame11_Frame11_YDisp:
	db $0B,$16,$08,$00,$F6,$F2,$F2,$FB
;>EndTable
;>Table: Sizes.
;>Description: size of each tile of each frame
;>ValuesSize: 8
Sizes:
    
Frame0_Frame0_Sizes:
	db $02,$02
Frame1_Frame1_Sizes:
	db $02,$02
Frame2_Frame2_Sizes:
	db $02,$00,$00,$02
Frame3_Frame3_Sizes:
	db $02,$02,$02,$00
Frame4_Frame4_Sizes:
	db $02,$02,$02,$02
Frame5_Frame5_Sizes:
	db $00,$02,$00,$02,$02,$02
Frame6_Frame6_Sizes:
	db $00,$02,$02,$02,$02,$02,$00
Frame7_Frame7_Sizes:
	db $02,$00,$02,$02,$02,$00,$02
Frame8_Frame8_Sizes:
	db $02,$02,$02,$02,$02,$02,$02
Frame9_Frame9_Sizes:
	db $02,$02,$02,$02,$02,$02,$02
Frame10_Frame10_Sizes:
	db $00,$02,$00,$02,$00,$02,$02,$02
Frame11_Frame11_Sizes:
	db $02,$00,$02,$00,$02,$00,$02,$02
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
	LDA #$01
	STA !AnimationIndex,x
	JSR ChangeAnimationFromStart
	PLB
	RTL

ChangeAnimationFromStart_open:
	STZ !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_close:
	LDA #$01
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
	dw $000C,$000C

AnimationLastTransition:
	dw $000B,$000B

AnimationIndexer:
	dw $0000,$000C

Frames:
	
Animation0_open_Frames:
	db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B
Animation1_close_Frames:
	db $0B,$0A,$09,$08,$07,$06,$05,$04,$03,$02,$01,$00

Times:
	
Animation0_open_Times:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
Animation1_close_Times:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;>End Animations Section

;Don't Delete or write another >Section Hitbox Interaction or >End Section
;All code between >Section Hitboxes Interaction and >End Hitboxes Interaction Section will be changed by Dyzen : Sprite Maker
;>Section Hitboxes Interaction
;>End Hitboxes Interaction Section
