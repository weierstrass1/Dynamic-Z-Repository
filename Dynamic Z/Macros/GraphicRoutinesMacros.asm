!OffsetX = !Scratch0
!OffsetY = !Scratch2
!SizeAndPriority = !Scratch4
!TileSizeAndPriority
!TileXPosition
!TileYPosition
!TileProperty
!TileCode

!XPosition = !Scratch6
!YPosition = !Scratch8
!Property = !ScratchA
!Tile = !ScratchB
!Flip = !ScratchC
!Palette = !ScratchD
!DrawSomething = !ScratchE
!TableSize = !Scratch45
!OffsetXTable = !Scratch47
!OffsetYTable = !Scratch49
!TileSizeTable = !Scratch4B
!TilePropertyTable = !Scratch4D
!TileTable = !Scratch4F

macro GraphicRoutine1Tile(XPositionl, XPositionh, YPositionl, YPositionh, property, tile, size)
    LDA <XPositionl>
    STA !OffsetX
    LDA <XPositionh>
    STA !OffsetX+1

    LDA <YPositionl>
    STA !OffsetY
    LDA <YPositionh>
    STA !OffsetY+1

    LDA <tile>
    STA !Tile
    
    LDA <property>
    STA !Property

    JSL !GraphicRoutine1Tile
endmacro

macro GraphicRoutine1TileWithFlip(XPositionl, XPositionh, YPositionl, YPositionh, property, Flip, tile, size)
    LDA <XPositionl>
    STA !OffsetX
    LDA <XPositionh>
    STA !OffsetX+1

    LDA <YPositionl>
    STA !OffsetY
    LDA <YPositionh>
    STA !OffsetY+1

    LDA <tile>
    STA !Tile

    LDA <property>
    STA !Property

    LDA <Flip>
    STA !Flip

    JSL !GraphicRoutine1TileWithFlip
endmacro

macro GraphicRoutine1TileWithPalette(XPositionl, XPositionh, YPositionl, YPositionh, property, Palette, tile, size)
    LDA <XPositionl>
    STA !OffsetX
    LDA <XPositionh>
    STA !OffsetX+1

    LDA <YPositionl>
    STA !OffsetY
    LDA <YPositionh>
    STA !OffsetY+1

    LDA <tile>
    STA !Tile
    
    LDA <property>
    STA !Property

    LDA <Palette>
    STA !Palette

    JSL !GraphicRoutine1TileWithPalette
endmacro

macro GraphicRoutine1TileWithFlipAndPalette(XPositionl, XPositionh, YPositionl, YPositionh, property, Flip, Palette, tile, size)
    LDA <XPositionl>
    STA !OffsetX
    LDA <XPositionh>
    STA !OffsetX+1

    LDA <YPositionl>
    STA !OffsetY
    LDA <YPositionh>
    STA !OffsetY+1

    LDA <tile>
    STA !Tile
    
    LDA <property>
    STA !Property

    LDA <Flip>
    STA !Flip
    LDA <Palette>
    STA !Palette

    JSL !GraphicRoutine1TileWithFlipAndPalette
endmacro

macro GraphicRoutineStart()
    STZ !DrawSomething
    LDA DZ_PPUMirrors_OAM_LastSlot    
    BMI +
    TAX

    LDA !TableSize
    TAY
-
endmacro

macro SetOffsetJustX()
    LDA #$00
    STA !OffsetX+1
    LDA (!OffsetXTable),y
    STA !OffsetX
    BPL ?+
    LDA #$FF
    STA !OffsetX+1
?+
    REP #$20
    LDA !OffsetX
    CLC
    ADC !XPosition
    STA !OffsetX
    SEP #$20
endmacro

macro SetOffsetJustY()
    LDA #$00
    STA !OffsetY+1
    LDA (!OffsetYTable),y
    STA !OffsetY
    BPL ?+
    LDA #$FF
    STA !OffsetY+1
?+
    REP #$20
    LDA !OffsetY
    CLC
    ADC !XPosition
    STA !OffsetY
    SEP #$20
endmacro

macro SetOffset()
    LDA #$00
    STA !OffsetX+1
    LDA (!OffsetXTable),y
    STA !OffsetX
    BPL ?+
    LDA #$FF
    STA !OffsetX+1
?+
    LDA #$00
    STA !OffsetY+1
    LDA (!OffsetYTable),y
    STA !OffsetY
    BPL ?+
    LDA #$FF
    STA !OffsetY+1
?+
    REP #$20
    LDA !OffsetX
    CLC
    ADC !XPosition
    STA !OffsetX

    LDA !OffsetY
    CLC
    ADC !XPosition
    STA !OffsetY
    SEP #$20
endmacro

macro GraphicRoutineSetTileAndNext(property, size)
    <size>
    JSR IsValid
    BCC ?.next
    %SetTile(!OffsetX, !OffsetY, "<property>", "(!TileTable),y")
    INC !DrawSomething
    BPL ?.next

?.next
endmacro

macro EndGraphicRoutine()
    INY
    DEX
    BPL -
    TYA
    STA DZ_PPUMirrors_OAM_LastSlot
+
    LDA !DrawSomething
    BEQ ?+
    PHX
    PHA
    LDA !SizeAndPriority
    LSR
    LSR
    TAX
    PLA
    CLC
    ADC DZ_PPUMirrors_OAM_PriorityLength,x
    STA DZ_PPUMirrors_OAM_PriorityLength,x
    PLX
    
    SEC
RTL
?+
    CLC
RTL
endmacro

macro BuildGraphicRoutine(sameX, sameY, sameProperty, sameSize, withFlip, withPalette)
    if sameProperty == !True
        !stringProp = "!Property"
        if withFlip == !True || withPalette == !True
            LDA !Property
        endif
        if withPalette == !True
            ORA !Palette
        endif
        if withFlip == !True
            EOR !Flip
        endif
        if withFlip == !True || withPalette == !True
            STA !Property
        endif
    else
        if withFlip == !True || withPalette == !True
            !stringProp = "(!TilePropertyTable),y : ORA !Palette : EOR !Flip"
        elseif withPalette == !True
            !stringProp = "(!TilePropertyTable),y : ORA !Palette"
        elseif withFlip == !True
            !stringProp = "(!TilePropertyTable),y : EOR !Flip"
        else
            !stringProp = "(!TilePropertyTable),y"
        endif
    endif

    if sameSize
        !stringSize = ""
    else
        !stringSize = "LDA !SizeAndPriority : AND #$03 : ORA (!TilePropertyTable),y : STA !SizeAndPriority"
    endif

    %GraphicRoutineStart()
    if sameX == !False && sameY == !False
        %SetOffset()
    elseif sameX == !True
        %SetOffsetJustY()
    else
        %SetOffsetJustX()
    endif

    %GraphicRoutineSetTileAndNext("!stringProp", "!stringSize")
    %EndGraphicRoutine()
endmacro