if !OAMSystem == !True
org $008055|!rom
    autoclean JML StartOAM
    NOP
    NOP

org $008494|!rom
    autoclean JML MoveOAM200
    NOP
else
org $008055|!rom
    STZ $0100                 ; Clear the game mode
    STZ $0109 

org $008494|!rom
    LDY.B #$1E
    LDX.W $8475,y
endif
