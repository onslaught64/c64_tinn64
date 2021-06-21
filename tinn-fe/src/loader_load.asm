/*
example usage - loading multiple parts
seems like the y register is preserved between calls to load
ce80   20 00 cc   jsr $cc00
ce83   a2 46      ldx #$46
ce85   a0 30      ldy #$30
ce87   20 00 cf   jsr $cf00
ce8a   c8         iny
ce8b   c0 34      cpy #$34
ce8d   d0 f8      bne $ce87
ce8f   a9 40      lda #$40
ce91   8d f9 ff   sta $fff9
ce94   a9 f9      lda #$f9
ce96   8d fa ff   sta $fffa
ce99   a9 ff      lda #$ff
ce9b   8d fb ff   sta $fffb
ce9e   4c 42 41   jmp $4142

*/
load:
    lda $dd00
    and #$0f
    sta l_cfce + 1
    eor #$10
    sta l_cfbf + 1
    eor #$30
    sta l_cf6a + 1
    eor #$b0
    sta l_cf95 + 1
    eor #$50
    sta l_cfa4 + 1
    sta l_cfe8 + 1
    lda #$02
    jsr l_cf63
    jsr l_cfdc
    jsr l_cf83
    bit $fe
    jsr l_cf83
    bit $ff
    ldy #$00
l_cf33:
    jsr l_cf83
    cmp #$ac
    bne l_cf4f
    jsr l_cf83
    cmp #$ac
    beq l_cf4f
    cmp #$ff
    beq l_cf59
    cmp #$f7
    beq l_cf5a
    jsr l_cfdc
    jmp l_cf33
l_cf4f:
    sta ($fe),y
    iny
    bne l_cf56
    inc $ff
l_cf56:
    jmp l_cf33
l_cf59:
    clc
l_cf5a:
    ldx l_cff9
    ldy l_cffa
    lda #$00
    rts
l_cf63:
    pha
    stx l_cff9
    sty l_cffa
l_cf6a:
    lda #$27
    sta $dd00
    jsr l_cfdc
    pla
    jsr l_cfb0
    lda l_cff9
    jsr l_cfb0
    lda l_cffa
    jsr l_cfb0
    rts
l_cf83:
    jsr l_cf95
    jsr l_cf95
    jsr l_cf95
    jsr l_cf95
    jsr l_cf94
    lda $fd
l_cf94:
    rts
l_cf95:
    ldx #$97
    lda $dd00
    stx $dd00
    asl
    ror $fd
    pha
    pla
    pha
    pla
l_cfa4:
    ldx #$c7
    lda $dd00
    stx $dd00
    asl
    ror $fd
    rts
l_cfb0:
    sta $fd
    jsr l_cfbf
    jsr l_cfbf
    jsr l_cfbf
    jsr l_cfbf
    rts
l_cfbf:
    lda #$17
    lsr $fd
    bcc l_cfc7
    ora #$20
l_cfc7:
    sta $dd00
    nop
    nop
    nop
    nop
l_cfce:
    lda #$07
    lsr $fd
    bcc l_cfd6
    ora #$20
l_cfd6:
    sta $dd00
    nop
    nop
    rts
l_cfdc:
    ldx #$32
l_cfde:
    dex
    bne l_cfde
l_cfe1:
    lda $dd00
    and #$40
    beq l_cfe1
l_cfe8:
    lda #$c7
    sta $dd00
    lda #$fe
    sta l_cffb
    ldx #$05
l_cff4:
    dex
    bne l_cff4
    rts

/*
cff8   05 2d      ora $2d
cffa   30 fe      bmi $cffa
cffc   31 30      and ($30),y
cffe   fe 00 00   inc $0000,x
*/
l_cff8: .byte $05
l_cff9: .byte $2d
l_cffa: .byte $30
l_cffb: .byte $fe
l_cffc: .byte $31
l_cffd: .byte $30
l_cffe: .byte $fe
l_cfff: .byte $00
