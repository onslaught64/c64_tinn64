BasicUpstart2(start)
* = $0810
start:
    sei
    jsr blanker
    lda #$20
    ldx #$00
!:
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne !-
    cli
    //relocate the loader
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

    ldx #'0'
    ldy #'1'
    lda #$10
    sta $ff
    lda #$00
    sta $fe
    jsr $cf00

    jmp $1000

wait:
!:
    lda $d011
    bmi !-
    lda $d012
!:
    cmp $d012
    beq !-
    lda #$00
!:
    cmp $d012
    bne !-
    rts



blanker:
    lda $d020
    sta border
    lda $d021
    sta screen

    ldx #$01
    ldy #$00
!loop:
    lda #$00
!:
    cmp $d012
    bne !-
!:
    lda $d011
    bmi !loop-


    lda #$00
    sta $d020
    sta $d021
    lda #$6b
    sta $d011

    cpy #$00
    bne !hiset+

!:
    cpx $d012
    bne !-
    
    lda border: #$00
    sta $d020
    lda screen: #$00
    sta $d021
    lda #$1b
    sta $d011
    clc
    txa
    adc #$04
    tax
    bcc !+
    iny
!:
    jmp !loop-
!hiset:
!:
    lda $d011
    bpl!-
!:
    cpx $d012
    bne !-
    lda #$1b
    sta $d011
    inx
    cpx #$10
    beq !+
    jmp !loop-
!:
    rts






* = $1000
.import c64 "tinn-fe/rsrc/realloader.prg"
