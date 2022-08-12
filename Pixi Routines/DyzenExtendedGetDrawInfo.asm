?DyzenExtendedGetDrawInfo:
    LDA !ExtendedXHigh,x
    STA $01
    LDA !ExtendedXLow,x
    STA $00
    LDA !ExtendedYHigh,x
    STA $07
    LDA !ExtendedYLow,x
    STA $06
    %DyzenGenericGetDrawInfo()
RTL