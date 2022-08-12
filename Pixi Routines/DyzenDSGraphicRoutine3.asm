!FramesFlippers = ($01,s)
!FramesLength = ($03,s)
!FramesStartPosition = ($05,s)
!FramesEndPosition = ($07,s)
!Tiles = ($09,s)
!XDisplacements = ($0B,s)
!YDisplacements = ($0D,s)
!Sizes = ($0F,s)

!XPos = $00
!YPos = $06

!XOff = $00
!YOff = $06

!maxtile_pointer = $49

?DyzenDSGraphicRoutine:

    %SubStack($0010)

    REP #$20

    LDY #$00
    LDA ($14,s),y
    STA $01,s

    LDY #$02
    LDA ($14,s),y
    STA $03,s

    LDY #$04
    LDA ($14,s),y
    STA $05,s

    LDY #$06
    LDA ($14,s),y
    STA $07,s

    LDY #$08
    LDA ($14,s),y
    STA $09,s

    LDY #$0A
    LDA ($14,s),y
    STA $0B,s

    LDY #$0C
    LDA ($14,s),y
    STA $0D,s

    LDY #$0E
    LDA ($14,s),y
    STA $0F,s

	REP #$30
    LDA $47
    TAY

    LDA $45
	ASL
    CLC
    ADC !FramesFlippers,y
	TAY
	
	LDA !FramesEndPosition,y
	STA $09

	LDA !FramesStartPosition,y
	TAY
	SEP #$20

?.Start
?..loop
	LDX !maxtile_pointer+0
	CPX !maxtile_pointer+4
	BNE ?..ContinueLoop
	JMP ?..no_slot

?..ContinueLoop

;Y Off
	STZ $0D
	LDA !YDisplacements,y
	STA $0C
	BPL ?+
	LDA #$FF
	STA $0D
?+
	REP #$20
	LDA $0C
	CLC 
	ADC !YOff
	BPL ?+
	CMP #$FFF1
	BCS ?++
	SEP #$20
	BRA ?..SkipSlot
?+
	CMP #$00E0
	BCC ?++
	SEP #$20
	BRA ?..SkipSlot
?++
	SEP #$20
if !sa1
	STA $400001,x
else 
	STA !TileYPosition,x
endif

;X Off
	STZ $0D
	LDA !XDisplacements,y
	STA $0C
	BPL ?+
	LDA #$FF
	STA $0D
?+
	REP #$20
	LDA $0C
	CLC 
	ADC !XOff
	BPL ?+
	CMP #$FFF1
	BCS ?++
	SEP #$20
	BRA ?..SkipSlot
?+
	CMP #$0100
	BCC ?++
	SEP #$20
	BRA ?..SkipSlot
?++
	SEP #$20
if !sa1
	STA $400000,x
else 
	STA !TileXPosition,x
endif

	LDA #$01
	STA !Scratch52

    %RemapOamTile("!Tiles,y", !ScratchE)

if !sa1
	STA $400002,x
	LDA $4F
	EOR !ScratchF
	STA $400003,x
    DEX #4
else
	STA !TileCode,x
	LDA $4F
	EOR !ScratchF
	STA !TileProperty,x
    INX #4
endif

    STX !maxtile_pointer+0
    
    LDX !maxtile_pointer+2

	REP #$20

	LDA $0C
	CLC 
	ADC !XOff
	SEP #$20
	BPL ?..clearHB
?..setHB
	LDA #$01
	BRA ?++
?..clearHB
	LDA #$00
?++
	ORA !Sizes,y

if !sa1
    STA $400000,x
    DEX
else
    STA !TileSize460,x
    INX
endif
    STX !maxtile_pointer+2

?..SkipSlot
	DEY
	BMI ?..no_slot
	CPY $09
	BCC ?..no_slot
	JMP ?..loop

?..no_slot
	SEP #$10
	
	
%RTLN($0010)