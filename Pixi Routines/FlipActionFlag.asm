?FlipActionFlag:

    LDA !SpriteActionFlag,x
    AND #$02
    BEQ ?+
RTL
?+
    LDA #$00
    XBA

    LDA !SpriteTweaker1686_DNCTSWYE,x
    AND #$18
    BEQ ?+
RTL
?+
    
    JSL $03B69F|!rom

    TXY
    DEY
?.loop
    BMI ?.end

    LDA !SpriteStatus,y
    CMP #$08
    BNE ?.next

    LDA !SpriteTweaker1686_DNCTSWYE,y
    AND #$18
    BNE ?.next

    LDA !SpriteXSpeed,y
    ORA !SpriteXSpeed,x
    BEQ ?.next

    LDA !SpriteXSpeed,y
    EOR !SpriteXSpeed,x
    AND #$80
    BEQ ?.next

    TYX

    JSL $03B6E5|!rom
    JSL $03B72B|!rom
    BCC ?.noContact

    LDA #$01
    XBA

    LDA !SpriteDecTimer5,x
    BNE ?.skip1
    LDA !SpriteBlockedStatus_ASB0UDLR,x
    AND #$23
    BNE ?.skip1
    LDA !SpriteActionFlag,x
    AND #$04
    BNE ?.skip1

    LDA #$06
    ORA !SpriteActionFlag,x
    STA !SpriteActionFlag,x

?.skip1
    TXY
    LDX !SpriteIndex

    LDA !SpriteDecTimer5,x
    BNE ?.skip2
    LDA !SpriteBlockedStatus_ASB0UDLR,x
    AND #$23
    BNE ?.skip2
    LDA !SpriteActionFlag,x
    AND #$04
    BNE ?.skip2

    LDA #$06
    ORA !SpriteActionFlag,x
    STA !SpriteActionFlag,x
?.skip2

    DEY
    BRA ?.loop

?.noContact

    TXY
    LDX !SpriteIndex

?.next
    DEY
    BRA ?.loop
?.end

    LDA !SpriteActionFlag,x
    AND #$02
    BNE ?+
    XBA
    BNE ?+

    LDA !SpriteActionFlag,x
    AND #$FB
    STA !SpriteActionFlag,x

?+
RTL