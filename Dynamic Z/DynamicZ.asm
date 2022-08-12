
;dont touch this
	!dp = $0000
	!addr = $0000
    !rom = $800000
	!sa1 = 0
    !Variables = $7F0B44 
    !Variables2 = $7FB080
    !MaxSprites = $0C
    !SpriteStatus = $14C8
    !SpriteNumberNormal = $7FAB9E
    !SpriteLoadStatus = $161A
    !SpriteLoadTable = $7FAF00
    !ExtraByte1 = $7FAB40
    !MultiplicationResult = $4216
    !DivisionResult = $4214
    !RemainderResult = $4216
    !SpriteOAMIndex = $15EA
    !SpriteXLow = $E4
    !SpriteYLow = $D8
    !SpriteXHigh = $14E0
    !SpriteYHigh = $14D4
    !UberASMTool = 0

if read1($00FFD5) == $23
	sa1rom
	!dp = $3000
	!addr = $6000
	!sa1 = 1
    !rom = $000000
    !Variables = $418000  
    !Variables2 = $418B80
    !MaxSprites = $16
    !SpriteStatus = $3242
    !SpriteNumberNormal = $400083
    !SpriteLoadStatus = $7578
    !SpriteLoadTable = $418A00
    !ExtraByte1 = $400099
    !MultiplicationResult = $2306
    !DivisionResult = $2306
    !RemainderResult = $2308
    !SpriteOAMIndex = $33A2
    !SpriteYLow = $3216
    !SpriteXLow = $322C
    !SpriteYHigh = $3258
    !SpriteXHigh = $326E
endif

incsrc "Hijacks/BaseHijack.asm"
incsrc "Options.asm"
incsrc "header.asm"
incsrc "Hijacks/MarioGFXDMAOptimizationHijack.asm"
;incsrc "Hijacks/OAMHijack.asm"

freecode

Routines:
if !DynamicSpriteSupport == !True
    dl ClearSlot|!rom
    dl CheckSlot|!rom
    dl FindSpace|!rom
    dl DynamicRoutine|!rom
else
    dl $000000
    dl $000000
    dl $000000
    dl $000000
endif 
if read2($00823D+4) == $8449
    dl $000000
else
    !__main_clean = read3((read1($0082DA+4)<<16+read2($00823D+4))+$0C)
    if !__main_clean == $000000
        dl $000000
    else
        if read3(!__main_clean-3) != $FFFFFF
            dl $000000
        else
            dl !__main_clean
        endif
    endif
endif
if !DynamicSpriteSupport == !True
    dl CheckEvenOrOdd|!rom
    dl GetVramDisp|!rom
    dl GetVramDispDynamicRoutine|!rom
    dl RemapOamTile|!rom
    if !SharedDynamicSpriteSupport == !True
    dl CheckNormalSharedDynamicExisted|!rom
    dl CheckClusterSharedDynamicExisted|!rom
    dl CheckExtendedSharedDynamicExisted|!rom
    dl CheckOWSharedDynamicExisted|!rom
    dl CheckIfLastNormalSharedProcessed|!rom
    dl CheckIfLastClusterSharedProcessed|!rom
    dl CheckIfLastExtendedSharedProcessed|!rom
    dl CheckIfLastOWSharedProcessed|!rom
    else
    dl $000000
    dl $000000
    dl $000000
    dl $000000
    dl $000000
    dl $000000
    dl $000000
    dl $000000
    endif
else
    dl $000000
    dl $000000
    dl $000000
    dl $000000
    dl $000000
    dl $000000
    dl $000000
    dl $000000
    dl $000000
    dl $000000
    dl $000000
    dl $000000
endif
if !HSVSystem == !True
    dl SetHSLBase|!rom
    dl SetRGBBase|!rom
    dl MixHSL|!rom
    dl MixRGB|!rom
else
    dl $000000
    dl $000000
    dl $000000
    dl $000000
endif
if !SemiDynamicSpriteSupport == !True
    dl LoadGraphicsSDSNormal|!rom
    dl FindCopyNormal|!rom
    dl LoadGraphicsSDSCluster|!rom
    dl FindCopyCluster|!rom
    dl LoadGraphicsSDSExtended|!rom
    dl FindCopyExtended|!rom
    dl LoadGraphicsSDSOW|!rom
    dl FindCopyOW|!rom
else 
    dl $000000
    dl $000000
    dl $000000
    dl $000000
    dl $000000
    dl $000000
    dl $000000
    dl $000000
endif
if !DynamicSpriteSupport == !True
    dl EasyNormalSpriteDynamicRoutine|!rom
    dl EasySpriteDynamicRoutine|!rom
else
    dl $000000
    dl $000000
endif

GameModeTable:
    db $00,$00,$01,$01,$01,$01,$01,$01
    ;  g00,g01,g02,g03,g04,g05,g06,g07
    db $01,$01,$01,$00,$02,$02,$02,$01
    ;  g08,g09,g0A,g0B,g0C,g0D,g0E,g0F
    db $00,$01,$01,$01,$01,$01,$01,$00
    ;  g10,g11,g12,g13,g14,g15,g16,g17
    db $01,$01,$01,$01,$01,$01,$01,$01
    ;  g18,g19,g1A,g1B,g1C,g1D,g1E,g1F
    db $00,$00,$00,$00,$01,$01,$00,$00
    ;  g20,g21,g22,g23,g24,g25,g26,g27
    db $00,$00,$00,$00,$00,$00,$00,$00
    ;  g28,g29,g2A,g2B,g2C,g2D,g2E,g2F
DynamicZ:

    LDX $0100|!addr

    ;Find on the table if the current level mode activate Dynamic Z
    LDA.l GameModeTable,x
    BNE +

    ;If Dynamic Z is inactive, reset its importants variables
    JSR DynamicZStart
RTL
+
    PHD

	REP #$30
	LDY #$0004            ;Used to activate DMA Transfer

	LDA #$4300
	TCD                 ;direct page = 4300 for speed

    SEP #$30

if !GFXFeatures == !True
    JSR VRAMDMA
endif
if !PaletteFeatures == !True
    JSR CGRAMDMA
    if !HSVSystem == !True || !RGBSystem == !True
    JSR CGRAMToBufferDMA
    endif
endif

    LDA DZ_Timer
    INC A
    STA DZ_Timer

if !DynamicSpriteSupport == !True
    AND #$01
    TAX
    LDA #$00
    XBA
    LDA DZ_DS_TotalDataSentOdd,x
    REP #$30
    CLC
    ASL
    TAX
    LDA.l X128,x
    STA DZ_CurrentDataSend
    SEP #$30
else
    LDA #$00
    STA DZ_CurrentDataSend
    STA DZ_CurrentDataSend+1
endif

    PLD
RTL

if !DynamicSpriteSupport == !True
X128:
    dw $0000,$0080,$0100,$0180,$0200,$0280,$0300,$0380,$0400,$0480,$0500,$0580,$0600,$0680,$0700,$0780
    dw $0800,$0880,$0900,$0980,$0A00,$0A80,$0B00,$0B80,$0C00,$0C80,$0D00,$0D80,$0E00,$0E80,$0F00,$0F80
    dw $1000,$1080,$1100,$1180,$1200,$1280,$1300,$1380,$1400,$1480,$1500,$1580,$1600,$1680,$1700,$1780
    dw $1800,$1880,$1900,$1980,$1A00,$1A80,$1B00,$1B80,$1C00,$1C80,$1D00,$1D80,$1E00,$1E80,$1F00,$1F80
    dw $2000,$2080,$2100,$2180,$2200,$2280,$2300,$2380,$2400,$2480,$2500,$2580,$2600,$2680,$2700,$2780
    dw $2800,$2880,$2900,$2980,$2A00,$2A80,$2B00,$2B80,$2C00,$2C80,$2D00,$2D80,$2E00,$2E80,$2F00,$2F80
    dw $3000,$3080,$3100,$3180,$3200,$3280,$3300,$3380,$3400,$3480,$3500,$3580,$3600,$3680,$3700,$3780
    dw $3800,$3880,$3900,$3980,$3A00,$3A80,$3B00,$3B80,$3C00,$3C80,$3D00,$3D80,$3E00,$3E80,$3F00,$3F80
    dw $4000,$4080,$4100,$4180,$4200,$4280,$4300,$4380,$4400,$4480,$4500,$4580,$4600,$4680,$4700,$4780
    dw $4800,$4880,$4900,$4980,$4A00,$4A80,$4B00,$4B80,$4C00,$4C80,$4D00,$4D80,$4E00,$4E80,$4F00,$4F80
    dw $5000,$5080,$5100,$5180,$5200,$5280,$5300,$5380,$5400,$5480,$5500,$5580,$5600,$5680,$5700,$5780
    dw $5800,$5880,$5900,$5980,$5A00,$5A80,$5B00,$5B80,$5C00,$5C80,$5D00,$5D80,$5E00,$5E80,$5F00,$5F80
    dw $6000,$6080,$6100,$6180,$6200,$6280,$6300,$6380,$6400,$6480,$6500,$6580,$6600,$6680,$6700,$6780
    dw $6800,$6880,$6900,$6980,$6A00,$6A80,$6B00,$6B80,$6C00,$6C80,$6D00,$6D80,$6E00,$6E80,$6F00,$6F80
    dw $7000,$7080,$7100,$7180,$7200,$7280,$7300,$7380,$7400,$7480,$7500,$7580,$7600,$7680,$7700,$7780
    dw $7800,$7880,$7900,$7980,$7A00,$7A80,$7B00,$7B80,$7C00,$7C80,$7D00,$7D80,$7E00,$7E80,$7F00,$7F80
endif

DynamicZStart:
if !PlayerGFX == !True || !PlayerPalette == !True
    REP #$20
    LDA #$FFFF
if !PlayerGFX == !True
    STA $0D85|!addr
    STA $0D87|!addr
    STA $0D89|!addr
    STA $0D8B|!addr
    STA $0D8D|!addr
    STA $0D8F|!addr
    STA $0D91|!addr
    STA $0D93|!addr
    STA $0D95|!addr
    STA $0D97|!addr
    STA $0D99|!addr
endif
if !PlayerPalette == !True
    LDA $0D82|!addr
    STA.l DZ_Player_Palette_Addr
endif
    SEP #$20
endif

    PHB
    LDA.b #!Variables>>16
    PHA
    PLB

    REP #$20
if !DynamicSpriteSupport == !True
    LDA.w #!DefaultLevelDSVRAMOFfset
    STA.w DZ_DS_StartingVRAMOffset
endif

    LDA.w #!DefaultLevelMaxDataTransferPerFrame
    STA.w DZ_MaxDataPerFrame

    LDA #$0000
if !DynamicSpriteSupport == !True
    STA.w DZ_DS_TotalSpaceUsed
    STA.w DZ_DS_TotalSpaceUsedOdd
    STA.w DZ_DS_TotalDataSentOdd
endif
if !SemiDynamicSpriteSupport == !True
    STA.w DZ_SDS_SpriteNumber_Normal
    STA.w DZ_SDS_SpriteNumber_Normal+$02
    STA.w DZ_SDS_SpriteNumber_Normal+$04
    STA.w DZ_SDS_SpriteNumber_Normal+$06
    STA.w DZ_SDS_SpriteNumber_Normal+$08
    STA.w DZ_SDS_SpriteNumber_Normal+$0A

    if !sa1
    STA.w DZ_SDS_SpriteNumber_Normal+$0C
    STA.w DZ_SDS_SpriteNumber_Normal+$0E
    STA.w DZ_SDS_SpriteNumber_Normal+$10
    STA.w DZ_SDS_SpriteNumber_Normal+$12
    STA.w DZ_SDS_SpriteNumber_Normal+$14
    endif

    STA.w DZ_SDS_SpriteNumber_Cluster
    STA.w DZ_SDS_SpriteNumber_Cluster+$02
    STA.w DZ_SDS_SpriteNumber_Cluster+$04
    STA.w DZ_SDS_SpriteNumber_Cluster+$06
    STA.w DZ_SDS_SpriteNumber_Cluster+$08
    STA.w DZ_SDS_SpriteNumber_Cluster+$0A
    STA.w DZ_SDS_SpriteNumber_Cluster+$0C
    STA.w DZ_SDS_SpriteNumber_Cluster+$0E
    STA.w DZ_SDS_SpriteNumber_Cluster+$10
    STA.w DZ_SDS_SpriteNumber_Cluster+$12

    STA.w DZ_SDS_SpriteNumber_Extended
    STA.w DZ_SDS_SpriteNumber_Extended+$02
    STA.w DZ_SDS_SpriteNumber_Extended+$04
    STA.w DZ_SDS_SpriteNumber_Extended+$06
    STA.w DZ_SDS_SpriteNumber_Extended+$08

    STA.w DZ_SDS_SpriteNumber_OW
    STA.w DZ_SDS_SpriteNumber_OW+$02
    STA.w DZ_SDS_SpriteNumber_OW+$04
    STA.w DZ_SDS_SpriteNumber_OW+$06
    STA.w DZ_SDS_SpriteNumber_OW+$08
    STA.w DZ_SDS_SpriteNumber_OW+$0A
    STA.w DZ_SDS_SpriteNumber_OW+$0C
    STA.w DZ_SDS_SpriteNumber_OW+$0E

endif
if !PlayerPalette == !True
    STA.w DZ_PPUMirrors_CGRAM_LastPlayerPal
endif

if !PlayerGFX == !True
    LDA #$2000
    STA.w DZ_Player_GFX_Addr
    LDA #$007E
    STA.w DZ_Player_GFX_BNK
endif

    LDA #$FFFF
if !DynamicSpriteSupport == !True
    STA.w DZ_DS_Loc_UsedBy
    STA.w DZ_DS_Loc_UsedBy+$02
    STA.w DZ_DS_Loc_UsedBy+$04
    STA.w DZ_DS_Loc_UsedBy+$06
    STA.w DZ_DS_Loc_UsedBy+$08
    STA.w DZ_DS_Loc_UsedBy+$0A
    STA.w DZ_DS_Loc_UsedBy+$0C
    STA.w DZ_DS_Loc_UsedBy+$0E
    STA.w DZ_DS_Loc_UsedBy+$10
    STA.w DZ_DS_Loc_UsedBy+$12
    STA.w DZ_DS_Loc_UsedBy+$14
    STA.w DZ_DS_Loc_UsedBy+$16
    STA.w DZ_DS_Loc_UsedBy+$18
    STA.w DZ_DS_Loc_UsedBy+$1A
    STA.w DZ_DS_Loc_UsedBy+$1C
    STA.w DZ_DS_Loc_UsedBy+$1E
    STA.w DZ_DS_Loc_UsedBy+$20
    STA.w DZ_DS_Loc_UsedBy+$22
    STA.w DZ_DS_Loc_UsedBy+$24
    STA.w DZ_DS_Loc_UsedBy+$26
    STA.w DZ_DS_Loc_UsedBy+$28
    STA.w DZ_DS_Loc_UsedBy+$2A
    STA.w DZ_DS_Loc_UsedBy+$2C
    STA.w DZ_DS_Loc_UsedBy+$2E

    STA.w DZ_DS_Loc_US_Normal
    STA.w DZ_DS_Loc_US_Normal+$02
    STA.w DZ_DS_Loc_US_Normal+$04
    STA.w DZ_DS_Loc_US_Normal+$06
    STA.w DZ_DS_Loc_US_Normal+$08
    STA.w DZ_DS_Loc_US_Normal+$0A

    if !sa1
    STA.w DZ_DS_Loc_US_Normal+$0E
    STA.w DZ_DS_Loc_US_Normal+$10
    STA.w DZ_DS_Loc_US_Normal+$12
    STA.w DZ_DS_Loc_US_Normal+$14
    endif

    STA.w DZ_DS_Loc_NextSlot
    STA.w DZ_DS_Loc_NextSlot+$02
    STA.w DZ_DS_Loc_NextSlot+$04
    STA.w DZ_DS_Loc_NextSlot+$06
    STA.w DZ_DS_Loc_NextSlot+$08
    STA.w DZ_DS_Loc_NextSlot+$0A
    STA.w DZ_DS_Loc_NextSlot+$0C
    STA.w DZ_DS_Loc_NextSlot+$0E
    STA.w DZ_DS_Loc_NextSlot+$10
    STA.w DZ_DS_Loc_NextSlot+$12
    STA.w DZ_DS_Loc_NextSlot+$14
    STA.w DZ_DS_Loc_NextSlot+$16
    STA.w DZ_DS_Loc_NextSlot+$18
    STA.w DZ_DS_Loc_NextSlot+$1A
    STA.w DZ_DS_Loc_NextSlot+$1C
    STA.w DZ_DS_Loc_NextSlot+$1E
    STA.w DZ_DS_Loc_NextSlot+$20
    STA.w DZ_DS_Loc_NextSlot+$22
    STA.w DZ_DS_Loc_NextSlot+$24
    STA.w DZ_DS_Loc_NextSlot+$26
    STA.w DZ_DS_Loc_NextSlot+$28
    STA.w DZ_DS_Loc_NextSlot+$2A
    STA.w DZ_DS_Loc_NextSlot+$2C
    STA.w DZ_DS_Loc_NextSlot+$2E
    STA.w DZ_DS_Loc_PreviewSlot
    STA.w DZ_DS_Loc_PreviewSlot+$02
    STA.w DZ_DS_Loc_PreviewSlot+$04
    STA.w DZ_DS_Loc_PreviewSlot+$06
    STA.w DZ_DS_Loc_PreviewSlot+$08
    STA.w DZ_DS_Loc_PreviewSlot+$0A
    STA.w DZ_DS_Loc_PreviewSlot+$0C
    STA.w DZ_DS_Loc_PreviewSlot+$0E
    STA.w DZ_DS_Loc_PreviewSlot+$10
    STA.w DZ_DS_Loc_PreviewSlot+$12
    STA.w DZ_DS_Loc_PreviewSlot+$14
    STA.w DZ_DS_Loc_PreviewSlot+$16
    STA.w DZ_DS_Loc_PreviewSlot+$18
    STA.w DZ_DS_Loc_PreviewSlot+$1A
    STA.w DZ_DS_Loc_PreviewSlot+$1C
    STA.w DZ_DS_Loc_PreviewSlot+$1E
    STA.w DZ_DS_Loc_PreviewSlot+$20
    STA.w DZ_DS_Loc_PreviewSlot+$22
    STA.w DZ_DS_Loc_PreviewSlot+$24
    STA.w DZ_DS_Loc_PreviewSlot+$26
    STA.w DZ_DS_Loc_PreviewSlot+$28
    STA.w DZ_DS_Loc_PreviewSlot+$2A
    STA.w DZ_DS_Loc_PreviewSlot+$2C
    STA.w DZ_DS_Loc_PreviewSlot+$2E

    STA.w DZ_DS_LastSlot
endif
    SEP #$20


if !GFXFeatures == !True
    STA.w DZ_PPUMirrors_VRAM_Transfer_Length
endif
if !PaletteFeatures == !True
    STA.w DZ_PPUMirrors_CGRAM_Transfer_Length
    if !HSVSystem == !True || !RGBSystem == !True
    STA.w DZ_PPUMirrors_CGRAM_BufferTransfer_Length
    endif
endif

    LDA.b #!DefaultLevelMaxDataTransferPerFrameIn16x16Tiles
    STA.w DZ_MaxDataPerFrameIn16x16Tiles

if !DynamicSpriteSupport == !True
    LDA.b #!DefaultLevelDSMaxSpaceIn16x16Tiles
    STA.w DZ_DS_MaxSpace

    LDA.b #!DefaultLevelFindMethod
    STA.w DZ_DS_FindSpaceMethod

    LDA.b #!DefaultLevelDSVRAMOffsetIn8x8Tiles
    STA.w DZ_DS_StartingVRAMOffset8x8Tiles

    LDA.b #$00
    STA.w DZ_DS_Length
endif

if !PlayerGFX == !True || !PlayerPalette == !True
    LDA #$01
if !PlayerGFX == !True
    STA.w DZ_Player_GFX_Enable
    LDA #$00
    STA.w DZ_Player_CustomPlayer
    LDA #$FF
    STA.w DZ_Player_LastCustomPlayer
endif
if !PlayerPalette == !True
    STA.w DZ_Player_Palette_Enable
    LDA #$00
    STA.w DZ_Player_Palette_BNK
endif
endif
    PLB
RTS

DZBaseHijack1:
    JSL DynamicZ
	PHK
	PEA.w .jslrtsreturn-1
	PEA.w $0084CE|!rom ; varies per bank, must point to RTL-1 in the same bank as the JML target (example: $0084CF-1)
	JML $0085D2|!rom
.jslrtsreturn
	PHK
	PEA.w .jslrtsreturn2-1
	PEA.w $0084CE|!rom ; varies per bank, must point to RTL-1 in the same bank as the JML target (example: $0084CF-1)
	JML $008449|!rom
.jslrtsreturn2
	JML $008243|!rom

DZBaseHijack2:
	JSL DynamicZ
	BIT.w $0D9B|!addr
	BVS +
	JML $0082E8|!rom
+	
	JML $0082DF|!rom

DZSpriteCleaner:
    INC $13
	PHK
	PEA.w .jslrtsreturn-1
	PEA.w $0084CE|!rom ; varies per bank, must point to RTL-1 in the same bank as the JML target (example: $0084CF-1)
	JML $009322|!rom
.jslrtsreturn
    JSL !ClearSlot
    JML $008075|!rom

if !DynamicSpriteSupport
incsrc "Library/DynamicSpriteRoutines.asm"
endif
if !SemiDynamicSpriteSupport == !True
incsrc "Library/SemiDynamicSpriteRoutines.asm"
endif
if !PaletteFeatures == !True
incsrc "Library/PalettesRoutines.asm"
endif
if !GFXFeatures == !True
incsrc "Features/GraphicsAndTilemapChange.asm"
endif
if !PaletteFeatures == !True
incsrc "Features/ColorPaletteChange.asm"
endif
if !PlayerPalette == !True || !PlayerGFX == !True
incsrc "Features/MarioGFXDMAOptimization.asm"
endif
;if !OAMSystem == !True
;incsrc "Features/OAMFeatures.asm"
;endif