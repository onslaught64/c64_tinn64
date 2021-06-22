/*
ZP used by this code
*/
.const ZPL=$9e
.const ZPH=$9f

/*
Load drivecode into the drive
Entry point
*/
init:
    jsr i_cc52
    lda #<drivecode
    ldx #>drivecode
    sta ZPL
    stx ZPH
i_cc11:
    jsr i_cc72
    ldy #$00
i_cc16:
    lda (ZPL),y
    jsr i_cc68
    iny
    cpy #$10
    bne i_cc16

    lda #$05 //debug
    sta $d020 //debug

    lda #$0d
    jsr i_cc68
    jsr i_ccae

    lda #$06 //debug
    sta $d020 //debug

    jsr i_cc52

    lda ZPL
    clc
    adc #$10
    sta ZPL
    bcc i_cc36
    inc ZPH
i_cc36:
    cmp #<end_drivecode
    lda ZPH
    sbc #>end_drivecode
    bcc i_cc11
    jsr i_cc9a
    jsr i_ccae

    lda #$c7
    sta $dd00
    ldx #$00

    stx $d020 //debug

i_cc4b:
    dey
    bne i_cc4b
    dex
    bne i_cc4b
    rts
i_cc52:
    ldx #$08
    lda #$0f
    tay
    jsr $ffba
    lda #$00
    jsr $ffbd
    jsr $ffc0
    ldx #$0f
    jsr $ffc9
    rts
i_cc68:
    sty i_tmp
    jsr $ffd2
    ldy i_tmp
    rts
i_cc72:
    lda #$4d
    jsr i_cc68
    lda #$2d
    jsr i_cc68
    lda #$57
    jsr i_cc68
    lda ZPL
    sec
    sbc #$b7
    php
    clc
    jsr i_cc68
    plp
    lda ZPH
    sbc #$c7
    clc
    jsr i_cc68
    lda #$10
    jsr i_cc68
    rts
i_cc9a:
    ldy #$00
i_cc9c:
    lda i_cca8,y
    jsr i_cc68
    iny
    cpy #$06
    bne i_cc9c
    rts
i_cca8:
.byte $4d, $2d, $45, $00, $05, $0d
/*
cca8   4d 2d 45   eor $452d
ccab   00         brk
ccac   05 0d      ora $0d
*/
i_ccae:
    jsr $ffcc
    lda #$0f
    jsr $ffc3
    rts
i_tmp:
.byte $00


drivecode:
.pseudopc $0500 {                
jsr dc_067f
dc_0503:
    jsr dc_05c3
    lda $0e
    sta dc_06a5
    lda $0f
    sta dc_06a6
    ldy #$01
dc_0512:
    ldx #$12
    stx $0e
    sty $0f
    jsr dc_05fb
    ldy #$02
dc_051d:
    lda $0700,y
    and #$83
    cmp #$82
    bne dc_0539
    lda $0703,y
    cmp dc_06a5
    bne dc_0539
    lda $0704,y
    cmp dc_06a6
    bne dc_0539
    jmp dc_0561
dc_0539:
    tya
    clc
    adc #$20
    tay
    bcc dc_051d
    ldy $0701
    bpl dc_0512
dc_0545:
    lda #$00
    sta $1800
    ldx #$fe
    jsr dc_062f
    ldx #$fe
    jsr dc_062f
    ldx #$ac
    jsr dc_062f
    ldx #$f7
    jsr dc_062f
    jmp dc_0503
dc_0561:
    lda $0701,y
    sta $0e
    lda $0702,y
    sta $0f
dc_056b:
    jsr dc_05fb
    ldy #$00
    lda $0700
    sta $0e
    bne dc_057b
    ldy $0701
    iny
dc_057b:
    sty dc_06a5
    lda $0701
    sta $0f
    ldy #$02
    lda #$00
    sta $1800
dc_058a:
    ldx $0700,y
    cpx #$ac
    bne dc_0596
    jsr dc_062f
    ldx #$ac
dc_0596:
    jsr dc_062f
    iny
    cpy dc_06a5
    bne dc_058a
    lda $0700
    beq dc_05b6
    ldx #$ac
    jsr dc_062f
    ldx #$c3
    jsr dc_062f
    lda #$08
    sta $1800
    jmp dc_056b
dc_05b6:
    ldx #$ac
    jsr dc_062f
    ldx #$ff
    jsr dc_062f
    jmp dc_0503
dc_05c3:
    lda #$08
    sta $1800
    lda $1c00
    and #$f7
    sta $1c00
    cli
    lda #$01
dc_05d3:
    bit $1800
    beq dc_05d3
    sei
    lda #$00
    sta $1800
    jsr dc_065d
    pha
    jsr dc_065d
    sta $0e
    jsr dc_065d
    sta $0f
    lda #$08
    sta $1800
    lda $1c00
    ora #$08
    sta $1c00
    pla
    rts
dc_05fb:
    ldy #$05
    sty $8b
dc_05ff:
    cli
    lda #$80
    sta $04
dc_0604:
    lda $04
    bmi dc_0604
    cmp #$01
    beq dc_062d
    dec $8b
    ldy $8b
    bmi dc_0628
    cpy #$02
    bne dc_061a
    lda #$c0
    sta $04
dc_061a:
    lda $16
    sta $12
    lda $17
    sta $13
dc_0622:
    lda $04
    bmi dc_0622
    bpl dc_05ff
dc_0628:
    pla
    pla
    jmp dc_0545
dc_062d:
    sei
    rts
dc_062f:
    stx $14
    lda #$04
    jsr dc_063c
    jsr dc_063c
    jsr dc_063c
dc_063c:
    lsr $14
    ldx #$02
    bcc dc_0644
    ldx #$00
dc_0644:
    bit $1800
    bne dc_0644
    stx $1800
    lsr $14
    ldx #$02
    bcc dc_0654
    ldx #$00
dc_0654:
    bit $1800
    beq dc_0654
    stx $1800
    rts
dc_065d:
    ldy #$04
dc_065f:
    lda #$04
dc_0661:
    bit $1800
    beq dc_0661
    lda $1800
    lsr
    ror $14
    lda #$04
dc_066e:
    bit $1800
    bne dc_066e
    lda $1800
    lsr
    ror $14
    dey
    bne dc_065f
    lda $14
    rts
dc_067f:
    sei
    cld
    ldy #$08
dc_0683:
    lda #$10
    sta $1800
dc_0688:
    dex
    bne dc_0688
    lda #$00
    sta $1800
dc_0690:
    dex
    bne dc_0690
    dey
    bne dc_0683
dc_0696:
    lda $1800
    and #$05
    bne dc_0696
    lda $1800
    and #$05
    bne dc_0696
    rts
dc_06a5:   .byte $00
dc_06a6:   .byte $00
dc_06a7:   .byte $00
}
end_drivecode:
.byte $00
/*
ce5e   00         brk
*/

