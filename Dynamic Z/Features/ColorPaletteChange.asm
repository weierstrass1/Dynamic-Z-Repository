CGRAMDMA:
    LDA.l DZ_PPUMirrors_CGRAM_Transfer_Length
    BPL +
RTS
+
    PHA
    ASL
    TAX

    REP #$20
	LDA.w #$2202              
	STA $20             ;parameter of DMA
-
    LDA.l DZ_PPUMirrors_CGRAM_Transfer_SourceLength,x
    STA $25
    
    LDA.l DZ_PPUMirrors_CGRAM_Transfer_Source,x
    STA $22                 ;Load Resource
    SEP #$20

    PLX

    LDA.l DZ_PPUMirrors_CGRAM_Transfer_SourceBNK,x
    STA $24

    LDA.l DZ_PPUMirrors_CGRAM_Transfer_Offset,x
    STA $2121

    STY $420B

    TXA
    DEC A
    BMI +

    PHA
    REP #$20
    ASL
    TAX
    BRA -
+
    LDA.b #$FF
    STA.l DZ_PPUMirrors_CGRAM_Transfer_Length
RTS

CGRAMToBufferDMA:
    LDA.l DZ_PPUMirrors_CGRAM_BufferTransfer_Length
    BPL +
RTS
+
    PHA
    ASL
    TAX

    REP #$20
	LDA.w #$3B80              
	STA $20             ;parameter of DMA
-
    LDA.l DZ_PPUMirrors_CGRAM_BufferTransfer_SourceLength,x
    STA $25
    
    LDA.l DZ_PPUMirrors_CGRAM_BufferTransfer_Destination,x
    STA $22                 ;Load Resource
    SEP #$20

    PLX

    LDA.l DZ_PPUMirrors_CGRAM_BufferTransfer_DestinationBNK,x
    STA $24

    LDA.l DZ_PPUMirrors_CGRAM_BufferTransfer_Offset,x
    STA $2121

    STY $420B

    TXA
    DEC A
    BMI +

    PHA
    REP #$20
    ASL
    TAX
    BRA -
+
    LDA.b #$FF
    STA.l DZ_PPUMirrors_CGRAM_BufferTransfer_Length
RTS