	!dp = $0000
	!addr = $0000
    !rom = $800000
	!sa1 = 0
	!gsu = 0
    !sram7000 = $000000
    !sram7008 = $000000
    !ram7F9A7B = $000000
    !ram7FC700 = $000000
	!PaletteFreeRAM = $7F0B44 
	!MaxSprites = $0C

if read1($00FFD6) == $15
	!dp = $6000
	!addr = !dp
	!gsu = 1
elseif read1($00FFD5) == $23
	!dp = $3000
	!addr = $6000
	!sa1 = 1
    !rom = $000000
    !sram7000 = $2E4000
    !sram7008 = $2E6800
    !ram7F9A7B = $3E127B
    !ram7FC700 = $3DFF00
	!PaletteFreeRAM = $418000  
	!MaxSprites = $16
endif

;########################################
;######## Scratchs Rams [$00,$0F] #######
;########################################
!Scratch0 = $00
!Scratch1 = $01
!Scratch2 = $02
!Scratch3 = $03
!Scratch4 = $04
!Scratch5 = $05
!Scratch6 = $06
!Scratch7 = $07
!Scratch8 = $08
!Scratch9 = $09
!ScratchA = $0A
!ScratchB = $0B
!ScratchC = $0C
!ScratchD = $0D
!ScratchE = $0E
!ScratchF = $0F
!Scratch45 = $45
!Scratch46 = $46
!Scratch47 = $47
!Scratch48 = $48
!Scratch49 = $49
!Scratch4A = $4A
!Scratch4B = $4B
!Scratch4C = $4C
!Scratch4D = $4D
!Scratch4E = $4E
!Scratch4F = $4F
!Scratch50 = $50
!Scratch51 = $51
!Scratch52 = $52
!Scratch53 = $53

;########################################
;############## Counters ################
;########################################
!TrueFrameCounter = $13
!EffectiveFrameCounter = $14

;########################################
;############## Control #################
;########################################
!ButtonPressed_BYETUDLR = $15
!ButtonDown_BYETUDLR = $16
!ButtonPressed_AXLR0000 = $17
!ButtonDown_AXLR0000 = $18

;########################################
;############## Layers ##################
;########################################
!Layer1X = $1A
!Layer1Y = $1C
!Layer2X = $1E
!Layer2Y = $20
!Layer3X = $22
!Layer3Y = $24

;########################################
;############## Player ##################
;########################################
!PlayerX = $94
!PlayerY = $96
!PlayerXSpeed = $7B
!PlayerYSpeed = $7D
!PowerUp = $19
!Lives = $0DBE|!addr
!Coins = $0DBF|!addr
!ItemBox = $0DC2|!addr
!PlayerInAirFlag = $72
!PlayerDuckingFlag = $73
!PlayerClimbingFlag_N00SIFHB = $74
!PlayerWaterFlag = $75
!PlayerDirection = $76
!PlayerBlockedStatus_S00MUDLR = $77
!PlayerHide_DLUCAPLU = $78
!CurrentPlayer = $0DB3|!addr
!CapeImage = $13DF|!addr
!PlayerPose = $13E0|!addr
!PlayerSlope = $13E1|!addr
!SpinjumpTimer = $13E2|!addr
!PlayerWallRunningFlag = $13E3|!addr
!PlayerFrozenFlag = $13FB|!addr
!SpinJumpFlag = $140D|!addr
!PlayerCarryingFlag = $1470|!addr
!PlayerCarryingFlagImage = $148F|!addr
!PlayerAnimationTimer = $1496|!addr
!PlayerFlashingTimer = $1F2B|!addr;$1497|!addr
!P1PowerUp = $0DB8|!addr
!P2PowerUp = $0DB9|!addr
!P1Lives = $0DB4|!addr
!P2Lives = $0DB5|!addr
!P1Coins = $0DB6|!addr
!P2Coins = $0DB7|!addr
!P1YoshiColor = $0DBA|!addr
!P2YoshiColor = $0DBB|!addr
!P1ItemBox = $0DBC|!addr
!P2ItemBox = $0DBD|!addr
!RidingYoshi = $187A|!addr

;########################################
;############### Global #################
;########################################
!LockAnimationFlag = $9D
!HScrollEnable = $1411|!addr
!VScrollEnable = $1412|!addr
!HScrollLayer2Type = $1413|!addr
!VScrollLayer2Type = $1414|!addr
!WaterFlag = $85
!SlipperyFlag = $86
!GameMode = $0100|!addr
!TwoPlayersFlag = $0DB2|!addr

;########################################
;################ OAM ###################
;########################################
!TileXPosition200 = $0200|!addr
!TileYPosition200 = $0201|!addr
!TileCode200 = $0202|!addr
!TileProperty200 = $0203|!addr
!TileSize420 = $0420|!addr
!TileXPosition = $0300|!addr
!TileYPosition = $0301|!addr
!TileCode = $0302|!addr
!TileProperty = $0303|!addr
!TileSize460 = $0460|!addr

;########################################
;############### Yoshi ##################
;########################################
!YoshiX = $18B0|!addr
!YoshiY = $18B2|!addr
!YoshiKeyInMouthFlag = $191C|!addr

;########################################
;############## Clusters ################
;########################################
!ClusterNumber = $1892|!addr
!ClusterXLow = $1E16|!addr
!ClusterYLow = $1E02|!addr
!ClusterXHigh = $1E3E|!addr
!ClusterYHigh = $1E2A|!addr
!ClusterMiscTable1 = $0F4A|!addr
!ClusterMiscTable2 = $0F5E|!addr
!ClusterMiscTable3 = $0F72|!addr
!ClusterMiscTable4 = $0F86|!addr
!ClusterMiscTable5 = $0F9A|!addr
!ClusterMiscTable6 = $1E52|!addr
!ClusterMiscTable7 = $1E66|!addr
!ClusterMiscTable8 = $1E7A|!addr
!ClusterMiscTable9 = $1E8E|!addr
!ClusterPlayerIsAbove = $7F837B-$14

;########################################
;############## Extended ################
;########################################
!ExtendedNumber = $170B|!addr
!ExtendedXLow = $171F|!addr
!ExtendedYLow = $1715|!addr
!ExtendedXHigh = $1733|!addr
!ExtendedYHigh = $1729|!addr
!ExtendedXSpeed = $1747|!addr
!ExtendedYSpeed = $173D|!addr
!ExtendedXSpeedAccumulatingFraction = $175B|!addr
!ExtendedYSpeedAccumulatingFraction = $1751|!addr
!ExtendedBehindLayersFlag = $1779|!addr
!ExtendedMiscTable1 = $1765|!addr
!ExtendedMiscTable2 = $176F|!addr

;########################################
;############### Sprites ################
;########################################
!SpriteIndex = $15E9|!addr
!SpriteNumber = $9E
!SpriteStatus = $14C8
!SpriteXLow = $E4
!SpriteYLow = $D8
!SpriteXHigh = $14E0
!SpriteYHigh = $14D4
!SpriteXSpeed = $B6
!SpriteYSpeed = $AA
!SpriteXSpeedAccumulatingFraction = $14F8
!SpriteYSpeedAccumulatingFraction = $14EC
!SpriteDirection = $157C
!SpriteBlockedStatus_ASB0UDLR = $1588
!SpriteHOffScreenFlag = $15A0
!SpriteVOffScreenFlag = $186C
!SpriteHMoreThan4TilesOffScreenFlag = $15C4
!SpriteSlope = $15B8
!SpriteYoshiTongueFlag = $15D0
!SpriteInteractionWithObjectEnable = $15DC
!SpriteIndexOAM = $15EA
!SpriteProperties_YXPPCCCT = $15F6
!SpriteLoadStatus = $161A
!SpriteBehindEscenaryFlag = $1632
!SpriteInLiquidFlag = $164A
!SpriteDecTimer1 = $1540
!SpriteDecTimer2 = $154C
!SpriteDecTimer3 = $1558
!SpriteDecTimer4 = $1564
!SpriteDecTimer5 = $15AC
!SpriteDecTimer6 = $163E
!SpriteDecTimer7 = $1FE2
!SpriteTweaker1656_SSJJCCCC = $1656
!SpriteTweaker1662_DSCCCCCC = $1662
!SpriteTweaker166E_LWCFPPPG = $166E
!SpriteTweaker167A_DPMKSPIS = $167A
!SpriteTweaker1686_DNCTSWYE = $1686
!SpriteTweaker190F_WCDJ5SDP = $190F
!SpriteMiscTable1 = $0DF5|!addr
!SpriteMiscTable2 = $0E0B|!addr
!SpriteMiscTable3 = $C2
!SpriteMiscTable4 = $1504
!SpriteMiscTable5 = $1510
!SpriteMiscTable6 = $151C
!SpriteMiscTable7 = $1528
!SpriteMiscTable8 = $1534
!SpriteMiscTable9 = $1570
!SpriteMiscTable10 = $1594
!SpriteMiscTable11 = $1602
!SpriteMiscTable12 = $160E
!SpriteMiscTable13 = $1626
!SpriteMiscTable14 = $187B
!SpriteMiscTable15 = $1FD6

;########################################
;############### GIEPY ##################
;########################################
!ExtraBits = $7FAB10
!NewCodeFlag = $7FAB1C
!ExtraProp1 = $7FAB28
!ExtraProp2 = $7FAB34
!ExtraByte1 = $7FAB40
!ExtraByte2 = $7FAB4C
!ExtraByte3 = $7FAB58
!ExtraByte4 = $7FAB64
!ShooterExtraByte = $7FAB70
!GeneratorExtraByte = $7FAB78
!ScrollerExtraByte = $7FAB79
!CustomSpriteNumber = $7FAB9E
!ShooterExtraBits = $7FABAA
!GeneratorExtraBits = $7FABB2
!Layer1ExtraBits = $7FABB3
!Layer2ExtraBits = $7FABB4
!SpriteFlags = $7FABB5

if !sa1

!SpriteNumber = $3200
!SpriteYSpeed = $9E
!SpriteXSpeed = $B6
!SpriteMiscTable3 = $D8
!SpriteYLow = $3216
!SpriteXLow = $322C
!SpriteStatus = $3242
!SpriteYHigh = $3258
!SpriteXHigh = $326E
!SpriteYSpeedAccumulatingFraction = $74C8
!SpriteXSpeedAccumulatingFraction = $74DE
!SpriteMiscTable4 = $74F4
!SpriteMiscTable5 = $750A
!SpriteMiscTable6 = $3284
!SpriteMiscTable7 = $329A
!SpriteMiscTable8 = $32B0
!SpriteDecTimer1 = $32C6
!SpriteDecTimer2 = $32DC
!SpriteDecTimer3 = $32F2
!SpriteDecTimer4 = $3308
!SpriteMiscTable9 = $331E
!SpriteDirection = $3334
!SpriteBlockedStatus_ASB0UDLR = $334A
!SpriteMiscTable10 = $3360
!SpriteHOffScreenFlag = $3376
!SpriteDecTimer5 = $338C
!SpriteSlope = $7520
!SpriteHMoreThan4TilesOffScreenFlag = $7536
!SpriteYoshiTongueFlag = $754C
!SpriteInteractionWithObjectEnable = $7562
!SpriteIndexOAM = $33A2
!SpriteProperties_YXPPCCCT = $33B8
!SpriteMiscTable11 = $33CE
!SpriteMiscTable12 = $33E4
!SpriteLoadStatus = $7578
!SpriteMiscTable13 = $758E
!SpriteBehindEscenaryFlag = $75A4
!SpriteDecTimer6 = $33FA
!SpriteInLiquidFlag = $75BA
!SpriteTweaker1656_SSJJCCCC = $75D0
!SpriteTweaker1662_DSCCCCCC = $75EA
!SpriteTweaker166E_LWCFPPPG = $7600
!SpriteTweaker167A_DPMKSPIS = $7616
!SpriteTweaker1686_DNCTSWYE = $762C
!SpriteVOffScreenFlag = $7642
!SpriteMiscTable14 = $3410
!SpriteTweaker190F_WCDJ5SDP = $7658
!SpriteMiscTable15 = $766E
!SpriteDecTimer7 = $7FD6

!ExtraBits = $400040
!NewCodeFlag = $400056
!ExtraProp1 = $400057
!ExtraProp2 = $40006D
!ExtraByte1 = $400099
!ExtraByte2 = $4000AF
!ExtraByte3 = $4000C5
!ExtraByte4 = $4000DB
!ShooterExtraByte = $400110
!GeneratorExtraByte = $4000FC
!ScrollerExtraByte = $4000FD
!CustomSpriteNumber = $400083
!ShooterExtraBits = $400099
!GeneratorExtraBits = $4000A1
!Layer1ExtraBits = $4000A2
!Layer2ExtraBits = $4000A3
!SpriteFlags = $400118

!cam_x = $34FF
!cam_y = !cam_x-$02
!level_size = !cam_y-$02
!level_height = !level_size-$02
!camera_lock_y = !level_height-$02
!camera_lock_x = !camera_lock_y-$02
!camera_mario_x = !camera_lock_x-$02
endif

!ExtendedAnimationIndex = DZ_FreeRams+$000
!ExtendedAnimationFrameIndex = DZ_FreeRams+$00A
!ExtendedLocalFlip = DZ_FreeRams+$014
!ExtendedGlobalFlip = DZ_FreeRams+$01E
!ExtendedLastFrameIndex = DZ_FreeRams+$028
!ExtendedStarted = DZ_FreeRams+$032
!ExtendedPal = DZ_FreeRams+$03C
!ExtendedLoadPal = DZ_FreeRams+$046
!ExtendedPlayerIsAbove = DZ_FreeRams+$050
!ExtendedUseDyzenHitbox = DZ_FreeRams+$05A
!ExtendedHitboxTableB = DZ_FreeRams+$064
!ExtendedHitboxTableH = DZ_FreeRams+$06E
!ExtendedHitboxTableL = DZ_FreeRams+$078
!ExtendedMiscTable3 = DZ_FreeRams+$082
!ExtendedMiscTable4 = DZ_FreeRams+$08C
!ExtendedMiscTable5 = DZ_FreeRams+$096
!ExtendedMiscTable6 = DZ_FreeRams+$230
!ExtendedMiscTable7 = DZ_FreeRams+$23A
!ExtendedMiscTable8 = DZ_FreeRams+$244
!ExtendedMiscTable9 = DZ_FreeRams+$24E
!ExtendedMiscTable10 = DZ_FreeRams+$258
!ExtendedMiscTable11 = DZ_FreeRams+$262
!ExtendedMiscTable12 = DZ_FreeRams+$26C
!ExtendedMiscTable13 = DZ_FreeRams+$276
!ExtendedMiscTable14 = DZ_FreeRams+$280
!ExtendedMiscTable15 = DZ_FreeRams+$28A

!ColorScratchs = DZ_FreeRams+$0A0
!IDK = DZ_FreeRams+$120

!ClusterPal = DZ_FreeRams+$12C
!ClusterLoadPal = DZ_FreeRams+$140
!ClusterPlayerIsAbove = DZ_FreeRams+$154
!ClusterUseDyzenHitbox = DZ_FreeRams+$168
!ClusterHitboxTableB = DZ_FreeRams+$17C
!ClusterHitboxTableH = DZ_FreeRams+$190
!ClusterHitboxTableL = DZ_FreeRams+$1A4
!ClusterMiscTable10 = DZ_FreeRams+$1B8
!ClusterMiscTable11 = DZ_FreeRams+$1CC
!ClusterMiscTable12 = DZ_FreeRams+$1E0
!ClusterMiscTable13 = DZ_FreeRams+$1F4
!ClusterMiscTable14 = DZ_FreeRams+$208
!ClusterMiscTable15 = DZ_FreeRams+$21C

!SpritePal = DZ_FreeRams+$294
!SpriteLoadPal = DZ_FreeRams+$2AA