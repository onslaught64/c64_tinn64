.pc = $0801 "Basic Upstart"
:BasicUpstart(start) // 10 sys$0810
.pc =$1000 "Program"
start:
    ldx #$00
!loop:
    lda #160
    ldy #$00
    jsr write
    
    lda PIXEL_LUT,x
    ldy #$01
    jsr write

    lda #160
    ldy #$02
    jsr write
    
    txa
    and #$01
    ldy #$00
    jsr color
    ldy #$02
    jsr color

    jsr newline
    inx
    cpx #$10
    bne !loop-
!end:
    jmp !end-

write:
    sta offs: $0400,y
    rts

color:
    sta coffs: $d800,y
    rts

newline:
    clc
    lda offs
    adc #$28
    sta offs
    bcc !skip+
    inc offs + 1
!skip:
    clc
    lda coffs
    adc #$28
    sta coffs
    bcc !skip+
    inc coffs + 1
!skip:
    rts


PIXEL_LUT:
.byte 32  //0000 
.byte 126 //0001
.byte 124 //0010
.byte 226 //0011
.byte 123 //0100
.byte 97  //0101
.byte 255 //0110
.byte 236 //0111
.byte 108 //1000
.byte 127 //1001
.byte 225 //1010
.byte 251 //1011
.byte 98  //1100
.byte 252 //1101
.byte 254 //1110
.byte 160 //1111

