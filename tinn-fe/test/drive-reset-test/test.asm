.pc =$1000 "Program"
start:
    ldx #< txt_1
    ldy #> txt_1
    jsr print
    jsr $c90 //load a demo part
    ldx #< txt_2
    ldy #> txt_2
    jsr print
    jsr $c90
    ldx #< txt_3
    ldy #> txt_3
    jsr print
    jsr $c90

    jsr $cc00 //init loader
    ldx #< txt_4
    ldy #> txt_4
    jsr print

    ldx #'0'
    ldy #'1'
    lda #$70
    sta $2f
    lda #$00
    sta $2e
    jsr $cf00 //perform the load to $7000

    ldx #< txt_5
    ldy #> txt_5
    jsr print

    jsr $7000 //something should load to $7000

    //this should never be run
end:
    inc $d020
    jmp end

print:
    stx print_ptr
    sty print_ptr + 1
    ldx #$00
loop:
    lda print_ptr: $ffff,x
    beq finish
    sta output_ptr: $0400,x
    inx
    jmp loop
finish:
    clc
    lda output_ptr
    adc #$28
    sta output_ptr
    lda output_ptr + 1 //carry the high byte 
    adc #$00
    sta output_ptr + 1
    rts

txt_1:
    .text "first part loaded"
    .byte $00
txt_2:
    .text "second part loaded"
    .byte $00
txt_3:
    .text "loader part loaded"
    .byte $00
txt_4:
    .text "loader initialised, loading..."
    .byte $00
txt_5:
    .text "loader complete!"
    .byte $00
