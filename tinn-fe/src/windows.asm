.importonce
/*
FUNCTIONS IN THIS LIBRARY:
funcDrawWindow

*/

/*
Struct for drawing anything using the window library.
Populate this before calling as follows:

'funcDrawWindow'
win_width:
win_height:
win_x:
win_y:
win_color:
win_text:

'funcDrawButton'
win_x:
win_y:
win_color:
win_text:

*/

win_width:
    .byte $00
win_height:
    .byte $00
win_x:
    .byte $00
win_y:
    .byte $00
win_color:
    .byte $00
win_text:
    .word $0000


funcDrawButton:
    lda win_text
    sta funcReadChar + 1
    lda win_text + 1
    sta funcReadChar + 2
    jsr funcSetRow //set y
    ldx win_x
    lda #$20 //space
    jsr funcDrawButtonRow
!loop:
    inx
    jsr funcReadChar
    beq !end+
    jsr funcDrawButtonRow
    jmp !loop-
!end:
    lda #$20 //space
    jsr funcDrawButtonRow
    rts

funcDrawButtonRow:
    sta win_tempChar
    txa
    tay
    clc
    adc #$28
    tax
    lda win_tempChar: #$00
    clc
    adc #$80 //invert the char
    jsr funcDrawChar
    tya
    adc #($28 + $28)
    tax
    lda #($20 + $80)
    jsr funcDrawChar
    tya
    tax
    lda #($20 + $80)
    jsr funcDrawChar
    rts


//temp data for window draw
win_endx:
    .byte $00
win_endx_inner:
    .byte $00

funcDrawWindow:
    //init 
    lda win_text
    sta funcReadChar + 1
    lda win_text + 1
    sta funcReadChar + 2
    clc
    lda win_width
    adc win_x
    sta win_endx
    dex
    dex
    sta win_endx_inner
    ldy #$00
    jsr funcSetRow //set y

    //top row of the window
    ldx win_x //set x
    lda #win_top_left
    jsr funcDrawChar
    inx
!:
    lda #win_top
    jsr funcDrawChar
    inx
    cpx win_endx_inner
    bne !-
    lda #win_top_right
    jsr funcDrawChar
    //rows of the window (loop)
!loop:
    jsr funcAddRow
    lda #$00
    sta win_skip_text //reset the flag to skip dialog text every new line
    ldx win_x //set x
    lda #win_left
    jsr funcDrawChar
    inx
!:
    lda win_skip_text: #$00
    bne !skipText+
    jsr funcReadChar
    cmp #$00
    bne !dontSkipText+
    inc win_skip_text
    jmp !skipText+
!dontSkipText:
    clc
    adc #$80 //invert the char
    jmp !continue+
!skipText:
    lda #win_background
!continue:
    jsr funcDrawChar
    inx
    cpx win_endx_inner
    bne !-
    lda #win_right
    jsr funcDrawChar
    iny
    cpy win_height
    bne !loop-
    //bottom row of the window
    jsr funcAddRow
    ldx win_x //set x
    lda #win_bot_left
    jsr funcDrawChar
    inx
!:
    lda #win_bot
    jsr funcDrawChar
    inx
    cpx win_endx_inner
    bne !-
    lda #win_bot_right
    jsr funcDrawChar
    rts

//window characters
.label win_background = $a0
.label win_top_left = $f0
.label win_top_right = $ee
.label win_top = $c0
.label win_left = $dd
.label win_right = $dd
.label win_bot_left = $ed
.label win_bot_right = $fd
.label win_bot = $c0


funcReadChar:
    lda $ffff
    sta tmpChar
    clc
    lda funcReadChar + 1
    adc #$01
    sta funcReadChar + 1
    lda funcReadChar + 2
    adc #$00
    sta funcReadChar + 2
    lda tmpChar: #$00
    rts

funcDrawChar:
    sta $ffff,x
    lda win_color
    sta $ffff,x
    rts

funcAddRow:
    clc
    lda funcDrawChar + 1
    adc #$28
    sta funcDrawChar + 1
    lda funcDrawChar + 2
    adc #$00
    sta funcDrawChar + 2
    clc
    lda funcDrawChar + 7
    adc #$28
    sta funcDrawChar + 7
    lda funcDrawChar + 8
    adc #$00
    sta funcDrawChar + 8
    rts

funcSetRow:
    lda #$04
    sta funcDrawChar + 2
    lda #$00
    sta funcDrawChar + 1
    lda #$d8
    sta funcDrawChar + 8
    lda #$00
    sta funcDrawChar + 7
    ldx win_y
!:
    jsr funcAddRow
    dex
    bne !-
    rts
