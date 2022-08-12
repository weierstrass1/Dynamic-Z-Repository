;@KlumpGrenade.bin	
!ResourceIndex = $27
%GFXTabDef(!ResourceIndex)
%GFXDef(00)

!ExplosionID = $01

;######################################
;############## Defines ###############
;######################################

!FrameIndex = !ExtendedMiscTable1
!AnimationTimer = !ExtendedMiscTable2
!AnimationIndex = !ExtendedAnimationIndex
!AnimationFrameIndex = !ExtendedAnimationFrameIndex
!LocalFlip = !ExtendedLocalFlip
!GlobalFlip = !ExtendedGlobalFlip
!Started = !ExtendedStarted
!LastFrameIndex = !ExtendedLastFrameIndex
!Pal = !ExtendedPal
!ExplosionTimer = !ExtendedMiscTable3
!Blocked = !ExtendedMiscTable4
!ExpPal = !ExtendedMiscTable5

!LastOAM200Slot = $0DDB|!addr

;######################################
;########### Init Routine #############
;######################################
StartRoutine:
	LDA #$00
	STA !Blocked,x
	STA !LocalFlip,x
	JSL InitWrapperChangeAnimationFromStart

	LDA #$FF
	STA !LastFrameIndex,x
	LDA #$01
	STA !Started,x

	%CheckSlot(#$00, #$07, "!ExtendedSpriteNumber,x", $40, DZ_DS_Loc_US_Extended)
    ;Here you can write your Init Code
    ;This will be excecuted when the sprite is spawned 
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
RTS
SpriteCode:
	LDA !Started,x
	BNE +

	JSR StartRoutine

RTS
+
	JSR DynamicRoutine

	PHX
	LDA DZ_DS_Loc_US_Extended,x
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
	BNE Return			                    ;if locked animation return.

    ;JSR InteractMarioSprite
    ;After this routine, if the sprite interact with mario, Carry is Set.
	LDA !Blocked,x
	BNE +

	LDA #$00
	%Speed()
	%SpeedX()

	JSR BlockInteraction
	BRA ++
+
	LDA !AnimationIndex,x
	BNE ++

	%CheckEvenOrOdd("DZ_DS_Loc_US_Extended")
	BEQ ++

	JSR ChangeAnimationFromStart_fall
++
    ;Here you can write your sprite code routine
    ;This will be excecuted once per frame excepts when 
    ;the animation is locked or when sprite status is not #$08

    JSR AnimationRoutine                ;Calls animation routine and decides the next frame to draw
    
	LDA !ExplosionTimer,x
	BEQ +
	DEC A
	STA !ExplosionTimer,x
	BRA Return
+

	PHX
	LDA DZ_DS_Loc_US_Extended,x
	TAX
	LDA DZ_Timer
	DEC A
	STA DZ_DS_Loc_SafeFrame,x
	PLX

	LDA !ExtendedXLow,x
	STA !Scratch0

	LDA !ExtendedXHigh,x
	STA !Scratch1

	LDA !ExtendedYLow,x
	STA !Scratch2

	LDA !ExtendedYHigh,x
	STA !Scratch3

	STZ $04
	LDA #$F0
	STA $05
	LDA #!ExplosionID
	CLC
	ADC #!ClusterOffset 
	%SpawnCluster()
	BCC +

	STZ !ExtendedSpriteNumber,x
	
	LDA #$00
	STA !ClusterMiscTable1,y
	PHX
	LDA !ExpPal,x
	TYX
	STA !ClusterPal,x
	LDA #$04
	STA !ClusterMiscTable11,x
	LDA #$00
	STA !ClusterMiscTable10,x
	PLX
+
RTS

;>EndRoutine

;######################################
;######## Sub Routine Space ###########
;######################################

;Here you can write routines or tables
BlockInteraction:

	LDA !ExtendedYSpeed,x
	BPL +
RTS
+

	PHK                       ;\This will push the 24-bit address location
	PEA.w .jslrtsreturn-1     ;/after the JML (below) into the stack*
	PEA $A772-1               ;>This modifies the RTS in the pointed routine (below) to jump to an RTL in same bank.*
                                  ;^This RTL then pulls the stack (which is the 24-bit address) to jump to a location after the JML
	JML $02A56E               ;>The desired routine that ends with RTS

.jslrtsreturn
	LDA $0E
	BEQ +

	LDA !ExtendedYSpeed,x
	LSR
	CMP #$08
	BCC ++

	EOR #$FF
	INC A
	STA !ExtendedYSpeed,x
RTS

++
	STZ !ExtendedYSpeed,x
	LDA #$01
	STA !Blocked,x

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
	dw $0080,$00C0
Frame2_ResourceOffset:
	dw $0100,$0140
Frame3_ResourceOffset:
	dw $0180,$01C0


ResourceSize:
Frame0_ResourceSize:
	db $02,$02
Frame1_ResourceSize:
	db $02,$02
Frame2_ResourceSize:
	db $02,$02
Frame3_ResourceSize:
	db $02,$02

DynamicRoutine:
    
	%EasySpriteDynamicRoutineFixedGFX("DZ_DS_Loc_US_Extended,x","!FrameIndex,x", "!LastFrameIndex,x", !GFX00, "#ResourceOffset", "#ResourceSize", #$10)
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

	%DyzenExtendedGetDrawInfo()

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
    STA $45                      ;$06 = Frame Index but in 16bits

	LDA #$21
	ORA !Pal,x
	STA $4F

	%GetVramDisp(DZ_DS_Loc_US_Extended)
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

;>Table: FramesFlippers
;>Description: Values used to add values to FramesStartPosition and FramesEndPosition
;To use a flipped version of the frames.
;>ValuesSize: 16
FramesFlippers:
    dw $0000,$0008
;>EndTable

FramesLength:
	dw $0000,$0000,$0000,$0000
	dw $0000,$0000,$0000,$0000

;>Table: FramesStartPosition
;>Description: Indicates the index where starts each frame
;>ValuesSize: 16
FramesStartPosition:
    dw $0000,$0001,$0002,$0003
	dw $0004,$0005,$0006,$0007
;>EndTable

;>Table: FramesEndPosition
;>Description: Indicates the index where end each frame
;>ValuesSize: 16
FramesEndPosition:
    dw $0000,$0001,$0002,$0003
	dw $0004,$0005,$0006,$0007
;>EndTable

;>Table: YDisplacements
;>Description: Y Displacement of each tile of each frame
;>ValuesSize: 8
Tiles:
XDisplacements:
    
Frame0_Frame0_XDisp:
	db $00
Frame1_Frame1_XDisp:
	db $00
Frame2_Frame2_XDisp:
	db $00
Frame3_Frame3_XDisp:
	db $00
Frame0_Frame0_XDispFlipX:
	db $00
Frame1_Frame1_XDispFlipX:
	db $00
Frame2_Frame2_XDispFlipX:
	db $00
Frame3_Frame3_XDispFlipX:
	db $00

YDisplacements:
    
Frame0_Frame0_YDisp:
	db $05-$06
Frame1_Frame1_YDisp:
	db $06-$06
Frame2_Frame2_YDisp:
	db $08-$06
Frame3_Frame3_YDisp:
	db $09-$06
Frame0_Frame0_YDispFlipX:
	db $05-$06
Frame1_Frame1_YDispFlipX:
	db $06-$06
Frame2_Frame2_YDispFlipX:
	db $08-$06
Frame3_Frame3_YDispFlipX:
	db $09-$06

Sizes:
    
Frame0_Frame0_Size:
	db $02
Frame1_Frame1_Size:
	db $02
Frame2_Frame2_Size:
	db $02
Frame3_Frame3_Size:
	db $02
Frame0_Frame0_SizeFlipX:
	db $02
Frame1_Frame1_SizeFlipX:
	db $02
Frame2_Frame2_SizeFlipX:
	db $02
Frame3_Frame3_SizeFlipX:
	db $02
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
	LDA #$00
	STA !AnimationIndex,x
	JSR ChangeAnimationFromStart
	PLB
	RTL

ChangeAnimationFromStart_idle:
	LDA #$00
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_fall:
	LDA #$01
	STA !AnimationIndex,x


ChangeAnimationFromStart:
	LDA #$00
	STA !AnimationFrameIndex,x

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
	%CheckEvenOrOdd("DZ_DS_Loc_US_Extended")
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
	dw $0001,$0004

AnimationLastTransition:
	dw $0000,$0003

AnimationIndexer:
	dw $0000,$0001

Frames:
	
Animation0_idle_Frames:
	db $00
Animation1_fall_Frames:
	db $00,$01,$02,$03

Times:
	
Animation0_idle_Times:
	db $04
Animation1_fall_Times:
	db $04,$04,$04,$04
;>End Animations Section

;Don't Delete or write another >Section Hitbox Interaction or >End Section
;All code between >Section Hitboxes Interaction and >End Hitboxes Interaction Section will be changed by Dyzen : Sprite Maker
;>Section Hitboxes Interaction
;>End Hitboxes Interaction Section
