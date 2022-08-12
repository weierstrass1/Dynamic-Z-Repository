;A = hitbox id
;$45 = X 16 bits
;$47 = Y 16 bits
;$49 = Frame
;Y = Flip
;Output:
;$00 = Left
;$02 = Right
;$08 = Top
;$0C = Bottom
;A = FF if it is the end of the hitbox 

!X = $45
!Y = $47
!Frame = $49
!HbID = $4B
!HitboxTables = ($8D)           ;HitboxTables
!HitboxAdder = ($00)            ;HitboxAdder
!FrameHitboxesIndexer = ($02)   ;FrameHitboxesIndexer
!FrameHitBoxes = ($04)          ;FrameHitBoxes
!HitboxXOffset = ($08)          ;HitboxXOffset
!HitboxYOffset = ($0A)          ;HitboxYOffset
!HitboxWidth = ($0C)            ;HitboxWidth
!HitboxHeight = ($0E)           ;HitboxHeight
!HitboxAction1 = ($53)          ;HitboxAction1
?DyzenGetHitBoxClippingB:
    STA !HbID
    STZ !HbID+1
    PHX
    TYX

    PHB

    LDA $8F
    PHA
    PLB

    LDY #$00
    REP #$20
    LDA !HitboxTables,y
    STA $00         ;HitboxAdder
    LDY #$02
    LDA !HitboxTables,y
    STA $02         ;FrameHitboxesIndexer
    LDY #$04
    LDA !HitboxTables,y     
    STA $04         ;FrameHitBoxes
    LDY #$08
    LDA !HitboxTables,y
    STA $08         ;HitboxXOffset
    LDY #$0A
    LDA !HitboxTables,y
    STA $0A         ;HitboxYOffset
    LDY #$0C
    LDA !HitboxTables,y
    STA $0C         ;HitboxWidth
    LDY #$0E
    LDA !HitboxTables,y
    STA $0E         ;HitboxHeight
    LDY #$10
    LDA !HitboxTables,y
    STA $53

    SEP #$20

    LDA #$00
    XBA
    TXA
    REP #$30
    ASL
    TAY

    LDA !Frame
    ASL
    CLC
    ADC !HitboxAdder,y
    TAY

    LDA !FrameHitboxesIndexer,y
    CLC
    ADC !HbID
    TAY

    SEP #$20
	LDA #$00
	XBA
	LDA !FrameHitBoxes,y		;FrameHitBoxes[Y]
    CMP #$FF
    BNE ?+
    SEP #$10
    PLB
    PLX
    CLC
RTL
?+

    REP #$20
    ASL
    TAY

	LDA !HitboxXOffset,y		;Hitboxes[Y].XOffset
	CLC
	ADC !X				        ;A = Hitboxes[Y].XOffset + X
    STA $00                     ;Left
    CLC
    ADC !HitboxWidth,y
    STA $02                     ;Right

	LDA !HitboxYOffset,y		;Hitboxes[Y].YOffset
	CLC
	ADC !Y				        ;A = Hitboxes[Y].YOffset + Y
	STA $08                     ;Top
    CLC
    ADC !HitboxHeight,y
    STA $0C                     ;Bottom
    
    SEP #$30

    PLB
    PLX
    SEC
RTL