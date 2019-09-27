.pc =$7000 "Program"
start:
lda #$01
sta $d021
lda #$04
sta $d021
lda #$06
sta $d020
lda #$0c
sta $d020
jmp start
