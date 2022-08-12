;@Gnawty.bin,GnawtyPal1.bin,GnawtyPal2.bin
!ResourceIndex = $02
%GFXTabDef(!ResourceIndex)
%GFXDef(00)
%GFXDef(01)
%GFXDef(02)

!DeadSFX = $3A

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
Xspeed: db -$F3,$F3	

!Palette0 = $0C
!Palette1 = $0F
!Pal = !SpritePal
!LoadPal = !SpriteLoadPal
!XSpeed = !ExtraByte2	
!AnimSpeed = !SpriteMiscTable12
!Version = !SpriteMiscTable13
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
	STA !SpriteActionFlag,x
	
	JSL InitWrapperChangeAnimationFromStart

	LDA #$FF
	STA !LastFrameIndex,x

	%CheckSlotNormalSprite(#$06, $00)
	STZ !SpriteMiscTable8,x

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

	%DyzenPrepareBounce()

    JSR InteractMarioSprite
    ;After this routine, if the sprite interact with mario, Carry is Set.

	%DyzenDetectPlayerIsAbove()
    ;After this routine, if the sprite interact with mario, Carry is Set.
	JSR ActionFlag
	JSR state

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
	LDA #!Scratch3
	STA !SpriteMiscTable8,x	
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
	STA !SpriteMiscTable8,x

+
RTS
;Here you can write routines or tables
state:
	LDA !SpriteMiscTable8,x
	ASL
	TAX

	STZ $8A

	JMP (States,x)
States:
dw WalkROUTINE,Flipping,Flipping1,Gnawtydead,Gnawtydead1

WalkROUTINE:		
	LDX !SpriteIndex    

	LDA !SpriteDecTimer5,x
	BNE +

	LDA !SpriteTweaker1686_DNCTSWYE,x
	AND #$F7
	STA !SpriteTweaker1686_DNCTSWYE,x

+
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
	
	LDA !Version,x
	BEQ .onGround1
	
	%UpdateNormalSpriteSpeedWithGravityAndFloorCheck()
	BCC .onGround

	LDA #$01
	STA !SpriteMiscTable8,x
RTS
.onGround1
	
	%UpdateNormalSpriteSpeedWithGravity()	
.onGround		 

	LDA !SpriteBlockedStatus_ASB0UDLR,x		
	AND #$03		   
	BEQ +			

	LDA #$01
	STA !SpriteMiscTable8,x
+
	RTS   
Flipping:
	LDX !SpriteIndex 

	STZ !SpriteXSpeed,x

	%UpdateNormalSpriteSpeedWithGravity()
		
	LDA !AnimationIndex,x
	CMP #$01
	BEQ +

	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BNE ++
RTS
++
	JSR ChangeAnimationFromStart_flip

	STZ !SpriteXSpeed,x

	LDA !SpriteTweaker1686_DNCTSWYE,x
	ORA #$08
	STA !SpriteTweaker1686_DNCTSWYE,x
+
	LDA !AnimationFrameIndex,x
	CMP #$03
	BCC +

	LDA !AnimationTimer,x
	BNE +

	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BNE +

	JSR ChangeAnimationFromStart_walk

	STZ !SpriteMiscTable8,x

	LDA !GlobalFlip,x
	EOR #$01
	STA !GlobalFlip,x

	LDA #$08
	STA !SpriteDecTimer5,x

+
RTS
Flipping1:
       LDX !SpriteIndex 

       RTS
Gnawtydead:
       LDX !SpriteIndex 

       LDA !AnimationIndex,x
	   CMP #$02
       BEQ +

	   %CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	   BEQ +	
	
	   JSR ChangeAnimationFromStart_deadstart
	   
       INC !SpriteMiscTable8,x
       RTS
+
       RTS	   
Gnawtydead1:
       LDX !SpriteIndex 	

       LDA !SpriteYSpeed,x
       BMI +
FallingCode:   	  
       LDA !AnimationIndex,x
	   CMP #$03
       BEQ +

	   %CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	   BEQ +	
	
	   JSR ChangeAnimationFromStart_deadend

+
       RTS
  	    
;>Section Dynamic
;######################################
;########## Animation Space ###########
;######################################
ResourceOffset:
Frame0_ResourceOffset:
	dw $0000,$0100
Frame1_ResourceOffset:
	dw $01C0,$02C0
Frame2_ResourceOffset:
	dw $0380,$04A0
Frame3_ResourceOffset:
	dw $05A0,$06C0
Frame4_ResourceOffset:
	dw $07C0,$08C0
Frame5_ResourceOffset:
	dw $0980,$0AA0
Frame6_ResourceOffset:
	dw $0BA0,$0CA0
Frame7_ResourceOffset:
	dw $0DA0,$0EA0
Frame8_ResourceOffset:
	dw $0F60,$1040
Frame9_ResourceOffset:
	dw $1100,$11E0
Frame10_ResourceOffset:
	dw $12A0,$13A0
Frame11_ResourceOffset:
	dw $14A0,$15C0
Frame12_ResourceOffset:
	dw $16C0,$17C0
Frame13_ResourceOffset:
	dw $1880,$19A0
Frame14_ResourceOffset:
	dw $1AA0,$1BE0


ResourceSize:
Frame0_ResourceSize:
	db $08,$06
Frame1_ResourceSize:
	db $08,$06
Frame2_ResourceSize:
	db $09,$08
Frame3_ResourceSize:
	db $09,$08
Frame4_ResourceSize:
	db $08,$06
Frame5_ResourceSize:
	db $09,$08
Frame6_ResourceSize:
	db $08,$08
Frame7_ResourceSize:
	db $08,$06
Frame8_ResourceSize:
	db $07,$06
Frame9_ResourceSize:
	db $07,$06
Frame10_ResourceSize:
	db $08,$08
Frame11_ResourceSize:
	db $09,$08
Frame12_ResourceSize:
	db $08,$06
Frame13_ResourceSize:
	db $09,$08
Frame14_ResourceSize:
	db $0A,$08

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
    dw $0004,$0004,$0004,$0004,$0004,$0004,$0003,$0004,$0003,$0003,$0003,$0004,$0004,$0004,$0005
	dw $0004,$0004,$0004,$0004,$0004,$0004,$0003,$0004,$0003,$0003,$0003,$0004,$0004,$0004,$0005
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
    dw $0004,$0009,$000E,$0013,$0018,$001D,$0021,$0026,$002A,$002E,$0032,$0037,$003C,$0041,$0047
	dw $004C,$0051,$0056,$005B,$0060,$0065,$0069,$006E,$0072,$0076,$007A,$007F,$0084,$0089,$008F
;>EndTable

;>Table: FramesEndPosition
;>Description: Indicates the index where end each frame
;>ValuesSize: 16
FramesEndPosition:
    dw $0000,$0005,$000A,$000F,$0014,$0019,$001E,$0022,$0027,$002B,$002F,$0033,$0038,$003D,$0042
	dw $0048,$004D,$0052,$0057,$005C,$0061,$0066,$006A,$006F,$0073,$0077,$007B,$0080,$0085,$008A
;>EndTable


;>Table: Tiles
;>Description: Tiles codes of each tile of each frame
;>ValuesSize: 8
Tiles:
    
Frame0_Frame0_Tiles:
	db $07,$04,$06,$02,$00
Frame1_Frame1_Tiles:
	db $04,$07,$02,$00,$06
Frame2_Frame2_Tiles:
	db $06,$04,$02,$00,$08
Frame3_Frame3_Tiles:
	db $08,$06,$04,$02,$00
Frame4_Frame4_Tiles:
	db $07,$04,$02,$00,$06
Frame5_Frame5_Tiles:
	db $08,$06,$04,$02,$00
Frame6_Frame6_Tiles:
	db $06,$04,$02,$00
Frame7_Frame7_Tiles:
	db $07,$06,$04,$02,$00
Frame8_Frame8_Tiles:
	db $04,$06,$02,$00
Frame9_Frame9_Tiles:
	db $04,$06,$02,$00
Frame10_Frame10_Tiles:
	db $06,$04,$02,$00
Frame11_Frame11_Tiles:
	db $06,$04,$02,$08,$00
Frame12_Frame12_Tiles:
	db $07,$04,$06,$02,$00
Frame13_Frame13_Tiles:
	db $08,$06,$04,$02,$00
Frame14_Frame14_Tiles:
	db $09,$06,$08,$04,$00,$02
Frame0_Frame0_TilesFlipX:
	db $07,$04,$06,$02,$00
Frame1_Frame1_TilesFlipX:
	db $04,$07,$02,$00,$06
Frame2_Frame2_TilesFlipX:
	db $06,$04,$02,$00,$08
Frame3_Frame3_TilesFlipX:
	db $08,$06,$04,$02,$00
Frame4_Frame4_TilesFlipX:
	db $07,$04,$02,$00,$06
Frame5_Frame5_TilesFlipX:
	db $08,$06,$04,$02,$00
Frame6_Frame6_TilesFlipX:
	db $06,$04,$02,$00
Frame7_Frame7_TilesFlipX:
	db $07,$06,$04,$02,$00
Frame8_Frame8_TilesFlipX:
	db $04,$06,$02,$00
Frame9_Frame9_TilesFlipX:
	db $04,$06,$02,$00
Frame10_Frame10_TilesFlipX:
	db $06,$04,$02,$00
Frame11_Frame11_TilesFlipX:
	db $06,$04,$02,$08,$00
Frame12_Frame12_TilesFlipX:
	db $07,$04,$06,$02,$00
Frame13_Frame13_TilesFlipX:
	db $08,$06,$04,$02,$00
Frame14_Frame14_TilesFlipX:
	db $09,$06,$08,$04,$00,$02
;>EndTable

;>Table: XDisplacements
;>Description: X Displacement of each tile of each frame
;>ValuesSize: 8
XDisplacements:
    
Frame0_Frame0_XDisp:
	db $F6,$FD,$FE,$06,$0B
Frame1_Frame1_XDisp:
	db $F5,$FF,$05,$07,$12
Frame2_Frame2_XDisp:
	db $F5,$FF,$05,$0B,$0F
Frame3_Frame3_XDisp:
	db $F6,$FE,$FE,$0B,$0B
Frame4_Frame4_XDisp:
	db $F6,$FE,$FE,$0A,$0E
Frame5_Frame5_XDisp:
	db $F6,$FE,$FE,$0A,$0A
Frame6_Frame6_XDisp:
	db $F6,$FE,$06,$0A
Frame7_Frame7_XDisp:
	db $F6,$FE,$FE,$06,$0A
Frame8_Frame8_XDisp:
	db $FB,$FC,$03,$0A
Frame9_Frame9_XDisp:
	db $FC,$FD,$02,$08
Frame10_Frame10_XDisp:
	db $F6,$FD,$06,$0A
Frame11_Frame11_XDisp:
	db $F6,$F8,$06,$08,$0A
Frame12_Frame12_XDisp:
	db $F6,$FA,$00,$08,$0A
Frame13_Frame13_XDisp:
	db $F5,$FB,$04,$0B,$0C
Frame14_Frame14_XDisp:
	db $F3,$FB,$FC,$05,$0A,$0B
Frame0_Frame0_XDispFlipX:
	db $12,$03,$0A,$FA,$F5
Frame1_Frame1_XDispFlipX:
	db $0B,$09,$FB,$F9,$F6
Frame2_Frame2_XDispFlipX:
	db $0B,$01,$FB,$F5,$F9
Frame3_Frame3_XDispFlipX:
	db $12,$02,$02,$F5,$F5
Frame4_Frame4_XDispFlipX:
	db $12,$02,$02,$F6,$FA
Frame5_Frame5_XDispFlipX:
	db $12,$02,$02,$F6,$F6
Frame6_Frame6_XDispFlipX:
	db $0A,$02,$FA,$F6
Frame7_Frame7_XDispFlipX:
	db $12,$0A,$02,$FA,$F6
Frame8_Frame8_XDispFlipX:
	db $05,$0C,$FD,$F6
Frame9_Frame9_XDispFlipX:
	db $04,$0B,$FE,$F8
Frame10_Frame10_XDispFlipX:
	db $0A,$03,$FA,$F6
Frame11_Frame11_XDispFlipX:
	db $0A,$08,$FA,$00,$F6
Frame12_Frame12_XDispFlipX:
	db $12,$06,$08,$F8,$F6
Frame13_Frame13_XDispFlipX:
	db $13,$05,$FC,$F5,$F4
Frame14_Frame14_XDispFlipX:
	db $15,$05,$0C,$FB,$F6,$F5
;>EndTable
;>Table: YDisplacements
;>Description: Y Displacement of each tile of each frame
;>ValuesSize: 8
!GFXYOffset = $07

YDisplacements:
    
Frame0_Frame0_YDisp:
	db !GFXYOffset+$10,!GFXYOffset+$0A,!GFXYOffset+$03,!GFXYOffset+$FE,!GFXYOffset+$0C
Frame1_Frame1_YDisp:
	db !GFXYOffset+$07,!GFXYOffset+$02,!GFXYOffset+$0A,!GFXYOffset+$FD,!GFXYOffset+$0C
Frame2_Frame2_YDisp:
	db !GFXYOffset+$08,!GFXYOffset+$FE,!GFXYOffset+$0C,!GFXYOffset+$05,!GFXYOffset+$FD
Frame3_Frame3_YDisp:
	db !GFXYOffset+$11,!GFXYOffset+$FD,!GFXYOffset+$0D,!GFXYOffset+$FD,!GFXYOffset+$0D
Frame4_Frame4_YDisp:
	db !GFXYOffset+$10,!GFXYOffset+$FD,!GFXYOffset+$0D,!GFXYOffset+$04,!GFXYOffset+$FC
Frame5_Frame5_YDisp:
	db !GFXYOffset+$10,!GFXYOffset+$FD,!GFXYOffset+$0D,!GFXYOffset+$FC,!GFXYOffset+$07
Frame6_Frame6_YDisp:
	db !GFXYOffset+$09,!GFXYOffset+$FD,!GFXYOffset+$0A,!GFXYOffset+$FC
Frame7_Frame7_YDisp:
	db !GFXYOffset+$11,!GFXYOffset+$03,!GFXYOffset+$0A,!GFXYOffset+$FD,!GFXYOffset+$0B
Frame8_Frame8_YDisp:
	db !GFXYOffset+$0B,!GFXYOffset+$03,!GFXYOffset+$FD,!GFXYOffset+$0B
Frame9_Frame9_YDisp:
	db !GFXYOffset+$0B,!GFXYOffset+$03,!GFXYOffset+$FD,!GFXYOffset+$0A
Frame10_Frame10_YDisp:
	db !GFXYOffset+$00,!GFXYOffset+$07,!GFXYOffset+$FC,!GFXYOffset+$05
Frame11_Frame11_YDisp:
	db !GFXYOffset+$FE,!GFXYOffset+$06,!GFXYOffset+$FD,!GFXYOffset+$0D,!GFXYOffset+$09
Frame12_Frame12_YDisp:
	db !GFXYOffset+$10,!GFXYOffset+$02,!GFXYOffset+$FD,!GFXYOffset+$FD,!GFXYOffset+$0D
Frame13_Frame13_YDisp:
	db !GFXYOffset+$0F,!GFXYOffset+$03,!GFXYOffset+$FD,!GFXYOffset+$03,!GFXYOffset+$08
Frame14_Frame14_YDisp:
	db !GFXYOffset+$09,!GFXYOffset+$01,!GFXYOffset+$0E,!GFXYOffset+$F4,!GFXYOffset+$11,!GFXYOffset+$01
Frame0_Frame0_YDispFlipX:
	db !GFXYOffset+$10,!GFXYOffset+$0A,!GFXYOffset+$03,!GFXYOffset+$FE,!GFXYOffset+$0C
Frame1_Frame1_YDispFlipX:
	db !GFXYOffset+$07,!GFXYOffset+$02,!GFXYOffset+$0A,!GFXYOffset+$FD,!GFXYOffset+$0C
Frame2_Frame2_YDispFlipX:
	db !GFXYOffset+$08,!GFXYOffset+$FE,!GFXYOffset+$0C,!GFXYOffset+$05,!GFXYOffset+$FD
Frame3_Frame3_YDispFlipX:
	db !GFXYOffset+$11,!GFXYOffset+$FD,!GFXYOffset+$0D,!GFXYOffset+$FD,!GFXYOffset+$0D
Frame4_Frame4_YDispFlipX:
	db !GFXYOffset+$10,!GFXYOffset+$FD,!GFXYOffset+$0D,!GFXYOffset+$04,!GFXYOffset+$FC
Frame5_Frame5_YDispFlipX:
	db !GFXYOffset+$10,!GFXYOffset+$FD,!GFXYOffset+$0D,!GFXYOffset+$FC,!GFXYOffset+$07
Frame6_Frame6_YDispFlipX:
	db !GFXYOffset+$09,!GFXYOffset+$FD,!GFXYOffset+$0A,!GFXYOffset+$FC
Frame7_Frame7_YDispFlipX:
	db !GFXYOffset+$11,!GFXYOffset+$03,!GFXYOffset+$0A,!GFXYOffset+$FD,!GFXYOffset+$0B
Frame8_Frame8_YDispFlipX:
	db !GFXYOffset+$0B,!GFXYOffset+$03,!GFXYOffset+$FD,!GFXYOffset+$0B
Frame9_Frame9_YDispFlipX:
	db !GFXYOffset+$0B,!GFXYOffset+$03,!GFXYOffset+$FD,!GFXYOffset+$0A
Frame10_Frame10_YDispFlipX:
	db !GFXYOffset+$00,!GFXYOffset+$07,!GFXYOffset+$FC,!GFXYOffset+$05
Frame11_Frame11_YDispFlipX:
	db !GFXYOffset+$FE,!GFXYOffset+$06,!GFXYOffset+$FD,!GFXYOffset+$0D,!GFXYOffset+$09
Frame12_Frame12_YDispFlipX:
	db !GFXYOffset+$10,!GFXYOffset+$02,!GFXYOffset+$FD,!GFXYOffset+$FD,!GFXYOffset+$0D
Frame13_Frame13_YDispFlipX:
	db !GFXYOffset+$0F,!GFXYOffset+$03,!GFXYOffset+$FD,!GFXYOffset+$03,!GFXYOffset+$08
Frame14_Frame14_YDispFlipX:
	db !GFXYOffset+$09,!GFXYOffset+$01,!GFXYOffset+$0E,!GFXYOffset+$F4,!GFXYOffset+$11,!GFXYOffset+$01
;>EndTable
;>Table: Sizes.
;>Description: size of each tile of each frame
;>ValuesSize: 8
Sizes:
    
Frame0_Frame0_Sizes:
	db $00,$02,$00,$02,$02
Frame1_Frame1_Sizes:
	db $02,$00,$02,$02,$00
Frame2_Frame2_Sizes:
	db $02,$02,$02,$02,$00
Frame3_Frame3_Sizes:
	db $00,$02,$02,$02,$02
Frame4_Frame4_Sizes:
	db $00,$02,$02,$02,$00
Frame5_Frame5_Sizes:
	db $00,$02,$02,$02,$02
Frame6_Frame6_Sizes:
	db $02,$02,$02,$02
Frame7_Frame7_Sizes:
	db $00,$00,$02,$02,$02
Frame8_Frame8_Sizes:
	db $02,$00,$02,$02
Frame9_Frame9_Sizes:
	db $02,$00,$02,$02
Frame10_Frame10_Sizes:
	db $02,$02,$02,$02
Frame11_Frame11_Sizes:
	db $02,$02,$02,$00,$02
Frame12_Frame12_Sizes:
	db $00,$02,$00,$02,$02
Frame13_Frame13_Sizes:
	db $00,$02,$02,$02,$02
Frame14_Frame14_Sizes:
	db $00,$02,$00,$02,$02,$02
Frame0_Frame0_SizesFlipX:
	db $00,$02,$00,$02,$02
Frame1_Frame1_SizesFlipX:
	db $02,$00,$02,$02,$00
Frame2_Frame2_SizesFlipX:
	db $02,$02,$02,$02,$00
Frame3_Frame3_SizesFlipX:
	db $00,$02,$02,$02,$02
Frame4_Frame4_SizesFlipX:
	db $00,$02,$02,$02,$00
Frame5_Frame5_SizesFlipX:
	db $00,$02,$02,$02,$02
Frame6_Frame6_SizesFlipX:
	db $02,$02,$02,$02
Frame7_Frame7_SizesFlipX:
	db $00,$00,$02,$02,$02
Frame8_Frame8_SizesFlipX:
	db $02,$00,$02,$02
Frame9_Frame9_SizesFlipX:
	db $02,$00,$02,$02
Frame10_Frame10_SizesFlipX:
	db $02,$02,$02,$02
Frame11_Frame11_SizesFlipX:
	db $02,$02,$02,$00,$02
Frame12_Frame12_SizesFlipX:
	db $00,$02,$00,$02,$02
Frame13_Frame13_SizesFlipX:
	db $00,$02,$02,$02,$02
Frame14_Frame14_SizesFlipX:
	db $00,$02,$00,$02,$02,$02
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
ChangeAnimationFromStart_deadstart:
	LDA #$02
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_deadend:
	LDA #$03
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
	dw $0008,$0004,$0001,$0004

AnimationLastTransition:
	dw $0000,$0003,$0000,$0003

AnimationIndexer:
	dw $0000,$0008,$000C,$000D

Frames:
	
Animation0_walk_Frames:
	db $00,$01,$02,$03,$04,$05,$06,$07
Animation1_flip_Frames:
	db $08,$09,$09,$08
Animation2_deadstart_Frames:
	db $0A
Animation3_deadend_Frames:
	db $0B,$0C,$0D,$0E

Times:
	
Animation0_walk_Times:
	db $04,$04,$04,$04,$04,$04,$04,$04
Animation1_flip_Times:
	db $02,$02,$02,$02
Animation2_deadstart_Times:
	db $04
Animation3_deadend_Times:
	db $04,$04,$04,$04

Flips:
	
Animation0_walk_Flips:
	db $00,$00,$00,$00,$00,$00,$00,$00
Animation1_flip_Flips:
	db $00,$00,$01,$01
Animation2_deadstart_Flips:
	db $00
Animation3_deadend_Flips:
	db $00,$00,$00,$00

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
	dw $0002,$0001,$0000,$FFFF,$0000,$0001
HitboxYOffset: 
	dw !GFXYOffset+$0004,!GFXYOffset+$0004,!GFXYOffset+$0004,!GFXYOffset+$0004,!GFXYOffset+$0004,!GFXYOffset+$0004
HitboxWidth: 
	dw $000F,$000F,$000F,$000F,$000F,$000F
HitboxHeight: 
	dw $0014,$0014,$0014,$0014,$0014,$0014
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
	LDA $1490|!addr	;if player is using the star
	BEQ +			;kill the sprite

	%Star()
	LDA #!Scratch3
	STA !SpriteMiscTable8,x
	LDA #!DeadSFX
    %PlaySound()
	LDA #$02
	STA !SpriteStatus,x
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

	LDA #!DeadSFX
    %PlaySound()
	
	LDA #$B0
	STA !SpriteYSpeed,x 
	LDA #!Scratch3
	STA !SpriteMiscTable8,x	
	LDA #$02
	STA !SpriteStatus,x

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
