.import source "./math.s"

.pc = $0801 "Basic Upstart"
:BasicUpstart(start) // 10 sys$0810
.pc =$1000 "Program"
start:

    //test
    load_a($01,$00,$01)
    load_b($00,$ff,$ff)
    jsr mAdd
    mv_result_lo($c000)
    assert($c000,$02,$00,$00,"01.0001 + 00.ffff")

    //test 
    load_a($01,$00,$00)
    jsr mNegA
    load_b($01,$00,$00)
    jsr mAdd
    mv_result_lo($c000)
    assert($c000,$00,$00,$00, "-01.0000 + 01.0000")

    //test 
    load_a($02,$00,$00)
    jsr mNegA
    load_b($01,$00,$00)
    jsr mAdd
    mv_result_lo($c000)
    assert($c000,$ff,$00,$00,"-02.0000 + 01.0000")

    //test 
    load_a($01,$01,$00)
    jsr mNegA
    load_b($01,$01,$00)
    jsr mAdd
    mv_result_lo($c000)
    assert($c000,$00,$00,$00,"-01.0100 + 01.0100")

    //test
    load_r($01,$00,$00)
    jsr mNegR
    mv_result_lo($c003)
    assert($c003,$ff,$00,$00,"-01.0000 immediate")

    //test 
    load_a($01,$01,$00)
    jsr mNegA
    load_b($01,$01,$00)
    jsr mNegB
    jsr mAdd
    mv_result_lo($c000)
    assert($c000,$02,$02,$00,"-01.0100 + -01.0100")

!end:
    inc $d020
    jmp !end-


.macro assert(address,vhi,vmd,vlo,test_name){
    .for(var i = 0; i < test_name.size(); i++){
        lda #test_name.charAt(i)
        sta $0400 + i
    }
    lda address 
    cmp #vlo
    beq !skip+
!loop:
    lda #$03
    sta $d020
    jmp !loop-
!skip:
    lda address + 1
    cmp #vmd
    beq !skip+
!loop:
    lda #$03
    sta $d020
    jmp !loop-
!skip:
    lda address + 2
    cmp #vhi
    beq !skip+
!loop:
    lda #$03
    sta $d020
    jmp !loop-
!skip:
    nop
}