if !PlayerGFX == !False && !PlayerPalette == !False
org $00F636|!rom
	REP #$20                  ; Accum (16 bit) 
	LDX.B #$00                
	LDA $09
else
org $00F636|!rom
	autoclean JML PlayerDynamicRoutine
	RTS
	NOP
endif

if !PlayerGFX == !True

org $01E19D|!rom
	autoclean JML PodooboDMA
	NOP

org $01EEAA|!rom
	autoclean JML YoshiDMA

org $02EA34|!rom
	autoclean JML IDKDMA

org $00A300|!rom
	RTS
	NOP
else

org $01E19D|!rom
	REP #$20                  ; Accum (16 bit) 
	LDA.W #$0008 

org $01EEAA|!rom
	REP #$20                  ; Accum (16 bit) 
	LDA $00      

org $02EA34|!rom
	REP #$20                  ; Accum (16 bit) 
	LDA $00  

org $00A300|!rom
	REP #$20                  ; 16 bit A ; Accum (16 bit) 
	
endif