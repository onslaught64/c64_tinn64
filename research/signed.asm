BasicUpstart2(start)
* = $0810
start:
    print("24-BIT SIGNED FIXED POINT MATH TESTS")
    print("TEST 1: BASIC SIGNED SUBTRACTION")
    print("$000002-$000004=$")
    lda #$02
    sta inal
    lda #$00
    sta inam
    lda #$00
    sta inah
    lda #$04
    sta inbl
    lda #$00
    sta inbm
    lda #$00
    sta inbh
    jsr sub
    jsr printbits
    print("TEST 2: MAX VALUE SUBTRACTION")
    print("$000000-$7FFFFF=$")
    lda #$00
    sta inal
    lda #$00
    sta inam
    lda #$00
    sta inah
    lda #$ff
    sta inbl
    lda #$ff
    sta inbm
    lda #$7f
    sta inbh
    jsr sub
    jsr printbits
    print("TEST 3: -1 + 1")
    print("$F00000+$100000=($000000) ACTUAL:$")
    lda #$00
    sta inal
    lda #$00
    sta inam
    lda #$f0
    sta inah
    lda #$00
    sta inbl
    lda #$00
    sta inbm
    lda #$10
    sta inbh
    jsr add
    jsr printbits

    print("TEST 4: -0.03 + 0.275")
    print("$FF851F+$046666=($03EB85) ACTUAL:$")
    lda #$1f
    sta inal
    lda #$85
    sta inam
    lda #$ff
    sta inah
    lda #$66
    sta inbl
    lda #$66
    sta inbm
    lda #$04
    sta inbh
    jsr add
    jsr printbits

    print("TEST 5: 7.9 - 0.27585")
    print("$7E6666-$0469E2=($79FC85) ACTUAL:$")
    lda #$66
    sta inal
    lda #$66
    sta inam
    lda #$7e
    sta inah
    lda #$e2
    sta inbl
    lda #$69
    sta inbm
    lda #$04
    sta inbh
    jsr sub
    jsr printbits


    rts

nega:
    lda inal
    eor #$ff
    clc
    adc #$01
    sta inal
    lda inam
    eor #$ff
    sta inam
    lda inah
    eor #$ff
    sta inah
    rts

negb:
    lda inbl
    eor #$ff
    clc
    adc #$01
    sta inbl
    lda inbm
    eor #$ff
    sta inbm
    lda inbh
    eor #$ff
    sta inbh
    rts

add:
    clc
    lda inal
    adc inbl
    sta outl
    lda inam
    adc inbm
    sta outm
    lda inah
    adc inbh
    sta outh
    rts

sub:
    jsr negb
    clc
    lda inbl
    adc inal
    sta outl
    lda inbm
    adc inam
    sta outm
    lda inbh
    adc inah
    sta outh
    rts


printbits:
    lda outh //h
    jsr hexout
    lda outm //m
    jsr hexout
    lda outl //l
    jmp hexout

    

hexout:
    clc
    pha //       (save the byte)
    lsr 
    lsr      
    lsr 
    lsr
    jsr hexdig
    pla
    and #$0f  
    jmp hexdig 

hexdig: 
    cmp #$0a //(alphabetic digit?)
    bcc !skip+ //  (no, skip next part)
    adc #$06 
!skip:
    adc #$30 //(convert to ASCII)
    jmp $ffd2 //(print it)

.macro print(string){
    ldx #$00
!loop:
    lda !data+,x
    cmp #$00
    beq !done+
    // lda #string.charAt(i)
    jsr $ffd2
    inx
    jmp !loop-
!data:
    .byte $0d
    .for(var i = 0; i < string.size(); i++){
        .byte string.charAt(i)
    }
    .byte $00
!done:
}

inal: .byte $00
inam: .byte $00
inah: .byte $00

inbl: .byte $00
inbm: .byte $00
inbh: .byte $00

outl: .byte $00
outm: .byte $00
outh: .byte $00


/*
Based on http://codebase64.org/doku.php?id=base:24bit_multiplication_24bit_product
	; Signed 24-bit multiply routine
	; Clobbers a, x, factor1, factor2
    modified to handle fixed point multiply (2 extra bytes of precision)
    note that the 24 bit result is actually r3 -> r5 NOT r1! 
    Bascially reading from r3 rescales the result
*/
// mMul:
// 	ldx #$00 // .x will hold the sign of product
//     stx r1 // init result
//     stx r2
//     stx r3
//     stx r4
//     stx r5
//     stx a4
//     stx a5
// 	lda a3 //high byte (sign)
// 	bpl !skip+ //  if factor1 is negative
// 	negative24(a1) // then factor1 := -factor1
// 	inx	// and switch sign
// !skip:
// 	lda b3 //high byte (sign)
// 	bpl !skip+ // if factor2 is negative
// 	negative24(b1) // then factor2 := -factor2
// 	inx // and switch sign
// !skip:
//     // do unsigned multiplication
// !loop:
// 	lda b1			// ; while factor2 != 0
// 	bne !nz+
// 	lda b2
// 	bne !nz+
// 	lda b3
// 	bne !nz+
// 	jmp !done+
// !nz:
// 	lda b1			// ; if factor2 is odd
// 	and #$01
// 	beq !skip+
	
// 	lda a1			// ; product += factor1
// 	clc
// 	adc r1
// 	sta r1
	
// 	lda a2
// 	adc r2
// 	sta r2
	
//     lda a3
//     adc r3
//     sta r3

//     lda a4
//     adc r4
//     sta r4

//     lda a5
//     adc r5
//     sta r5

// //; end if

// !skip:
// 	asl a1			//; << factor1 
// 	rol a2
// 	rol a3
//     rol a4
//     rol a5
// 	lsr b3			//; >> factor2
// 	ror b2
// 	ror b1

// 	jmp !loop-		//; end while	

// !done:
//     //clean up sign
// 	txa
// 	and #$01 // if .x is odd
// 	beq !skip+
// 	negative24(r3) // then product := -product
// !skip:
//     rts
