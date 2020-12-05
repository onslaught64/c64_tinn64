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

    print("TEST 6: multiply 2 x 3")
    print("$020000*$030000=$")
    lda #$00
    sta inal
    lda #$00
    sta inam
    lda #$02
    sta inah
    lda #$00
    sta inbl
    lda #$00
    sta inbm
    lda #$03
    sta inbh
    jsr mul
    jsr printbits

    print("TEST 7: 7.9 x 0.27585=2.179215")
    print("$7E6666*$0469E2=$22DE11=$")
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
    jsr mul
    jsr printbits

    print("TEST 8: 7 x 1=7")
    print("$700000*$100000=$700000=$")
    lda #$00
    sta inal
    lda #$00
    sta inam
    lda #$70
    sta inah
    lda #$00
    sta inbl
    lda #$00
    sta inbm
    lda #$10
    sta inbh
    jsr mul
    jsr printbits

    print("TEST 9: -7.9 x 0.27585=-2.179215")
    print("$81999A*$0469E2=$DD21EF=$")
    lda #$9a
    sta inal
    lda #$99
    sta inam
    lda #$81
    sta inah
    lda #$e2
    sta inbl
    lda #$69
    sta inbm
    lda #$04
    sta inbh
    jsr mul
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

nego:
    lda outl
    eor #$ff
    clc
    adc #$01
    sta outl
    lda outm
    eor #$ff
    sta outm
    lda outh
    eor #$ff
    sta outh
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


mul:
    ldy #$00
	lda inah //high byte (sign)
	bpl !skip+ //  if factor1 is negative
	jsr nega // then factor1 := -factor1
	iny	// and switch sign
!skip:
	lda inbh //high byte (sign)
	bpl !skip+ // if factor2 is negative
	jsr negb // then factor2 := -factor2
	iny // and switch sign
!skip:
    lda #$00     // clear p2 and p3 of product
    sta outl
    sta outm
    sta outh
    sta out4
    sta out5
    sta out6
    ldx #24     // multiplier bit count = 16
nxtbt:
    lsr inah
    ror inam
    ror inal    //shift two-byte multiplier right
    bcc align   // multiplier = 1?
    clc
    lda out4      // yes. fetch p2
    adc inbl      // and add m0 to it
    sta out4      // store new p2
    lda out5      // yes. fetch p2
    adc inbm      /// and add m0 to it
    sta out5      // store new p2
    lda out6      // yes. fetch p2
    adc inbh      // and add m0 to it
align:   
    ror        // rotate four-byte product right
    sta out6      // store new p3
    ror out5
    ror out4
    ror outh
    ror outm
    ror outl
    dex          // decrement bit count
    bne nxtbt    // loop until 16 bits are done
    .for(var i=0; i<4; i++){
        lsr out6
        ror out5
        ror out4
        ror outh
    }
    lda outh
    sta outl
    lda out4 
    sta outm
    lda out5
    sta outh
//clean up sign
	tya
	and #$01 // if .x is odd
	beq !skip+
	jsr nego // then product := -product
!skip:
    rts


inal: .byte $00
inam: .byte $00
inah: .byte $00
ina4: .byte $00 //mul overflow
ina5: .byte $00
ina6: .byte $00

inbl: .byte $00
inbm: .byte $00
inbh: .byte $00

outl: .byte $00
outm: .byte $00
outh: .byte $00
out4: .byte $00
out5: .byte $00
out6: .byte $00


