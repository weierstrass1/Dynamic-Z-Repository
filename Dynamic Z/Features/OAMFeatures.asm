MoveOAM200:
    PHB
    PHK
    PLB

    LDA #$00
    XBA
    LDA DZ_PPUMirrors_OAM_Length        ;A = Length
    REP #$10                            ;X/Y 16 bits
    TAX                                 ;X = Length 
    LDY #$0000                          ;Y = 0
    STY $0000|!dp                       ;$00 = 0
-
    LDA $0201|!addr,y                   ;A = Y Offset
    CMP #$F0                            ;if Y Offset >= 0xF0, then go to next slot.
    BCS .next
    STA DZ_PPUMirrors_OAM_YOffset,x     ;List[x].YOffset = Y Offset

    LDA $3EDEAD

    LDA #$F0
    STA $0201|!addr,y 

    LDA $0200|!addr,y
    STA DZ_PPUMirrors_OAM_XOffset,x     ;List[x].XOffset = X Offset

    LDA $0202|!addr,y
    STA DZ_PPUMirrors_OAM_Property,x    ;List[x].Property = Property
    
    LDA $0203|!addr,y
    STA DZ_PPUMirrors_OAM_Tile,x        ;List[x].Tile = Tile

    PHY
    LDY $0000|!dp                       ;Y = $0000
    LDA $0420|!addr,y                   ;A = Size
    STA DZ_PPUMirrors_OAM_Size,x        ;List[x].Size = Size
    LDA PriorityTable,y                 ;A = Priority
    STA DZ_PPUMirrors_OAM_Priority,x    ;List[x].Priority = Priority

    PHX
    TAX                                         ;X = Priority
    LDA DZ_PPUMirrors_OAM_LengthByPriority,x    ;Priorities[X]++;
    INC A
    STA DZ_PPUMirrors_OAM_LengthByPriority,x
    PLX

    PLY

    INX
    CPX #$0080                          ;If X >= 80 then Start Sorting
    BCS +                               ;else go to next slot

.next
    INY
    INY
    INY
    INY                     ;y+=4
    INC $00                 ;$00++;
    CPY #$0120              ;if Y < 0x121 go to next slot. 
    BCC -
+
    TXA                     
    STA DZ_PPUMirrors_OAM_Length    ;Length = X
    SEP #$10

SortPos:
    STZ $00

    LDX #$00
-
    
    LDA $00
    PHA
    CLC
    ADC DZ_PPUMirrors_OAM_LengthByPriority,x
    STA $00
    PLA
    STA DZ_PPUMirrors_OAM_LengthByPriority,x
    INX
    CPX #$40
    BCC -

    ;LDA $3EDEAD
BucketSort:
    ;LDA $3EDEAD
    REP #$10
    LDX #$0000
-
    PHX
    LDA DZ_PPUMirrors_OAM_Priority,x
    TAX

    LDA #$00
    XBA
    LDA DZ_PPUMirrors_OAM_LengthByPriority,x
    CLC
    REP #$20
    ASL
    ASL
    TAY
    SEP #$20
    LDA DZ_PPUMirrors_OAM_LengthByPriority,x
    INC A
    STA DZ_PPUMirrors_OAM_LengthByPriority,x

    PLX

    LDA DZ_PPUMirrors_OAM_XOffset,x
    STA $0200|!addr,y

    LDA DZ_PPUMirrors_OAM_YOffset,x
    STA $0201|!addr,y

    LDA DZ_PPUMirrors_OAM_Property,x
    STA $0202|!addr,y

    LDA DZ_PPUMirrors_OAM_Tile,x
    STA $0203|!addr,y

    REP #$20
    TYA
    LSR
    LSR
    TAY
    SEP #$20
    LDA DZ_PPUMirrors_OAM_Size,x
    STA $0420|!addr,y

    INX
    TXA
    CMP DZ_PPUMirrors_OAM_Length
    BCC -

ResetValues:
    REP #$20
    LDA #$0000
    !i = $00
    while !i < $40
        STA DZ_PPUMirrors_OAM_LengthByPriority+!i
        !i #= !i+2
    endif
    SEP #$20

    LDA #$00
    XBA
    LDA DZ_PPUMirrors_OAM_Length
    CLC
    REP #$30
    ASL
    ASL
    TAY
    LDA DZ_PPUMirrors_OAM_LastLength
    CLC
    ASL
    ASL
    STA $00
    SEP #$20
    LDA #$F0
-
    CPY $00
    BCS +
    STA $0201|!addr,y

    INY
    INY
    INY
    INY
    BRA -
+
    SEP #$10

    LDY #$1E      
-          
    LDX DATA_008475,Y       
    LDA $0423|!addr,X             
    ASL                       
    ASL                       
    ORA $0422|!addr,X             
    ASL                       
    ASL                       
    ORA $0421|!addr,X             
    ASL                       
    ASL                       
    ORA $0420|!addr,X             
    STA $0400|!addr,Y             
    LDA $0427|!addr,X             
    ASL                       
    ASL                       
    ORA $0426|!addr,X             
    ASL                       
    ASL                       
    ORA $0425|!addr,X             
    ASL                       
    ASL                       
    ORA $0424|!addr,X             
    STA $0401|!addr,Y             
    DEY                       
    DEY                       
    BPL -           

    LDA DZ_PPUMirrors_OAM_Length
    STA DZ_PPUMirrors_OAM_LastLength
    LDA #$00
    STA DZ_PPUMirrors_OAM_Length
    PLB
    JML $0084C7|!rom

DATA_008475:                      
    db $00,$00,$08,$00,$10,$00,$18,$00
    db $20,$00,$28,$00,$30,$00,$38,$00
    db $40,$00,$48,$00,$50,$00,$58,$00
    db $60,$00,$68,$00,$70,$00,$78                      

PriorityTable:
    ;   00  04  08
    db $00,$00,$00
    ;   0C  10  14
    db $02,$02,$02
    ;   18  1C
    db $04,$04
    ;   20  24  28  2C
    db $06,$06,$06,$06
    ;   30  34  38  3C  40  44  48  4C
    db $08,$08,$08,$08,$08,$08,$08,$08
    ;   50  54  58  5C  60  64  68  6C  70  74  78  7C
    db $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
    ;   80  84  88  8C
    db $0C,$0C,$0C,$0C
    ;   90  94  98  9C  A0  A4  A8  AC  B0  B4  B8  BC  C0  C4  C8  CC  D0  D4  D8  DC
    db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
    ;   E0
    db $10
    ;   E4  E8  EC  F0  F4
    db $11,$11,$11,$11,$11
    ;   F8  FC
    db $12,$12
    ;  100 104
    db $13,$13
    ;  108 10C
    db $14,$14
    ;  110
    db $16
    ;  114
    db $18
    ;  118 11C
    db $1A,$1A
    ;  120
    db $1C
    ;  124 128 12C 130 134 138 13C 140 144 148 14C 150 154 158 15C 160 164 168 16C 
    db $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
    ;  170 174 178 17C 180 184 188 18C 190 194 198 19C 1A0 1A4 1A8 1AC 1B0 1B4 1B8 1BC
    db $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
    ;  1C0 1C4 1C8 1CC 1D0 1D4 1D8 1DC 1E0 1E4 1E8 1EC 1F0 1F4 1F8 1FC
    db $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20

StartOAM:
    ;LDA $3EDEAD
    REP #$20
    LDA #$8000
    STA DZ_PPUMirrors_OAM_Length
    LDA #$0000
    !i = $00
    while !i < $40
        STA DZ_PPUMirrors_OAM_LengthByPriority+!i
        !i #= !i+2
    endif
    SEP #$20
    JSL $7F8000
    STZ $0100                 ; Clear the game mode
    STZ $0109                 ; Clear the level number
JML $00805B|!rom

CODE_04DC09:
    SEP #$30                  ; Index (8 bit) Accum (8 bit) 
    JSL $7F8000
    LDA.W $0DD6               ;\
JML $04DC0E|!rom