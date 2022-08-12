;Get Max between 3 values
macro max(v1,v2,v3)
?max:
    LDA <v1>
    CMP <v2>
    BCS ?.v1maxcandidate

    LDA <v2>
    CMP <v3>
    BCC ?.v3max
?.v2max
    LDX #$0002
    BRA  ?.finish

?.v1maxcandidate
    CMP <v3>
    BCS ?.v1max

?.v3max
    LDX #$0004
    LDA <v3>
    BRA ?.finish
?.v1max
    LDX #$0000
?.finish
endmacro

;Get Min between 3 values
macro min(v1,v2,v3)
?min:
    LDA <v1>
    CMP <v2>
    BCC ?.v1mincandidate

    LDA <v2>
    CMP <v3>
    BCS ?.v3min
    BRA ?.v2min

?.v1mincandidate
    CMP <v3>
    BCC ?.v1min

?.v3min
    LDA <v3>

?.v2min
?.v1min
endmacro

;Split v into 3 differents channels c1,c2,c3
macro splitChannels(v,c1,c2,c3)
    
    REP #$20
    LDA <v>
    AND #$001F
    STA <c3>

    LDA <v>
    LSR
    LSR
    XBA
    AND #$001F
    STA <c1>

    LDA <v>
    LSR
    LSR
    LSR
    LSR
    LSR
    SEP #$20
    AND #$1F
    STA <c2>

endmacro

;Merge channels v1,v2,v3 into r
macro mergeChannels(v1,v2,v3,rh,rl)
    LDA <v2>
    ASL
    ASL
    ASL
    ASL
    ASL
    ORA <v3>
    STA <rl>

    LDA <v1>
    ASL
    ASL
    PHA 

    LDA <v2>
    LSR
    LSR
    LSR
    ORA $01,s
    STA <rh>

    PLA
endmacro

!R = $00
!G = $01
!B = $02

!Min = $04
!Max = $05

!H = $06
!S = $07
!L = $08

!C = $09
!Div = $0A

!C = $09
!X = $0A
!M = $0B

RGB2HSL:
    %max("!R","!G","!B")
    STA !Max

    %min("!R","!G","!B")
    STA !Min

    CLC
    ADC !Max
    LSR
    STA !L

    LDA !Max
    SEC
    SBC !Min
    BNE +
    STA !S
    STA !H
RTS
+
    STA !C

    LDA !Min
    CLC
    ADC !Max
    SEC
    SBC #$1F
    BPL +
    EOR #$FF
    INC A
+
    EOR #$FF
    INC A
    CLC
    ADC #$1F
    STA !Div

    %Mul(" !C", " #$1F")
    %DivWAfterMul("!Div")

    LDA !DivisionResult
    STA !S

    JMP (hcalc,x)

hcalc:
    dw rmax
    dw gmax
    dw bmax

X60degrees:
    dw $FF5B,$FF60,$FF65,$FF6B,$FF70,$FF75,$FF7B,$FF80,$FF85,$FF8B,$FF90,$FF95,$FF9B,$FFA0,$FFA5,$FFAB
    dw $FFB0,$FFB5,$FFBB,$FFC0,$FFC5,$FFCB,$FFD0,$FFD5,$FFDB,$FFE0,$FFE5,$FFEB,$FFF0,$FFF5,$FFFB,$0000
    dw $0005,$000B,$0010,$0015,$001B,$0020,$0025,$002B,$0030,$0035,$003B,$0040,$0045,$004B,$0050,$0055
    dw $005B,$0060,$0065,$006B,$0070,$0075,$007B,$0080,$0085,$008B,$0090,$0095,$009B,$00A0,$00A5
rmax:

    LDA #$00
    XBA
    LDA !G
    SEC
    SBC !B
    CLC
    ADC #$1F
    ASL
    TAX

    STZ $0A

    REP #$20
    LDA X60degrees,x
    BPL +
    EOR #$FFFF
    INC A
    INC $0A
+
    STA $0B
    SEP #$20
    
    %DivW(" $0C", " $0B", " !C")

    LDA $0A
    BEQ +

    LDA !DivisionResult
    EOR #$FF
    INC A
    CLC
    ADC #$20
    AND #$1F
    STA !H

RTS

+
    LDA !DivisionResult
    CLC
    ADC #$20
    AND #$1F
    STA !H

RTS

gmax:

    LDA #$00
    XBA
    LDA !B
    SEC
    SBC !R
    CLC
    ADC #$1F
    ASL
    TAX

    STZ $0A

    REP #$20
    LDA X60degrees,x
    BPL +
    EOR #$FFFF
    INC A
    INC $0A
+
    STA $0B
    SEP #$20
    
    %DivW(" $0C", " $0B", " !C")

    LDA $0A
    BEQ +

    LDA !DivisionResult
    EOR #$FF
    INC A
    CLC
    ADC #$0B
    STA !H

RTS

+
    LDA !DivisionResult
    CLC
    ADC #$0B
    STA !H

RTS

bmax:

    LDA #$00
    XBA
    LDA !R
    SEC
    SBC !G
    CLC
    ADC #$1F
    ASL
    TAX

    STZ $0A

    REP #$20
    LDA X60degrees,x
    BPL +
    EOR #$FFFF
    INC A
    INC $0A
+
    STA $0B
    SEP #$20
    
    %DivW(" $0C", " $0B", " !C")

    LDA $0A
    BEQ +

    LDA !DivisionResult
    EOR #$FF
    INC A
    CLC
    ADC #$15
    STA !H

RTS

+
    LDA !DivisionResult
    CLC
    ADC #$15
    STA !H

RTS

HSL2RGB:

    LDA #$00
    XBA
    LDA !L
    REP #$20
    ASL
    ASL
    ASL
    ASL
    ASL
    SEP #$20
    ORA !S
    TAX

    LDA #$00
    XBA
    LDA Cs,x
    STA !C
    REP #$20
    ASL
    ASL
    ASL
    ASL
    ASL
    SEP #$20
    ORA !H
    TAX

    LDA Xs,x
    STA !X

    LDA !C
    LSR
    EOR #$FF
    INC A
    CLC
    ADC !L
    STA !M

    LDA #$00
    XBA
    LDA !H
    ASL
    TAX

    JMP (hfunc,x)

Cs:
    incbin "cs.bin"
Xs:
    incbin "xs.bin"

hfunc:
    dw h1,h1,h1,h1,h1,h1
    dw h2,h2,h2,h2,h2
    dw h3,h3,h3,h3,h3,h3
    dw h4,h4,h4,h4,h4
    dw h5,h5,h5,h5,h5
    dw h6,h6,h6,h6,h6

h1:
    LDA !C
    CLC
    ADC !M
    STA !R

    LDA !X
    CLC
    ADC !M
    STA !G

    LDA !M
    STA !B
RTS

h2:
    LDA !X
    CLC
    ADC !M
    STA !R

    LDA !C
    CLC
    ADC !M
    STA !G

    LDA !M
    STA !B
RTS

h3:
    LDA !C
    CLC
    ADC !M
    STA !G

    LDA !X
    CLC
    ADC !M
    STA !B

    LDA !M
    STA !R
RTS

h4:
    LDA !X
    CLC
    ADC !M
    STA !G

    LDA !C
    CLC
    ADC !M
    STA !B

    LDA !M
    STA !R
RTS

h5:
    LDA !X
    CLC
    ADC !M
    STA !R

    LDA !C
    CLC
    ADC !M
    STA !B

    LDA !M
    STA !G
RTS

h6:
    LDA !C
    CLC
    ADC !M
    STA !R

    LDA !X
    CLC
    ADC !M
    STA !B

    LDA !M
    STA !G
RTS

MulTable:
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  ;X0
    db $00,$01,$02,$03,$04,$05,$06,$07,$08,$00,$00,$00,$00,$00,$00,$00  ;X1
    db $00,$02,$04,$06,$08,$0A,$0C,$0E,$10,$00,$00,$00,$00,$00,$00,$00  ;X2
    db $00,$03,$06,$09,$0C,$0F,$12,$15,$18,$00,$00,$00,$00,$00,$00,$00
    db $00,$04,$08,$0C,$10,$14,$18,$1C,$20,$00,$00,$00,$00,$00,$00,$00
    db $00,$05,$0A,$0F,$14,$19,$1E,$23,$28,$00,$00,$00,$00,$00,$00,$00
    db $00,$06,$0C,$12,$18,$1E,$24,$2A,$30,$00,$00,$00,$00,$00,$00,$00
    db $00,$07,$0E,$15,$1C,$23,$2A,$31,$38,$00,$00,$00,$00,$00,$00,$00
    db $00,$08,$10,$18,$20,$28,$30,$38,$40,$00,$00,$00,$00,$00,$00,$00
    db $00,$09,$12,$1B,$24,$2D,$36,$3F,$48,$00,$00,$00,$00,$00,$00,$00
    db $00,$0A,$14,$1E,$28,$32,$3C,$46,$50,$00,$00,$00,$00,$00,$00,$00
    db $00,$0B,$16,$21,$2C,$37,$42,$4D,$58,$00,$00,$00,$00,$00,$00,$00
    db $00,$0C,$18,$24,$30,$3C,$48,$54,$60,$00,$00,$00,$00,$00,$00,$00
    db $00,$0D,$1A,$27,$34,$41,$4E,$5B,$68,$00,$00,$00,$00,$00,$00,$00
    db $00,$0E,$1C,$2A,$38,$46,$54,$62,$70,$00,$00,$00,$00,$00,$00,$00
    db $00,$0F,$1E,$2D,$3C,$4B,$5A,$69,$78,$00,$00,$00,$00,$00,$00,$00
    db $00,$10,$20,$30,$40,$50,$60,$70,$80,$00,$00,$00,$00,$00,$00,$00
    db $00,$11,$22,$33,$44,$55,$66,$77,$88,$00,$00,$00,$00,$00,$00,$00
    db $00,$12,$24,$36,$48,$5A,$6C,$7E,$90,$00,$00,$00,$00,$00,$00,$00
    db $00,$13,$26,$39,$4C,$5F,$72,$85,$98,$00,$00,$00,$00,$00,$00,$00
    db $00,$14,$28,$3C,$50,$64,$78,$8C,$A0,$00,$00,$00,$00,$00,$00,$00
    db $00,$15,$2A,$3F,$54,$69,$7E,$93,$A8,$00,$00,$00,$00,$00,$00,$00
    db $00,$16,$2C,$42,$58,$6E,$84,$9A,$B0,$00,$00,$00,$00,$00,$00,$00
    db $00,$17,$2E,$45,$5C,$73,$8A,$A1,$B8,$00,$00,$00,$00,$00,$00,$00
    db $00,$18,$30,$48,$60,$78,$90,$A8,$C0,$00,$00,$00,$00,$00,$00,$00
    db $00,$19,$32,$4B,$64,$7D,$96,$AF,$C8,$00,$00,$00,$00,$00,$00,$00
    db $00,$1A,$34,$4E,$68,$82,$9C,$B6,$D0,$00,$00,$00,$00,$00,$00,$00
    db $00,$1B,$36,$51,$6C,$87,$A2,$BD,$D8,$00,$00,$00,$00,$00,$00,$00
    db $00,$1C,$38,$54,$70,$8C,$A8,$C4,$E0,$00,$00,$00,$00,$00,$00,$00
    db $00,$1D,$3A,$57,$74,$91,$AE,$CB,$E8,$00,$00,$00,$00,$00,$00,$00
    db $00,$1E,$3C,$5A,$78,$96,$B4,$D2,$F0,$00,$00,$00,$00,$00,$00,$00
    db $00,$1F,$3E,$5D,$7C,$9B,$BA,$D9,$F8,$00,$00,$00,$00,$00,$00,$00

macro getRatio(ratio,value)

    LDA #$00
    XBA
    LDA <value>
    REP #$20
    ASL
    ASL
    ASL
    ASL
    ORA <ratio>
    TAX
    SEP #$20

    LDA MulTable,x

endmacro

!Source = $45
!Dst = $48 
!iSource = $4B
!iDst = $4D
!length = $4F
!ratio1 = $8A
!ratio2 = $8C
!ratio3 = $8E
!V1 = $51
!V2 = $52
!V3 = $53
!tmprl = $0E
!tmprh = $0F

SetHSLBase:
    PHB
    PHK
    PLB

    REP #$30

    LDA !length
    DEC A
    STA !length
    ASL
    STA !iSource    ;!iSource = length*2
    TAY
    CLC
    ADC !length
    STA !iDst      ;!iDest = length*3

    SEP #$20
.loop
    %splitChannels("[!Source],y",!B,!G,!R)

    JSR RGB2HSL

    REP #$20
    LDA !iDst
    TAY
    SEC
    SBC #$0003
    STA !iDst
    SEP #$20

    LDA !H
    STA [!Dst],y
    INY
    LDA !S
    STA [!Dst],y
    INY
    LDA !L
    STA [!Dst],y

    REP #$20
    LDA !iSource
    DEC A
    DEC A
    STA !iSource
    TAY
    SEP #$20
    BPL .loop

    SEP #$10
    PLB
RTL

MixHSL:
    PHB
    PHK
    PLB

    STZ !ratio1+1
    STZ !ratio2+1
    STZ !ratio3+1

    REP #$10

    %getRatio(!ratio1,!V1)
    STA !V1

    %getRatio(!ratio2,!V2)
    STA !V2

    %getRatio(!ratio3,!V3)
    STA !V3

    REP #$20

    LDA #$0008 
    SEC
    SBC !ratio1
    STA !ratio1

    LDA #$0008 
    SEC
    SBC !ratio2
    STA !ratio2

    LDA #$0008 
    SEC
    SBC !ratio3
    STA !ratio3

    LDA !length
    DEC A
    STA !length
    ASL
    STA !iDst       ;!iDest = length*2
    CLC
    ADC !length
    STA !iSource    ;!iSource = length*3
    TAY

    SEP #$20
.loop

    %getRatio(!ratio1,"[!Source],y")
    CLC
    ADC !V1
    LSR
    LSR
    LSR
    STA !H

    INY

    %getRatio(!ratio2,"[!Source],y")
    CLC
    ADC !V2
    LSR
    LSR
    LSR
    STA !S

    INY

    %getRatio(!ratio3,"[!Source],y")
    CLC
    ADC !V3
    LSR
    LSR
    LSR
    STA !L

    JSR HSL2RGB

    %mergeChannels(!B,!G,!R,!tmprh,!tmprl)

    REP #$20
    LDA !iDst
    TAY
    DEC A
    DEC A
    STA !iDst

    LDA !tmprl
    STA [!Dst],y
    SEP #$20

    REP #$20
    LDA !iSource
    SEC
    SBC #$0003
    STA !iSource
    TAY 
    SEP #$20
    BMI .exit
    JMP .loop
.exit
    SEP #$10

    PLB
RTL

SetRGBBase:
    PHB
    PHK
    PLB

    REP #$30

    LDA !length
    DEC A
    STA !length
    ASL
    STA !iSource    ;!iSource = length*2
    TAY
    CLC
    ADC !length
    STA !iDst      ;!iDest = length*3

    SEP #$20
.loop
    %splitChannels("[!Source],y",!B,!G,!R)

    REP #$20
    LDA !iDst
    TAY
    SEC
    SBC #$0003
    STA !iDst
    SEP #$20

    LDA !R
    STA [!Dst],y
    INY
    LDA !G
    STA [!Dst],y
    INY
    LDA !B
    STA [!Dst],y

    REP #$20
    LDA !iSource
    DEC A
    DEC A
    STA !iSource
    TAY
    SEP #$20
    BPL .loop

    SEP #$10
    PLB
RTL

MixRGB:
    PHB
    PHK
    PLB

    STZ !ratio1+1
    STZ !ratio2+1
    STZ !ratio3+1

    REP #$10

    %getRatio(!ratio1,!V1)
    STA !V1

    %getRatio(!ratio2,!V2)
    STA !V2

    %getRatio(!ratio3,!V3)
    STA !V3

    REP #$20

    LDA #$0008 
    SEC
    SBC !ratio1
    STA !ratio1

    LDA #$0008 
    SEC
    SBC !ratio2
    STA !ratio2

    LDA #$0008 
    SEC
    SBC !ratio3
    STA !ratio3

    LDA !length
    DEC A
    STA !length
    ASL
    STA !iDst       ;!iDest = length*2
    CLC
    ADC !length
    STA !iSource    ;!iSource = length*3
    TAY

    SEP #$20
.loop

    %getRatio(!ratio1,"[!Source],y")
    CLC
    ADC !V1
    LSR
    LSR
    LSR
    STA !R

    INY

    %getRatio(!ratio2,"[!Source],y")
    CLC
    ADC !V2
    LSR
    LSR
    LSR
    STA !G

    INY

    %getRatio(!ratio3,"[!Source],y")
    CLC
    ADC !V3
    LSR
    LSR
    LSR
    STA !B

    %mergeChannels(!B,!G,!R,!tmprh,!tmprl)

    REP #$20
    LDA !iDst
    TAY
    DEC A
    DEC A
    STA !iDst

    LDA !tmprl
    STA [!Dst],y
    SEP #$20

    REP #$20
    LDA !iSource
    SEC
    SBC #$0003
    STA !iSource
    TAY 
    SEP #$20
    BMI .exit
    JMP .loop
.exit

    SEP #$10

    PLB
RTL