FindCopyNormal:
    LDA DZ_SDS_SpriteNumber_Normal,x
    STA !Scratch45

    STX !Scratch46

    LDX #!MaxSprites-1
-
    CPX !Scratch46
    BEQ .next

    LDA DZ_SDS_SpriteNumber_Normal,x
    CMP !Scratch45
    BNE .next

    BRA .found
.next
    DEX
    BPL -

    LDX !Scratch46
    CLC
RTL

.found
    LDA DZ_SDS_Offset_Normal,x
    PHA
    LDA DZ_SDS_PaletteAndPage_Normal,x
    PHA
    LDA DZ_SDS_SendOffset_Normal,x
    PHA
    LDA DZ_SDS_Valid_Normal,x
    LDX !Scratch46
    STA DZ_SDS_Valid_Normal,x
    PLA
    STA DZ_SDS_SendOffset_Normal,x
    LDA $01,s
    AND #$01
    ORA DZ_SDS_PaletteAndPage_Normal,x
    STA DZ_SDS_PaletteAndPage_Normal,x
    PLA
    CMP DZ_SDS_PaletteAndPage_Normal,x
    BNE +
    LDA #$01
    STA DZ_SDS_PaletteLoaded_Normal,x
+
    PLA
    STA DZ_SDS_Offset_Normal,x

    SEC
RTL

LoadGraphicsSDSNormal:
    LDA DZ_SDS_SpriteNumber_Normal,x
    STA !Scratch45

    LDA DZ_SDS_Offset_Normal,x     ;
    CLC                     ;
    ADC DZ_SDS_Size_Normal,x       ;
    SEC                     ;
    SBC DZ_SDS_SendOffset_Normal,x ;
    STA !Scratch0           ;Scratch0 = Offset + Size - SendOffset = Current Remaining Size 

    REP #$20
    LDA DZ_MaxDataPerFrame  ;
    SEC                     ;
    SBC DZ_CurrentDataSend  ;Scratch1 = (Max - Current + 0x1F)/0x20
    CLC
    ADC #$001F
    LSR
    LSR
    LSR
    LSR
    LSR
    SEP #$20
    STA !Scratch1

    LDA #$01
    STA DZ_SDS_Valid_Normal,x  ;Valid = 1

    LDA !Scratch0
    CMP !Scratch1   ;Scratch0 = Min(Scratch0, Scratch1)
    BCC +
    BEQ +           ;if Scratch0 > Scratch1 then Valid = 0 
    LDA !Scratch1
    STA !Scratch0

    LDA #$00
    STA DZ_SDS_Valid_Normal,x
+
    LDA !Scratch0
    BNE +
RTL
+

    LDA DZ_SDS_Valid_Normal,x
    STA !Scratch46

    PHX

    LDA DZ_SDS_PaletteAndPage_Normal,x
    AND #$01
    STA !ScratchE
    STZ !ScratchF

    LDA #$00
    XBA
    LDA DZ_SDS_SendOffset_Normal,x
    STA !Scratch4
    STZ !Scratch5
    SEC
    SBC DZ_SDS_Offset_Normal,x
    STA !ScratchC
    STZ !ScratchD

    LDA !Scratch0
    REP #$30
    ASL
    TAX
    LDA.l SizeSDS,x
    STA !Scratch2

    LDA !ScratchE
    BEQ +

    LDA !Scratch4
    CLC
    ADC #$0100
    ASL
    TAX
    LDA.l VRAMOffsetSDS,x
    STA !Scratch8
    BRA ++
+
    LDA !Scratch4
    ASL
    TAX
    LDA.l VRAMOffsetSDS,x
    STA !Scratch8
++
    LDA !ScratchC
    ASL
    TAX

    LDA.l SizeSDS,x
    CLC
    ADC !Scratch6
    STA !Scratch6
    SEP #$30

    %TransferToVRAM(!Scratch8, !Scratch6, !ScratchA, !Scratch2)

    LDA !Scratch46
    BNE +
    
    LDA $01,s
    STA !Scratch47
    TAX

    LDA DZ_SDS_SendOffset_Normal,x
    CLC
    ADC !Scratch0
    STA DZ_SDS_SendOffset_Normal,x
    STA !Scratch46

    LDX #!MaxSprites-1
-
    CPX !Scratch47
    BEQ .next2

    LDA !SpriteStatus,x
    BEQ .next2

    LDA DZ_SDS_SpriteNumber_Normal,x
    CMP !SpriteNumberNormal,x
    BNE .next2
    CMP !Scratch45
    BNE .next2

    LDA !Scratch46
    STA DZ_SDS_SendOffset_Normal,x
.next2
    DEX
    BPL -

    PLX
RTL
+
    LDA $01,s
    STA !Scratch47

    LDX #!MaxSprites-1
-
    CPX !Scratch47
    BEQ .next

    LDA !SpriteStatus,x
    BEQ .next

    LDA DZ_SDS_SpriteNumber_Normal,x
    CMP !SpriteNumberNormal,x
    BNE .next
    CMP !Scratch45
    BNE .next

    LDA #$01
    STA DZ_SDS_Valid_Normal,x

.next
    DEX
    BPL -

    PLX
    LDA DZ_SDS_SendOffset_Normal,x
    CLC
    ADC !Scratch0
    STA DZ_SDS_SendOffset_Normal,x
RTL

FindCopyCluster:
    LDA DZ_SDS_SpriteNumber_Cluster,x
    STA !Scratch45

    STX !Scratch46

    LDX #$13
-
    CPX !Scratch46
    BEQ .next

    LDA DZ_SDS_SpriteNumber_Cluster,x
    CMP !Scratch45
    BNE .next

    BRA .found
.next
    DEX
    BPL -

    LDX !Scratch46
    CLC
RTL

.found
    LDA DZ_SDS_Offset_Cluster,x
    PHA
    LDA DZ_SDS_PaletteAndPage_Cluster,x
    PHA
    LDA DZ_SDS_SendOffset_Cluster,x
    PHA
    LDA DZ_SDS_Valid_Cluster,x
    LDX !Scratch46
    STA DZ_SDS_Valid_Cluster,x
    PLA
    STA DZ_SDS_SendOffset_Cluster,x
    LDA $01,s
    AND #$01
    ORA DZ_SDS_PaletteAndPage_Cluster,x
    STA DZ_SDS_PaletteAndPage_Cluster,x
    PLA
    CMP DZ_SDS_PaletteAndPage_Cluster,x
    BNE +
    LDA #$01
    STA DZ_SDS_PaletteLoaded_Cluster,x
+
    PLA
    STA DZ_SDS_Offset_Cluster,x

    SEC
RTL

LoadGraphicsSDSCluster:
    LDA DZ_SDS_SpriteNumber_Cluster,x
    STA !Scratch45

    LDA DZ_SDS_Offset_Cluster,x     ;
    CLC                     ;
    ADC DZ_SDS_Size_Cluster,x       ;
    SEC                     ;
    SBC DZ_SDS_SendOffset_Cluster,x ;
    STA !Scratch0           ;Scratch0 = Offset + Size - SendOffset = Current Remaining Size 

    REP #$20
    LDA DZ_MaxDataPerFrame  ;
    SEC                     ;
    SBC DZ_CurrentDataSend  ;Scratch1 = (Max - Current + 0x1F)/0x20
    CLC
    ADC #$001F
    LSR
    LSR
    LSR
    LSR
    LSR
    SEP #$20
    STA !Scratch1

    LDA #$01
    STA DZ_SDS_Valid_Cluster,x  ;Valid = 1

    LDA !Scratch0
    CMP !Scratch1   ;Scratch0 = Min(Scratch0, Scratch1)
    BCC +
    BEQ +           ;if Scratch0 > Scratch1 then Valid = 0 
    LDA !Scratch1
    STA !Scratch0

    LDA #$00
    STA DZ_SDS_Valid_Cluster,x
+
    LDA !Scratch0
    BNE +
RTL
+

    LDA DZ_SDS_Valid_Cluster,x
    STA !Scratch46

    PHX

    LDA DZ_SDS_PaletteAndPage_Cluster,x
    AND #$01
    STA !ScratchE
    STZ !ScratchF

    LDA #$00
    XBA
    LDA DZ_SDS_SendOffset_Cluster,x
    STA !Scratch4
    STZ !Scratch5
    SEC
    SBC DZ_SDS_Offset_Cluster,x
    STA !ScratchC
    STZ !ScratchD

    LDA !Scratch0
    REP #$30
    ASL
    TAX
    LDA.l SizeSDS,x
    STA !Scratch2

    LDA !ScratchE
    BEQ +

    LDA !Scratch4
    CLC
    ADC #$0100
    ASL
    TAX
    LDA.l VRAMOffsetSDS,x
    STA !Scratch8
    BRA ++
+
    LDA !Scratch4
    ASL
    TAX
    LDA.l VRAMOffsetSDS,x
    STA !Scratch8
++
    LDA !ScratchC
    ASL
    TAX

    LDA.l SizeSDS,x
    CLC
    ADC !Scratch6
    STA !Scratch6
    SEP #$30

    %TransferToVRAM(!Scratch8, !Scratch6, !ScratchA, !Scratch2)

    LDA !Scratch46
    BNE +
    
    LDA $01,s
    STA !Scratch47
    TAX

    LDA DZ_SDS_SendOffset_Cluster,x
    CLC
    ADC !Scratch0
    STA DZ_SDS_SendOffset_Cluster,x
    STA !Scratch46

    LDX #$13
-
    CPX !Scratch47
    BEQ .next2

    LDA !SpriteStatus,x
    BEQ .next2

    LDA DZ_SDS_SpriteNumber_Cluster,x
    CMP !ClusterSpriteNumber,x
    BNE .next2
    CMP !Scratch45
    BNE .next2

    LDA !Scratch46
    STA DZ_SDS_SendOffset_Cluster,x
.next2
    DEX
    BPL -

    PLX
RTL
+
    LDA $01,s
    STA !Scratch47

    LDX #$13
-
    CPX !Scratch47
    BEQ .next

    LDA !SpriteStatus,x
    BEQ .next

    LDA DZ_SDS_SpriteNumber_Cluster,x
    CMP !ClusterSpriteNumber,x
    BNE .next
    CMP !Scratch45
    BNE .next

    LDA #$01
    STA DZ_SDS_Valid_Cluster,x

.next
    DEX
    BPL -

    PLX
    LDA DZ_SDS_SendOffset_Cluster,x
    CLC
    ADC !Scratch0
    STA DZ_SDS_SendOffset_Cluster,x
RTL

FindCopyExtended:
    LDA DZ_SDS_SpriteNumber_Extended,x
    STA !Scratch45

    STX !Scratch46

    LDX #$09
-
    CPX !Scratch46
    BEQ .next

    LDA DZ_SDS_SpriteNumber_Extended,x
    CMP !Scratch45
    BNE .next

    BRA .found
.next
    DEX
    BPL -

    LDX !Scratch46
    CLC
RTL

.found
    LDA DZ_SDS_Offset_Extended,x
    PHA
    LDA DZ_SDS_PaletteAndPage_Extended,x
    PHA
    LDA DZ_SDS_SendOffset_Extended,x
    PHA
    LDA DZ_SDS_Valid_Extended,x
    LDX !Scratch46
    STA DZ_SDS_Valid_Extended,x
    PLA
    STA DZ_SDS_SendOffset_Extended,x
    LDA $01,s
    AND #$01
    ORA DZ_SDS_PaletteAndPage_Extended,x
    STA DZ_SDS_PaletteAndPage_Extended,x
    PLA
    CMP DZ_SDS_PaletteAndPage_Extended,x
    BNE +
    LDA #$01
    STA DZ_SDS_PaletteLoaded_Extended,x
+
    PLA
    STA DZ_SDS_Offset_Extended,x

    SEC
RTL

LoadGraphicsSDSExtended:
    LDA DZ_SDS_SpriteNumber_Extended,x
    STA !Scratch45

    LDA DZ_SDS_Offset_Extended,x     ;
    CLC                     ;
    ADC DZ_SDS_Size_Extended,x       ;
    SEC                     ;
    SBC DZ_SDS_SendOffset_Extended,x ;
    STA !Scratch0           ;Scratch0 = Offset + Size - SendOffset = Current Remaining Size 

    REP #$20
    LDA DZ_MaxDataPerFrame  ;
    SEC                     ;
    SBC DZ_CurrentDataSend  ;Scratch1 = (Max - Current + 0x1F)/0x20
    CLC
    ADC #$001F
    LSR
    LSR
    LSR
    LSR
    LSR
    SEP #$20
    STA !Scratch1

    LDA #$01
    STA DZ_SDS_Valid_Extended,x  ;Valid = 1

    LDA !Scratch0
    CMP !Scratch1   ;Scratch0 = Min(Scratch0, Scratch1)
    BCC +
    BEQ +           ;if Scratch0 > Scratch1 then Valid = 0 
    LDA !Scratch1
    STA !Scratch0

    LDA #$00
    STA DZ_SDS_Valid_Extended,x
+
    LDA !Scratch0
    BNE +
RTL
+

    LDA DZ_SDS_Valid_Extended,x
    STA !Scratch46

    PHX

    LDA DZ_SDS_PaletteAndPage_Extended,x
    AND #$01
    STA !ScratchE
    STZ !ScratchF

    LDA #$00
    XBA
    LDA DZ_SDS_SendOffset_Extended,x
    STA !Scratch4
    STZ !Scratch5
    SEC
    SBC DZ_SDS_Offset_Extended,x
    STA !ScratchC
    STZ !ScratchD

    LDA !Scratch0
    REP #$30
    ASL
    TAX
    LDA.l SizeSDS,x
    STA !Scratch2

    LDA !ScratchE
    BEQ +

    LDA !Scratch4
    CLC
    ADC #$0100
    ASL
    TAX
    LDA.l VRAMOffsetSDS,x
    STA !Scratch8
    BRA ++
+
    LDA !Scratch4
    ASL
    TAX
    LDA.l VRAMOffsetSDS,x
    STA !Scratch8
++
    LDA !ScratchC
    ASL
    TAX

    LDA.l SizeSDS,x
    CLC
    ADC !Scratch6
    STA !Scratch6
    SEP #$30

    %TransferToVRAM(!Scratch8, !Scratch6, !ScratchA, !Scratch2)

    LDA !Scratch46
    BNE +
    
    LDA $01,s
    STA !Scratch47
    TAX

    LDA DZ_SDS_SendOffset_Extended,x
    CLC
    ADC !Scratch0
    STA DZ_SDS_SendOffset_Extended,x
    STA !Scratch46

    LDX #$09
-
    CPX !Scratch47
    BEQ .next2

    LDA !SpriteStatus,x
    BEQ .next2

    LDA DZ_SDS_SpriteNumber_Extended,x
    CMP !ExtendedSpriteNumber,x
    BNE .next2
    CMP !Scratch45
    BNE .next2

    LDA !Scratch46
    STA DZ_SDS_SendOffset_Extended,x
.next2
    DEX
    BPL -

    PLX
RTL
+
    LDA $01,s
    STA !Scratch47

    LDX #$09
-
    CPX !Scratch47
    BEQ .next

    LDA !SpriteStatus,x
    BEQ .next

    LDA DZ_SDS_SpriteNumber_Extended,x
    CMP !ExtendedSpriteNumber,x
    BNE .next
    CMP !Scratch45
    BNE .next

    LDA #$01
    STA DZ_SDS_Valid_Extended,x

.next
    DEX
    BPL -

    PLX
    LDA DZ_SDS_SendOffset_Extended,x
    CLC
    ADC !Scratch0
    STA DZ_SDS_SendOffset_Extended,x
RTL

FindCopyOW:
    LDA DZ_SDS_SpriteNumber_OW,x
    STA !Scratch45

    STX !Scratch46

    LDX #$0F
-
    CPX !Scratch46
    BEQ .next

    LDA DZ_SDS_SpriteNumber_OW,x
    CMP !Scratch45
    BNE .next

    BRA .found
.next
    DEX
    BPL -

    LDX !Scratch46
    CLC
RTL

.found
    LDA DZ_SDS_Offset_OW,x
    PHA
    LDA DZ_SDS_PaletteAndPage_OW,x
    PHA
    LDA DZ_SDS_SendOffset_OW,x
    PHA
    LDA DZ_SDS_Valid_OW,x
    LDX !Scratch46
    STA DZ_SDS_Valid_OW,x
    PLA
    STA DZ_SDS_SendOffset_OW,x
    LDA $01,s
    AND #$01
    ORA DZ_SDS_PaletteAndPage_OW,x
    STA DZ_SDS_PaletteAndPage_OW,x
    PLA
    CMP DZ_SDS_PaletteAndPage_OW,x
    BNE +
    LDA #$01
    STA DZ_SDS_PaletteLoaded_OW,x
+
    PLA
    STA DZ_SDS_Offset_OW,x

    SEC
RTL

LoadGraphicsSDSOW:
    LDA DZ_SDS_SpriteNumber_OW,x
    STA !Scratch45

    LDA DZ_SDS_Offset_OW,x     ;
    CLC                     ;
    ADC DZ_SDS_Size_OW,x       ;
    SEC                     ;
    SBC DZ_SDS_SendOffset_OW,x ;
    STA !Scratch0           ;Scratch0 = Offset + Size - SendOffset = Current Remaining Size 

    REP #$20
    LDA DZ_MaxDataPerFrame  ;
    SEC                     ;
    SBC DZ_CurrentDataSend  ;Scratch1 = (Max - Current + 0x1F)/0x20
    CLC
    ADC #$001F
    LSR
    LSR
    LSR
    LSR
    LSR
    SEP #$20
    STA !Scratch1

    LDA #$01
    STA DZ_SDS_Valid_OW,x  ;Valid = 1

    LDA !Scratch0
    CMP !Scratch1   ;Scratch0 = Min(Scratch0, Scratch1)
    BCC +
    BEQ +           ;if Scratch0 > Scratch1 then Valid = 0 
    LDA !Scratch1
    STA !Scratch0

    LDA #$00
    STA DZ_SDS_Valid_OW,x
+
    LDA !Scratch0
    BNE +
RTL
+

    LDA DZ_SDS_Valid_OW,x
    STA !Scratch46

    PHX

    LDA DZ_SDS_PaletteAndPage_OW,x
    AND #$01
    STA !ScratchE
    STZ !ScratchF

    LDA #$00
    XBA
    LDA DZ_SDS_SendOffset_OW,x
    STA !Scratch4
    STZ !Scratch5
    SEC
    SBC DZ_SDS_Offset_OW,x
    STA !ScratchC
    STZ !ScratchD

    LDA !Scratch0
    REP #$30
    ASL
    TAX
    LDA.l SizeSDS,x
    STA !Scratch2

    LDA !ScratchE
    BEQ +

    LDA !Scratch4
    CLC
    ADC #$0100
    ASL
    TAX
    LDA.l VRAMOffsetSDS,x
    STA !Scratch8
    BRA ++
+
    LDA !Scratch4
    ASL
    TAX
    LDA.l VRAMOffsetSDS,x
    STA !Scratch8
++
    LDA !ScratchC
    ASL
    TAX

    LDA.l SizeSDS,x
    CLC
    ADC !Scratch6
    STA !Scratch6
    SEP #$30

    %TransferToVRAM(!Scratch8, !Scratch6, !ScratchA, !Scratch2)

    LDA !Scratch46
    BNE +
    
    LDA $01,s
    STA !Scratch47
    TAX

    LDA DZ_SDS_SendOffset_OW,x
    CLC
    ADC !Scratch0
    STA DZ_SDS_SendOffset_OW,x
    STA !Scratch46

    LDX #$0F
-
    CPX !Scratch47
    BEQ .next2

    LDA !SpriteStatus,x
    BEQ .next2

    LDA DZ_SDS_SpriteNumber_OW,x
    CMP !OWSpriteNumber,x
    BNE .next2
    CMP !Scratch45
    BNE .next2

    LDA !Scratch46
    STA DZ_SDS_SendOffset_OW,x
.next2
    DEX
    BPL -

    PLX
RTL
+
    LDA $01,s
    STA !Scratch47

    LDX #$0F
-
    CPX !Scratch47
    BEQ .next

    LDA !SpriteStatus,x
    BEQ .next

    LDA DZ_SDS_SpriteNumber_OW,x
    CMP !OWSpriteNumber,x
    BNE .next
    CMP !Scratch45
    BNE .next

    LDA #$01
    STA DZ_SDS_Valid_OW,x

.next
    DEX
    BPL -

    PLX
    LDA DZ_SDS_SendOffset_OW,x
    CLC
    ADC !Scratch0
    STA DZ_SDS_SendOffset_OW,x
RTL

VRAMOffsetSDS:
    dw $6000,$6010,$6020,$6030,$6040,$6050,$6060,$6070,$6080,$6090,$60A0,$60B0,$60C0,$60D0,$60E0,$60F0
    dw $6100,$6110,$6120,$6130,$6140,$6150,$6160,$6170,$6180,$6190,$61A0,$61B0,$61C0,$61D0,$61E0,$61F0
    dw $6200,$6210,$6220,$6230,$6240,$6250,$6260,$6270,$6280,$6290,$62A0,$62B0,$62C0,$62D0,$62E0,$62F0
    dw $6300,$6310,$6320,$6330,$6340,$6350,$6360,$6370,$6380,$6390,$63A0,$63B0,$63C0,$63D0,$63E0,$63F0
    dw $6400,$6410,$6420,$6430,$6440,$6450,$6460,$6470,$6480,$6490,$64A0,$64B0,$64C0,$64D0,$64E0,$64F0
    dw $6500,$6510,$6520,$6530,$6540,$6550,$6560,$6570,$6580,$6590,$65A0,$65B0,$65C0,$65D0,$65E0,$65F0
    dw $6600,$6610,$6620,$6630,$6640,$6650,$6660,$6670,$6680,$6690,$66A0,$66B0,$66C0,$66D0,$66E0,$66F0
    dw $6700,$6710,$6720,$6730,$6740,$6750,$6760,$6770,$6780,$6790,$67A0,$67B0,$67C0,$67D0,$67E0,$67F0
    dw $6800,$6810,$6820,$6830,$6840,$6850,$6860,$6870,$6880,$6890,$68A0,$68B0,$68C0,$68D0,$68E0,$68F0
    dw $6900,$6910,$6920,$6930,$6940,$6950,$6960,$6970,$6980,$6990,$69A0,$69B0,$69C0,$69D0,$69E0,$69F0
    dw $6A00,$6A10,$6A20,$6A30,$6A40,$6A50,$6A60,$6A70,$6A80,$6A90,$6AA0,$6AB0,$6AC0,$6AD0,$6AE0,$6AF0
    dw $6B00,$6B10,$6B20,$6B30,$6B40,$6B50,$6B60,$6B70,$6B80,$6B90,$6BA0,$6BB0,$6BC0,$6BD0,$6BE0,$6BF0
    dw $6C00,$6C10,$6C20,$6C30,$6C40,$6C50,$6C60,$6C70,$6C80,$6C90,$6CA0,$6CB0,$6CC0,$6CD0,$6CE0,$6CF0
    dw $6D00,$6D10,$6D20,$6D30,$6D40,$6D50,$6D60,$6D70,$6D80,$6D90,$6DA0,$6DB0,$6DC0,$6DD0,$6DE0,$6DF0
    dw $6E00,$6E10,$6E20,$6E30,$6E40,$6E50,$6E60,$6E70,$6E80,$6E90,$6EA0,$6EB0,$6EC0,$6ED0,$6EE0,$6EF0
    dw $6F00,$6F10,$6F20,$6F30,$6F40,$6F50,$6F60,$6F70,$6F80,$6F90,$6FA0,$6FB0,$6FC0,$6FD0,$6FE0,$6FF0
    dw $7000,$7010,$7020,$7030,$7040,$7050,$7060,$7070,$7080,$7090,$70A0,$70B0,$70C0,$70D0,$70E0,$70F0
    dw $7100,$7110,$7120,$7130,$7140,$7150,$7160,$7170,$7180,$7190,$71A0,$71B0,$71C0,$71D0,$71E0,$71F0
    dw $7200,$7210,$7220,$7230,$7240,$7250,$7260,$7270,$7280,$7290,$72A0,$72B0,$72C0,$72D0,$72E0,$72F0
    dw $7300,$7310,$7320,$7330,$7340,$7350,$7360,$7370,$7380,$7390,$73A0,$73B0,$73C0,$73D0,$73E0,$73F0
    dw $7400,$7410,$7420,$7430,$7440,$7450,$7460,$7470,$7480,$7490,$74A0,$74B0,$74C0,$74D0,$74E0,$74F0
    dw $7500,$7510,$7520,$7530,$7540,$7550,$7560,$7570,$7580,$7590,$75A0,$75B0,$75C0,$75D0,$75E0,$75F0
    dw $7600,$7610,$7620,$7630,$7640,$7650,$7660,$7670,$7680,$7690,$76A0,$76B0,$76C0,$76D0,$76E0,$76F0
    dw $7700,$7710,$7720,$7730,$7740,$7750,$7760,$7770,$7780,$7790,$77A0,$77B0,$77C0,$77D0,$77E0,$77F0
    dw $7800,$7810,$7820,$7830,$7840,$7850,$7860,$7870,$7880,$7890,$78A0,$78B0,$78C0,$78D0,$78E0,$78F0
    dw $7900,$7910,$7920,$7930,$7940,$7950,$7960,$7970,$7980,$7990,$79A0,$79B0,$79C0,$79D0,$79E0,$79F0
    dw $7A00,$7A10,$7A20,$7A30,$7A40,$7A50,$7A60,$7A70,$7A80,$7A90,$7AA0,$7AB0,$7AC0,$7AD0,$7AE0,$7AF0
    dw $7B00,$7B10,$7B20,$7B30,$7B40,$7B50,$7B60,$7B70,$7B80,$7B90,$7BA0,$7BB0,$7BC0,$7BD0,$7BE0,$7BF0
    dw $7C00,$7C10,$7C20,$7C30,$7C40,$7C50,$7C60,$7C70,$7C80,$7C90,$7CA0,$7CB0,$7CC0,$7CD0,$7CE0,$7CF0
    dw $7D00,$7D10,$7D20,$7D30,$7D40,$7D50,$7D60,$7D70,$7D80,$7D90,$7DA0,$7DB0,$7DC0,$7DD0,$7DE0,$7DF0
    dw $7E00,$7E10,$7E20,$7E30,$7E40,$7E50,$7E60,$7E70,$7E80,$7E90,$7EA0,$7EB0,$7EC0,$7ED0,$7EE0,$7EF0
    dw $7F00,$7F10,$7F20,$7F30,$7F40,$7F50,$7F60,$7F70,$7F80,$7F90,$7FA0,$7FB0,$7FC0,$7FD0,$7FE0,$7FF0

SizeSDS:
    dw $0000,$0020,$0040,$0060,$0080,$00A0,$00C0,$00E0,$0100,$0120,$0140,$0160,$0180,$01A0,$01C0,$01E0
    dw $0200,$0220,$0240,$0260,$0280,$02A0,$02C0,$02E0,$0300,$0320,$0340,$0360,$0380,$03A0,$03C0,$03E0
    dw $0400,$0420,$0440,$0460,$0480,$04A0,$04C0,$04E0,$0500,$0520,$0540,$0560,$0580,$05A0,$05C0,$05E0
    dw $0600,$0620,$0640,$0660,$0680,$06A0,$06C0,$06E0,$0700,$0720,$0740,$0760,$0780,$07A0,$07C0,$07E0
    dw $0800,$0820,$0840,$0860,$0880,$08A0,$08C0,$08E0,$0900,$0920,$0940,$0960,$0980,$09A0,$09C0,$09E0
    dw $0A00,$0A20,$0A40,$0A60,$0A80,$0AA0,$0AC0,$0AE0,$0B00,$0B20,$0B40,$0B60,$0B80,$0BA0,$0BC0,$0BE0
    dw $0C00,$0C20,$0C40,$0C60,$0C80,$0CA0,$0CC0,$0CE0,$0D00,$0D20,$0D40,$0D60,$0D80,$0DA0,$0DC0,$0DE0
    dw $0E00,$0E20,$0E40,$0E60,$0E80,$0EA0,$0EC0,$0EE0,$0F00,$0F20,$0F40,$0F60,$0F80,$0FA0,$0FC0,$0FE0
    dw $1000,$1020,$1040,$1060,$1080,$10A0,$10C0,$10E0,$1100,$1120,$1140,$1160,$1180,$11A0,$11C0,$11E0
    dw $1200,$1220,$1240,$1260,$1280,$12A0,$12C0,$12E0,$1300,$1320,$1340,$1360,$1380,$13A0,$13C0,$13E0
    dw $1400,$1420,$1440,$1460,$1480,$14A0,$14C0,$14E0,$1500,$1520,$1540,$1560,$1580,$15A0,$15C0,$15E0
    dw $1600,$1620,$1640,$1660,$1680,$16A0,$16C0,$16E0,$1700,$1720,$1740,$1760,$1780,$17A0,$17C0,$17E0
    dw $1800,$1820,$1840,$1860,$1880,$18A0,$18C0,$18E0,$1900,$1920,$1940,$1960,$1980,$19A0,$19C0,$19E0
    dw $1A00,$1A20,$1A40,$1A60,$1A80,$1AA0,$1AC0,$1AE0,$1B00,$1B20,$1B40,$1B60,$1B80,$1BA0,$1BC0,$1BE0
    dw $1C00,$1C20,$1C40,$1C60,$1C80,$1CA0,$1CC0,$1CE0,$1D00,$1D20,$1D40,$1D60,$1D80,$1DA0,$1DC0,$1DE0
    dw $1E00,$1E20,$1E40,$1E60,$1E80,$1EA0,$1EC0,$1EE0,$1F00,$1F20,$1F40,$1F60,$1F80,$1FA0,$1FC0,$1FE0