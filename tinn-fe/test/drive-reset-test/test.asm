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


    jsr $c90 //load a demo part
lda #$04
sta $d020


    sei
    lda #$37
    sta $01
    cli 

    jsr proper_error_status
lda #$05
sta $d020

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

/*
This version seems to not work (locks up)
*/

cmd:
.text "I"

proper_error_status:
    clc
    lda #$01      // no filename
    ldx #<cmd
    ldy #>cmd
    jsr $FFBD     // call SETNAM
    lda #$0F      // file number 15
    ldx #$08      // default to device 8
    ldy #$0F      // secondary address 15 (error channel)
    jsr $FFBA     // call SETLFS
    jsr $FFC0     // call OPEN
    //bcs !error+    // if carry set, the file could not be opened

    ldx #$0F      // filenumber 15
    jsr $FFC3     

// !loop:
//     jsr $FFB7     // call READST (read status byte)
//     bne !eof+     // either EOF or read error
//     jsr $FFCF     // call CHRIN (get a byte from file)
//     jsr $FFD2     // call CHROUT (print byte to screen)
//     jmp !loop-    // next byte

// !eof:
!close:
    lda #$0F      // filenumber 15
    jsr $FFC3     // call CLOSE

    jsr $FFCC     // call CLRCHN
    rts

!error:
    // Akkumulator contains BASIC error code
    // most likely error:
    // A = $05 (DEVICE NOT PRESENT)
    sta $0400 //put error at top left char
    jmp !close-    // even if OPEN failed, the file has to be closed