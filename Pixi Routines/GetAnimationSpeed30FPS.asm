
;A = Animation Pixels Per Frame
?GetAnimationSpeed30FPS:
    LSR
    %GetAnimationSpeed()

    BIT #$01
    BEQ ?+
    INC A
?+
RTL