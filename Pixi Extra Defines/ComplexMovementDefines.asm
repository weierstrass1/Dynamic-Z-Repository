!MaxSprites = $0C

if read1($00FFD5) == $23
    !MaxSprites = $16
endif

!Pal = !SpritePal
!Version = !SpriteMiscTable11
!MovTypeY = DZ_FreeRams2
!MaxSpeedX = !MovTypeY+!MaxSprites
!MaxSpeedY = !MaxSpeedX+!MaxSprites
!AccelX = !MaxSpeedY+!MaxSprites
!AccelY = !AccelX+!MaxSprites
!AngleLow = !AccelY+!MaxSprites
!AngleHigh = !AngleLow+!MaxSprites
!AngleSpeed = !AngleHigh+!MaxSprites
!AmplitudeX = !AngleSpeed+!MaxSprites
!AmplitudeY = !AmplitudeX+!MaxSprites
!PosXL = !AmplitudeY+!MaxSprites
!PosXH = !PosXL+!MaxSprites
!PosYL = !PosXH+!MaxSprites
!PosYH = !PosYL+!MaxSprites
!MovTypeX = !PosYH+!MaxSprites
!PhaseLow = !MovTypeX+!MaxSprites
!PhaseHigh = !PhaseLow+!MaxSprites
!RatioX = !PhaseHigh+!MaxSprites
!RatioY = !RatioX+!MaxSprites
!RatioIncreaseX = !RatioY+!MaxSprites
!RatioIncreaseY = !RatioIncreaseX+!MaxSprites
!RatioIncreaseTimerX = !RatioIncreaseY+!MaxSprites
!RatioIncreaseTimerY = !RatioIncreaseTimerX+!MaxSprites
!RatioAccelX = !RatioIncreaseTimerY+!MaxSprites
!RatioAccelY = !RatioAccelX+!MaxSprites
!RatioMaxX = !RatioAccelY+!MaxSprites
!RatioMaxY = !RatioMaxX+!MaxSprites
!PaletteChecker = !RatioMaxY+!MaxSprites
!FreeRams3 = !PaletteChecker+$10

!SpritePlayerIsAbove = !FreeRams3
!SpriteActionFlag = !SpritePlayerIsAbove+!MaxSprites
!SpriteHitboxTableB = !SpriteActionFlag+!MaxSprites
!SpriteHitboxTableH = !SpriteHitboxTableB+!MaxSprites
!SpriteHitboxTableL = !SpriteHitboxTableH+!MaxSprites
!SpriteMiscTable16 = !SpriteHitboxTableL+!MaxSprites
!SpriteMiscTable17 = !SpriteMiscTable16+!MaxSprites
!SpriteMiscTable18 = !SpriteMiscTable17+!MaxSprites
!SpriteMiscTable19 = !SpriteMiscTable18+!MaxSprites
!SpriteMiscTable20 = !SpriteMiscTable19+!MaxSprites
!SpriteMiscTable21 = !SpriteMiscTable20+!MaxSprites

!SpriteHitboxXOffset = !SpriteMiscTable21+!MaxSprites
!SpriteHitboxYOffset = !SpriteHitboxXOffset+!MaxSprites
!SpriteHitboxWidth = !SpriteHitboxYOffset+!MaxSprites
!SpriteHitboxHeight = !SpriteHitboxWidth+!MaxSprites