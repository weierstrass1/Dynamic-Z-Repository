    PHB
    PHK
    PLB
    PHY                    
    LDA $1697|!addr              
    CLC                      
    ADC !SpriteMiscTable13,x            
    INC $1697|!addr                
    TAY                      
    INY                      
    CPY.B #$08                
    BCS ?+          
    LDA ?Return01A61D,y      
    STA $1DF9|!addr               ; / Play sound effect
?+
    TYA                      
    CMP #$08                
    BCC ?+
    LDA #$08
?+
    JSL $02ACE5|!rom      
    PLY                     
    PLB 
RTL                       ; Return
 
?Return01A61D:
RTS                       ; Return
 
 
?DATA_01A61E:
    db $13,$14,$15,$16,$17,$18,$19 