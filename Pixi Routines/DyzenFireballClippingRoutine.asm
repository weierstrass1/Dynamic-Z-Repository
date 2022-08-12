?DyzenFireballClippingRoutine:

    PHK                       ;\This will push the 24-bit address location
	PEA.w ?.ret-1     ;/after the JML (below) into the stack*
	PEA.w $A772-1               ;>This modifies the RTS in the pointed routine (below) to jump to an RTL in same bank.*
                                  ;^This RTL then pulls the stack (which is the 24-bit address) to jump to a location after the JML
	JML $02A547|!rom               ;>The desired routine that ends with RTS

?.ret
    %DyzenFixClippingForInteraction()

RTL