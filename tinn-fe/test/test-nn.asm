
.pc = $0801 "Basic Upstart"
:BasicUpstart(start) // 10 sys$0810
.pc =$1000 "Program"
start:
lda #$00
sta $d020
sta $d021
print("HELLO")
/*
TODO:
-----
1. copy some mnist bytemaps 
2. routine to replace SCREEN_BUFFER with a test bytemap
3. test signmoid activation_function
4. test nn_forward_propagate classifier

*/
!end: jmp !end-

.align $100
SCREEN_BUFFER:
.fill $100, $00

.pc=* "MATH"
.import source "../src/math.asm"
.pc=* "NN2"
.import source "../src/nn2.asm"
.pc=* "MNIST"
.import source "../rsrc/mnist.asm"
