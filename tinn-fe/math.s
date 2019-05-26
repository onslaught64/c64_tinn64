/*
24 bit fixed point signed math library
*/

.label a1 = $a0
.label a2 = $a1
.label a3 = $a2
.label a4 = $a3
.label a5 = $a4
.label a6 = $a5

.label b1 = $a6
.label b2 = $a7
.label b3 = $a8
.label b4 = $a9
.label b5 = $aa
.label b6 = $ab

.label r1 = $ac
.label r2 = $ad
.label r3 = $ae
.label r4 = $af
.label r5 = $b0
.label r6 = $b1

.label pztemp = $b2


.macro load_a(bhi,bmd,blo){
    lda #blo
    sta a1
    lda #bmd
    sta a2
    lda #bhi
    sta a3
}

.macro load_b(bhi,bmd,blo){
    lda #blo
    sta b1
    lda #bmd
    sta b2
    lda #bhi
    sta b3
}

.macro mv_result_lo(address){
    lda r1
    sta address
    lda r2
    sta address + 1
    lda r3
    sta address + 2
}

.macro mv_result_hi(address){
    lda r4
    sta address
    lda r5
    sta address + 1
    lda r6
    sta address + 2
}



/*
24 bit signed add
*/
mAdd:
    clc				
    lda a1
    adc b1
    sta r1
    lda a2
    adc b2
    sta r2
    lda a3
    adc b3
    sta r3
    rts

/*
24 bit signed subtract
*/
mSub:
    sec				
    lda a1
    sbc b1
    sta r1
    lda a2
    sbc b2
    sta r2
    lda a3
    sbc b3
    sta r3
    rts


/*
24 bit signed compare
N will contain the signed comparison result, but in this case:
If the N flag is 1, then A (signed) <= NUM (signed) and BMI will branch
If the N flag is 0, then A (signed) > NUM (signed) and BPL will branch
*/
mCmp:
    sec
    lda a1
    cmp b1
    lda a2
    cmp b2
    lda a3
    cmp b3
    bvc !skip+
    eor #$80
!skip:
    rts

mNeg:
    negative24(a1)
    rts

.macro negative24(lowestByte){
    sec
    lda #$00
    sbc lowestByte
    sta lowestByte
    lda #$00
    sbc lowestByte + 1
    sta lowestByte + 1
    lda #$00
    sbc lowestByte + 2
    sta lowestByte + 2
}

.macro negative48(lowestByte){
    sec
    lda #$00
    sbc lowestByte
    sta lowestByte
    lda #$00
    sbc lowestByte + 1
    sta lowestByte + 1
    lda #$00
    sbc lowestByte + 2
    sta lowestByte + 2
    lda #$00
    sbc lowestByte + 3
    sta lowestByte + 3
    lda #$00
    sbc lowestByte + 4
    sta lowestByte + 4
    lda #$00
    sbc lowestByte + 5
    sta lowestByte + 5
    lda #$00
    sbc lowestByte + 6
    sta lowestByte + 6
}


/*
	; Signed 24-bit multiply routine
	; Clobbers a, x, factor1, factor2
*/
mMul:
	ldx #$00 // .x will hold the sign of product
    stx r1 // init result
    stx r2
    stx r3
    stx r4
    stx r5
    stx r6

	lda a3 //high byte (sign)
	bpl !skip+ //  if factor1 is negative
	negative24(a1) // then factor1 := -factor1
	inx	// and switch sign
!skip:
	lda b3 //high byte (sign)
	bpl !skip+ // if factor2 is negative
	negative24(b1) // then factor2 := -factor2
	inx // and switch sign
!skip:
    // do unsigned multiplication
    ldy #$18     //Set binary count to 24
!SHIFT_R:
    lsr a3   //Shift multiplyer right
    ror a2
    ror a1
    bcc !ROTATE_R+ //Go rotate right if c = 0
    lda r4 // Get upper half of product
    clc      // and add multiplicand to it
    adc b1
    sta r4
    lda r5
    adc b2
    sta r5
    lda r6
    adc b3
!ROTATE_R:  
    ror //a Rotate partial product right
    sta r6 
    ror r5 
    ror r4 
    ror r3 
    ror r2 
    ror r1 
    dey //Decrement bit count and
    bne !SHIFT_R-  // loop until 24 bits are done
	txa
	and #$01 // if .x is odd
	beq !skip+
	negative48(r1) // then product := -product
    //rescale result
!skip:
    rts


	

mDiv:
	ldx #$00 // .x will hold the sign of division
    stx r1 // init result
    stx r2
    stx r3
    stx r4
    stx r5
    stx r6

	lda a3 //high byte (sign)
	bpl !skip+ //  if factor1 is negative
	negative24(a1) // then factor1 := -factor1
	inx	// and switch sign
!skip:
	lda b3 //high byte (sign)
	bpl !skip+ // if factor2 is negative
	negative24(b1) // then factor2 := -factor2
	inx // and switch sign
!skip:
    stx divDoNeg
    // do unsigned division
    ldx #24 //Set bit length the 48bits (24 bit double)
!loop:
    asl a1 //dividend	;dividend lb & hb*2, msb -> Carry
    rol a2 //dividend+1	
    rol a3 //dividend+2
    rol r1 //remainder	;remainder lb & hb * 2 + msb from carry
    rol r2 //remainder+1
    rol r3 //remainder+2
    lda r1 //remainder
    sec
    sbc b1 //divisor	;substract divisor to see if it fits in
    tay	   //lb result -> Y, for we may need it later
    lda r2 //remainder+1
    sbc b2 //divisor+1
    sta pztemp
    lda r3 //remainder+2
    sbc b3 //divisor+2
    bcc !skip+ //;if carry=0 then divisor didn't fit in yet
    sta r3 //remainder+2	;else save substraction result as new remainder,
    lda pztemp
    sta r2 //remainder+1
    sty r1 //remainder	
    inc a1 //dividend 	;and INCrement result cause divisor fit in 1 times
!skip:
    dex
    bne !loop-
	lda divDoNeg: #$00
	and #$01 // if .x is odd
	beq !skip+
	negative48(r1) // then product := -product
    //rescale result
!skip:
    rts
