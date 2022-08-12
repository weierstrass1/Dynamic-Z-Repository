?DyzenClusterSpriteNormalSpriteInteraction:
    PHY
    %DyzenNormalSpriteClippingRoutine()				; MarioClipping
	PLY

    LDX !SpriteIndex
    PHY
    %DyzenClusterSpriteInteraction()
    BCS ?+
    PLY
    CLC
RTL
?+
    PLY
    SEC
RTL