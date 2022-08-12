?DyzenClusterGetDrawInfo:
    LDA !ClusterXHigh,x
    STA $01
    LDA !ClusterXLow,x
    STA $00
    LDA !ClusterYHigh,x
    STA $07
    LDA !ClusterYLow,x
    STA $06
    %DyzenGenericGetDrawInfo()
RTL