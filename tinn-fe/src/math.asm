.var inal = $a0
.var inam = $a1
.var inah = $a2
.var ina4 = $a3
.var ina5 = $a4
.var ina6 = $a5
.var inbl = $a5
.var inbm = $a6
.var inbh = $a7
.var outl = $a8
.var outm = $a9
.var outh = $aa
.var out4 = $ab
.var out5 = $ac
.var out6 = $ad
/*
Processing Marcos
*/
.macro push_direct_a(addr){
    lda addr
    sta inal
    lda addr + 1 
    sta inam
    lda addr + 2
    sta inah
    lda #$00
    sta ina4
    sta ina5
    sta ina6
}

.macro push_direct_b(addr){
    lda addr
    sta inbl
    lda addr + 1 
    sta inbm
    lda addr + 2
    sta inbh
}

.macro pop_direct(addr){
    lda outl
    sta addr
    lda outm
    sta addr + 1
    lda outh
    sta addr + 2
}

.macro push_zp_a(addr){
    lda (addr),y
    sta inal
    inc addr
    bne !+
    inc addr + 1
!:
    lda (addr),y
    sta inam
    inc addr
    bne !+
    inc addr + 1
!:
    lda (addr),y
    sta inah
    inc addr
    bne !+
    inc addr + 1
!:
    lda #$00
    sta ina4
    sta ina5
    sta ina6
}

.macro push_zp_b(addr){
    lda (addr),y
    sta inbl
    inc addr
    bne !+
    inc addr + 1
!:
    lda (addr),y
    sta inbm
    inc addr
    bne !+
    inc addr + 1
!:
    lda (addr),y
    sta inbh
    inc addr
    bne !+
    inc addr + 1
!:
}

.macro pop_zp(addr){
    lda outl
    sta (addr),y
    inc addr
    bne !+
    inc addr + 1
!:
    lda outm
    sta (addr),y
    inc addr
    bne !+
    inc addr + 1
!:
    lda outh
    sta (addr),y
    inc addr
    bne !+
    inc addr + 1
!:
}
//--------------------
/*
Is negative
*/
neg_byte:
.byte %10000000


//--------------------
/*
Feeds back the result as an input
*/
feedback:
    lda outl
    sta inal
    lda outm
    sta inam
    lda outh
    sta inah
    lda #$00
    sta ina4
    sta ina5
    sta ina6
    sta outl
    sta outm
    sta outh
    sta out4
    sta out5
    sta out6
    rts

//--------------------
clear_all:
    lda #$00
    sta inal
    sta inam
    sta inah
    sta ina4
    sta ina5
    sta ina6
    sta inbl
    sta inbm
    sta inbh
    sta outl 
    sta outm
    sta outh
    sta out4
    sta out5
    sta out6
    rts

//--------------------
clear_a:
    lda #$00
    sta inal
    sta inam
    sta inah
    sta ina4
    sta ina5
    sta ina6
    rts

//--------------------
clear_b:
    lda #$00
    sta inbl
    sta inbm
    sta inbh
    rts

//--------------------
clear_out:
    lda #$00
    sta outl 
    sta outm
    sta outh
    sta out4
    sta out5
    sta out6
    rts

//--------------------
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

//--------------------
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

//--------------------
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

//--------------------
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

//--------------------
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

//--------------------
mul:
    stx !shadow_x+ + 1
    sty !shadow_y+ + 1
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
!shadow_x:
    ldx #$00
!shadow_y:
    ldy #$00
    rts
    


//--------------------
// Output functions
//--------------------
printbits:
    lda outh //h
    jsr hexout
    lda outm //m
    jsr hexout
    lda outl //l
    jmp hexout
//--------------------
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
//--------------------
hexdig: 
    cmp #$0a //(alphabetic digit?)
    bcc !skip+ //  (no, skip next part)
    adc #$06 
!skip:
    adc #$30 //(convert to ASCII)
    jmp $ffd2 //(print it)
//--------------------
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


