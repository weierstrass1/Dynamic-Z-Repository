!True = 1
!False = 0

!GFXFeatures = !True
!DynamicSpriteSupport = !True
!SharedDynamicSpriteSupport = !True
!SemiDynamicSpriteSupport = !True
!TwoPhaseDynamicSpriteSupport = !False
!BlockChange = !False
!PlayerGFX = !True
!Mode50 = !False
!PaletteFeatures = !True
!HSVSystem = !True
!RGBSystem = !False
!PlayerPalette = !True
!OAMSystem = !False
!Widescreen = !False


if !GFXFeatures == !False
!DynamicSpriteSupport = !False
!SharedDynamicSpriteSupport = !False
!SemiDynamicSpriteSupport = !False
!TwoPhaseDynamicSpriteSupport = !False
!PlayerGFX  = !False
endif

if !DynamicSpriteSupport == !False
!SharedDynamicSpriteSupport = !False
endif

if !PaletteFeatures == !False
!HSVSystem = !False
!RGBSystem = !False
!PlayerPalette = !False
endif