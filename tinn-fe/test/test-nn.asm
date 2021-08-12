
.pc = $0801 "Basic Upstart"
BasicUpstart2(start2)    // 10 sys$0810

test_seven:
.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$00,$01,$01,$01,$01,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00
//0 0 0 0 0 0 0 1 0 0 

test_four:
.byte $00,$00,$00,$00,$00,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$00,$00,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$00,$00,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$01,$01,$01,$00,$00,$00,$00,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01
//0 0 0 0 1 0 0 0 0 0 

.var zpl = $b0
.var zph = $b1

mv_screen_buffer:
    ldy #$00
!loop:
    lda (zpl),y
    sta SCREEN_BUFFER,y
    iny
    cpy #$00
    bne !loop-
    rts

.align $100
SCREEN_BUFFER:
.fill $100, $00

.pc=* "MATH"
.import source "../src/math.asm"
.pc=* "NN2"
.import source "../src/nn2.asm"
.pc=* "MNIST"
.import source "../rsrc/mnist.asm"

start2:
lda #$00
sta $d020
sta $d021
print("HELLOmm")
/*
TODO:
-----
1. copy some mnist bytemaps 
2. routine to replace SCREEN_BUFFER with a test bytemap
3. test signmoid activation_function
4. test nn_forward_propagate classifier

Exp LUT range limits
.byte $00,$00,$d4// FLOAT: -00000000000000000000011		 SCALAR:-2883584		 HEX:$d4$00$00
.byte $00,$00,$2c// FLOAT: 000000000000000000000011		 SCALAR:02883584		 HEX:$2c$00$00
Anything below 11 should be 0
Anything above 11 should be 1
Around 0 should be MIDDLE of the sigmoid function  
*/

jsr clear_all
lda #$04 //$01 in fixed point
sta outh
jsr activation_function
print("$000000 (+01) -> ")
jsr printbits

jsr clear_all
lda #$d4 //-11 in fixed point
sta outh
jsr activation_function
print("$D40000 (-11) -> ")
jsr printbits

jsr clear_all
lda #$2c //+11 in fixed point
sta outh
jsr activation_function
print("$2C0000 (+11) -> ")
jsr printbits

jsr clear_all
lda #$80 //-31 in fixed point
sta outh
jsr activation_function
print("$800000 (-31) -> ")
jsr printbits

jsr clear_all
lda #$7f //+31 in fixed point
sta outh
jsr activation_function
print("$7F0000 (+31) -> ")
jsr printbits

/*
.for(var i=$20;i<$2d;i++){
    jsr clear_all
    lda #i 
    sta outh
    jsr nego
    jsr activation_function
    print(toIntString(i * -1) + " -> ")
    jsr printbits
}

.for(var i=$20;i<$2d;i++){
    jsr clear_all
    lda #i 
    sta outh
    jsr activation_function
    print(toIntString(i) + " -> ")
    // print(" -> ")
    jsr printbits
}
*/

print("FPROP TEST 1")
print("m")
lda #<test_four
sta zpl
lda #>test_four
sta zph
jsr nn_forward_propagate
jsr clear_all
lda wini
sta outh
print("FOUR: ")
jsr printbits

!end: jmp !end-


