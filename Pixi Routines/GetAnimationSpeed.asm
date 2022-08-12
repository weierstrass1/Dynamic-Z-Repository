
;A = Animation Pixels Per Frame
?GetAnimationSpeed:
    STA $00

    LDA !SpriteXSpeed,x
    BPL ?+
    EOR #$FF
    INC A
?+
    STA $02
    STZ $01

    %DivW(" $01", " $00", " $02")

    LDA !DivisionResult
    DEC A
RTL