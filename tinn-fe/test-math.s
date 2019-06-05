.import source "./math.s"

.pc = $0801 "Basic Upstart"
:BasicUpstart(start) // 10 sys$0810
.pc =$3000 "Program"
start:

    //test
    load_a($01,$00,$01)
    load_b($00,$ff,$ff)
    jsr mAdd
    mv_result($c000)
    assert($c000,$02,$00,$00,"01.0001 + 00.ffff")

    //test 
    load_a($01,$00,$00)
    jsr mNegA
    load_b($01,$00,$00)
    jsr mAdd
    mv_result($c000)
    assert($c000,$00,$00,$00, "-01.0000 + 01.0000")

    //test 
    load_a($02,$00,$00)
    jsr mNegA
    load_b($01,$00,$00)
    jsr mAdd
    mv_result($c000)
    assert($c000,$ff,$00,$00,"-02.0000 + 01.0000")

    //test 
    load_a($01,$01,$00)
    jsr mNegA
    load_b($01,$01,$00)
    jsr mAdd
    mv_result($c000)
    assert($c000,$00,$00,$00,"-01.0100 + 01.0100")

    //test
    load_r($01,$00,$00)
    jsr mNegR
    mv_result($c000)
    assert($c000,$ff,$00,$00,"-01.0000 immediate")

    //test
    load_r($00,$01,$00)
    jsr mNegR
    mv_result($c000)
    assert($c000,$ff,$ff,$00,"-00.0100 immediate")

    //test
    load_r($00,$00,$01)
    jsr mNegR
    mv_result($c000)
    assert($c000,$ff,$ff,$ff,"-00.0001 immediate")

    //test
    load_r($00,$00,$02)
    jsr mNegR
    mv_result($c000)
    assert($c000,$ff,$ff,$fe,"-00.0002 immediate")

    //test
    load_r($01,$01,$00)
    jsr mNegR
    mv_result($c000)
    assert($c000,$fe,$ff,$00,"-01.0100 immediate")


    //test
    load_r($7f,$ff,$ff)
    jsr mNegR
    mv_result($c000)
    assert($c000,$80,$00,$01,"7f.ffff immediate")

    //test
    load_r($00,$00,$ff)
    jsr mNegR
    mv_result($c000)
    assert($c000,$ff,$ff,$01,"negative of 0000ff")

    //test
    load_r($00,$ff,$ff)
    jsr mNegR
    mv_result($c000)
    assert($c000,$ff,$00,$01,"negative of 00ffff")

    //test
    load_r($00,$ff,$fe)
    jsr mNegR
    mv_result($c000)
    assert($c000,$ff,$00,$02,"negative of 00fffe")


    //test
    load_r($00,$00,$00)
    jsr mNegR
    mv_result($c000)
    assert($c000,$00,$00,$00,"negative of 000000")


    //test
    load_r($00,$01,$01)
    jsr mNegR
    mv_result($c000)
    assert($c000,$ff,$fe,$ff,"negative of 000101")


    //test
    load_r($01,$01,$01)
    jsr mNegR
    mv_result($c000)
    assert($c000,$fe,$fe,$ff,"negative of 010101")


    //test
    load_r($00,$80,$00)
    jsr mNegR
    mv_result($c000)
    assert($c000,$ff,$80,$00,"negative $008000")


    //test 
    load_a($01,$01,$00)
    jsr mNegA
    load_b($01,$02,$00)
    jsr mNegB
    jsr mAdd
    mv_result($c000)
    assert($c000,$fd,$fd,$00,"-01.0100 + -01.0100") 

    //test 
    load_a($01,$01,$00)
    jsr mNegA
    load_b($01,$02,$00)
    jsr mSub
    mv_result($c000)
    assert($c000,$fd,$fd,$00,"-01.0100 - 01.0100 = fd.fd00") 

    //test
    load_a($00,$00,$01)
    load_b($00,$00,$01)
    jsr mAdd
    mv_result($c000)
    assert($c000,$00,$00,$02,"00.0001 + 00.0001 = 00.0002")

    //test
    load_a($44,$44,$44)
    load_b($20,$20,$20)
    jsr mSub
    mv_result($c000)
    assert($c000,$24,$24,$24,"44.4444 - 20.2020 = 24.2424")

    //test
    load_a($00,$00,$03)
    load_b($00,$00,$02)
    jsr mMul
    mv_mul_result($c000)
    assert($c000,$00,$00,$00,"00.0003 * 00.0002 = 00.0000")

    //test
    load_a($02,$00,$00)
    load_b($03,$00,$00)
    jsr mMul
    mv_mul_result($c000)
    assert($c000,$06,$00,$00,"02.0000 * 03.0000 = 06.0000")

    //test
    load_a($00,$02,$00)
    load_b($00,$03,$00)
    jsr mMul
    mv_mul_result($c000)
    assert($c000,$00,$00,$06,"00.0200 * 00.0300 = 00.0006")

    //test
    load_a($00,$08,$00)
    load_b($02,$00,$00)
    jsr mMul
    mv_mul_result($c000)
    assert($c000,$00,$10,$00,"02.0000 * 00.0800 = 00.1000")


    //test
    load_a($00,$08,$00)
    jsr mNegA
    load_b($02,$00,$00)
    jsr mNegB
    jsr mMul
    mv_mul_result($c000)
    assert($c000,$00,$10,$00,"-02.0000 * -00.0800 = 00.1000")


    //test
    load_a($00,$08,$00)
    jsr mNegA
    load_b($02,$00,$00)
    jsr mMul
    mv_mul_result($c000)
    negative24($c000)
    assert($c000,$00,$10,$00,"-02.0000 * 00.0800 = -00.1000")


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