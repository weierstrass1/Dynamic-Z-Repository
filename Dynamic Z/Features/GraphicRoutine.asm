
GetSlot:
    REP #$20
    LDA DZ_PPUMirrors_OAM_LastSlot    
    TAY
    SEP #$20
RTS

!OffsetX = !Scratch0
!OffsetY = !Scratch2
!SizeAndPriority = !Scratch4
!TileSizeAndPriority
!TileXPosition
!TileYPosition
!TileProperty
!TileCode

CheckTopLeft:
    db $FFF8,$00F0

IsValid:
    PHX
    REP #$20
    LDX !SizeAndPriority

    LDA !OffsetY
    SEC
    SBC !Layer1Y
    CMP CheckTopLeft,x
    BCS .CheckH
    
    CMP #$00E0
    BCC .CheckH
    PLX
    SEP #$20
    CLC
RTS
+
    STA !OffsetY

    LDA !OffsetX
    SEC
    SBC !Layer1X
    CMP CheckTopLeft,x
    BCC +
    STA !OffsetX
    LDA !SizeAndPriority
    INC A
    PLX
    SEP #$20
    SEC
RTS
+
    CMP #$0100
    BCS +
    LDA !SizeAndPriority
    PLX
    SEP #$20
    SEC
RTS
+
    PLX
    SEP #$20
    CLC
RTS

macro SetTile(offsetX, offsetY, property, tile)
    STA !TileSizeAndPriority,x
    LDA <offsetX>
    STA !TileXPosition,x
    LDA <offsetY>
    STA !TileYPosition,x
    LDA <property>
    STA !TileProperty,x
    LDA <tile>
    STA !TileCode,x
endmacro

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

macro GraphicRoutine1Tile(name, property)
<name>:

    LDA DZ_PPUMirrors_OAM_LastSlot
    BMI +    
    TAX

    JSR IsValid
    BCC +
    %SetTile(!OffsetX, !OffsetY, "<property>", !Tile)
    PHX
    LDA !SizeAndPriority
    AND #$FF
    LSR
    LSR
    TAX
    LDA DZ_PPUMirrors_OAM_PriorityLength,x
    INC A
    STA DZ_PPUMirrors_OAM_PriorityLength,x
    LDA LDA DZ_PPUMirrors_OAM_LastSlot
    INC A
    STA DZ_PPUMirrors_OAM_LastSlot
    PLX
    SEC
RTL
+
    CLC
RTL

endmacro

%GraphicRoutine1Tile("GraphicRoutine1Tile", !Property)
%GraphicRoutine1Tile("GraphicRoutine1TileWithFlip", "!Property : EOR !Flip")
%GraphicRoutine1Tile("GraphicRoutine1TileWithPalette", "!Property : ORA !Palette")
%GraphicRoutine1Tile("GraphicRoutine1TileWithFlipAndPalette", "!Property : ORA !Palette : EOR !Flip")
