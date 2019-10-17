BasicUpstart2(start)
* = $0810
start:
    lda #$04
    sta $d020
    sta $d021
    ldx #$00
!loop:
    lda $1000,x
    sta $cc00,x
    lda $1100,x
    sta $cd00,x
    lda $1200,x
    sta $ce00,x
    lda $1300,x
    sta $cf00,x
    inx
    bne !loop-

    jsr $cc00 //init loader

    sei
    lda #$7f
    sta $dc0d
    cli

    lda #$05
    sta $d020
    sta $d021

    ldx #'0'
    ldy #'1'
    lda #$10
    sta $ff
    lda #$00
    sta $fe
    jsr $cf00

    lda #$00
    sta $d020
    sta $d021

    jmp $1000

* = $1000
.import c64 "tinn-fe/rsrc/realloader.prg"
