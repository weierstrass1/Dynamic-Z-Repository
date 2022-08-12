!AnimationTables = ($65)

!FramesFlippers = ($67)
!FramesLength = ($69)
!FramesStartPosition = ($6B)
!FramesEndPosition = ($8A)

!Tiles = ($67)
!XDisplacements = ($69)
!YDisplacements = ($6B)
!Sizes = ($8A)

!XPos = $00
!YPos = $06

!XOff = $00
!YOff = $06

!maxtile_pointer = $49

?DyzenGraphicRoutine:

    PHX
    PHB

    LDA $67
    PHA
    PLB

    REP #$20
    LDY #$00
    LDA !AnimationTables,y
    STA $67
    LDY #$02
    LDA !AnimationTables,y
    STA $69
    LDY #$04
    LDA !AnimationTables,y
    STA $6B
    LDY #$06
    LDA !AnimationTables,y
    STA $8A

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
	PHA

    LDY #$0008
    LDA !AnimationTables,y
    STA $67
    LDY #$000A
    LDA !AnimationTables,y
    STA $69
    LDY #$000C
    LDA !AnimationTables,y
    STA $6B
    LDY #$000E
    LDA !AnimationTables,y
    STA $8A

    PLY

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

    LDA !Tiles,y

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

    PLB
    PLX
RTL