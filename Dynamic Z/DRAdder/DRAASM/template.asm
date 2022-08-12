!NumberOfSprites = ${val}

if read1($00FFD5) == $23
    sa1rom
endif

org (read1($0082DA+4)<<16+read2($00823D+4))+$0C
    dl SpriteNumberToGraphics

freedata cleaned

print "dl $FFFFFF insertado: $", pc
    dl $FFFFFF
SpriteNumberToGraphics:
    !i = 0
    while !i < !NumberOfSprites
        dl Resource!i
        !i #= !i+1
    endif
    dl $FFFFFF