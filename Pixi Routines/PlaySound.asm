?PlaySound:
    XBA
    LDA $0DA1|!addr
    AND #$01
    EOR #$01
    STA $0DA1|!addr
    BEQ ?+

    XBA
    STA $1DF9|!addr
RTL
?+
    XBA
    STA $1DFC|!addr
RTL

