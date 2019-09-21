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

    jsr error_status
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

error_status:
    lda #$08
    sta $ba
    lda #$00
    sta $90       // clear STATUS flags
    lda $BA       // device number
    jsr $FFB1     // call LISTEN
    lda #$0F      // secondary address 15 (command channel)
    jsr $FF93     // call SECLSN (SECOND)
    jsr $FFAE     // call UNLSN
    lda $90       // get STATUS flags
    bne devnp    // device not present

    lda $BA       // device number
    jsr $FFB4     // call TALK
    lda #$0F      // secondary address 15 (error channel)
    jsr $FF96     // call SECTLK (TKSA)
loop:  
    lda $90       // get STATUS flags
    bne eof      // either EOF or error
    jsr $FFA5     // call IECIN (get byte from IEC bus)
    jsr $FFD2     // call CHROUT (print byte to screen)
    jmp loop     // next byte
eof:
    jsr $FFAB     // call UNTLK
    lda #$01
    sta $d020
    rts
devnp:
    //... device not present handling ...
    lda #$02
    sta $d020
    sta $d021
    rts

 LDA #$00      ; no filename
        LDX #$00
        LDY #$00
        JSR $FFBD     ; call SETNAM

        LDA #$0F      ; file number 15
        LDX $BA       ; last used device number
        BNE .skip
        LDX #$08      ; default to device 8
.skip   LDY #$0F      ; secondary address 15 (error channel)
        JSR $FFBA     ; call SETLFS

        JSR $FFC0     ; call OPEN
        BCS .error    ; if carry set, the file could not be opened

        LDX #$0F      ; filenumber 15
        JSR $FFC6     ; call CHKIN (file 15 now used as input)

.loop   JSR $FFB7     ; call READST (read status byte)
        BNE .eof      ; either EOF or read error
        JSR $FFCF     ; call CHRIN (get a byte from file)
        JSR $FFD2     ; call CHROUT (print byte to screen)
        JMP .loop     ; next byte

.eof
.close
        LDA #$0F      ; filenumber 15
        JSR $FFC3     ; call CLOSE

        JSR $FFCC     ; call CLRCHN
        RTS
.error
        ; Akkumulator contains BASIC error code

        ; most likely error:
        ; A = $05 (DEVICE NOT PRESENT)

        ... error handling for open errors ...
        JMP .close    ; even if OPEN failed, the file has to be closed