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

;$009079
ReservedItemGraphicRoutine:
    PHX
    LDX $0DC2|!addr
    BNE +
    PLX
RTS
+
    LDA ReservedItemTile,X
    STA $01
    LDA ReservedItemPalette,X
    STA $00

    CPX #$03
    BNE +
    LDA $13
    LSR
    AND #$03
    TAX
    LDA ReservedItemStarPalette,x
    STA $00
+

    LDA DZ_PPUMirrors_OAM_LastSlot    
    BMI +
    TAX

    LDA #$42            ;Priority $10, Size 4.
    %SetTile(#$78, #$0F, "#$30 : ORA $00", $01)

    LDX #$10
    LDA DZ_PPUMirrors_OAM_PriorityLength,x
    INC A
    STA DZ_PPUMirrors_OAM_PriorityLength,x

    LDA DZ_PPUMirrors_OAM_LastSlot
    INC A
    STA DZ_PPUMirrors_OAM_LastSlot
+
    PLX
RTS     

ReservedItemStarPalette:
    db $00,$02,$04,$06
ReservedItemTile:
    db $44,$24,$26,$48,$0E
ReservedItemPalette:
    db $02,$08,$0A,$00,$04

;Nintendo Present
;$00939A
NintendoPresentGraphicRoutine:
    PHB
    PHK
    PLB
    LDA DZ_PPUMirrors_OAM_LastSlot                              ;4
    BMI +                                                       ;2
    TAX                                                         ;1

    LDY #$03                                                    ;2
-
    LDA #$02            ;Priority $00, Size 4.                  ;2
    %SetTile("NintendoPos,Y", #$70, #$30, "NintendoTile,Y")     ;15+4+6 = 25
    INX                                                         ;1 
    DEY                                                         ;1
    BPL -                                                       ;2
+
    LDX #$00                                                    ;2
    TYA                                                         ;1
    STA DZ_PPUMirrors_OAM_LastSlot                              ;4

    LDA #$04                                                    ;2
    CLC                                                         ;1
    ADC DZ_PPUMirrors_OAM_PriorityLength,x                      ;4
    STA DZ_PPUMirrors_OAM_PriorityLength,x                      ;4
                                                                ;58
    PLB
    JML $0093BB|!rom

NintendoPos:
    db $60,$70,$80,$90
NintendoTile:
    db $02,$04,$06,$08     ; Nintendo Presents tilemap 

;Yoshi Tongue
;$01F468
YoshiTongue:
    LDY.B #$0C    
-            
    LDA $00                   
    STA.W OAM_ExtendedDispX,Y 
    CLC                       
    ADC $05                   
    STA $00                   
    LDA $05                   
    BPL +           
    BCC .ret          
    BRA ++           

+
    BCS .ret          
++
    LDA $01                   
    STA.W OAM_ExtendedDispY,Y 
    LDA $06                   
    CMP.B #$01                
    LDA.B #$76                
    BCS +           
    LDA.B #$66                
+
    STA.W OAM_ExtendedTile,Y  
    LDA $07                   
    LSR                       
    LDA.B #$09                
    BCS +           
    ORA.B #$40                
+
    ORA $64                   
    STA.W OAM_ExtendedProp,Y  
    PHY                       
    TYA                       
    LSR                       
    LSR                       
    TAY                       
    LDA.B #$00                
    STA.W $0420,Y             
    PLY                       
    INY                       
    INY                       
    INY                       
    INY                       
    DEC $06                   
    BPL -           
.ret 
RTS                       ; Return 