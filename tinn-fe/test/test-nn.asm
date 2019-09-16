
.pc = $0801 "Basic Upstart"
:BasicUpstart(start) // 10 sys$0810
.pc =$1000 "Program"
start:

    //test just confirm bcs is a > m
    lda #$02
    sta $c001
    lda #$01
    cmp $c001
    bcs !greater+
    jmp !assert+
!greater:
    sta $c001
!assert:
    assert_8($c001,$02,"test 1: bcs test 2>1")

    //test just confirming bcs is a > m
    lda #$02
    sta $c001
    lda #$0e
    cmp $c001
    bcs !greater+
    jmp !assert+
!greater:
    sta $c001
!assert:
    assert_8($c001,$0e,"test 2: bcs test e>2")

    //test 
    set_output_layer(1,$01,$00,$00)
    set_output_layer(2,$00,$01,$01)
    set_output_layer(4,$02,$00,$00)
    jsr nnWinner
    sta $c000
    assert_8($c000,$04,"winner test 1 is 4")

    //test
    set_output_layer(1,$00,$00,$00)
    set_output_layer(2,$00,$01,$01)
    set_output_layer(4,$00,$00,$00)
    jsr nnWinner
    sta $c000
    assert_8($c000,$02,"winner test 2 is 2")

    //test
    lda #$00
    ldx #$00
    ldy #$00
    jsr nnActivation
    mv_result($c000)
    assert_24($c000,$00,$80,$00,"sigmoid 0 = .5")

    //test
    load_a($02,00,00)
    jsr mNegA
    lda a3
    ldx a2
    ldy a1
    jsr nnActivation
    mv_result($c000)
    assert_24($c000,$00,$1e,$84,"sigmoid -2 = $1e84") // -2 = offset 40, which is $001e84

    




!end:
    inc $d020
    jmp !end-


.macro set_output_layer(index,hi,med,lo){
    lda #hi
    sta output_layer + (index * 3) + 2
    lda #med
    sta output_layer + (index * 3) + 1
    lda #lo
    sta output_layer + (index * 3)
}

.macro assert_8(address,value,test_name){
    .for(var i = 0; i < test_name.size(); i++){
        lda #test_name.charAt(i)
        sta $0400 + i
    }
    lda address 
    cmp #value
    beq !skip+
!loop:
    lda #$02
    sta $d020
    jmp !loop-
!skip:
    nop
}

.macro assert_24(address,vhi,vmd,vlo,test_name){
    .for(var i = 0; i < test_name.size(); i++){
        lda #test_name.charAt(i)
        sta $0400 + i
    }
    lda address 
    cmp #vlo
    beq !skip+
!loop:
    lda #$02
    sta $d020
    jmp !loop-
!skip:
    lda address + 1
    cmp #vmd
    beq !skip+
!loop:
    lda #$02
    sta $d020
    jmp !loop-
!skip:
    lda address + 2
    cmp #vhi
    beq !skip+
!loop:
    lda #$02
    sta $d020
    jmp !loop-
!skip:
    nop
}

.import source "../src/nn.asm"

