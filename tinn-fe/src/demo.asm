.import source "lib.asm"
.import source "const.asm"
.import source "easingLib.asm"

.label raster_line_1 = $00

BasicUpstart2(start)
* = $0810
start:
    lda #$01
    sta lo
    sta hi
    sta lob
    sta hib

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

	:setupInterrupt(irq1, raster_line_1) // last six chars (with a few raster lines to stabalize raster)

!:
    lda stop
    beq !-

    lda #$00
    sta $d020
    sta $d021

    lda #$20
    ldx #$00
!:
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne !-

    lda #$01
    sta hib
    sta lob

    ldx #'0'
    ldy #'1'
    lda #$10
    sta $ff
    lda #$00
    sta $fe
    jsr $cf00

    jmp $1000


bg:
    .byte $00
fg: 
    .byte $00

irq1:
	:startInterrupt()
	:doubleIRQ(raster_line_1)

    lda $d020 
    sta bg
    lda $d021
    sta fg
    ldx #$07
!:
    dex
    bne !-
    nop

    lda #$00
    sta $d020
    sta $d021
    lda #%01111011
    sta $d011

//insert delay
!:
    bit $ea
    nop
    dec lo
    bne !-
    dec hi
    bne !-

    lda $d012
!:
    cmp $d012
    beq !-
    ldx #$08
!:
    dex
    bne !-
    nop
    nop
    lda #%00011011
    sta $d011
    lda bg
    sta $d020
    lda fg
    sta $d021

    lda stop
    bne !+
    clc
    lda lob
    adc #$0c
    sta lob
    lda hib
    adc #$00
    sta hib
    cmp #$06
    bne !+
    inc stop
    //set flag to stop
!:
    lda lob
    sta lo
    lda hib
    sta hi

    :mov #$ff: $d019
    :mov #<irq1: $fffe
    :mov #>irq1: $ffff
	:mov #raster_line_1:$d012
	:endInterrupt()

* = $1000
.import c64 "tinn-fe/rsrc/realloader.prg"

lo:
.byte $00
hi:
.byte $00
lob:
.byte $00
hib:
.byte $00
stop:
.byte $00
