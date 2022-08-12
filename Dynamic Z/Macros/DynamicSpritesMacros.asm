macro FindSpace(DSSlotUsed)

    LDA <DSSlotUsed>
    STA !Scratch0

    JSL !FindSpace
endmacro

macro CheckSlot(FrameRateMode, NumberOf16x16Tiles, SpriteNumber, SpriteTypeAndSlot, SpriteUsedSlot)
    
    PHX

    TSC
    PHA

if <SpriteTypeAndSlot> < $80
    TXA
    AND #$1F
else
    LDA #$00
endif
    ORA #<SpriteTypeAndSlot>
    PHA

    LDA <FrameRateMode>
    PHA

    LDA <SpriteNumber>
    PHA

    LDA <NumberOf16x16Tiles>
    PHA
    JSL !CheckSlot
    BCS ?+
if !sa1
    PLA
    PLA
    PLA
    PLA
    PLA
else
    LDA #$01
    XBA
    LDA $05,s
    TCS
endif

    PLX
    STZ <SpriteNumber>
    BRA ?++
?+
if !sa1
    PLA
    PLA
    PLA
    PLA
    PLA
else
    LDA #$01
    XBA
    LDA $05,s
    TCS
endif

    TXA
    PLX
	STA.l <SpriteUsedSlot>,x
?++
endmacro

macro CheckSlotNormalSprite(NumberOf16x16Tiles, SpriteTypeAndSlot)
    
    TSC
    PHA

if <SpriteTypeAndSlot> < $80
    TXA
    AND #$1F
else
    LDA #$00
endif
    ORA #<SpriteTypeAndSlot>
    PHA

    LDA !ExtraByte1,x
    CLC
    ROL
    ROL
    ROL
    AND #$03
    PHA

    LDA !SpriteNumberNormal,x
    PHA

    LDA <NumberOf16x16Tiles>
    PHA
    JSL !CheckSlot
    BCS ?+
    
if !sa1
    PLA
    PLA
    PLA
    PLA
    PLA
else
    LDA #$01
    XBA
    LDA $05,s
    TCS
endif

    LDX $15E9|!addr
    STZ !SpriteStatus,x
    LDA !SpriteLoadStatus,x
    TAX
    LDA #$00
    STA !SpriteLoadTable,x
    LDX $15E9|!addr

RTL
?+
if !sa1
    PLA
    PLA
    PLA
    PLA
    PLA
else
    LDA #$01
    XBA
    LDA $05,s
    TCS
endif

    TXA
    LDX $15E9|!addr
	STA.l DZ_DS_Loc_US_Normal,x
endmacro

macro CheckSlotNormalSpriteNoRemove(NumberOf16x16Tiles, SpriteTypeAndSlot)
    
    TSC
    PHA

if <SpriteTypeAndSlot> < $80
    TXA
    AND #$1F
else
    LDA #$00
endif
    ORA #<SpriteTypeAndSlot>
    PHA

    LDA !ExtraByte1,x
    CLC
    ROL
    ROL
    ROL
    AND #$03
    PHA

    LDA !SpriteNumberNormal,x
    PHA

    LDA <NumberOf16x16Tiles>
    PHA
    JSL !CheckSlot
    BCS ?+
    
if !sa1
    PLA
    PLA
    PLA
    PLA
    PLA
else
    LDA #$01
    XBA
    LDA $05,s
    TCS
endif
    LDX $15E9|!addr
    CLC
    BRA ?++
?+
if !sa1
    PLA
    PLA
    PLA
    PLA
    PLA
else
    LDA #$01
    XBA
    LDA $05,s
    TCS
endif

    TXA
    LDX $15E9|!addr
	STA.l DZ_DS_Loc_US_Normal,x
    SEC
?++
endmacro

macro DynamicRoutine(VRAMOffset, ResourceAddr, ResourceBNK, ResourceOffset, size)
    PHX                     ;B

    TSC
    PHA                     ;B

    LDA <size>              ;A
    PHA

    LDA <VRAMOffset>        ;9
    PHA

    LDA <ResourceBNK>     ;8
    PHA

    REP #$20
    LDA <ResourceAddr>
    CLC
    ADC <ResourceOffset>
    PHA                     ;6
    SEP #$20
    JSL !DynamicRoutine

if !sa1
    PLA
    PLA
    PLA
    PLA
    PLA
    PLA
else
    LDA #$01
    XBA
    LDA $06,s
    TCS
endif

    PLX

endmacro

macro GFXTabDef(index)
    !GraphicsTable #= read3(!SpriteNumberToGraphics+(3*<index>))
endmacro

macro GFXDef(offset)
    !GFX<offset> #= read3(!GraphicsTable+(3*$<offset>))
endmacro

macro CheckEvenOrOdd(DSLocUS)
	LDA.l <DSLocUS>,x
    JSL !CheckEvenOrOdd
endmacro

macro GetVramDisp(DSLocUS)
	LDA.l <DSLocUS>,x
    JSL !GetVramDisp
endmacro

macro GetVramDispDynamicRoutine(DSLocUS)
	LDA <DSLocUS>,x
    JSL !GetVramDispDynamicRoutine
endmacro

macro RemapOamTile(Tile, Offset)

    LDA <Tile>
    PHA

    LDA <Offset>
    PHA
    JSL !RemapOamTile
    PLA
    PLA
endmacro

macro EasyNormalSpriteDynamicRoutine(CurrentFrame, LastFrame, GFXAddr, GFXBNK, OffsetTable, SizeTable, LastLineOffset)

    LDA <CurrentFrame>
    STA !Scratch4F
    LDA <LastFrame>
    STA !Scratch50

    LDA <GFXBNK>
    STA !Scratch49

    LDA <LastLineOffset>
    STA !Scratch4E

    REP #$20
    LDA <GFXAddr>
    STA !Scratch47
    LDA <OffsetTable>
    STA !Scratch4A
    LDA <SizeTable>
    STA !Scratch4C
    SEP #$20

    LDA #$01
    JSL !EasyNormalSpriteDynamicRoutine
    BCC ?+

    LDA <CurrentFrame>
    STA <LastFrame>
    SEC
?+
endmacro

macro EasyNormalSpriteDynamicRoutineFixedGFX(CurrentFrame, LastFrame, GFX, OffsetTable, SizeTable, LastLineOffset)
    %EasyNormalSpriteDynamicRoutine("<CurrentFrame>", "<LastFrame>", "#<GFX>", "#<GFX>>>16", "<OffsetTable>", "<SizeTable>", "<LastLineOffset>")
endmacro

macro EasyNormalSpriteDynamicRoutineNoFindSpace(CurrentFrame, LastFrame, GFXAddr, GFXBNK, OffsetTable, SizeTable, LastLineOffset)

    LDA <CurrentFrame>
    STA !Scratch4F
    LDA <LastFrame>
    STA !Scratch50

    LDA <GFXBNK>
    STA !Scratch49

    LDA <LastLineOffset>
    STA !Scratch4E

    REP #$20
    LDA <GFXAddr>
    STA !Scratch47
    LDA <OffsetTable>
    STA !Scratch4A
    LDA <SizeTable>
    STA !Scratch4C
    SEP #$20

    LDA #$00
    JSL !EasyNormalSpriteDynamicRoutine
    BCC ?+

    LDA <CurrentFrame>
    STA <LastFrame>
    SEC
?+
endmacro

macro EasyNormalSpriteDynamicRoutineNoFindSpaceFixedGFX(CurrentFrame, LastFrame, GFX, OffsetTable, SizeTable, LastLineOffset)
    %EasyNormalSpriteDynamicRoutineNoFindSpace("<CurrentFrame>", "<LastFrame>", "#<GFX>", "#<GFX>>>16", "<OffsetTable>", "<SizeTable>", "<LastLineOffset>")
endmacro

macro EasySpriteDynamicRoutine(DSLocUS,CurrentFrame, LastFrame, GFXAddr, GFXBNK, OffsetTable, SizeTable, LastLineOffset)

    PHX

    PHX
    LDA <DSLocUS>
    STA !Scratch51
	TAX
    LDA.l DZ_Timer
    CMP DZ_DS_Loc_SafeFrame,x
    BNE ?+
    PLX
    PLX
    CLC
    BRA ?++
?+
    STA.l DZ_DS_Loc_SafeFrame,x
    PLX

    LDA <CurrentFrame>
    STA !Scratch4F
    LDA <LastFrame>
    STA !Scratch50

    LDA <GFXBNK>
    STA !Scratch49

    LDA <LastLineOffset>
    STA !Scratch4E

    REP #$20
    LDA <GFXAddr>
    STA !Scratch47
    LDA <OffsetTable>
    STA !Scratch4A
    LDA <SizeTable>
    STA !Scratch4C
    SEP #$20

    LDX #$00
    LDA #$01
    JSL !EasySpriteDynamicRoutine
    BCC ?+

    PLX
    LDA <CurrentFrame>
    STA <LastFrame>
    SEC
    BRA ?++
?+
    PLX
    CLC
?++
endmacro

macro EasySpriteDynamicRoutineFixedGFX(DSLocUS,CurrentFrame, LastFrame, GFX, OffsetTable, SizeTable, LastLineOffset)
    %EasySpriteDynamicRoutine("<DSLocUS>","<CurrentFrame>", "<LastFrame>", "#<GFX>", "#<GFX>>>16", "<OffsetTable>", "<SizeTable>", "<LastLineOffset>")
endmacro

macro EasySpriteDynamicRoutineNoFindSpace(DSLocUS,CurrentFrame, LastFrame, GFXAddr, GFXBNK, OffsetTable, SizeTable, LastLineOffset)

    PHX

    PHX
    LDA <DSLocUS>
    STA !Scratch51
	TAX
    LDA.l DZ_Timer
    CMP DZ_DS_Loc_SafeFrame,x
    BNE ?+
    PLX
    PLX
    CLC
    BRA ?++
?+
    STA.l DZ_DS_Loc_SafeFrame,x
    PLX

    LDA <CurrentFrame>
    STA !Scratch4F
    LDA <LastFrame>
    STA !Scratch50

    LDA <GFXBNK>
    STA !Scratch49

    LDA <LastLineOffset>
    STA !Scratch4E

    REP #$20
    LDA <GFXAddr>
    STA !Scratch47
    LDA <OffsetTable>
    STA !Scratch4A
    LDA <SizeTable>
    STA !Scratch4C
    SEP #$20

    LDX #$00
    LDA #$00
    JSL !EasySpriteDynamicRoutine
    BCC ?+

    PLX
    LDA <CurrentFrame>
    STA <LastFrame>
    SEC
    BRA ?++
?+
    PLX
    CLC
?++
endmacro

macro EasySpriteDynamicRoutineNoFindSpaceFixedGFX(DSLocUS,CurrentFrame, LastFrame, GFX, OffsetTable, SizeTable, LastLineOffset)
    %EasySpriteDynamicRoutineNoFindSpace("<DSLocUS>","<CurrentFrame>", "<LastFrame>", "#<GFX>", "#<GFX>>>16", "<OffsetTable>", "<SizeTable>", "<LastLineOffset>")
endmacro