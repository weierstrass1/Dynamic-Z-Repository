
macro CheckAndSendDMA(addr, vram, bnk, size)
    CMP <addr>|!addr
    BEQ ?+
    STA <addr>|!addr
    PHA
    SEP #$20
    %ForcedTransferToVRAM(<vram>, "<addr>|!addr", <bnk>, <size>)
    REP #$20
    PLA
?+       
endmacro

PlayerDynamicRoutine:
if !PlayerGFX == !True
    LDA.l DZ_Player_GFX_Enable
    BNE +
    JMP .pal
+
    REP #$20                  ; Accum (16 bit) 
    LDX.B #$00
    LDA $09
    ORA.W #$0800
    CMP $09
    BEQ +           
    CLC                       
+
    AND.w #$F700              
    ROR                       
    LSR                       
    ADC.l DZ_Player_GFX_Addr       
    %CheckAndSendDMA($0D85, #$6000, DZ_Player_GFX_BNK, #$0040)             
    CLC                       
    ADC.W #$0200     
    %CheckAndSendDMA($0D8F, #$6100, DZ_Player_GFX_BNK, #$0040)                    
    LDX.B #$00                
    LDA $0A                   
    ORA.W #$0800              
    CMP $0A                   
    BEQ +           
    CLC                       
+
    AND.W #$F700              
    ROR                       
    LSR                       
    ADC.l DZ_Player_GFX_Addr 
    %CheckAndSendDMA($0D87, #$6020, DZ_Player_GFX_BNK, #$0040)                           
    CLC                       
    ADC.W #$0200       
    %CheckAndSendDMA($0D91, #$6120, DZ_Player_GFX_BNK, #$0040)                     
    LDA $0B                   
    AND.W #$FF00              
    LSR                       
    LSR                       
    LSR                       
    ADC.l DZ_Player_GFX_Addr       
    %CheckAndSendDMA($0D89, #$6040, DZ_Player_GFX_BNK, #$0040)                     
    CLC                       
    ADC.W #$0200  
    %CheckAndSendDMA($0D93, #$6140, DZ_Player_GFX_BNK, #$0040)                       
    LDA $0C                   
    AND.W #$FF00              
    LSR                       
    LSR                       
    LSR                       
    ADC.l DZ_Player_GFX_Addr     
    %CheckAndSendDMA($0D99, #$67F0, DZ_Player_GFX_BNK, #$0020)               
    SEP #$20     
else
    REP #$20                  ; Accum (16 bit) 
    LDX.B #$00                
    LDA $09                   
    ORA.W #$0800              
    CMP $09                   
    BEQ +           
    CLC 
+                      
    AND.W #$F700              
    ROR                       
    LSR                       
    ADC.W #$2000              
    STA.W $0D85               
    CLC                       
    ADC.W #$0200              
    STA.W $0D8F               
    LDX.B #$00                
    LDA $0A                   
    ORA.W #$0800              
    CMP $0A                   
    BEQ +           
    CLC  
+                     
    AND.W #$F700              
    ROR                       
    LSR                       
    ADC.W #$2000              
    STA.W $0D87               
    CLC                       
    ADC.W #$0200              
    STA.W $0D91               
    LDA $0B                   
    AND.W #$FF00              
    LSR                       
    LSR                       
    LSR                       
    ADC.W #$2000              
    STA.W $0D89               
    CLC                       
    ADC.W #$0200              
    STA.W $0D93               
    LDA $0C                   
    AND.W #$FF00              
    LSR                       
    LSR                       
    LSR                       
    ADC.W #$2000              
    STA.W $0D99    
    SEP #$20  
endif
.pal

if !PlayerPalette == !True
    LDA.l DZ_Player_Palette_Enable
    BEQ ++
    REP #$20
    LDA.l DZ_Player_Palette_BNK
    AND #$00FF
    BNE +
    LDA $0D82|!addr
    STA.l DZ_Player_Palette_Addr
+
    LDA.l DZ_Player_Palette_Addr
    CMP.l DZ_PPUMirrors_CGRAM_LastPlayerPal
    BEQ +
    STA.l DZ_PPUMirrors_CGRAM_LastPlayerPal
    SEP #$20
    %ForcedTransferToCGRAM(#$86, DZ_Player_Palette_Addr, DZ_Player_Palette_BNK, #$0014)
+
    SEP #$20
++  
endif
                ; Accum (8 bit) 

    LDA.B #$0A                
    STA.W $0D84               

JML $00F69E|!rom

PodooboDMA:
    REP #$20                  ; Accum (16 bit) 
    LDA.W #$0008              
    ASL                       
    ASL                       
    ASL                       
    ASL                       
    ASL                       
    CLC                       
    ADC.W #$8500              
    %CheckAndSendDMA($0D8B, #$6060, #$007E, #$0040)               
    CLC                       
    ADC.W #$0200   
    %CheckAndSendDMA($0D95, #$6160, #$007E, #$0040)                          
    SEP #$20                  ; Accum (8 bit) 
JML $01E1B7|!rom

YoshiDMA:
    REP #$20                  ; Accum (16 bit) 
    LDA $00                   
    ASL                       
    ASL                       
    ASL                       
    ASL                       
    ASL                       
    CLC                       
    ADC.W #$8500              
    %CheckAndSendDMA($0D8B, #$6060, #$007E, #$0040)              
    CLC                       
    ADC.W #$0200              
    %CheckAndSendDMA($0D95, #$6160, #$007E, #$0040)               
    LDA $02                   
    ASL                       
    ASL                       
    ASL                       
    ASL                       
    ASL                       
    CLC                       
    ADC.W #$8500              
    %CheckAndSendDMA($0D8D, #$6080, #$007E, #$0040)                 
    CLC                       
    ADC.W #$0200              
    %CheckAndSendDMA($0D97, #$6180, #$007E, #$0040)                  
    SEP #$20                  ; Accum (8 bit) 
JML $01EED8|!rom

IDKDMA:
    REP #$20                  ; Accum (16 bit) 
    LDA $00                   
    ASL                       
    ASL                       
    ASL                       
    ASL                       
    ASL                       
    CLC                       
    ADC.W #$8500              
    %CheckAndSendDMA($0D8B, #$6060, #$007E, #$0040)               
    CLC                       
    ADC.W #$0200              
    %CheckAndSendDMA($0D95, #$6160, #$007E, #$0040)                
    SEP #$20                  ; Accum (8 bit) 
JML $02EA4D|!rom