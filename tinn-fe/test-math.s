.import source "./math.s"

.pc = $0801 "Basic Upstart"
:BasicUpstart(start) // 10 sys$0810
.pc =$1000 "Program"
start:

    //test decimal point add
    load_a($01,$00,$01)
    load_b($00,$ff,$ff)
    jsr mAdd
    mv_result_lo($c000)
    assert($c000,$02,$00,$00)

    //test negative add 
    load_a($01,$00,$00)
    jsr mNeg
    load_b($01,$00,$00)
    jsr mAdd
    mv_result_lo($c000)
    assert($c000,$00,$00,$00)


!end:
    inc $d020
    jmp !end-


.macro assert(address,vhi,vmd,vlo){
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