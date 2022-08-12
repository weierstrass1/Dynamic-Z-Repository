;@SMMMidwayFlag1.bin,SMMMidwayFlag2.bin,SMMMidwayFlagPal1.bin,SMMMidwayFlagPal2.bin
!ResourceIndex = $0B
%GFXTabDef(!ResourceIndex)
%GFXDef(00)
%GFXDef(01)
%GFXDef(02)
%GFXDef(03)

if !SA1
	!RAM_Midway		= $40D000
else
	!RAM_Midway		= $7ED000
endif

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
!LoadPal = !SpriteMiscTable11
!Pal = !SpriteMiscTable12

;######################################
;########### Init Routine #############
;######################################
print "INIT ",pc

	LDA	!ExtraByte1,x
	AND #$08
	LSR
	LSR
	LSR
	STA	$00
	BEQ	.normal_midpoint
	
	LDX	$13BF|!Base2
	LDA	!RAM_Midway,x
	CMP	$00
	BCS	.midpoint_crossed

.midpoint_not_crossed	
	LDX	$15E9|!Base2
	STZ !State,x

	LDA #$00
	STA !GlobalFlip,x
	LDA #$00
	JSL InitWrapperChangeAnimationFromStart

	LDA #$FF
	STA !LastFrameIndex,x

	%CheckSlotNormalSprite(#$06, $00)

	LDA #$01
	STA !LoadPal,x

	LDA !ExtraByte1,x
	AND #$07
	ASL
	STA !Pal,x
RTL	

.normal_midpoint	
	LDX	$13BF|!Base2
	LDA	$1EA2|!Base2,x
	AND	#$40
	ORA	$13CE|!Base2
	BEQ	.midpoint_not_crossed
.midpoint_crossed	
	LDX	$15E9|!Base2
	LDA	#$02
	STA	!State,x


	LDA #$00
	STA !GlobalFlip,x
	LDA #$01
	JSL InitWrapperChangeAnimationFromStart

	LDA #$FF
	STA !LastFrameIndex,x

	%CheckSlotNormalSprite(#$06, $00)

	LDA #$01
	STA !LoadPal,x

	LDA !ExtraByte1,x
	AND #$07
	ASL
	STA !Pal,x
    ;Here you can write your Init Code
    ;This will be excecuted when the sprite is spawned 
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

	STZ !LoadPal,x

	LDA !Pal,x
	ASL
	ASL
	ASL
	CLC
	ADC #$81
	STA !Scratch0

	LDA !State,x
	BEQ ++

	LDA.b #!GFX03
	STA !Scratch1
	LDA.b #!GFX03>>8
	STA !Scratch2
	LDA.b #!GFX03>>16
	STA !Scratch3
	BRA +++
++
	LDA.b #!GFX02
	STA !Scratch1
	LDA.b #!GFX02>>8
	STA !Scratch2
	LDA.b #!GFX02>>16
	STA !Scratch3
+++

	%TransferToCGRAM(!Scratch0, !Scratch1, !Scratch3, #$001E)

+
	LDX !SpriteIndex 
    JSR GraphicRoutine                  ;Calls the graphic routine and updates sprite graphics

    ;Here you can put code that will be excecuted each frame even if the sprite is locked

    LDA !SpriteStatus,x			        
	CMP #$08                            ;if sprite dead return
	BNE Return	

	LDA !LockAnimationFlag				    
	BNE Return			                    ;if locked animation return.

    %SubOffScreen()

    JSR InteractMarioSprite
    ;After this routine, if the sprite interact with mario, Carry is Set.

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

StateMachine:

	LDA !State,x
	ASL
	TAX

	JSR (States,x)
RTS

States:
	dw Bowser
	dw Change
	dw Mario
;Here you can write routines or tables
Bowser:
	LDX !SpriteIndex
RTS

Change:
	LDX !SpriteIndex

	LDA !AnimationIndex,x
	CMP #$02
	BEQ +

	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BEQ ++	

	JSR ChangeAnimationFromStart_change
	JSR CrossMidway
++
RTS
+
	LDA !AnimationFrameIndex,x
	CMP #$26
	BNE +

	LDA !AnimationTimer,x
	BNE +

	%CheckEvenOrOdd("DZ_DS_Loc_US_Normal")
	BEQ +

	JSR ChangeAnimationFromStart_wavemario
	LDA #$02
	STA !State,x
+
RTS

Mario:
	LDX !SpriteIndex
RTS

CrossMidway:
	LDA	!ExtraByte1,x
	AND #$08
	LSR
	LSR
	LSR
	BEQ	.normal_midpoint
	LDX	$13BF|!Base2
	STA	!RAM_Midway,x
.normal_midpoint	
	LDX	$15E9|!Base2

	LDA	#$01
	STA	$13CE|!Base2
	LDA #$40
	TSB $1EA2|!Base2
.no_contact		
RTS

;>Section Dynamic
;######################################
;########## Animation Space ###########
;######################################
ResourceOffset:
Bowser0_ResourceOffset:
	dw $0000,$0140
Bowser1_ResourceOffset:
	dw $0240,$0380
Bowser2_ResourceOffset:
	dw $0480,$05C0
Bowser3_ResourceOffset:
	dw $06C0,$0800
Bowser4_ResourceOffset:
	dw $0900,$0A40
Bowser5_ResourceOffset:
	dw $0B40,$0C80
Bowser6_ResourceOffset:
	dw $0D80,$0EC0
Bowser7_ResourceOffset:
	dw $0FC0,$1100
Bowser8_ResourceOffset:
	dw $1200,$1340
Bowser9_ResourceOffset:
	dw $1440,$1580
Bowser10_ResourceOffset:
	dw $1680,$17C0
Bowser11_ResourceOffset:
	dw $18C0,$1A00
Bowser12_ResourceOffset:
	dw $1B00,$1C40
Bowser13_ResourceOffset:
	dw $1D40,$1E80
Bowser14_ResourceOffset:
	dw $1F80,$20C0
Bowser15_ResourceOffset:
	dw $21C0,$2300
Bowser16_ResourceOffset:
	dw $2400,$2540
Bowser17_ResourceOffset:
	dw $2640,$2780
Bowser18_ResourceOffset:
	dw $2880,$29C0
Bowser19_ResourceOffset:
	dw $2AC0,$2C00
Bowser20_ResourceOffset:
	dw $2D00,$2E40
Bowser21_ResourceOffset:
	dw $2F40,$3080
Bowser22_ResourceOffset:
	dw $3180,$32C0
Bowser23_ResourceOffset:
	dw $33C0,$3500
Bowser24_ResourceOffset:
	dw $3600,$3740
Bowser25_ResourceOffset:
	dw $3840,$3980
Bowser26_ResourceOffset:
	dw $3A80,$3BC0
Bowser27_ResourceOffset:
	dw $3CC0,$3E00
Bowser28_ResourceOffset:
	dw $3F00,$4040
Bowser29_ResourceOffset:
	dw $4140,$4280
Bowser30_ResourceOffset:
	dw $4380,$44C0
Bowser31_ResourceOffset:
	dw $45C0,$4700
Bowser32_ResourceOffset:
	dw $4800,$4940
Bowser33_ResourceOffset:
	dw $4A40,$4B80
Bowser34_ResourceOffset:
	dw $4C80,$4DC0
Bowser35_ResourceOffset:
	dw $4EC0,$4FE0
Bowser36_ResourceOffset:
	dw $50E0,$51E0
Bowser37_ResourceOffset:
	dw $52E0,$53E0
Mario0_ResourceOffset:
	dw $54E0,$5620
Mario1_ResourceOffset:
	dw $5720,$5860
Mario2_ResourceOffset:
	dw $5960,$5AA0
Mario3_ResourceOffset:
	dw $5BA0,$5CE0
Mario4_ResourceOffset:
	dw $5DE0,$5F20
Mario5_ResourceOffset:
	dw $6020,$6160
Mario6_ResourceOffset:
	dw $6260,$63A0
Mario7_ResourceOffset:
	dw $64A0,$65E0
Mario8_ResourceOffset:
	dw $66E0,$6820
Mario9_ResourceOffset:
	dw $6920,$6A60
Mario10_ResourceOffset:
	dw $6B60,$6CA0
Mario11_ResourceOffset:
	dw $6DA0,$6EE0
Mario12_ResourceOffset:
	dw $6FE0,$7120
Mario13_ResourceOffset:
	dw $7220,$7360
Mario14_ResourceOffset:
	dw $7460,$75A0
Mario15_ResourceOffset:
	dw $76A0,$77E0
Mario16_ResourceOffset:
	dw $78E0,$7A20
Mario17_ResourceOffset:
	dw $7B20,$7C60
Mario18_ResourceOffset:
	dw $7D60,$7EA0
Mario19_ResourceOffset:
	dw $7FA0-$7FA0,$80E0-$7FA0
Mario20_ResourceOffset:
	dw $81E0-$7FA0,$8320-$7FA0
Mario21_ResourceOffset:
	dw $8420-$7FA0,$8560-$7FA0
Mario22_ResourceOffset:
	dw $8660-$7FA0,$87A0-$7FA0
Mario23_ResourceOffset:
	dw $88A0-$7FA0,$89E0-$7FA0
Mario24_ResourceOffset:
	dw $8AE0-$7FA0,$8C20-$7FA0
Mario25_ResourceOffset:
	dw $8D20-$7FA0,$8E60-$7FA0
Mario26_ResourceOffset:
	dw $8F60-$7FA0,$90A0-$7FA0
Mario27_ResourceOffset:
	dw $91A0-$7FA0,$92E0-$7FA0
Mario28_ResourceOffset:
	dw $93E0-$7FA0,$9520-$7FA0
Mario29_ResourceOffset:
	dw $9620-$7FA0,$9760-$7FA0
Mario30_ResourceOffset:
	dw $9860-$7FA0,$99A0-$7FA0
Mario31_ResourceOffset:
	dw $9AA0-$7FA0,$9BE0-$7FA0
Mario32_ResourceOffset:
	dw $9CE0-$7FA0,$9E20-$7FA0
Mario33_ResourceOffset:
	dw $9F20-$7FA0,$A060-$7FA0
Mario38_ResourceOffset:
	dw $A160-$7FA0,$A260-$7FA0
Mario39_ResourceOffset:
	dw $A320-$7FA0,$A440-$7FA0
Mario40_ResourceOffset:
	dw $A540-$7FA0,$A6A0-$7FA0
Mario41_ResourceOffset:
	dw $A7E0-$7FA0,$A940-$7FA0
Mario42_ResourceOffset:
	dw $AA80-$7FA0,$ABC0-$7FA0
Mario43_ResourceOffset:
	dw $ACC0-$7FA0,$AE00-$7FA0
Mario44_ResourceOffset:
	dw $AF40-$7FA0,$B080-$7FA0
Mario45_ResourceOffset:
	dw $B1C0-$7FA0,$B300-$7FA0
Mario46_ResourceOffset:
	dw $B400-$7FA0,$B540-$7FA0
Mario47_ResourceOffset:
	dw $B640-$7FA0,$B780-$7FA0
Mario48_ResourceOffset:
	dw $B8C0-$7FA0,$B9E0-$7FA0
Mario49_ResourceOffset:
	dw $BAE0-$7FA0,$BC00-$7FA0
Mario50_ResourceOffset:
	dw $BD00-$7FA0,$BE20-$7FA0
Mario51_ResourceOffset:
	dw $BF20-$7FA0,$C020-$7FA0
Mario52_ResourceOffset:
	dw $C0E0-$7FA0,$C200-$7FA0
Mario53_ResourceOffset:
	dw $C300-$7FA0,$C440-$7FA0
Mario54_ResourceOffset:
	dw $C580-$7FA0,$C6C0-$7FA0
Mario55_ResourceOffset:
	dw $C7C0-$7FA0,$C900-$7FA0
Mario56_ResourceOffset:
	dw $CA00-$7FA0,$CB40-$7FA0
Mario57_ResourceOffset:
	dw $CC40-$7FA0,$CD80-$7FA0
Mario58_ResourceOffset:
	dw $CE80-$7FA0,$CFC0-$7FA0
Mario59_ResourceOffset:
	dw $D0C0-$7FA0,$D200-$7FA0
Mario60_ResourceOffset:
	dw $D300-$7FA0,$D440-$7FA0
Mario61_ResourceOffset:
	dw $D540-$7FA0,$D680-$7FA0
Mario62_ResourceOffset:
	dw $D780-$7FA0,$D8C0-$7FA0
Mario63_ResourceOffset:
	dw $D9C0-$7FA0,$DB00-$7FA0
Mario64_ResourceOffset:
	dw $DC00-$7FA0,$DD40-$7FA0
Mario65_ResourceOffset:
	dw $DE40-$7FA0,$DF80-$7FA0
Mario66_ResourceOffset:
	dw $E080-$7FA0,$E1C0-$7FA0
Mario67_ResourceOffset:
	dw $E2C0-$7FA0,$E400-$7FA0
Mario68_ResourceOffset:
	dw $E500-$7FA0,$E640-$7FA0
Mario69_ResourceOffset:
	dw $E740-$7FA0,$E880-$7FA0
Mario70_ResourceOffset:
	dw $E980-$7FA0,$EAC0-$7FA0
Mario71_ResourceOffset:
	dw $EBC0-$7FA0,$ED00-$7FA0
Mario72_ResourceOffset:
	dw $EE00-$7FA0,$EF40-$7FA0


ResourceSize:
Bowser0_ResourceSize:
	db $0A,$08
Bowser1_ResourceSize:
	db $0A,$08
Bowser2_ResourceSize:
	db $0A,$08
Bowser3_ResourceSize:
	db $0A,$08
Bowser4_ResourceSize:
	db $0A,$08
Bowser5_ResourceSize:
	db $0A,$08
Bowser6_ResourceSize:
	db $0A,$08
Bowser7_ResourceSize:
	db $0A,$08
Bowser8_ResourceSize:
	db $0A,$08
Bowser9_ResourceSize:
	db $0A,$08
Bowser10_ResourceSize:
	db $0A,$08
Bowser11_ResourceSize:
	db $0A,$08
Bowser12_ResourceSize:
	db $0A,$08
Bowser13_ResourceSize:
	db $0A,$08
Bowser14_ResourceSize:
	db $0A,$08
Bowser15_ResourceSize:
	db $0A,$08
Bowser16_ResourceSize:
	db $0A,$08
Bowser17_ResourceSize:
	db $0A,$08
Bowser18_ResourceSize:
	db $0A,$08
Bowser19_ResourceSize:
	db $0A,$08
Bowser20_ResourceSize:
	db $0A,$08
Bowser21_ResourceSize:
	db $0A,$08
Bowser22_ResourceSize:
	db $0A,$08
Bowser23_ResourceSize:
	db $0A,$08
Bowser24_ResourceSize:
	db $0A,$08
Bowser25_ResourceSize:
	db $0A,$08
Bowser26_ResourceSize:
	db $0A,$08
Bowser27_ResourceSize:
	db $0A,$08
Bowser28_ResourceSize:
	db $0A,$08
Bowser29_ResourceSize:
	db $0A,$08
Bowser30_ResourceSize:
	db $0A,$08
Bowser31_ResourceSize:
	db $0A,$08
Bowser32_ResourceSize:
	db $0A,$08
Bowser33_ResourceSize:
	db $0A,$08
Bowser34_ResourceSize:
	db $0A,$08
Bowser35_ResourceSize:
	db $09,$08
Bowser36_ResourceSize:
	db $08,$08
Bowser37_ResourceSize:
	db $08,$08
Mario0_ResourceSize:
	db $0A,$08
Mario1_ResourceSize:
	db $0A,$08
Mario2_ResourceSize:
	db $0A,$08
Mario3_ResourceSize:
	db $0A,$08
Mario4_ResourceSize:
	db $0A,$08
Mario5_ResourceSize:
	db $0A,$08
Mario6_ResourceSize:
	db $0A,$08
Mario7_ResourceSize:
	db $0A,$08
Mario8_ResourceSize:
	db $0A,$08
Mario9_ResourceSize:
	db $0A,$08
Mario10_ResourceSize:
	db $0A,$08
Mario11_ResourceSize:
	db $0A,$08
Mario12_ResourceSize:
	db $0A,$08
Mario13_ResourceSize:
	db $0A,$08
Mario14_ResourceSize:
	db $0A,$08
Mario15_ResourceSize:
	db $0A,$08
Mario16_ResourceSize:
	db $0A,$08
Mario17_ResourceSize:
	db $0A,$08
Mario18_ResourceSize:
	db $0A,$08
Mario19_ResourceSize:
	db $0A,$08
Mario20_ResourceSize:
	db $0A,$08
Mario21_ResourceSize:
	db $0A,$08
Mario22_ResourceSize:
	db $0A,$08
Mario23_ResourceSize:
	db $0A,$08
Mario24_ResourceSize:
	db $0A,$08
Mario25_ResourceSize:
	db $0A,$08
Mario26_ResourceSize:
	db $0A,$08
Mario27_ResourceSize:
	db $0A,$08
Mario28_ResourceSize:
	db $0A,$08
Mario29_ResourceSize:
	db $0A,$08
Mario30_ResourceSize:
	db $0A,$08
Mario31_ResourceSize:
	db $0A,$08
Mario32_ResourceSize:
	db $0A,$08
Mario33_ResourceSize:
	db $0A,$08
Mario38_ResourceSize:
	db $08,$06
Mario39_ResourceSize:
	db $09,$08
Mario40_ResourceSize:
	db $0B,$0A
Mario41_ResourceSize:
	db $0B,$0A
Mario42_ResourceSize:
	db $0A,$08
Mario43_ResourceSize:
	db $0A,$0A
Mario44_ResourceSize:
	db $0A,$0A
Mario45_ResourceSize:
	db $0A,$08
Mario46_ResourceSize:
	db $0A,$08
Mario47_ResourceSize:
	db $0A,$0A
Mario48_ResourceSize:
	db $09,$08
Mario49_ResourceSize:
	db $09,$08
Mario50_ResourceSize:
	db $09,$08
Mario51_ResourceSize:
	db $08,$06
Mario52_ResourceSize:
	db $09,$08
Mario53_ResourceSize:
	db $0A,$0A
Mario54_ResourceSize:
	db $0A,$08
Mario55_ResourceSize:
	db $0A,$08
Mario56_ResourceSize:
	db $0A,$08
Mario57_ResourceSize:
	db $0A,$08
Mario58_ResourceSize:
	db $0A,$08
Mario59_ResourceSize:
	db $0A,$08
Mario60_ResourceSize:
	db $0A,$08
Mario61_ResourceSize:
	db $0A,$08
Mario62_ResourceSize:
	db $0A,$08
Mario63_ResourceSize:
	db $0A,$08
Mario64_ResourceSize:
	db $0A,$08
Mario65_ResourceSize:
	db $0A,$08
Mario66_ResourceSize:
	db $0A,$08
Mario67_ResourceSize:
	db $0A,$08
Mario68_ResourceSize:
	db $0A,$08
Mario69_ResourceSize:
	db $0A,$08
Mario70_ResourceSize:
	db $0A,$08
Mario71_ResourceSize:
	db $0A,$08
Mario72_ResourceSize:
	db $0A,$08

DynamicRoutine:
    
	LDA !FrameIndex,x
	CMP #$39
	BCC +
	JMP +++	
+

	%EasyNormalSpriteDynamicRoutineFixedGFX("!FrameIndex,x", "!LastFrameIndex,x", !GFX00, "#ResourceOffset", "#ResourceSize", #$10)
	BCC ++

	LDA !FrameIndex,x
	CMP #$48
	BNE ++

	LDA !Pal,x
	ASL
	ASL
	ASL
	CLC
	ADC #$81
	STA !Scratch0

	LDA.b #!GFX03
	STA !Scratch1
	LDA.b #!GFX03>>8
	STA !Scratch2
	LDA.b #!GFX03>>16
	STA !Scratch3

	%TransferToCGRAM(!Scratch0, !Scratch1, !Scratch3, #$001E)

++
RTS
+++

	%EasyNormalSpriteDynamicRoutineFixedGFX("!FrameIndex,x", "!LastFrameIndex,x", !GFX01, "#ResourceOffset", "#ResourceSize", #$10)
	LDA !FrameIndex,x
	CMP #$48
	BNE +

	LDA !Pal,x
	ASL
	ASL
	ASL
	CLC
	ADC #$81
	STA !Scratch0

	LDA.b #!GFX03
	STA !Scratch1
	LDA.b #!GFX03>>8
	STA !Scratch2
	LDA.b #!GFX03>>16
	STA !Scratch3

	%TransferToCGRAM(!Scratch0, !Scratch1, !Scratch3, #$001E)

+
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
	LDA !maxtile_pointer_low
	STA $49
	LDA !maxtile_pointer_low+2
	STA $4B
	LDA !maxtile_pointer_low+8
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
	STA !maxtile_pointer_low
	LDA $4B
	STA !maxtile_pointer_low+2
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
    dw $0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005
	dw $0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005
	dw $0005,$0005,$0005,$0004,$0003,$0003,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005
	dw $0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005
	dw $0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0004,$0004,$0005,$0005,$0005,$0004,$0004,$0005
	dw $0005,$0004,$0004,$0004,$0004,$0004,$0004,$0004,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005
	dw $0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005
;>EndTable


;>Table: FramesStartPosition
;>Description: Indicates the index where starts each frame
;>ValuesSize: 16
FramesStartPosition:
    dw $0005,$000B,$0011,$0017,$001D,$0023,$0029,$002F,$0035,$003B,$0041,$0047,$004D,$0053,$0059,$005F
	dw $0065,$006B,$0071,$0077,$007D,$0083,$0089,$008F,$0095,$009B,$00A1,$00A7,$00AD,$00B3,$00B9,$00BF
	dw $00C5,$00CB,$00D1,$00D6,$00DA,$00DE,$00E4,$00EA,$00F0,$00F6,$00FC,$0102,$0108,$010E,$0114,$011A
	dw $0120,$0126,$012C,$0132,$0138,$013E,$0144,$014A,$0150,$0156,$015C,$0162,$0168,$016E,$0174,$017A
	dw $0180,$0186,$018C,$0192,$0198,$019E,$01A4,$01AA,$01AF,$01B4,$01BA,$01C0,$01C6,$01CB,$01D0,$01D6
	dw $01DC,$01E1,$01E6,$01EB,$01F0,$01F5,$01FA,$01FF,$0205,$020B,$0211,$0217,$021D,$0223,$0229,$022F
	dw $0235,$023B,$0241,$0247,$024D,$0253,$0259,$025F,$0265,$026B,$0271
;>EndTable

;>Table: FramesEndPosition
;>Description: Indicates the index where end each frame
;>ValuesSize: 16
FramesEndPosition:
    dw $0000,$0006,$000C,$0012,$0018,$001E,$0024,$002A,$0030,$0036,$003C,$0042,$0048,$004E,$0054,$005A
	dw $0060,$0066,$006C,$0072,$0078,$007E,$0084,$008A,$0090,$0096,$009C,$00A2,$00A8,$00AE,$00B4,$00BA
	dw $00C0,$00C6,$00CC,$00D2,$00D7,$00DB,$00DF,$00E5,$00EB,$00F1,$00F7,$00FD,$0103,$0109,$010F,$0115
	dw $011B,$0121,$0127,$012D,$0133,$0139,$013F,$0145,$014B,$0151,$0157,$015D,$0163,$0169,$016F,$0175
	dw $017B,$0181,$0187,$018D,$0193,$0199,$019F,$01A5,$01AB,$01B0,$01B5,$01BB,$01C1,$01C7,$01CC,$01D1
	dw $01D7,$01DD,$01E2,$01E7,$01EC,$01F1,$01F6,$01FB,$0200,$0206,$020C,$0212,$0218,$021E,$0224,$022A
	dw $0230,$0236,$023C,$0242,$0248,$024E,$0254,$025A,$0260,$0266,$026C
;>EndTable


;>Table: Tiles
;>Description: Tiles codes of each tile of each frame
;>ValuesSize: 8
Tiles:
    
Frame0_Bowser0_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame1_Bowser1_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame2_Bowser2_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame3_Bowser3_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame4_Bowser4_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame5_Bowser5_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame6_Bowser6_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame7_Bowser7_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame8_Bowser8_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame9_Bowser9_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame10_Bowser10_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame11_Bowser11_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame12_Bowser12_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame13_Bowser13_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame14_Bowser14_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame15_Bowser15_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame16_Bowser16_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame17_Bowser17_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame18_Bowser18_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame19_Bowser19_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame20_Bowser20_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame21_Bowser21_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame22_Bowser22_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame23_Bowser23_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame24_Bowser24_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame25_Bowser25_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame26_Bowser26_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame27_Bowser27_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame28_Bowser28_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame29_Bowser29_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame30_Bowser30_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame31_Bowser31_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame32_Bowser32_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame33_Bowser33_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame34_Bowser34_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame35_Bowser35_Tiles:
	db $06,$04,$02,$00,$08
Frame36_Bowser36_Tiles:
	db $06,$04,$02,$00
Frame37_Bowser37_Tiles:
	db $06,$04,$02,$00
Frame38_Mario0_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame39_Mario1_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame40_Mario2_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame41_Mario3_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame42_Mario4_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame43_Mario5_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame44_Mario6_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame45_Mario7_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame46_Mario8_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame47_Mario9_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame48_Mario10_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame49_Mario11_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame50_Mario12_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame51_Mario13_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame52_Mario14_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame53_Mario15_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame54_Mario16_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame55_Mario17_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame56_Mario18_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame57_Mario19_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame58_Mario20_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame59_Mario21_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame60_Mario22_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame61_Mario23_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame62_Mario24_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame63_Mario25_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame64_Mario26_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame65_Mario27_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame66_Mario28_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame67_Mario29_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame68_Mario30_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame69_Mario31_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame70_Mario32_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame71_Mario33_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame72_Mario38_Tiles:
	db $04,$02,$00,$07,$06
Frame73_Mario39_Tiles:
	db $08,$06,$04,$02,$00
Frame74_Mario40_Tiles:
	db $08,$06,$0A,$04,$00,$02
Frame75_Mario41_Tiles:
	db $0A,$08,$06,$04,$00,$02
Frame76_Mario42_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame77_Mario43_Tiles:
	db $08,$06,$04,$02,$00
Frame78_Mario44_Tiles:
	db $08,$06,$04,$02,$00
Frame79_Mario45_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame80_Mario46_Tiles:
	db $09,$06,$04,$02,$00,$08
Frame81_Mario47_Tiles:
	db $08,$06,$04,$00,$02
Frame82_Mario48_Tiles:
	db $08,$06,$04,$02,$00
Frame83_Mario49_Tiles:
	db $06,$04,$08,$02,$00
Frame84_Mario50_Tiles:
	db $06,$04,$02,$08,$00
Frame85_Mario51_Tiles:
	db $04,$07,$02,$00,$06
Frame86_Mario52_Tiles:
	db $08,$06,$04,$02,$00
Frame87_Mario53_Tiles:
	db $08,$06,$04,$02,$00
Frame88_Mario54_Tiles:
	db $09,$06,$04,$02,$00,$08
Frame89_Mario55_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame90_Mario56_Tiles:
	db $06,$04,$09,$02,$00,$08
Frame91_Mario57_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame92_Mario58_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame93_Mario59_Tiles:
	db $09,$06,$04,$02,$00,$08
Frame94_Mario60_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame95_Mario61_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame96_Mario62_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame97_Mario63_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame98_Mario64_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame99_Mario65_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame100_Mario66_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame101_Mario67_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame102_Mario68_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame103_Mario69_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame104_Mario70_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame105_Mario71_Tiles:
	db $06,$09,$04,$02,$00,$08
Frame106_Mario72_Tiles:
	db $06,$09,$04,$02,$00,$08
;>EndTable


;>Table: Properties
;>Description: Properties of each tile of each frame
;>ValuesSize: 8
Properties:
    
Frame0_Bowser0_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame1_Bowser1_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame2_Bowser2_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame3_Bowser3_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame4_Bowser4_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame5_Bowser5_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame6_Bowser6_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame7_Bowser7_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame8_Bowser8_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame9_Bowser9_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame10_Bowser10_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame11_Bowser11_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame12_Bowser12_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame13_Bowser13_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame14_Bowser14_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame15_Bowser15_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame16_Bowser16_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame17_Bowser17_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame18_Bowser18_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame19_Bowser19_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame20_Bowser20_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame21_Bowser21_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame22_Bowser22_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame23_Bowser23_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame24_Bowser24_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame25_Bowser25_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame26_Bowser26_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame27_Bowser27_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame28_Bowser28_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame29_Bowser29_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame30_Bowser30_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame31_Bowser31_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame32_Bowser32_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame33_Bowser33_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame34_Bowser34_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D
Frame35_Bowser35_Properties:
	db $2D,$2D,$2D,$2D,$2D
Frame36_Bowser36_Properties:
	db $2D,$2D,$2D,$2D
Frame37_Bowser37_Properties:
	db $2D,$2D,$2D,$2D
Frame38_Mario0_Properties:
	db $29,$29,$29,$29,$29,$29
Frame39_Mario1_Properties:
	db $29,$29,$29,$29,$29,$29
Frame40_Mario2_Properties:
	db $29,$29,$29,$29,$29,$29
Frame41_Mario3_Properties:
	db $29,$29,$29,$29,$29,$29
Frame42_Mario4_Properties:
	db $29,$29,$29,$29,$29,$29
Frame43_Mario5_Properties:
	db $29,$29,$29,$29,$29,$29
Frame44_Mario6_Properties:
	db $29,$29,$29,$29,$29,$29
Frame45_Mario7_Properties:
	db $29,$29,$29,$29,$29,$29
Frame46_Mario8_Properties:
	db $29,$29,$29,$29,$29,$29
Frame47_Mario9_Properties:
	db $29,$29,$29,$29,$29,$29
Frame48_Mario10_Properties:
	db $29,$29,$29,$29,$29,$29
Frame49_Mario11_Properties:
	db $29,$29,$29,$29,$29,$29
Frame50_Mario12_Properties:
	db $29,$29,$29,$29,$29,$29
Frame51_Mario13_Properties:
	db $29,$29,$29,$29,$29,$29
Frame52_Mario14_Properties:
	db $29,$29,$29,$29,$29,$29
Frame53_Mario15_Properties:
	db $29,$29,$29,$29,$29,$29
Frame54_Mario16_Properties:
	db $29,$29,$29,$29,$29,$29
Frame55_Mario17_Properties:
	db $29,$29,$29,$29,$29,$29
Frame56_Mario18_Properties:
	db $29,$29,$29,$29,$29,$29
Frame57_Mario19_Properties:
	db $29,$29,$29,$29,$29,$29
Frame58_Mario20_Properties:
	db $29,$29,$29,$29,$29,$29
Frame59_Mario21_Properties:
	db $29,$29,$29,$29,$29,$29
Frame60_Mario22_Properties:
	db $29,$29,$29,$29,$29,$29
Frame61_Mario23_Properties:
	db $29,$29,$29,$29,$29,$29
Frame62_Mario24_Properties:
	db $29,$29,$29,$29,$29,$29
Frame63_Mario25_Properties:
	db $29,$29,$29,$29,$29,$29
Frame64_Mario26_Properties:
	db $29,$29,$29,$29,$29,$29
Frame65_Mario27_Properties:
	db $29,$29,$29,$29,$29,$29
Frame66_Mario28_Properties:
	db $29,$29,$29,$29,$29,$29
Frame67_Mario29_Properties:
	db $29,$29,$29,$29,$29,$29
Frame68_Mario30_Properties:
	db $29,$29,$29,$29,$29,$29
Frame69_Mario31_Properties:
	db $29,$29,$29,$29,$29,$29
Frame70_Mario32_Properties:
	db $29,$29,$29,$29,$29,$29
Frame71_Mario33_Properties:
	db $29,$29,$29,$29,$29,$29
Frame72_Mario38_Properties:
	db $29,$29,$29,$29,$29
Frame73_Mario39_Properties:
	db $29,$29,$29,$29,$29
Frame74_Mario40_Properties:
	db $29,$29,$29,$29,$29,$29
Frame75_Mario41_Properties:
	db $29,$29,$29,$29,$29,$29
Frame76_Mario42_Properties:
	db $29,$29,$29,$29,$29,$29
Frame77_Mario43_Properties:
	db $29,$29,$29,$29,$29
Frame78_Mario44_Properties:
	db $29,$29,$29,$29,$29
Frame79_Mario45_Properties:
	db $29,$29,$29,$29,$29,$29
Frame80_Mario46_Properties:
	db $29,$29,$29,$29,$29,$29
Frame81_Mario47_Properties:
	db $29,$29,$29,$29,$29
Frame82_Mario48_Properties:
	db $29,$29,$29,$29,$29
Frame83_Mario49_Properties:
	db $29,$29,$29,$29,$29
Frame84_Mario50_Properties:
	db $29,$29,$29,$29,$29
Frame85_Mario51_Properties:
	db $29,$29,$29,$29,$29
Frame86_Mario52_Properties:
	db $29,$29,$29,$29,$29
Frame87_Mario53_Properties:
	db $29,$29,$29,$29,$29
Frame88_Mario54_Properties:
	db $29,$29,$29,$29,$29,$29
Frame89_Mario55_Properties:
	db $29,$29,$29,$29,$29,$29
Frame90_Mario56_Properties:
	db $29,$29,$29,$29,$29,$29
Frame91_Mario57_Properties:
	db $29,$29,$29,$29,$29,$29
Frame92_Mario58_Properties:
	db $29,$29,$29,$29,$29,$29
Frame93_Mario59_Properties:
	db $29,$29,$29,$29,$29,$29
Frame94_Mario60_Properties:
	db $29,$29,$29,$29,$29,$29
Frame95_Mario61_Properties:
	db $29,$29,$29,$29,$29,$29
Frame96_Mario62_Properties:
	db $29,$29,$29,$29,$29,$29
Frame97_Mario63_Properties:
	db $29,$29,$29,$29,$29,$29
Frame98_Mario64_Properties:
	db $29,$29,$29,$29,$29,$29
Frame99_Mario65_Properties:
	db $29,$29,$29,$29,$29,$29
Frame100_Mario66_Properties:
	db $29,$29,$29,$29,$29,$29
Frame101_Mario67_Properties:
	db $29,$29,$29,$29,$29,$29
Frame102_Mario68_Properties:
	db $29,$29,$29,$29,$29,$29
Frame103_Mario69_Properties:
	db $29,$29,$29,$29,$29,$29
Frame104_Mario70_Properties:
	db $29,$29,$29,$29,$29,$29
Frame105_Mario71_Properties:
	db $29,$29,$29,$29,$29,$29
Frame106_Mario72_Properties:
	db $29,$29,$29,$29,$29,$29
;>EndTable
;>Table: XDisplacements
;>Description: X Displacement of each tile of each frame
;>ValuesSize: 8
XDisplacements:
    
Frame0_Bowser0_XDisp:
	db $01,$04,$04,$04,$10,$12
Frame1_Bowser1_XDisp:
	db $01,$04,$04,$04,$10,$12
Frame2_Bowser2_XDisp:
	db $01,$04,$04,$04,$0F,$12
Frame3_Bowser3_XDisp:
	db $01,$04,$04,$04,$0E,$12
Frame4_Bowser4_XDisp:
	db $01,$04,$04,$04,$0E,$12
Frame5_Bowser5_XDisp:
	db $01,$04,$04,$04,$0D,$12
Frame6_Bowser6_XDisp:
	db $01,$04,$04,$04,$0A,$14
Frame7_Bowser7_XDisp:
	db $01,$04,$04,$04,$0A,$13
Frame8_Bowser8_XDisp:
	db $01,$04,$04,$04,$0A,$12
Frame9_Bowser9_XDisp:
	db $01,$04,$04,$04,$0A,$12
Frame10_Bowser10_XDisp:
	db $01,$04,$04,$04,$0B,$13
Frame11_Bowser11_XDisp:
	db $01,$04,$04,$04,$0A,$13
Frame12_Bowser12_XDisp:
	db $01,$04,$04,$04,$0B,$14
Frame13_Bowser13_XDisp:
	db $01,$04,$04,$04,$0B,$14
Frame14_Bowser14_XDisp:
	db $01,$04,$04,$04,$0D,$13
Frame15_Bowser15_XDisp:
	db $01,$04,$04,$04,$0D,$13
Frame16_Bowser16_XDisp:
	db $01,$04,$04,$04,$0F,$14
Frame17_Bowser17_XDisp:
	db $01,$04,$04,$04,$0F,$14
Frame18_Bowser18_XDisp:
	db $01,$04,$04,$04,$0E,$14
Frame19_Bowser19_XDisp:
	db $01,$04,$04,$04,$0D,$13
Frame20_Bowser20_XDisp:
	db $01,$04,$04,$04,$0D,$14
Frame21_Bowser21_XDisp:
	db $01,$04,$04,$04,$0B,$14
Frame22_Bowser22_XDisp:
	db $01,$04,$04,$04,$0B,$13
Frame23_Bowser23_XDisp:
	db $01,$04,$04,$04,$0A,$13
Frame24_Bowser24_XDisp:
	db $01,$04,$04,$04,$0A,$12
Frame25_Bowser25_XDisp:
	db $01,$04,$04,$04,$0A,$13
Frame26_Bowser26_XDisp:
	db $01,$04,$04,$04,$0A,$13
Frame27_Bowser27_XDisp:
	db $01,$04,$04,$04,$0A,$13
Frame28_Bowser28_XDisp:
	db $01,$04,$04,$04,$0A,$14
Frame29_Bowser29_XDisp:
	db $01,$04,$04,$04,$0D,$14
Frame30_Bowser30_XDisp:
	db $01,$04,$04,$04,$0E,$12
Frame31_Bowser31_XDisp:
	db $01,$04,$04,$04,$0F,$11
Frame32_Bowser32_XDisp:
	db $01,$04,$04,$04,$0F,$11
Frame33_Bowser33_XDisp:
	db $01,$04,$04,$04,$10,$12
Frame34_Bowser34_XDisp:
	db $01,$04,$04,$04,$10,$12
Frame35_Bowser35_XDisp:
	db $01,$07,$0C,$15,$17
Frame36_Bowser36_XDisp:
	db $01,$08,$13,$14
Frame37_Bowser37_XDisp:
	db $01,$08,$0F,$16
Frame38_Mario0_XDisp:
	db $01,$04,$04,$04,$10,$12
Frame39_Mario1_XDisp:
	db $01,$04,$04,$04,$10,$12
Frame40_Mario2_XDisp:
	db $01,$04,$04,$04,$0E,$11
Frame41_Mario3_XDisp:
	db $01,$04,$04,$04,$0D,$11
Frame42_Mario4_XDisp:
	db $01,$04,$04,$04,$0E,$12
Frame43_Mario5_XDisp:
	db $01,$04,$04,$04,$0A,$14
Frame44_Mario6_XDisp:
	db $01,$04,$04,$04,$09,$13
Frame45_Mario7_XDisp:
	db $01,$04,$04,$04,$0A,$13
Frame46_Mario8_XDisp:
	db $01,$04,$04,$04,$09,$11
Frame47_Mario9_XDisp:
	db $01,$04,$04,$04,$09,$11
Frame48_Mario10_XDisp:
	db $01,$04,$04,$04,$0A,$12
Frame49_Mario11_XDisp:
	db $01,$04,$04,$04,$0A,$13
Frame50_Mario12_XDisp:
	db $01,$04,$04,$04,$0A,$13
Frame51_Mario13_XDisp:
	db $01,$04,$04,$04,$0B,$14
Frame52_Mario14_XDisp:
	db $01,$04,$04,$04,$0B,$14
Frame53_Mario15_XDisp:
	db $01,$04,$04,$04,$0D,$13
Frame54_Mario16_XDisp:
	db $01,$04,$04,$04,$0E,$13
Frame55_Mario17_XDisp:
	db $01,$04,$04,$04,$0E,$13
Frame56_Mario18_XDisp:
	db $01,$04,$04,$04,$0D,$13
Frame57_Mario19_XDisp:
	db $01,$04,$04,$04,$0D,$13
Frame58_Mario20_XDisp:
	db $01,$04,$04,$04,$0B,$14
Frame59_Mario21_XDisp:
	db $01,$04,$04,$04,$0A,$13
Frame60_Mario22_XDisp:
	db $01,$04,$04,$04,$0A,$12
Frame61_Mario23_XDisp:
	db $01,$04,$04,$04,$0A,$13
Frame62_Mario24_XDisp:
	db $01,$04,$04,$04,$09,$11
Frame63_Mario25_XDisp:
	db $01,$04,$04,$04,$09,$12
Frame64_Mario26_XDisp:
	db $01,$04,$04,$04,$09,$12
Frame65_Mario27_XDisp:
	db $01,$04,$04,$04,$09,$12
Frame66_Mario28_XDisp:
	db $01,$04,$04,$04,$0A,$14
Frame67_Mario29_XDisp:
	db $01,$04,$04,$04,$0A,$14
Frame68_Mario30_XDisp:
	db $01,$04,$04,$04,$0D,$14
Frame69_Mario31_XDisp:
	db $01,$04,$04,$04,$0F,$11
Frame70_Mario32_XDisp:
	db $01,$04,$04,$04,$0F,$11
Frame71_Mario33_XDisp:
	db $01,$04,$04,$04,$10,$12
Frame72_Mario38_XDisp:
	db $01,$07,$09,$0C,$19
Frame73_Mario39_XDisp:
	db $01,$01,$01,$01,$0B
Frame74_Mario40_XDisp:
	db $FB,$00,$01,$01,$06,$06
Frame75_Mario41_XDisp:
	db $FA,$FE,$01,$01,$04,$07
Frame76_Mario42_XDisp:
	db $01,$03,$03,$03,$0C,$13
Frame77_Mario43_XDisp:
	db $01,$07,$09,$09,$12
Frame78_Mario44_XDisp:
	db $01,$07,$09,$0B,$12
Frame79_Mario45_XDisp:
	db $01,$05,$05,$05,$0E,$15
Frame80_Mario46_XDisp:
	db $FE,$01,$01,$01,$0A,$0E
Frame81_Mario47_XDisp:
	db $FB,$01,$01,$05,$06
Frame82_Mario48_XDisp:
	db $FE,$01,$01,$01,$09
Frame83_Mario49_XDisp:
	db $01,$05,$05,$05,$0D
Frame84_Mario50_XDisp:
	db $01,$06,$08,$09,$10
Frame85_Mario51_XDisp:
	db $01,$06,$06,$06,$14
Frame86_Mario52_XDisp:
	db $00,$01,$01,$01,$0B
Frame87_Mario53_XDisp:
	db $FE,$01,$01,$01,$09
Frame88_Mario54_XDisp:
	db $00,$01,$01,$01,$09,$11
Frame89_Mario55_XDisp:
	db $01,$04,$04,$04,$0B,$14
Frame90_Mario56_XDisp:
	db $01,$06,$07,$07,$0F,$16
Frame91_Mario57_XDisp:
	db $01,$05,$05,$05,$0E,$15
Frame92_Mario58_XDisp:
	db $01,$02,$02,$02,$0D,$12
Frame93_Mario59_XDisp:
	db $00,$01,$01,$01,$0B,$11
Frame94_Mario60_XDisp:
	db $01,$02,$02,$02,$0D,$12
Frame95_Mario61_XDisp:
	db $01,$04,$04,$04,$0E,$14
Frame96_Mario62_XDisp:
	db $01,$05,$05,$05,$0F,$15
Frame97_Mario63_XDisp:
	db $01,$04,$04,$04,$0F,$10
Frame98_Mario64_XDisp:
	db $01,$04,$04,$04,$10,$14
Frame99_Mario65_XDisp:
	db $01,$04,$04,$04,$10,$11
Frame100_Mario66_XDisp:
	db $01,$04,$04,$04,$10,$14
Frame101_Mario67_XDisp:
	db $01,$04,$04,$04,$10,$10
Frame102_Mario68_XDisp:
	db $01,$04,$04,$04,$10,$11
Frame103_Mario69_XDisp:
	db $01,$04,$04,$04,$0F,$11
Frame104_Mario70_XDisp:
	db $01,$04,$04,$04,$0F,$11
Frame105_Mario71_XDisp:
	db $01,$04,$04,$04,$0F,$11
Frame106_Mario72_XDisp:
	db $01,$04,$04,$04,$0F,$11
;>EndTable
;>Table: YDisplacements
;>Description: Y Displacement of each tile of each frame
;>ValuesSize: 8
YDisplacements:
    
Frame0_Bowser0_YDisp:
	db $11,$EF,$F6,$06,$F7,$07
Frame1_Bowser1_YDisp:
	db $11,$EF,$F6,$06,$F7,$07
Frame2_Bowser2_YDisp:
	db $11,$EF,$F6,$06,$F7,$07
Frame3_Bowser3_YDisp:
	db $11,$EF,$F6,$06,$F7,$07
Frame4_Bowser4_YDisp:
	db $11,$EF,$F6,$06,$F7,$07
Frame5_Bowser5_YDisp:
	db $11,$EF,$F6,$06,$F7,$07
Frame6_Bowser6_YDisp:
	db $11,$EF,$F6,$06,$00,$F8
Frame7_Bowser7_YDisp:
	db $11,$EF,$F6,$06,$00,$F8
Frame8_Bowser8_YDisp:
	db $11,$EF,$F6,$06,$00,$F8
Frame9_Bowser9_YDisp:
	db $11,$EF,$F6,$06,$00,$F8
Frame10_Bowser10_YDisp:
	db $11,$EF,$F6,$06,$00,$F8
Frame11_Bowser11_YDisp:
	db $11,$EF,$F6,$06,$00,$F8
Frame12_Bowser12_YDisp:
	db $11,$EF,$F6,$06,$FF,$F7
Frame13_Bowser13_YDisp:
	db $11,$EF,$F6,$06,$FF,$F7
Frame14_Bowser14_YDisp:
	db $11,$EF,$F6,$06,$F7,$07
Frame15_Bowser15_YDisp:
	db $11,$EF,$F6,$06,$F7,$07
Frame16_Bowser16_YDisp:
	db $11,$EF,$F6,$06,$F7,$07
Frame17_Bowser17_YDisp:
	db $11,$EF,$F6,$06,$F7,$07
Frame18_Bowser18_YDisp:
	db $11,$EF,$F6,$06,$F7,$07
Frame19_Bowser19_YDisp:
	db $11,$EF,$F6,$06,$F7,$07
Frame20_Bowser20_YDisp:
	db $11,$EF,$F6,$06,$F7,$07
Frame21_Bowser21_YDisp:
	db $11,$EF,$F6,$06,$FF,$F7
Frame22_Bowser22_YDisp:
	db $11,$EF,$F6,$06,$FF,$F7
Frame23_Bowser23_YDisp:
	db $11,$EF,$F6,$06,$00,$F8
Frame24_Bowser24_YDisp:
	db $11,$EF,$F6,$06,$00,$F8
Frame25_Bowser25_YDisp:
	db $11,$EF,$F6,$06,$00,$F8
Frame26_Bowser26_YDisp:
	db $11,$EF,$F6,$06,$00,$F8
Frame27_Bowser27_YDisp:
	db $11,$EF,$F6,$06,$00,$F8
Frame28_Bowser28_YDisp:
	db $11,$EF,$F6,$06,$00,$F8
Frame29_Bowser29_YDisp:
	db $11,$EF,$F6,$06,$FB,$F7
Frame30_Bowser30_YDisp:
	db $11,$EF,$F6,$06,$F7,$07
Frame31_Bowser31_YDisp:
	db $11,$EF,$F6,$06,$F7,$07
Frame32_Bowser32_YDisp:
	db $11,$EF,$F6,$06,$F7,$07
Frame33_Bowser33_YDisp:
	db $11,$EF,$F6,$06,$F7,$07
Frame34_Bowser34_YDisp:
	db $11,$EF,$F6,$06,$F7,$07
Frame35_Bowser35_YDisp:
	db $11,$01,$F1,$FF,$FD
Frame36_Bowser36_YDisp:
	db $11,$01,$F6,$06
Frame37_Bowser37_YDisp:
	db $12,$02,$F3,$03
Frame38_Mario0_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame39_Mario1_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame40_Mario2_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame41_Mario3_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame42_Mario4_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame43_Mario5_YDisp:
	db $11,$EE,$F6,$06,$00,$F8
Frame44_Mario6_YDisp:
	db $11,$EE,$F6,$06,$00,$F8
Frame45_Mario7_YDisp:
	db $11,$EE,$F6,$06,$00,$F8
Frame46_Mario8_YDisp:
	db $11,$EE,$F6,$06,$00,$F8
Frame47_Mario9_YDisp:
	db $11,$EE,$F6,$06,$00,$F8
Frame48_Mario10_YDisp:
	db $11,$EE,$F6,$06,$00,$F8
Frame49_Mario11_YDisp:
	db $11,$EE,$F6,$06,$00,$F8
Frame50_Mario12_YDisp:
	db $11,$EE,$F6,$06,$00,$F8
Frame51_Mario13_YDisp:
	db $11,$EE,$F6,$06,$FF,$F7
Frame52_Mario14_YDisp:
	db $11,$EE,$F6,$06,$FF,$F7
Frame53_Mario15_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame54_Mario16_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame55_Mario17_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame56_Mario18_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame57_Mario19_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame58_Mario20_YDisp:
	db $11,$EE,$F6,$06,$FF,$F7
Frame59_Mario21_YDisp:
	db $11,$EE,$F6,$06,$FF,$F7
Frame60_Mario22_YDisp:
	db $11,$EE,$F6,$06,$00,$F8
Frame61_Mario23_YDisp:
	db $11,$EE,$F6,$06,$00,$F8
Frame62_Mario24_YDisp:
	db $11,$EE,$F6,$06,$00,$F8
Frame63_Mario25_YDisp:
	db $11,$EE,$F6,$06,$00,$F8
Frame64_Mario26_YDisp:
	db $11,$EE,$F6,$06,$00,$F8
Frame65_Mario27_YDisp:
	db $11,$EE,$F6,$06,$00,$F8
Frame66_Mario28_YDisp:
	db $11,$EE,$F6,$06,$00,$F8
Frame67_Mario29_YDisp:
	db $11,$EE,$F6,$06,$00,$F8
Frame68_Mario30_YDisp:
	db $11,$EE,$F6,$06,$FB,$F7
Frame69_Mario31_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame70_Mario32_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame71_Mario33_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame72_Mario38_YDisp:
	db $14,$04,$F6,$EF,$FF
Frame73_Mario39_YDisp:
	db $EF,$F5,$05,$11,$F8
Frame74_Mario40_YDisp:
	db $F0,$00,$10,$11,$F6,$01
Frame75_Mario41_YDisp:
	db $F0,$F7,$07,$11,$07,$F7
Frame76_Mario42_YDisp:
	db $11,$EF,$F7,$07,$FC,$FA
Frame77_Mario43_YDisp:
	db $11,$01,$EF,$FF,$FC
Frame78_Mario44_YDisp:
	db $11,$01,$FB,$EF,$FD
Frame79_Mario45_YDisp:
	db $11,$EF,$F5,$05,$FA,$F7
Frame80_Mario46_YDisp:
	db $EF,$F5,$05,$11,$F5,$05
Frame81_Mario47_YDisp:
	db $F1,$01,$11,$04,$F4
Frame82_Mario48_YDisp:
	db $F0,$F6,$06,$11,$F7
Frame83_Mario49_YDisp:
	db $11,$EE,$FE,$01,$FE
Frame84_Mario50_YDisp:
	db $11,$01,$F2,$EF,$02
Frame85_Mario51_YDisp:
	db $11,$EE,$F6,$06,$01
Frame86_Mario52_YDisp:
	db $EF,$F6,$06,$11,$FA
Frame87_Mario53_YDisp:
	db $EF,$F6,$06,$11,$F8
Frame88_Mario54_YDisp:
	db $EF,$F6,$06,$11,$FE,$F6
Frame89_Mario55_YDisp:
	db $11,$EF,$F6,$06,$FF,$F7
Frame90_Mario56_YDisp:
	db $11,$01,$EF,$F7,$F9,$04
Frame91_Mario57_YDisp:
	db $11,$EF,$F6,$06,$FB,$F8
Frame92_Mario58_YDisp:
	db $11,$EF,$F5,$05,$FA,$F7
Frame93_Mario59_YDisp:
	db $EF,$F6,$06,$11,$FA,$F7
Frame94_Mario60_YDisp:
	db $11,$EE,$F5,$05,$FB,$F7
Frame95_Mario61_YDisp:
	db $11,$EE,$F6,$06,$FC,$F8
Frame96_Mario62_YDisp:
	db $11,$EE,$F6,$06,$FB,$F8
Frame97_Mario63_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame98_Mario64_YDisp:
	db $11,$EE,$F6,$06,$FA,$F7
Frame99_Mario65_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame100_Mario66_YDisp:
	db $11,$EE,$F6,$06,$F9,$F7
Frame101_Mario67_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame102_Mario68_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame103_Mario69_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame104_Mario70_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame105_Mario71_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
Frame106_Mario72_YDisp:
	db $11,$EE,$F6,$06,$F7,$07
;>EndTable
;>Table: Sizes.
;>Description: size of each tile of each frame
;>ValuesSize: 8
Sizes:
    
Frame0_Bowser0_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame1_Bowser1_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame2_Bowser2_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame3_Bowser3_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame4_Bowser4_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame5_Bowser5_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame6_Bowser6_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame7_Bowser7_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame8_Bowser8_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame9_Bowser9_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame10_Bowser10_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame11_Bowser11_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame12_Bowser12_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame13_Bowser13_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame14_Bowser14_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame15_Bowser15_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame16_Bowser16_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame17_Bowser17_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame18_Bowser18_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame19_Bowser19_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame20_Bowser20_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame21_Bowser21_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame22_Bowser22_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame23_Bowser23_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame24_Bowser24_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame25_Bowser25_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame26_Bowser26_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame27_Bowser27_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame28_Bowser28_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame29_Bowser29_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame30_Bowser30_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame31_Bowser31_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame32_Bowser32_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame33_Bowser33_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame34_Bowser34_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame35_Bowser35_Sizes:
	db $02,$02,$02,$02,$00
Frame36_Bowser36_Sizes:
	db $02,$02,$02,$02
Frame37_Bowser37_Sizes:
	db $02,$02,$02,$02
Frame38_Mario0_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame39_Mario1_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame40_Mario2_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame41_Mario3_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame42_Mario4_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame43_Mario5_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame44_Mario6_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame45_Mario7_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame46_Mario8_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame47_Mario9_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame48_Mario10_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame49_Mario11_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame50_Mario12_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame51_Mario13_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame52_Mario14_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame53_Mario15_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame54_Mario16_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame55_Mario17_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame56_Mario18_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame57_Mario19_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame58_Mario20_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame59_Mario21_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame60_Mario22_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame61_Mario23_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame62_Mario24_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame63_Mario25_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame64_Mario26_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame65_Mario27_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame66_Mario28_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame67_Mario29_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame68_Mario30_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame69_Mario31_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame70_Mario32_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame71_Mario33_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame72_Mario38_Sizes:
	db $02,$02,$02,$00,$00
Frame73_Mario39_Sizes:
	db $00,$02,$02,$02,$02
Frame74_Mario40_Sizes:
	db $02,$02,$00,$02,$02,$02
Frame75_Mario41_Sizes:
	db $00,$02,$02,$02,$02,$02
Frame76_Mario42_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame77_Mario43_Sizes:
	db $02,$02,$02,$02,$02
Frame78_Mario44_Sizes:
	db $02,$02,$02,$02,$02
Frame79_Mario45_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame80_Mario46_Sizes:
	db $00,$02,$02,$02,$02,$00
Frame81_Mario47_Sizes:
	db $02,$02,$02,$02,$02
Frame82_Mario48_Sizes:
	db $00,$02,$02,$02,$02
Frame83_Mario49_Sizes:
	db $02,$02,$00,$02,$02
Frame84_Mario50_Sizes:
	db $02,$02,$02,$00,$02
Frame85_Mario51_Sizes:
	db $02,$00,$02,$02,$00
Frame86_Mario52_Sizes:
	db $00,$02,$02,$02,$02
Frame87_Mario53_Sizes:
	db $02,$02,$02,$02,$02
Frame88_Mario54_Sizes:
	db $00,$02,$02,$02,$02,$00
Frame89_Mario55_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame90_Mario56_Sizes:
	db $02,$02,$00,$02,$02,$00
Frame91_Mario57_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame92_Mario58_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame93_Mario59_Sizes:
	db $00,$02,$02,$02,$02,$00
Frame94_Mario60_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame95_Mario61_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame96_Mario62_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame97_Mario63_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame98_Mario64_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame99_Mario65_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame100_Mario66_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame101_Mario67_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame102_Mario68_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame103_Mario69_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame104_Mario70_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame105_Mario71_Sizes:
	db $02,$00,$02,$02,$02,$00
Frame106_Mario72_Sizes:
	db $02,$00,$02,$02,$02,$00
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
	STA !AnimationIndex,x
	JSR ChangeAnimationFromStart
	PLB
	RTL

ChangeAnimationFromStart_wavebowser:
	STZ !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_wavemario:
	LDA #$01
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_change:
	LDA #$02
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

	LDA !Scratch2
	STA !AnimationFrameIndex,x

	SEP #$10						;X/Y of 8 bits
	LDX !Scratch4					;X = sprite index in 8 bits
RTS
;>EndRoutine

;All words that starts with '>' and finish with '.' will be replaced by Dyzen

AnimationLenght:
	dw $0022,$0022,$0027

AnimationLastTransition:
	dw $0000,$0000,$0026

AnimationIndexer:
	dw $0000,$0022,$0044

Frames:
	
Animation0_wavebowser_Frames:
	db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
	db $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F
	db $20,$21
Animation1_wavemario_Frames:
	db $26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F,$30,$31,$32,$33,$34,$35
	db $36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F,$40,$41,$42,$43,$44,$45
	db $46,$47
Animation2_change_Frames:
	db $22,$23,$24,$25,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F,$50,$51,$52,$53
	db $54,$55,$56,$57,$58,$59,$5A,$5B,$5C,$5D,$5E,$5F,$60,$61,$62,$63
	db $64,$65,$66,$67,$68,$69,$6A

Times:
	
Animation0_wavebowser_Times:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00
Animation1_wavemario_Times:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00
Animation2_change_Times:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00
;>End Animations Section

;Don't Delete or write another >Section Hitbox Interaction or >End Section
;All code between >Section Hitboxes Interaction and >End Hitboxes Interaction Section will be changed by Dyzen : Sprite Maker
;>Section Hitboxes Interaction
;######################################
;######## Interaction Space ###########
;######################################

InteractMarioSprite:

	LDA !State,X
	BEQ +
RTS
+
	LDA.b #HitboxTables
	STA $8A
	LDA.b #HitboxTables>>8
	STA $8B
	LDA.b #HitboxTables>>16
	STA $8C

	LDA #$00
	TAY                     ;Y = Flip Adder, used to jump to the frame with the current flip

	STZ $4A
    LDA !FrameIndex,x		;A 16 bits frame index
	AND #$0F
	STA $49

	%DyzenPlayerNormalSpriteInteraction()
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
	dw $0000,$0000

FrameHitboxesIndexer:
    dw $0000,$0002,$0004,$0006,$0008,$000A,$000C,$000E,$0010,$0012,$0014,$0016,$0018,$001A,$001C,$001E
	dw $0020,$0022,$0024,$0026,$0028,$002A,$002C,$002E,$0030,$0032,$0034,$0036,$0038,$003A,$003C,$003E
	dw $0040,$0042,$0044,$0045,$0046,$0047,$0048,$0049,$004A,$004B,$004C,$004D,$004E,$004F,$0050,$0051
	dw $0052,$0053,$0054,$0055,$0056,$0057,$0058,$0059,$005A,$005B,$005C,$005D,$005E,$005F,$0060,$0061
	dw $0062,$0063,$0064,$0065,$0066,$0067,$0068,$0069,$006A,$006B,$006C,$006D,$006E,$006F,$0070,$0071
	dw $0072,$0073,$0074,$0075,$0076,$0077,$0078,$0079,$007A,$007B,$007C,$007D,$007E,$007F,$0080,$0081
	dw $0082,$0083,$0084,$0085,$0086,$0087,$0088,$0089,$008A,$008B,$008C

FrameHitBoxes:
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
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF

Hitboxes:
HitboxType: 
	dw $0001
HitboxXOffset: 
	dw $0006
HitboxYOffset: 
	dw $FFF5
HitboxWidth: 
	dw $0010
HitboxHeight: 
	dw $0015
HitboxAction1: 
	dw $0000
HitboxAction2: 
	dw $0002
	

;This routine will be executed when mario interact with a standar hitbox.
;It will be excecuted if $0E is 1 after execute Interaction routine
DefaultAction:
	LDA #$01
	STA !State,x

	%DyzenPrepareContactEffect()
	LDA #$00
    %DisplayContactEffect()
RTS
Actions:
	dw CatchPlayer
	dw Nothing
	
;$6C = Left
;$6A = Top
;$6E = Right
;$8D = Bottom
CatchPlayer:

	REP #$20
	LDA #$0001
	STA $4F

	LDA $45
	STA $6C
	LDA $47
	STA $6A
	LDA $49
	STA $6E
	LDA $4B
	STA $1487|!addr
	SEP #$20
RTL

Nothing:
RTL
;>End Hitboxes Interaction Section
