;@Krusha.bin,KrushaPal1.bin,KrushaPal2.bin
!ResourceIndex = $03
%GFXTabDef(!ResourceIndex)
%GFXDef(00)
%GFXDef(01)
%GFXDef(02)

!LaughSFX = $3A
!LaughBank = $1DFC|!addr
!DeadSFX = $39
!DeadBank = $1DFC|!addr
;######################################
;############## Defines ###############
;######################################}

!MaxTime = #$1F 

!FrameIndex = !SpriteMiscTable1
!AnimationTimer = !SpriteMiscTable7
!AnimationIndex = !SpriteMiscTable2
!AnimationFrameIndex = !SpriteMiscTable3
!LocalFlip = !SpriteMiscTable4
!GlobalFlip = !SpriteMiscTable5
!LastFrameIndex = !SpriteMiscTable6
!Pal = !SpritePal
!LoadPal = !SpriteLoadPal
!Timer = !SpriteDecTimer2        	
!XSpeed = !ExtraByte2	
!AnimSpeed = !SpriteMiscTable12
!PaletteTimer = !SpriteDecTimer3   

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
	STA !SpriteActionFlag,x
	STA !LocalFlip,x
	JSL InitWrapperChangeAnimationFromStart
	LDA #$FF
	STA !LastFrameIndex,x

	%CheckSlotNormalSprite(#$0B, $00)
    LDA #$03
	STA !SpriteMiscTable8,x

	LDA #$01
	STA !LoadPal,x

	LDA !ExtraByte1,x
	AND #$07
	ASL
	STA !Pal,x

	JSR SetWalkAnimationSpeed

	LDA #$02
	STA !PaletteTimer,x
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

	LDA.b #!GFX02
	STA !Scratch1
	LDA.b #!GFX02>>8
	STA !Scratch2
	LDA.b #!GFX02>>16
	STA !Scratch3

	LDA !ExtraBits,x
	AND #$04
	BEQ ++
	
	LDA.b #!GFX01
	STA !Scratch1
	LDA.b #!GFX01>>8
	STA !Scratch2
	LDA.b #!GFX01>>16
	STA !Scratch3

++

	%TransferToCGRAM(!Scratch0, !Scratch1, !Scratch3, #$001E)
	LDX !SpriteIndex

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

	LDA #$04
    %SubOffScreen()

	%DyzenPrepareBounce()

    JSR InteractMarioSprite
    ;After this routine, if the sprite interact with mario, Carry is Set.

	%DyzenDetectPlayerIsAbove()
	
	JSR ActionFlag
    JSR Spritestates
	;JSR PalEffect

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

+++
	LDA !SpriteActionFlag,x
	EOR #$01
	STA !SpriteActionFlag,x

	LDA #!DeadSFX
    %PlaySound()
	
	LDA #$B0
	STA !SpriteYSpeed,x 
	LDA #!Scratch8
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

Spritestates:
LDA !SpriteMiscTable8,x
ASL
TAX
JMP (States,x)
States:
dw WalkROUTINE,Flipping,Flipping1,aniwak,laughstart,Laugh
dw laughloope,laughloope1,krushadead,krushadead1
krushadead:
       	LDX !SpriteIndex 

		LDA !AnimationIndex,x
		CMP #$02
		BEQ +

		%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
		BEQ +	
		
		JSR ChangeAnimationFromStart_deadstart
		
		INC !SpriteMiscTable8,x
+
       RTS
krushadead1:
		LDX !SpriteIndex 	

		LDA !SpriteYSpeed,x
		BMI +

		LDA !AnimationIndex,x
		CMP #$03
		BEQ +

		%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
		BEQ +	
		
		JSR ChangeAnimationFromStart_deadfall
+
RTS
 
aniwak:
       	LDX !SpriteIndex 

		LDA !SpriteDecTimer5,x
		BNE +

		LDA !SpriteTweaker1686_DNCTSWYE,x
		AND #$F7
		STA !SpriteTweaker1686_DNCTSWYE,x

+

		%UpdateNormalSpriteSpeedWithGravity()
		LDA !AnimationIndex,x
		CMP #$05
		BEQ +

		%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
		BEQ +	
		
		JSR ChangeAnimationFromStart_walk
		STZ !SpriteMiscTable8,x
+
RTS

laughstart:
       	LDX !SpriteIndex   

		STZ !SpriteXSpeed,x
		%UpdateNormalSpriteSpeedWithGravity()

		LDA !AnimationIndex,x
		BEQ +

		%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
		BEQ +	

		STZ !SpriteXSpeed,x

		LDA !SpriteTweaker1686_DNCTSWYE,x
		ORA #$08
		STA !SpriteTweaker1686_DNCTSWYE,x

		JSR ChangeAnimationFromStart_laughstart

		INC !SpriteMiscTable8,x

		LDA #!LaughSFX
		STA !LaughBank
RTS
+
		INC !SpriteMiscTable8,x
RTS

Laugh:
       	LDX !SpriteIndex 

		LDA !AnimationIndex,x
		BEQ +

		JSR laughstart
RTS

+ 

		%UpdateNormalSpriteSpeedWithGravity()

		LDA !AnimationFrameIndex,x
		CMP #$05
		BNE +

		LDA !AnimationTimer,x
		BNE +

		INC !SpriteMiscTable8,x
+
       RTS

laughloope:
       	LDX !SpriteIndex 
  
  		%UpdateNormalSpriteSpeedWithGravity()
		LDA !AnimationIndex,x
		CMP #$01
		BEQ +

		%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
		BEQ +	
		JSR ChangeAnimationFromStart_laughloop

		INC !SpriteMiscTable8,x
		LDA !MaxTime
		STA !Timer,x
+
RTS
laughloope1:
       	LDX !SpriteIndex 

		%UpdateNormalSpriteSpeedWithGravity()
		LDA !Timer,x        
		BNE +		
		LDA !AnimationIndex,x
		CMP #$05
		BEQ +

		%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
		BEQ +	

		JSR ChangeAnimationFromStart_walk
		STZ !SpriteMiscTable8,x
		LDA #$08
		STA !SpriteDecTimer5,x
+
RTS

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

	LDA !ExtraBits,x
	AND #$04
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
	AND #$04
	BEQ +

	LDA !SpriteBlockedStatus_ASB0UDLR,x		
	AND #$03		   
	BEQ +			

	LDA #$01
	STA !SpriteMiscTable8,x
+
	RTS 
 
Flipping:
       LDX !SpriteIndex 
	   %UpdateNormalSpriteSpeedWithGravity()	
       LDA !AnimationIndex,x
	   CMP #$04
       BEQ +

       %CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
       BNE ++
RTS
++
		STZ !SpriteXSpeed,x

		LDA !SpriteTweaker1686_DNCTSWYE,x
		ORA #$08
		STA !SpriteTweaker1686_DNCTSWYE,x

	   JSR ChangeAnimationFromStart_flip	 
+

	LDA !AnimationFrameIndex,x
	CMP #$03
	BNE +
	LDA !AnimationTimer,x
	BNE +

	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BEQ +	

	JSR ChangeAnimationFromStart_walk

	STZ !SpriteMiscTable8,x
	LDA !GlobalFlip,x
	EOR #$01
	STA !GlobalFlip,x

+
RTS

Flipping1:
       LDX !SpriteIndex 
       RTS
FollowPlayer:

       JSR CheckPlayerSide	;Check the side of the player
       BCS .right
.left
       LDA #$01
       STA !GlobalFlip,x	   
	   LDA #-$2F
	   STA !PlayerXSpeed
+
       RTS
.right
       LDA #$00
       STA !GlobalFlip,x
       LDA #$2F
	   STA !PlayerXSpeed 	   
+
       RTS
CheckPlayerSide:
       LDA !SpriteXLow,x	
       STA !Scratch0		
       LDA !SpriteXHigh,x	
       STA !Scratch1		
       REP #$20		
       LDA !PlayerX		
       CMP !Scratch0		
       SEP #$20		
RTS

;>Section Dynamic
;######################################
;########## Animation Space ###########
;######################################
ResourceOffset:
Frame0_ResourceOffset:
	dw $0000,$0460
Frame1_ResourceOffset:
	dw $04A0,$0900
Frame2_ResourceOffset:
	dw $0940,$0DA0
Frame3_ResourceOffset:
	dw $0DE0,$1260
Frame4_ResourceOffset:
	dw $12A0,$1700
Frame5_ResourceOffset:
	dw $1740,$1BA0
Frame6_ResourceOffset:
	dw $1BE0,$2080
Frame7_ResourceOffset:
	dw $20C0,$24C0
Frame8_ResourceOffset:
	dw $2540,$2940
Frame9_ResourceOffset:
	dw $2960,$2D60
Frame10_ResourceOffset:
	dw $2D80,$31C0
Frame11_ResourceOffset:
	dw $3200,$3600
Frame12_ResourceOffset:
	dw $3680,$3B20
Frame13_ResourceOffset:
	dw $3BA0,$4020
Frame14_ResourceOffset:
	dw $4060,$4460
Frame15_ResourceOffset:
	dw $44A0,$46A0
Frame16_ResourceOffset:
	dw $4880,$4CE0
Frame17_ResourceOffset:
	dw $4D20,$5180
Frame18_ResourceOffset:
	dw $51C0,$55C0
Frame19_ResourceOffset:
	dw $5600,$5A00
Frame20_ResourceOffset:
	dw $5A60,$5E60
Frame21_ResourceOffset:
	dw $5EA0,$62A0
Frame22_ResourceOffset:
	dw $62E0,$6760
Frame23_ResourceOffset:
	dw $67E0,$6BE0
Frame24_ResourceOffset:
	dw $6C40,$70C0
Frame25_ResourceOffset:
	dw $7140,$7540

ResourceSize:
Frame0_ResourceSize:
	db $23,$02
Frame1_ResourceSize:
	db $23,$02
Frame2_ResourceSize:
	db $23,$02
Frame3_ResourceSize:
	db $24,$02
Frame4_ResourceSize:
	db $23,$02
Frame5_ResourceSize:
	db $23,$02
Frame6_ResourceSize:
	db $25,$02
Frame7_ResourceSize:
	db $24,$00
Frame8_ResourceSize:
	db $21,$00
Frame9_ResourceSize:
	db $21,$00
Frame10_ResourceSize:
	db $22,$02
Frame11_ResourceSize:
	db $24,$00
Frame12_ResourceSize:
	db $25,$04
Frame13_ResourceSize:
	db $24,$02
Frame14_ResourceSize:
	db $22,$00
Frame15_ResourceSize:
	db $1F,$00
Frame16_ResourceSize:
	db $23,$02
Frame17_ResourceSize:
	db $23,$02
Frame18_ResourceSize:
	db $22,$00
Frame19_ResourceSize:
	db $23,$00
Frame20_ResourceSize:
	db $22,$00
Frame21_ResourceSize:
	db $22,$00
Frame22_ResourceSize:
	db $24,$04
Frame23_ResourceSize:
	db $23,$00
Frame24_ResourceSize:
	db $24,$04
Frame25_ResourceSize:
	db $23,$00
;>End Dynamic Section

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
    dw $0009,$0009,$0009,$000A,$0009,$0009,$000B,$000B,$0008,$0008,$0008,$000B,$000A,$000A,$0009,$0009
	dw $0009,$0009,$0009,$000A,$0009,$0009,$0009,$000A,$0009,$000A
	dw $0009,$0009,$0009,$000A,$0009,$0009,$000B,$000B,$0008,$0008,$0008,$000B,$000A,$000A,$0009,$0009
	dw $0009,$0009,$0009,$000A,$0009,$0009,$0009,$000A,$0009,$000A
;>EndTable


;>Table: FramesFlippers
;>Description: Values used to add values to FramesStartPosition and FramesEndPosition
;To use a flipped version of the frames.
;>ValuesSize: 16
FramesFlippers:
    dw $0000,$0034
;>EndTable


;>Table: FramesStartPosition
;>Description: Indicates the index where starts each frame
;>ValuesSize: 16
FramesStartPosition:
    dw $0009,$0013,$001D,$0028,$0032,$003C,$0048,$0054,$005D,$0066,$006F,$007B,$0086,$0091,$009B,$00A5
	dw $00AF,$00B9,$00C3,$00CE,$00D8,$00E2,$00EC,$00F7,$0101,$010C
	dw $0116,$0120,$012A,$0135,$013F,$0149,$0155,$0161,$016A,$0173,$017C,$0188,$0193,$019E,$01A8,$01B2
	dw $01BC,$01C6,$01D0,$01DB,$01E5,$01EF,$01F9,$0204,$020E,$0219
;>EndTable

;>Table: FramesEndPosition
;>Description: Indicates the index where end each frame
;>ValuesSize: 16
FramesEndPosition:
    dw $0000,$000A,$0014,$001E,$0029,$0033,$003D,$0049,$0055,$005E,$0067,$0070,$007C,$0087,$0092,$009C
	dw $00A6,$00B0,$00BA,$00C4,$00CF,$00D9,$00E3,$00ED,$00F8,$0102
	dw $010D,$0117,$0121,$012B,$0136,$0140,$014A,$0156,$0162,$016B,$0174,$017D,$0189,$0194,$019F,$01A9
	dw $01B3,$01BD,$01C7,$01D1,$01DC,$01E6,$01F0,$01FA,$0205,$020F
;>EndTable


;>Table: Tiles
;>Description: Tiles codes of each tile of each frame
;>ValuesSize: 8
Tiles:
    
Frame0_Frame0_Tiles:
	db $20,$0E,$0C,$0A,$08,$06,$04,$02,$00,$22
Frame1_Frame1_Tiles:
	db $20,$0E,$0C,$0A,$08,$06,$04,$00,$02,$22
Frame2_Frame2_Tiles:
	db $20,$0E,$0C,$0A,$08,$06,$04,$00,$02,$22
Frame3_Frame3_Tiles:
	db $23,$20,$0E,$0C,$22,$0A,$08,$06,$04,$02,$00
Frame4_Frame4_Tiles:
	db $20,$0E,$0C,$0A,$08,$06,$04,$02,$00,$22
Frame5_Frame5_Tiles:
	db $20,$0E,$0C,$0A,$08,$06,$04,$02,$00,$22
Frame6_Frame6_Tiles:
	db $24,$20,$0E,$0C,$23,$0A,$08,$06,$22,$04,$02,$00
Frame7_Frame7_Tiles:
	db $23,$22,$0E,$0C,$0A,$08,$06,$04,$21,$20,$02,$00
Frame8_Frame8_Tiles:
	db $0E,$20,$0C,$0A,$08,$06,$04,$02,$00
Frame9_Frame9_Tiles:
	db $0E,$20,$0C,$0A,$08,$06,$04,$02,$00
Frame10_Frame10_Tiles:
	db $20,$0E,$0C,$0A,$08,$06,$04,$02,$00
Frame11_Frame11_Tiles:
	db $23,$0E,$22,$0C,$0A,$08,$06,$04,$02,$21,$00,$20
Frame12_Frame12_Tiles:
	db $22,$20,$0E,$0C,$24,$0A,$08,$06,$04,$02,$00
Frame13_Frame13_Tiles:
	db $23,$20,$0E,$0C,$0A,$08,$06,$04,$22,$02,$00
Frame14_Frame14_Tiles:
	db $0E,$0C,$21,$0A,$08,$06,$04,$02,$00,$20
Frame15_Frame15_Tiles:
	db $1E,$0C,$0F,$0E,$0A,$08,$06,$04,$02,$00
Frame16_Frame16_Tiles:
	db $20,$0E,$22,$0C,$0A,$08,$06,$04,$02,$00
Frame17_Frame17_Tiles:
	db $20,$0E,$0C,$0A,$08,$06,$04,$00,$02,$22
Frame18_Frame18_Tiles:
	db $0E,$0C,$21,$0A,$08,$06,$04,$20,$02,$00
Frame19_Frame19_Tiles:
	db $22,$0E,$0C,$0A,$08,$06,$04,$21,$02,$00,$20
Frame20_Frame20_Tiles:
	db $0E,$0C,$0A,$08,$06,$04,$21,$02,$00,$20
Frame21_Frame21_Tiles:
	db $21,$0E,$0C,$0A,$08,$06,$04,$20,$02,$00
Frame22_Frame22_Tiles:
	db $22,$20,$0E,$0C,$0A,$08,$06,$04,$02,$00
Frame23_Frame23_Tiles:
	db $22,$0E,$0C,$0A,$08,$06,$04,$21,$02,$00,$20
Frame24_Frame24_Tiles:
	db $22,$20,$0E,$0C,$0A,$08,$06,$04,$02,$00
Frame25_Frame25_Tiles:
	db $0E,$0C,$22,$0A,$08,$06,$04,$21,$02,$20,$00
Frame0_Frame0_TilesFlipX:
	db $20,$0E,$0C,$0A,$08,$06,$04,$02,$00,$22
Frame1_Frame1_TilesFlipX:
	db $20,$0E,$0C,$0A,$08,$06,$04,$00,$02,$22
Frame2_Frame2_TilesFlipX:
	db $20,$0E,$0C,$0A,$08,$06,$04,$00,$02,$22
Frame3_Frame3_TilesFlipX:
	db $23,$20,$0E,$0C,$22,$0A,$08,$06,$04,$02,$00
Frame4_Frame4_TilesFlipX:
	db $20,$0E,$0C,$0A,$08,$06,$04,$02,$00,$22
Frame5_Frame5_TilesFlipX:
	db $20,$0E,$0C,$0A,$08,$06,$04,$02,$00,$22
Frame6_Frame6_TilesFlipX:
	db $24,$20,$0E,$0C,$23,$0A,$08,$06,$22,$04,$02,$00
Frame7_Frame7_TilesFlipX:
	db $23,$22,$0E,$0C,$0A,$08,$06,$04,$21,$20,$02,$00
Frame8_Frame8_TilesFlipX:
	db $0E,$20,$0C,$0A,$08,$06,$04,$02,$00
Frame9_Frame9_TilesFlipX:
	db $0E,$20,$0C,$0A,$08,$06,$04,$02,$00
Frame10_Frame10_TilesFlipX:
	db $20,$0E,$0C,$0A,$08,$06,$04,$02,$00
Frame11_Frame11_TilesFlipX:
	db $23,$0E,$22,$0C,$0A,$08,$06,$04,$02,$21,$00,$20
Frame12_Frame12_TilesFlipX:
	db $22,$20,$0E,$0C,$24,$0A,$08,$06,$04,$02,$00
Frame13_Frame13_TilesFlipX:
	db $23,$20,$0E,$0C,$0A,$08,$06,$04,$22,$02,$00
Frame14_Frame14_TilesFlipX:
	db $0E,$0C,$21,$0A,$08,$06,$04,$02,$00,$20
Frame15_Frame15_TilesFlipX:
	db $1E,$0C,$0F,$0E,$0A,$08,$06,$04,$02,$00
Frame16_Frame16_TilesFlipX:
	db $20,$0E,$22,$0C,$0A,$08,$06,$04,$02,$00
Frame17_Frame17_TilesFlipX:
	db $20,$0E,$0C,$0A,$08,$06,$04,$00,$02,$22
Frame18_Frame18_TilesFlipX:
	db $0E,$0C,$21,$0A,$08,$06,$04,$20,$02,$00
Frame19_Frame19_TilesFlipX:
	db $22,$0E,$0C,$0A,$08,$06,$04,$21,$02,$00,$20
Frame20_Frame20_TilesFlipX:
	db $0E,$0C,$0A,$08,$06,$04,$21,$02,$00,$20
Frame21_Frame21_TilesFlipX:
	db $21,$0E,$0C,$0A,$08,$06,$04,$20,$02,$00
Frame22_Frame22_TilesFlipX:
	db $22,$20,$0E,$0C,$0A,$08,$06,$04,$02,$00
Frame23_Frame23_TilesFlipX:
	db $22,$0E,$0C,$0A,$08,$06,$04,$21,$02,$00,$20
Frame24_Frame24_TilesFlipX:
	db $22,$20,$0E,$0C,$0A,$08,$06,$04,$02,$00
Frame25_Frame25_TilesFlipX:
	db $0E,$0C,$22,$0A,$08,$06,$04,$21,$02,$20,$00
;>EndTable

;>Table: XDisplacements
;>Description: X Displacement of each tile of each frame
;>ValuesSize: 8
XDisplacements:
    
Frame0_Frame0_XDisp:
	db $F1,$F3,$FB,$01,$01,$01,$0B,$10,$10,$11
Frame1_Frame1_XDisp:
	db $F1,$F2,$FB,$01,$01,$01,$0B,$0D,$0F,$11
Frame2_Frame2_XDisp:
	db $F2,$F2,$FB,$02,$02,$02,$0B,$0C,$0F,$12
Frame3_Frame3_XDisp:
	db $F2,$F4,$F4,$FB,$FE,$03,$03,$03,$03,$0F,$0F
Frame4_Frame4_XDisp:
	db $F2,$F2,$FB,$00,$00,$00,$0B,$0E,$0E,$10
Frame5_Frame5_XDisp:
	db $F2,$F2,$FB,$00,$00,$00,$0B,$0E,$0E,$10
Frame6_Frame6_XDisp:
	db $EE,$EF,$EF,$F2,$F4,$FF,$FF,$FF,$03,$0F,$0F,$13
Frame7_Frame7_XDisp:
	db $ED,$EE,$EF,$EF,$EF,$FF,$FF,$FF,$01,$0F,$0F,$14
Frame8_Frame8_XDisp:
	db $E8,$ED,$EE,$F5,$F8,$FE,$FE,$0E,$19
Frame9_Frame9_XDisp:
	db $E3,$EB,$EF,$F3,$F3,$FF,$FF,$0F,$1D
Frame10_Frame10_XDisp:
	db $E1,$F1,$F1,$F2,$FC,$01,$01,$11,$1F
Frame11_Frame11_XDisp:
	db $E2,$EA,$F1,$F6,$F6,$F8,$06,$06,$06,$08,$16,$26
Frame12_Frame12_XDisp:
	db $ED,$F6,$FD,$FD,$FD,$06,$06,$06,$0D,$13,$13
Frame13_Frame13_XDisp:
	db $F0,$F1,$F8,$FE,$01,$01,$01,$0E,$11,$11,$11
Frame14_Frame14_XDisp:
	db $F2,$F2,$F3,$FB,$01,$01,$01,$0F,$0F,$11
Frame15_Frame15_XDisp:
	db $F3,$F5,$F5,$F5,$FB,$FD,$02,$09,$0D,$0D
Frame16_Frame16_XDisp:
	db $F3,$F9,$FB,$01,$01,$03,$03,$0D,$0D,$0D
Frame17_Frame17_XDisp:
	db $F4,$FB,$FB,$FE,$05,$05,$05,$0C,$0D,$14
Frame18_Frame18_XDisp:
	db $F4,$FA,$FB,$FB,$FC,$FC,$0B,$0B,$0C,$0D
Frame19_Frame19_XDisp:
	db $F4,$F4,$F6,$F6,$02,$02,$04,$04,$0D,$0D,$12
Frame20_Frame20_XDisp:
	db $F2,$F2,$F3,$01,$01,$01,$06,$0F,$0F,$11
Frame21_Frame21_XDisp:
	db $F0,$F1,$F3,$F3,$01,$01,$01,$08,$10,$10
Frame22_Frame22_XDisp:
	db $EF,$F3,$F4,$F4,$03,$03,$03,$08,$12,$12
Frame23_Frame23_XDisp:
	db $EE,$F0,$F0,$F5,$00,$00,$00,$08,$10,$10,$1A
Frame24_Frame24_XDisp:
	db $EF,$F4,$F4,$F4,$04,$04,$04,$04,$12,$12
Frame25_Frame25_XDisp:
	db $F0,$F0,$F1,$F9,$FF,$FF,$FF,$0F,$0F,$0F,$10
Frame0_Frame0_XDispFlipX:
	db $0F,$0D,$05,$FF,$FF,$FF,$F5,$F0,$F0,$F7
Frame1_Frame1_XDispFlipX:
	db $0F,$0E,$05,$FF,$FF,$FF,$F5,$F3,$F1,$F7
Frame2_Frame2_XDispFlipX:
	db $0E,$0E,$05,$FE,$FE,$FE,$F5,$F4,$F1,$F6
Frame3_Frame3_XDispFlipX:
	db $16,$0C,$0C,$05,$0A,$FD,$FD,$FD,$FD,$F1,$F1
Frame4_Frame4_XDispFlipX:
	db $0E,$0E,$05,$00,$00,$00,$F5,$F2,$F2,$F8
Frame5_Frame5_XDispFlipX:
	db $0E,$0E,$05,$00,$00,$00,$F5,$F2,$F2,$F8
Frame6_Frame6_XDispFlipX:
	db $1A,$11,$11,$0E,$14,$01,$01,$01,$05,$F1,$F1,$ED
Frame7_Frame7_XDispFlipX:
	db $1B,$1A,$11,$11,$11,$01,$01,$01,$07,$F9,$F1,$EC
Frame8_Frame8_XDispFlipX:
	db $18,$1B,$12,$0B,$08,$02,$02,$F2,$E7
Frame9_Frame9_XDispFlipX:
	db $1D,$1D,$11,$0D,$0D,$01,$01,$F1,$E3
Frame10_Frame10_XDispFlipX:
	db $1F,$0F,$0F,$0E,$04,$FF,$FF,$EF,$E1
Frame11_Frame11_XDispFlipX:
	db $26,$16,$17,$0A,$0A,$08,$FA,$FA,$FA,$00,$EA,$E2
Frame12_Frame12_XDispFlipX:
	db $13,$0A,$03,$03,$0B,$FA,$FA,$FA,$F3,$ED,$ED
Frame13_Frame13_XDispFlipX:
	db $18,$0F,$08,$02,$FF,$FF,$FF,$F2,$F7,$EF,$EF
Frame14_Frame14_XDispFlipX:
	db $0E,$0E,$15,$05,$FF,$FF,$FF,$F1,$F1,$F7
Frame15_Frame15_XDispFlipX:
	db $15,$0B,$13,$13,$05,$03,$FE,$F7,$F3,$F3
Frame16_Frame16_XDispFlipX:
	db $0D,$07,$0D,$FF,$FF,$FD,$FD,$F3,$F3,$F3
Frame17_Frame17_XDispFlipX:
	db $0C,$05,$05,$02,$FB,$FB,$FB,$F4,$F3,$F4
Frame18_Frame18_XDispFlipX:
	db $0C,$06,$0D,$05,$04,$04,$F5,$FD,$F4,$F3
Frame19_Frame19_XDispFlipX:
	db $14,$0C,$0A,$0A,$FE,$FE,$FC,$04,$F3,$F3,$F6
Frame20_Frame20_XDispFlipX:
	db $0E,$0E,$0D,$FF,$FF,$FF,$02,$F1,$F1,$F7
Frame21_Frame21_XDispFlipX:
	db $18,$0F,$0D,$0D,$FF,$FF,$FF,$00,$F0,$F0
Frame22_Frame22_XDispFlipX:
	db $11,$0D,$0C,$0C,$FD,$FD,$FD,$F8,$EE,$EE
Frame23_Frame23_XDispFlipX:
	db $1A,$10,$10,$0B,$00,$00,$00,$00,$F0,$F0,$EE
Frame24_Frame24_XDispFlipX:
	db $11,$0C,$0C,$0C,$FC,$FC,$FC,$FC,$EE,$EE
Frame25_Frame25_XDispFlipX:
	db $10,$10,$17,$07,$01,$01,$01,$F9,$F1,$F9,$F0
;>EndTable
;>Table: YDisplacements
;>Description: Y Displacement of each tile of each frame
;>ValuesSize: 8
YDisplacements:
    
Frame0_Frame0_YDisp:
	db $F3,$03,$10,$E4,$F4,$04,$0E,$F1,$01,$E9
Frame1_Frame1_YDisp:
	db $F2,$02,$10,$E3,$F3,$03,$0E,$05,$F5,$ED
Frame2_Frame2_YDisp:
	db $F0,$00,$10,$E3,$F3,$03,$0E,$05,$F5,$ED
Frame3_Frame3_YDisp:
	db $FE,$ED,$FD,$0D,$18,$E2,$F2,$02,$0E,$EC,$FC
Frame4_Frame4_YDisp:
	db $F0,$00,$10,$E2,$F2,$02,$0E,$F1,$01,$E9
Frame5_Frame5_YDisp:
	db $F0,$00,$10,$E2,$F2,$02,$0E,$F0,$00,$E8
Frame6_Frame6_YDisp:
	db $FC,$EE,$FE,$0E,$18,$E3,$F3,$03,$13,$E5,$F5,$FC
Frame7_Frame7_YDisp:
	db $03,$01,$EE,$FE,$0E,$E6,$F6,$06,$13,$EB,$F3,$00
Frame8_Frame8_YDisp:
	db $07,$FF,$EF,$FD,$07,$E7,$F7,$F2,$FD
Frame9_Frame9_YDisp:
	db $FF,$F7,$EC,$FC,$06,$E8,$F6,$EB,$EE
Frame10_Frame10_YDisp:
	db $F5,$E8,$F8,$08,$09,$E9,$F9,$E6,$E5
Frame11_Frame11_YDisp:
	db $F7,$EF,$E7,$EF,$FF,$0C,$E7,$F5,$05,$13,$E2,$E2
Frame12_Frame12_YDisp:
	db $F6,$EA,$FA,$0A,$1A,$E3,$F3,$03,$0E,$F3,$03
Frame13_Frame13_YDisp:
	db $FE,$F3,$03,$10,$E3,$F3,$03,$0D,$E8,$F0,$00
Frame14_Frame14_YDisp:
	db $F2,$02,$12,$0F,$E3,$F3,$03,$EC,$FC,$E9
Frame15_Frame15_YDisp:
	db $10,$F3,$03,$0B,$0F,$FF,$EF,$E5,$EE,$FE
Frame16_Frame16_YDisp:
	db $0E,$FE,$F6,$E4,$F4,$04,$0F,$E4,$F4,$04
Frame17_Frame17_YDisp:
	db $09,$F0,$00,$0F,$E3,$F3,$03,$02,$EA,$FA
Frame18_Frame18_YDisp:
	db $08,$10,$FD,$02,$ED,$FA,$E3,$F3,$FB,$ED
Frame19_Frame19_YDisp:
	db $0A,$11,$F2,$02,$E4,$F4,$04,$14,$EC,$FC,$E4
Frame20_Frame20_YDisp:
	db $F3,$03,$11,$E5,$F5,$05,$15,$ED,$FD,$E5
Frame21_Frame21_YDisp:
	db $02,$F2,$02,$11,$E6,$F6,$06,$16,$EC,$FC
Frame22_Frame22_YDisp:
	db $FF,$F3,$03,$11,$E8,$F8,$08,$11,$F2,$02
Frame23_Frame23_YDisp:
	db $04,$F4,$04,$0F,$E9,$F9,$09,$19,$ED,$FD,$04
Frame24_Frame24_YDisp:
	db $FD,$F1,$01,$11,$E6,$F6,$06,$11,$EF,$FF
Frame25_Frame25_YDisp:
	db $F2,$02,$12,$11,$E5,$F5,$01,$E9,$EE,$FE,$FE
Frame0_Frame0_YDispFlipX:
	db $F3,$03,$10,$E4,$F4,$04,$0E,$F1,$01,$E9
Frame1_Frame1_YDispFlipX:
	db $F2,$02,$10,$E3,$F3,$03,$0E,$05,$F5,$ED
Frame2_Frame2_YDispFlipX:
	db $F0,$00,$10,$E3,$F3,$03,$0E,$05,$F5,$ED
Frame3_Frame3_YDispFlipX:
	db $FE,$ED,$FD,$0D,$18,$E2,$F2,$02,$0E,$EC,$FC
Frame4_Frame4_YDispFlipX:
	db $F0,$00,$10,$E2,$F2,$02,$0E,$F1,$01,$E9
Frame5_Frame5_YDispFlipX:
	db $F0,$00,$10,$E2,$F2,$02,$0E,$F0,$00,$E8
Frame6_Frame6_YDispFlipX:
	db $FC,$EE,$FE,$0E,$18,$E3,$F3,$03,$13,$E5,$F5,$FC
Frame7_Frame7_YDispFlipX:
	db $03,$01,$EE,$FE,$0E,$E6,$F6,$06,$13,$EB,$F3,$00
Frame8_Frame8_YDispFlipX:
	db $07,$FF,$EF,$FD,$07,$E7,$F7,$F2,$FD
Frame9_Frame9_YDispFlipX:
	db $FF,$F7,$EC,$FC,$06,$E8,$F6,$EB,$EE
Frame10_Frame10_YDispFlipX:
	db $F5,$E8,$F8,$08,$09,$E9,$F9,$E6,$E5
Frame11_Frame11_YDispFlipX:
	db $F7,$EF,$E7,$EF,$FF,$0C,$E7,$F5,$05,$13,$E2,$E2
Frame12_Frame12_YDispFlipX:
	db $F6,$EA,$FA,$0A,$1A,$E3,$F3,$03,$0E,$F3,$03
Frame13_Frame13_YDispFlipX:
	db $FE,$F3,$03,$10,$E3,$F3,$03,$0D,$E8,$F0,$00
Frame14_Frame14_YDispFlipX:
	db $F2,$02,$12,$0F,$E3,$F3,$03,$EC,$FC,$E9
Frame15_Frame15_YDispFlipX:
	db $10,$F3,$03,$0B,$0F,$FF,$EF,$E5,$EE,$FE
Frame16_Frame16_YDispFlipX:
	db $0E,$FE,$F6,$E4,$F4,$04,$0F,$E4,$F4,$04
Frame17_Frame17_YDispFlipX:
	db $09,$F0,$00,$0F,$E3,$F3,$03,$02,$EA,$FA
Frame18_Frame18_YDispFlipX:
	db $08,$10,$FD,$02,$ED,$FA,$E3,$F3,$FB,$ED
Frame19_Frame19_YDispFlipX:
	db $0A,$11,$F2,$02,$E4,$F4,$04,$14,$EC,$FC,$E4
Frame20_Frame20_YDispFlipX:
	db $F3,$03,$11,$E5,$F5,$05,$15,$ED,$FD,$E5
Frame21_Frame21_YDispFlipX:
	db $02,$F2,$02,$11,$E6,$F6,$06,$16,$EC,$FC
Frame22_Frame22_YDispFlipX:
	db $FF,$F3,$03,$11,$E8,$F8,$08,$11,$F2,$02
Frame23_Frame23_YDispFlipX:
	db $04,$F4,$04,$0F,$E9,$F9,$09,$19,$ED,$FD,$04
Frame24_Frame24_YDispFlipX:
	db $FD,$F1,$01,$11,$E6,$F6,$06,$11,$EF,$FF
Frame25_Frame25_YDispFlipX:
	db $F2,$02,$12,$11,$E5,$F5,$01,$E9,$EE,$FE,$FE
;>EndTable
;>Table: Sizes.
;>Description: size of each tile of each frame
;>ValuesSize: 8
Sizes:
    
Frame0_Frame0_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame1_Frame1_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame2_Frame2_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame3_Frame3_Sizes:
	db $00,$02,$02,$02,$00,$02,$02,$02,$02,$02,$02
Frame4_Frame4_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame5_Frame5_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame6_Frame6_Sizes:
	db $00,$02,$02,$02,$00,$02,$02,$02,$00,$02,$02,$02
Frame7_Frame7_Sizes:
	db $00,$00,$02,$02,$02,$02,$02,$02,$00,$00,$02,$02
Frame8_Frame8_Sizes:
	db $02,$00,$02,$02,$02,$02,$02,$02,$02
Frame9_Frame9_Sizes:
	db $02,$00,$02,$02,$02,$02,$02,$02,$02
Frame10_Frame10_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame11_Frame11_Sizes:
	db $00,$02,$00,$02,$02,$02,$02,$02,$02,$00,$02,$00
Frame12_Frame12_Sizes:
	db $02,$02,$02,$02,$00,$02,$02,$02,$02,$02,$02
Frame13_Frame13_Sizes:
	db $00,$02,$02,$02,$02,$02,$02,$02,$00,$02,$02
Frame14_Frame14_Sizes:
	db $02,$02,$00,$02,$02,$02,$02,$02,$02,$00
Frame15_Frame15_Sizes:
	db $00,$02,$00,$00,$02,$02,$02,$02,$02,$02
Frame16_Frame16_Sizes:
	db $02,$02,$00,$02,$02,$02,$02,$02,$02,$02
Frame17_Frame17_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame18_Frame18_Sizes:
	db $02,$02,$00,$02,$02,$02,$02,$00,$02,$02
Frame19_Frame19_Sizes:
	db $00,$02,$02,$02,$02,$02,$02,$00,$02,$02,$00
Frame20_Frame20_Sizes:
	db $02,$02,$02,$02,$02,$02,$00,$02,$02,$00
Frame21_Frame21_Sizes:
	db $00,$02,$02,$02,$02,$02,$02,$00,$02,$02
Frame22_Frame22_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame23_Frame23_Sizes:
	db $00,$02,$02,$02,$02,$02,$02,$00,$02,$02,$00
Frame24_Frame24_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame25_Frame25_Sizes:
	db $02,$02,$00,$02,$02,$02,$02,$00,$02,$00,$02
Frame0_Frame0_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame1_Frame1_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame2_Frame2_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame3_Frame3_SizesFlipX:
	db $00,$02,$02,$02,$00,$02,$02,$02,$02,$02,$02
Frame4_Frame4_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame5_Frame5_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame6_Frame6_SizesFlipX:
	db $00,$02,$02,$02,$00,$02,$02,$02,$00,$02,$02,$02
Frame7_Frame7_SizesFlipX:
	db $00,$00,$02,$02,$02,$02,$02,$02,$00,$00,$02,$02
Frame8_Frame8_SizesFlipX:
	db $02,$00,$02,$02,$02,$02,$02,$02,$02
Frame9_Frame9_SizesFlipX:
	db $02,$00,$02,$02,$02,$02,$02,$02,$02
Frame10_Frame10_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame11_Frame11_SizesFlipX:
	db $00,$02,$00,$02,$02,$02,$02,$02,$02,$00,$02,$00
Frame12_Frame12_SizesFlipX:
	db $02,$02,$02,$02,$00,$02,$02,$02,$02,$02,$02
Frame13_Frame13_SizesFlipX:
	db $00,$02,$02,$02,$02,$02,$02,$02,$00,$02,$02
Frame14_Frame14_SizesFlipX:
	db $02,$02,$00,$02,$02,$02,$02,$02,$02,$00
Frame15_Frame15_SizesFlipX:
	db $00,$02,$00,$00,$02,$02,$02,$02,$02,$02
Frame16_Frame16_SizesFlipX:
	db $02,$02,$00,$02,$02,$02,$02,$02,$02,$02
Frame17_Frame17_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$00
Frame18_Frame18_SizesFlipX:
	db $02,$02,$00,$02,$02,$02,$02,$00,$02,$02
Frame19_Frame19_SizesFlipX:
	db $00,$02,$02,$02,$02,$02,$02,$00,$02,$02,$00
Frame20_Frame20_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$00,$02,$02,$00
Frame21_Frame21_SizesFlipX:
	db $00,$02,$02,$02,$02,$02,$02,$00,$02,$02
Frame22_Frame22_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame23_Frame23_SizesFlipX:
	db $00,$02,$02,$02,$02,$02,$02,$00,$02,$02,$00
Frame24_Frame24_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame25_Frame25_SizesFlipX:
	db $02,$02,$00,$02,$02,$02,$02,$00,$02,$00,$02
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

ChangeAnimationFromStart_laughstart:
	STZ !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_laughloop:
	LDA #$01
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_deadstart:
	LDA #$02
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_deadfall:
	LDA #$03
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_flip:
	LDA #$04
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_walk:
	LDA #$05
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
	CMP #$04
	BCC +

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
	dw $0006,$0004,$0002,$0004,$0004,$000C

AnimationLastTransition:
	dw $0005,$0000,$0001,$0003,$0003,$0000

AnimationIndexer:
	dw $0000,$0006,$000A,$000C,$0010,$0014

Frames:
	
Animation0_laughstart_Frames:
	db $00,$01,$02,$03,$04,$05
Animation1_laughloop_Frames:
	db $04,$03,$04,$05
Animation2_deadstart_Frames:
	db $06,$07
Animation3_deadfall_Frames:
	db $08,$09,$0A,$0B
Animation4_flip_Frames:
	db $0D,$0C,$0C,$0D
Animation5_walk_Frames:
	db $0E,$0F,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19

Times:
	
Animation0_laughstart_Times:
	db $02,$02,$02,$02,$02,$02
Animation1_laughloop_Times:
	db $02,$02,$02,$02
Animation2_deadstart_Times:
	db $04,$04
Animation3_deadfall_Times:
	db $04,$04,$04,$04
Animation4_flip_Times:
	db $02,$02,$02,$02
Animation5_walk_Times:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02

Flips:
	
Animation0_laughstart_Flips:
	db $00,$00,$00,$00,$00,$00
Animation1_laughloop_Flips:
	db $00,$00,$00,$00
Animation2_deadstart_Flips:
	db $00,$00
Animation3_deadfall_Flips:
	db $00,$00,$00,$00
Animation4_flip_Flips:
	db $00,$00,$01,$01
Animation5_walk_Flips:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

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
    dw $0000,$0034

FrameHitboxesIndexer:
    dw $0000,$0002,$0004,$0006,$0008,$000A,$000C,$000D,$000E,$000F,$0010,$0011,$0012,$0014,$0016,$0018
	dw $001A,$001C,$001E,$0020,$0022,$0024,$0026,$0028,$002A,$002C
	dw $002E,$0030,$0032,$0034,$0036,$0038,$003A,$003B,$003C,$003D,$003E,$003F,$0040,$0042,$0044,$0046
	dw $0048,$004A,$004C,$004E,$0050,$0052,$0054,$0056,$0058,$005A

FrameHitBoxes:
    db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF

Hitboxes:
HitboxType: 
	dw $0001,$0001
HitboxXOffset: 
	dw $0001,$FFFD
HitboxYOffset: 
	dw $FFF0,$FFF0
HitboxWidth: 
	dw $0012,$0012
HitboxHeight: 
	dw $002D,$002D
HitboxAction1: 
	dw $0000,$0000
HitboxAction2: 
	dw $0002,$0002
	

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
	LDA #$08
	STA !SpriteMiscTable8,x
	LDA #!DeadSFX
    STA !DeadBank
	LDA #$B0
	STA !SpriteYSpeed,x 
	LDA #$02
	STA !SpriteStatus,x
RTS
+

	LDA !SpritePlayerIsAbove,x
	BNE +

	%DyzenPrepareContactEffect()
	LDA #$01
	%DisplayContactEffect()

-
	LDA !PlayerFlashingTimer
	BNE ++

	LDA #!Scratch4
	STA !SpriteMiscTable8,x	

	JSR FollowPlayer

	%DamagePlayer()
++

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

    LDA !RidingYoshi	
	BNE SpinKill		; Go to spin kill.

    LDA !SpriteMiscTable8,x
    CMP #$04 
	BCC +
	
	JSR FollowPlayer

    LDA !ExtraBits,x
    AND #$04
    ASL
	AND !ExtraByte1,x
	AND #$08
	BNE -

RTS					;Return
+
	LDA #!Scratch4
	STA !SpriteMiscTable8,x	
	JSR FollowPlayer

    LDA !ExtraBits,x
    AND #$04
    ASL
	AND !ExtraByte1,x
	AND #$08
	BNE -
RTS
SpinKill:
    LDA !ExtraBits,x
    AND #$04
    BEQ +	

	LDA #!Scratch4
	STA !SpriteMiscTable8,x
	JSR FollowPlayer

	LDA !ExtraByte1,x
	AND #$08
	BNE -
RTS	
+	
    LDA #!DeadSFX
    STA !DeadBank
	LDA #!Scratch8
	STA !SpriteMiscTable8,x

	LDA #$B0
	STA !SpriteYSpeed,x 
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
