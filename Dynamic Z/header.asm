;dont touch this
	!dp = $0000
	!addr = $0000
    !rom = $800000
	!sa1 = 0
    !Variables = $7F9C7B 
    !Variables2 = !Variables+$0800
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

    !ClusterSpriteNumber = $1892|!addr
    !ExtendedSpriteNumber = $170B|!addr
    !OWSpriteNumber = $0DE5|!addr
    
;DS = Dynamic Sprite
;GDS = Giant Dynamic Sprite
;SDS = Semi-Dynamic Sprite

;#################################################<-----------------
;#################################################<-----------------
;############# Editable Constants ################<-----------------
;#################################################<-----------------
;#################################################<-----------------

;Constants for level
!DefaultLevelDSVRAMOFfset = $7800       ;6000 = SP3, 6400 = Second half SP1
                                        ;6800 = SP2, 6C00 = Second half SP2
                                        ;7000 = SP3, 7400 = Second half SP3
                                        ;7800 = SP4, 7C00 = Second half SP4
                                        ;Recommended 7000, 7400 or 7800 without 50% more mode or without scanlines sacrifice
                                        ;Recommended 7000 or 7400 with 50% more mode or with scanline sacrifice
!DefaultLevelDSVRAMOffsetIn8x8Tiles #= ((!DefaultLevelDSVRAMOFfset-$6000)/$10)&$FF
!DefaultLevelDSMaxSpaceIn16x16Tiles = $20   ;number of 16x16 tiles that can use by default
!DefaultLevelMaxDataTransferPerFrameIn16x16Tiles = $10  ;number of 16x16 tiles that can transfer per frame by default
                                                        ;Recommended $10 without 50% more mode or without scanlines sacrifice
                                                        ;Recommended $18 with 50% more mode
                                                        ;With scanlines sacrifice, must calculate number based on how many scanlines
                                                        ;In this case i recommend:
                                                        ;3 on the top, 4 on the bottom, No 50% more mode = $18, With 50% more mode = $20
                                                        ;6 on the top, 7 on the bottom, No 50% more mode = $20, With 50% more mode = $28
                                                        ;9 on the top, 10 on the bottom, No 50% more mode = $28, With 50% more mode = $30
                                                        ;12 on the top, 13 on the bottom, No 50% more mode = $30
                                                        ;etc... Basically 50% more mode is a +8 and 3n lines on the top and 3n+1 on the bottom is a +8n
!DefaultLevelMaxDataTransferPerFrame = $0800
!DefaultLevelFindMethod = $01
;Constants for Overworld
!DefaultOWDSVRAMOFfset = $6800 
!DefaultOWDSVRAMOffsetIn8x8Tiles #= ((!DefaultOWDSVRAMOFfset-$6000)/$10)&$FF
!DefaultOWDSMaxSpace = $20
!DefaultOWMaxDataTransferPerFrameIn16x16Tiles = $10    
!DefaultOWMaxDataTransferPerFrame = $0800
!DefaultOWFindMethod = $01     

;#################################################<-----------------
;#################################################<-----------------
;################# Free Rams #####################<-----------------
;#################################################<-----------------
;#################################################<-----------------

;#################################################
;############# Dynamic Sprite Support ############
;#################################################

namespace nested on

base !Variables

namespace DZ
    Timer: skip 1                               ;$7F0B44
    MaxDataPerFrameIn16x16Tiles: skip 1         ;$7F0B45
    MaxDataPerFrame: skip 2                     ;$7F0B46
    CurrentDataSend: skip 2

if !GFXFeatures == !True && !DynamicSpriteSupport == !True
    namespace DS
        Length: skip 1                          ;$7F0B48
        LastSlot: skip 1                        ;$7F0B49
        FirstSlot: skip 1                       ;$7F0B4A
        MaxSpace: skip 1                        ;$7F0B4B
        FindSpaceMethod: skip 1                 ;$7F0B4C
        StartingVRAMOffset: skip 2              ;$7F0B4D
        StartingVRAMOffset8x8Tiles: skip 1      ;$7F0B4F
        TotalSpaceUsed: skip 1                  ;$7F0B50
        TotalSpaceUsedOdd: skip 1               ;$7F0B51
        TotalSpaceUsedEven: skip 1              ;$7F0B52
        TotalDataSentOdd: skip 1                ;$7F0B53
        TotalDataSentEven: skip 1               ;$7F0B54

        namespace Loc
            UsedBy: skip 48                     ;$7F0B57
            SpriteNumber: skip 48               ;$7F0B86
            SpaceUsedOffset: skip 48            ;$7F0BE7
            SpaceUsed: skip 48                  ;$7F0C17
            IsValid: skip 48                    ;$7F0C47
            FrameRateMethod: skip 48            ;$7F0C77
            NextSlot: skip 48                   ;$7F0CA7
            PreviewSlot: skip 48                ;$7F0CD7
            SafeFrame: skip 48
    if !SharedDynamicSpriteSupport == !True
            SharedFrame: skip 48                ;$7F0D07
            SharedUpdated: skip 48              ;$7F0BB7
            SharedProperty1: skip 48
            SharedProperty2: skip 48
    endif                      
            namespace US                     
                Normal: skip !MaxSprites        ;$7F0D37
                Cluster: skip 20                ;$7F0D43
                Extended: skip 10               ;$7F0D57
                OW: skip 16                     ;$7F0D61
            namespace off
            namespace SharedPropertyPerSprite1                     
                Normal: skip !MaxSprites        ;$7F0D37
                Cluster: skip 20                ;$7F0D43
                Extended: skip 10               ;$7F0D57
                OW: skip 16                     ;$7F0D61
            namespace off
            namespace SharedPropertyPerSprite2                     
                Normal: skip !MaxSprites        ;$7F0D37
                Cluster: skip 20                ;$7F0D43
                Extended: skip 10               ;$7F0D57
                OW: skip 16                     ;$7F0D61
            namespace off
        namespace off
    namespace off
endif
if !SemiDynamicSpriteSupport == !True
    namespace SDS
        namespace Offset
            Normal: skip !MaxSprites        ;$7F0D37
            Cluster: skip 20                ;$7F0D43
            Extended: skip 10               ;$7F0D57
            OW: skip 16                     ;$7F0D61
        namespace off
        namespace PaletteAndPage
            Normal: skip !MaxSprites        ;$7F0D37
            Cluster: skip 20                ;$7F0D43
            Extended: skip 10               ;$7F0D57
            OW: skip 16                     ;$7F0D61
        namespace off
        namespace Size
            Normal: skip !MaxSprites        ;$7F0D37
            Cluster: skip 20                ;$7F0D43
            Extended: skip 10               ;$7F0D57
            OW: skip 16                     ;$7F0D61
        namespace off
        namespace Valid
            Normal: skip !MaxSprites        ;$7F0D37
            Cluster: skip 20                ;$7F0D43
            Extended: skip 10               ;$7F0D57
            OW: skip 16                     ;$7F0D61
        namespace off
        namespace SendOffset
            Normal: skip !MaxSprites        ;$7F0D37
            Cluster: skip 20                ;$7F0D43
            Extended: skip 10               ;$7F0D57
            OW: skip 16                     ;$7F0D61
        namespace off
        namespace SpriteNumber
            Normal: skip !MaxSprites        ;$7F0D37
            Cluster: skip 20                ;$7F0D43
            Extended: skip 10               ;$7F0D57
            OW: skip 16                     ;$7F0D61
        namespace off
        namespace PaletteLoaded
            Normal: skip !MaxSprites        ;$7F0D37
            Cluster: skip 20                ;$7F0D43
            Extended: skip 10               ;$7F0D57
            OW: skip 16                     ;$7F0D61
        namespace off
    namespace off
endif
if !PlayerGFX == !True || !PlayerPalette == !True
    namespace Player
if !PlayerGFX == !True
        CustomPlayer: skip 1
        LastCustomPlayer: skip 1
        namespace GFX
            Enable: skip 1
            Addr: skip 2
            BNK: skip 2
        namespace off
endif
if !PlayerPalette == !True
        namespace Palette
            Enable: skip 1
            Addr: skip 2
            BNK: skip 1
        namespace off
endif
    namespace off
endif
    FreeRams:
    org !Variables2
    namespace PPUMirrors                          ;$7FB080
if !PaletteFeatures == !True
        namespace CGRAM
            namespace Transfer
                Length: skip 1                      ;$7FB080
                SourceLength: skip 128              ;$7FB080
                Offset: skip 64                     ;$7FB080
                Source: skip 128                    ;$7FB080
                SourceBNK: skip 128                 ;$7FB080
            namespace off
    if !PlayerPalette == !True
            LastPlayerPal: skip 2  
    endif
    if !HSVSystem == !True || !RGBSystem == !True
            namespace BufferTransfer
                Length: skip 1                      ;$7FB080
                SourceLength: skip 64               ;$7FB080
                Offset: skip 64                     ;$7FB080
                Destination: skip 128               ;$7FB080
                DestinationBNK: skip 128            ;$7FB080
            namespace off
            PaletteCopy: skip 512
            BasePalette: skip 768                   ;$7FB080
            PaletteWriteMirror: skip 512            ;$7FB080
    endif
        namespace off
endif
if !Widescreen == !True && !sa1
        namespace WS
            Enable: skip 1                          ;$7FB080
            Buffer: skip 435                        ;$7FB080
        namespace off
endif
if !GFXFeatures == !True
        namespace VRAM
            namespace Transfer
                Length: skip 1                      ;$7FB080 
                SourceLength: skip 256              ;$7FB080
                Offset: skip 256                    ;$7FB080
                Source: skip 256                    ;$7FB080
                SourceBNK: skip 256                 ;$7FB080
            namespace off
        namespace off
endif
if !OAMSystem == !True
        namespace OAM
            Length: skip 1
            LastLength: skip 1
            LengthByPriority: skip 64
            XOffset: skip 128
            YOffset: skip 128
            Property: skip 128
            Tile: skip 128
            Priority: skip 128
            Size: skip 128
        namespace off
endif
    namespace off
    FreeRams2:
namespace off


print "General Variables"
print "-------------------------------------------------------------------------------"
print " "
print "DZ_Timer $", hex(DZ_Timer)
print "DZ_MaxDataPerFrameIn16x16Tiles $", hex(DZ_MaxDataPerFrameIn16x16Tiles)
print "DZ_MaxDataPerFrame $", hex(DZ_MaxDataPerFrame)
print "DZ_CurrentDataSend $", hex(DZ_CurrentDataSend)
print " "
if !DynamicSpriteSupport
print "Dynamic Sprites Variables"
print "-------------------------------------------------------------------------------"
print " "
print "DZ_DS_Length $", hex(DZ_DS_Length)
print "DZ_DS_LastSlot $", hex(DZ_DS_LastSlot)
print "DZ_DS_FirstSlot $", hex(DZ_DS_FirstSlot)
print "DZ_DS_MaxSpace $", hex(DZ_DS_MaxSpace)
print "DZ_DS_FindSpaceMethod $", hex(DZ_DS_FindSpaceMethod)
print "DZ_DS_StartingVRAMOffset $", hex(DZ_DS_StartingVRAMOffset)
print "DZ_DS_StartingVRAMOffset8x8Tiles $", hex(DZ_DS_StartingVRAMOffset8x8Tiles)
print "DZ_DS_TotalSpaceUsed $", hex(DZ_DS_TotalSpaceUsed)
print "DZ_DS_TotalSpaceUsedOdd $", hex(DZ_DS_TotalSpaceUsedOdd)
print "DZ_DS_TotalSpaceUsedEven $", hex(DZ_DS_TotalSpaceUsedEven)
print "DZ_DS_TotalDataSentOdd $", hex(DZ_DS_TotalDataSentOdd)
print "DZ_DS_TotalDataSentEven $", hex(DZ_DS_TotalDataSentEven)
print " "
print "Dynamic Sprites Local Variables"
print "-------------------------------------------------------------------------------"
print " "
print "DZ_DS_Loc_UsedBy $", hex(DZ_DS_Loc_UsedBy)
print "DZ_DS_Loc_SpriteNumber $", hex(DZ_DS_Loc_SpriteNumber)
print "DZ_DS_Loc_SpaceUsedOffset $", hex(DZ_DS_Loc_SpaceUsedOffset)
print "DZ_DS_Loc_SpaceUsed $", hex(DZ_DS_Loc_SpaceUsed)
print "DZ_DS_Loc_IsValid $", hex(DZ_DS_Loc_IsValid)
print "DZ_DS_Loc_FrameRateMethod $", hex(DZ_DS_Loc_FrameRateMethod)
print "DZ_DS_Loc_NextSlot $", hex(DZ_DS_Loc_NextSlot)
print "DZ_DS_Loc_PreviewSlot $", hex(DZ_DS_Loc_PreviewSlot)
print "DZ_DS_Loc_SafeFrame $", hex(DZ_DS_Loc_SafeFrame)
if !SharedDynamicSpriteSupport == !True
print "DZ_DS_Loc_SharedUpdated $", hex(DZ_DS_Loc_SharedUpdated)
print "DZ_DS_Loc_SharedFrame $", hex(DZ_DS_Loc_SharedFrame)
endif
print " "
print "Dynamic Sprites Local Variables Used Slot Tables"
print "-------------------------------------------------------------------------------"
print " "
print "DZ_DS_Loc_US_Normal $", hex(DZ_DS_Loc_US_Normal)
print "DZ_DS_Loc_US_Cluster $", hex(DZ_DS_Loc_US_Cluster)
print "DZ_DS_Loc_US_Extended $", hex(DZ_DS_Loc_US_Extended)
print "DZ_DS_Loc_US_OW $", hex(DZ_DS_Loc_US_OW)
print " "
endif
if !SemiDynamicSpriteSupport == !True
print "Semi Dynamic Sprites Variables"
print "-------------------------------------------------------------------------------"
print " "
print "DZ_SDS_Offset_Normal $", hex(DZ_SDS_Offset_Normal)
print "DZ_SDS_Offset_Cluster $", hex(DZ_SDS_Offset_Cluster)
print "DZ_SDS_Offset_Extended $", hex(DZ_SDS_Offset_Extended)
print "DZ_SDS_Offset_OW $", hex(DZ_SDS_Offset_OW)
print "DZ_SDS_PaletteAndPage_Normal $", hex(DZ_SDS_PaletteAndPage_Normal)
print "DZ_SDS_PaletteAndPage_Cluster $", hex(DZ_SDS_PaletteAndPage_Cluster)
print "DZ_SDS_PaletteAndPage_Extended $", hex(DZ_SDS_PaletteAndPage_Extended)
print "DZ_SDS_PaletteAndPage_OW $", hex(DZ_SDS_PaletteAndPage_OW)
print "DZ_SDS_Size_Normal $", hex(DZ_SDS_Size_Normal)
print "DZ_SDS_Size_Cluster $", hex(DZ_SDS_Size_Cluster)
print "DZ_SDS_Size_Extended $", hex(DZ_SDS_Size_Extended)
print "DZ_SDS_Size_OW $", hex(DZ_SDS_Size_OW)
print "DZ_SDS_Valid_Normal $", hex(DZ_SDS_Valid_Normal)
print "DZ_SDS_Valid_Cluster $", hex(DZ_SDS_Valid_Cluster)
print "DZ_SDS_Valid_Extended $", hex(DZ_SDS_Valid_Extended)
print "DZ_SDS_Valid_OW $", hex(DZ_SDS_Valid_OW)
print "DZ_SDS_SendOffset_Normal $", hex(DZ_SDS_SendOffset_Normal)
print "DZ_SDS_SendOffset_Cluster $", hex(DZ_SDS_SendOffset_Cluster)
print "DZ_SDS_SendOffset_Extended $", hex(DZ_SDS_SendOffset_Extended)
print "DZ_SDS_SendOffset_OW $", hex(DZ_SDS_SendOffset_OW)
print "DZ_SDS_SpriteNumber_Normal $", hex(DZ_SDS_SpriteNumber_Normal)
print "DZ_SDS_SpriteNumber_Cluster $", hex(DZ_SDS_SpriteNumber_Cluster)
print "DZ_SDS_SpriteNumber_Extended $", hex(DZ_SDS_SpriteNumber_Extended)
print "DZ_SDS_SpriteNumber_OW $", hex(DZ_SDS_SpriteNumber_OW)
print "DZ_SDS_PaletteLoaded_Normal $", hex(DZ_SDS_PaletteLoaded_Normal)
print "DZ_SDS_PaletteLoaded_Cluster $", hex(DZ_SDS_PaletteLoaded_Cluster)
print "DZ_SDS_PaletteLoaded_Extended $", hex(DZ_SDS_PaletteLoaded_Extended)
print "DZ_SDS_PaletteLoaded_OW $", hex(DZ_SDS_PaletteLoaded_OW)
print " "
endif
print "FreeRams"
print "-------------------------------------------------------------------------------"
print " "
print "DZ_FreeRams $", hex(DZ_FreeRams)
print " "
print "PPU Mirrors"
print "-------------------------------------------------------------------------------"
print " "
if !PaletteFeatures == !True
print "CGRAM Mirrors"
print "-------------------------------------------------------------------------------"
print " "
print "CGRAM Mirrors Transfer From Buffer to CGRAM"
print "-------------------------------------------------------------------------------"
print " "
print "DZ_PPUMirrors_CGRAM_Transfer_Length $", hex(DZ_PPUMirrors_CGRAM_Transfer_Length)
print "DZ_PPUMirrors_CGRAM_Transfer_SourceLength $", hex(DZ_PPUMirrors_CGRAM_Transfer_SourceLength)
print "DZ_PPUMirrors_CGRAM_Transfer_Offset $", hex(DZ_PPUMirrors_CGRAM_Transfer_Offset)
print "DZ_PPUMirrors_CGRAM_Transfer_Source $", hex(DZ_PPUMirrors_CGRAM_Transfer_Source)
print "DZ_PPUMirrors_CGRAM_Transfer_SourceBNK $", hex(DZ_PPUMirrors_CGRAM_Transfer_SourceBNK)
print " "
if !HSVSystem == !True || !RGBSystem == !True
print "CGRAM Mirrors Transfer From CGRAM to Buffer"
print "-------------------------------------------------------------------------------"
print " "
print "DZ_PPUMirrors_CGRAM_BufferTransfer_Length $", hex(DZ_PPUMirrors_CGRAM_BufferTransfer_Length)
print "DZ_PPUMirrors_CGRAM_BufferTransfer_SourceLength $", hex(DZ_PPUMirrors_CGRAM_BufferTransfer_SourceLength)
print "DZ_PPUMirrors_CGRAM_BufferTransfer_Offset $", hex(DZ_PPUMirrors_CGRAM_BufferTransfer_Offset)
print "DZ_PPUMirrors_CGRAM_BufferTransfer_Destination $", hex(DZ_PPUMirrors_CGRAM_BufferTransfer_Destination)
print "DZ_PPUMirrors_CGRAM_BufferTransfer_DestinationBNK $", hex(DZ_PPUMirrors_CGRAM_BufferTransfer_DestinationBNK)
print " "
print "CGRAM Mirrors Read Buffer"
print "-------------------------------------------------------------------------------"
print " "
print "DZ_PPUMirrors_CGRAM_BasePalette $", hex(DZ_PPUMirrors_CGRAM_BasePalette)
print " "
print "CGRAM Mirrors Write Buffer"
print "-------------------------------------------------------------------------------"
print " "
print "DZ_PPUMirrors_CGRAM_PaletteWriteMirror $", hex(DZ_PPUMirrors_CGRAM_PaletteWriteMirror)
print " "
endif
if !PlayerPalette == !True
print "CGRAM Mirrors Last Palette used by the player"
print "-------------------------------------------------------------------------------"
print " "
print "DZ_PPUMirrors_CGRAM_LastPlayerPal $", hex(DZ_PPUMirrors_CGRAM_LastPlayerPal)
print "DZ_Player_Palette_Enable $", hex(DZ_Player_Palette_Enable)
print "DZ_Player_Palette_BNK $", hex(DZ_Player_Palette_BNK)
print "DZ_Player_Palette_Addr $", hex(DZ_Player_Palette_Addr)
print " "
endif
endif
if !Widescreen == !True && !sa1
print "WideScreen Mirrors"
print "-------------------------------------------------------------------------------"
print " "
print "DZ_PPUMirrors_WS_Enable $", hex(DZ_PPUMirrors_WS_Enable)
print "DZ_PPUMirrors_WS_Buffer $", hex(DZ_PPUMirrors_WS_Buffer)
print " "
endif
if !GFXFeatures == !True
print "VRAM Mirrors"
print "-------------------------------------------------------------------------------"
print " "
print "DZ_PPUMirrors_VRAM_Transfer_Length $", hex(DZ_PPUMirrors_VRAM_Transfer_Length)
print "DZ_PPUMirrors_VRAM_Transfer_SourceLength $", hex(DZ_PPUMirrors_VRAM_Transfer_SourceLength)
print "DZ_PPUMirrors_VRAM_Transfer_Offset $", hex(DZ_PPUMirrors_VRAM_Transfer_Offset)
print "DZ_PPUMirrors_VRAM_Transfer_Source $", hex(DZ_PPUMirrors_VRAM_Transfer_Source)
print "DZ_PPUMirrors_VRAM_Transfer_SourceBNK $", hex(DZ_PPUMirrors_VRAM_Transfer_SourceBNK)
print " "
endif
if !PlayerGFX == !True
print "GFX Player Change"
print "-------------------------------------------------------------------------------"
print " "
print "DZ_Player_CustomPlayer $", hex(DZ_Player_CustomPlayer)
print "DZ_Player_LastCustomPlayer", hex(DZ_Player_LastCustomPlayer)
print "DZ_Player_GFX_Enable $", hex(DZ_Player_GFX_Enable)
print "DZ_Player_GFX_BNK $", hex(DZ_Player_GFX_BNK)
print "DZ_Player_GFX_Addr $", hex(DZ_Player_GFX_Addr)
print " "
endif

print "You can use DZ_FreeRams = $", hex(DZ_FreeRams), " ($",hex(DZ_FreeRams),"-$",hex(!Variables+$0800-1),") as freerams. Size of Freerams: 0x0", hex(!Variables+$0800-DZ_FreeRams), "."
print " "
;#################################################
;########## Giant Dynamic Sprite Support #########
;#################################################

;#################################################
;########## Semi Dynamic Sprite Support ##########
;#################################################

;#################################################
;########### DSX Dynamic Sprite Support ##########
;#################################################

;#################################################
;############# Graphic Change Support ############
;#################################################

;#################################################
;############# Palette Change Support ############
;#################################################

;#################################################
;############### DMA Mirror Support ##############
;#################################################

;#################################################
;######## Original Player DMA Optimization #######
;#################################################

;#################################################
;##### 16x32 Player Graphic Change Support #######
;#################################################

;#################################################
;######## Player Palette Change Support ##########
;#################################################

;#################################################
;######### Fully Custom Player Support ###########
;#################################################

;#################################################
;############# 32x32 Player Patch ################
;#################################################

;#################################################
;####### Mario's 8x8 Tiles DMA-er Patch ##########
;#################################################

;#################################################
;############ 50% More Mode Support ##############
;#################################################

;#################################################<-----------------
;#################################################<-----------------
;############## Dynamic Z Library ################<-----------------
;#################################################<-----------------
;#################################################<-----------------
!Routines = ((read1($0082DA+4)<<16)+read2($00823D+4))|!rom

!ClearSlot = read3(!Routines)
!CheckSlot = read3(!Routines+$03)
!FindSpace = read3(!Routines+$06)
!DynamicRoutine = read3(!Routines+$09)

!SpriteNumberToGraphics = read3(!Routines+$0C)
!CheckEvenOrOdd = read3(!Routines+$0F)
!GetVramDisp = read3(!Routines+$12)
!GetVramDispDynamicRoutine = read3(!Routines+$15)
!RemapOamTile = read3(!Routines+$18)
!CheckNormalSharedDynamicExisted = read3(!Routines+$1B)
!CheckClusterSharedDynamicExisted = read3(!Routines+$1E)
!CheckExtendedSharedDynamicExisted = read3(!Routines+$21)
!CheckOWSharedDynamicExisted = read3(!Routines+$24)
!CheckIfLastNormalSharedProcessed = read3(!Routines+$27)
!CheckIfLastClusterSharedProcessed = read3(!Routines+$2A)
!CheckIfLastExtendedSharedProcessed = read3(!Routines+$2D)
!CheckIfLastOWSharedProcessed = read3(!Routines+$30)
!ChangePaletteHue = read3(!Routines+$33)
!ChangePaletteSaturation = read3(!Routines+$36)
!ChangePaletteValue = read3(!Routines+$39)
!ChangePaletteHueAndSaturation = read3(!Routines+$3C)
!ChangePaletteHueAndValue = read3(!Routines+$3F)
!ChangePaletteSaturationAndValue = read3(!Routines+$42)
!RandomizePalette = read3(!Routines+$45)
!MixWithColor = read3(!Routines+$48)
!MixWithBaseColor = read3(!Routines+$4B)
!SetBaseAsHSV = read3(!Routines+$4E)
!SetBaseAsRGB = read3(!Routines+$51)
!MixPaletteHue = read3(!Routines+$54)
!MixPaletteSaturation = read3(!Routines+$57)
!MixPaletteValue = read3(!Routines+$5A)
!MixPaletteHueAndSaturation = read3(!Routines+$5D)
!MixPaletteHueAndValue = read3(!Routines+$60)
!MixPaletteSaturationAndValue = read3(!Routines+$63)
!MixPaletteHueSaturationAndValue = read3(!Routines+$66)
!LoadGraphicsSDSNormal = read3(!Routines+$69)
!FindCopyNormal = read3(!Routines+$6C)
!LoadGraphicsSDSCluster = read3(!Routines+$6F)
!FindCopyCluster = read3(!Routines+$72)
!LoadGraphicsSDSExtended = read3(!Routines+$75)
!FindCopyExtended = read3(!Routines+$78)
!LoadGraphicsSDSOW = read3(!Routines+$7B)
!FindCopyOW = read3(!Routines+$7E)
!EasyNormalSpriteDynamicRoutine = read3(!Routines+$81)
!EasySpriteDynamicRoutine = read3(!Routines+$84)

incsrc "./Macros/STDCall.asm"
incsrc "./Macros/MultAndDiv.asm"
incsrc "./Macros/DynamicSpritesMacros.asm"
incsrc "./Macros/Palettes.asm"
incsrc "./Macros/PPU.asm"

