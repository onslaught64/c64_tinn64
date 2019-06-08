.import source "./math.s"

/*
Labels and config
*/
.label input_layer_size = 256
.label hidden_layer_size = 32
.label output_layer_size = 10

/*
def fprop(t: Tinn, in_: float) -> None:
	"""Forward propagation."""
	# Calculate hidden layer neuron values.
	for i in range(t.nhid):
		s = t.b[0]  # start with bias
		for j in range(t.nips):
			s += in_[j] * t.x1[i][j]
		t.h[i] = act(s)
	# Calculate output layer neuron values.
	for i in range(t.nops):
		s = t.b[1]  # start with bias
		for j in range(t.nhid):
			s += t.h[j] * t.x2[i][j]
		t.o[i] = act(s)

Returns A winning index (0->A)
*/

nnFProp:
//set up biases in the hidden layer first
	ldx #$00
	ldy #$00
!loop:
	lda t_biases
	sta hidden_layer,x
	inx
	lda t_biases + 1
	sta hidden_layer,x
	inx
	lda t_biases + 2
	sta hidden_layer,x
	inx
	cpx #hidden_layer_size * 3
	bne !loop-

//reset loop values below
	jsr nnResetX1

//multiply each input on a hidden layer node
.for(var i=0; i<hidden_layer_size; i++){
	lda #$00
	sta _nip
!loop:
	ldx _nip: #$00
	lda SCREEN_BUFFER,x
	sta a3
	lda #$00
	sta a2
	sta a1
	jsr nnReadX1
	jsr mLoadB
	jsr mMul
	mv_mul_a()
	ldx #< hidden_layer + (i*3)
	ldy #> hidden_layer + (i*3)
	jsr mLoadB
	jsr mAdd //add to existing hidden layer value
	mv_result(hidden_layer + (i*3))
	inc _nip
	bne !loop-
	//activation function here
	lda hidden_layer + (i*3) +2
	ldy hidden_layer + (i*3) +1
	ldx hidden_layer + (i*3)
	jsr nnActivation
	mv_result(hidden_layer + (i*3))
}
//set up biases in the output layer first
	ldx #$00
	ldy #$00
!loop:
	lda t_biases + 3
	sta output_layer,x
	inx
	lda t_biases + 4
	sta output_layer,x
	inx
	lda t_biases + 5
	sta output_layer,x
	inx
	cpx #output_layer_size * 3
	bne !loop-
//reset output layer call
	jsr nnResetX2

//multiply each input on a output layer node
.for(var i=0; i<output_layer_size; i++){
	lda #$00
	sta _nhid
!loop:
	ldx _nhid: #$00
	lda hidden_layer,x
	sta a1
	inx
	lda hidden_layer,x
	sta a2
	inx
	lda hidden_layer,x
	sta a3
	jsr nnReadX2
	jsr mLoadB
	jsr mMul
	mv_mul_a()
	ldx #< output_layer + (i*3)
	ldy #> output_layer + (i*3)
	jsr mLoadB
	jsr mAdd //add to existing hidden layer value
	mv_result(output_layer + (i*3))
	inc _nhid
	inc _nhid
	inc _nhid
	lda _nhid
	cmp #(hidden_layer_size * 3)
	bne !loop-
	lda output_layer + (i*3) + 2
	ldy output_layer + (i*3) + 1
	ldx output_layer + (i*3)
	jsr nnActivation
	mv_result(output_layer + (i*3))
}
	jsr nnWinner
	rts

/*
get next t_x1 value
x is lo
y is hi
*/
nnReadX1:
	ldx _hid_lo: #< t_x1
	ldy _hid_hi: #> t_x1
	clc
	inc _hid_lo
	bne !skip+
	inc _hid_hi
!skip:
	rts

/*
Reset X1 reader
*/
nnResetX1:
	lda #< t_x1
	sta _hid_lo
	lda #> t_x1
	sta _hid_hi
	rts

/*
get next t_x1 value
x is lo
y is hi
*/
nnReadX2:
	ldx _out_lo: #< t_x2
	ldy _out_hi: #> t_x2
	clc
	inc _out_lo
	bne !skip+
	inc _out_hi
!skip:
	rts

/*
Reset X1 reader
*/
nnResetX2:
	lda #< t_x2
	sta _out_lo
	lda #> t_x2
	sta _out_hi
	rts


/*
def act(a: float) -> float:
	"""Activation function."""
	if a > 4:
		return 1.0
	if a < -4: 
		return 0.0
	tmp = int(((a + 4) / 8) * 256)
	return exp_lut[tmp]
	# return 1 / (1 + math.exp(-a))

a = value hi byte
y = value mid byte
x = value lo byte

returns result using math
*/
nnActivation:
	sta a3
	sty a2
	stx a1
	lda #$04
	sta b3
	lda #$00
	sta b2
	sta b1
	jsr mAdd
	mv_add_a()
	lda #$00
	sta b1
	sta b2
	sta b3
	jsr mCmp
	bpl !skip+
	//a < -4
	lda #$00
	ldx #$00
	ldy #$00
	rts
!skip:
	lda #$08
	sta b3
	jsr mCmp
	bmi !skip+
	// a > 4
	lda #$01
	ldx #$00
	ldy #$00
	rts
!skip: 
	//shift up the index for the exponent lookup
	asl r1
	rol r2
	rol r3
	asl r1
	rol r2
	rol r3
	asl r1
	rol r2
	rol r3
	asl r1
	rol r2
	rol r3
	//lookup exp using r3
	lda r3
	tax 
	lda exp_lut_lo,x
	sta r1
	lda exp_lut_med,x
	sta r2
	lda exp_lut_hi,x
	sta r3
	rts

_winner:
	.byte $00, $00, $00, $00

/*
returns winner in A
*/
nnWinner:
	lda #$00
	ldx #$00
	ldy #$00
	sta _winner
	sta _winner + 1
	sta _winner + 2
!loop:
	lda output_layer+2,x
	cmp _winner+2
	bcs !winner+ //a>m hi
	lda output_layer+1,x
	cmp _winner+1
	bcs !winner+  //a>m med
	lda output_layer,x
	cmp _winner
	bcs !winner+ //a>m lo
!notWinner:
	inx
	inx
	inx //skip ahead 3 bytes for 24bit
	iny
	cpx #(output_layer_size * 3)
	bne !loop-
	lda _winner+3
	rts
!winner:
	lda output_layer+2,x
	sta _winner+2
	lda output_layer+1,x
	sta _winner+1
	lda output_layer,x
	sta _winner
	sty _winner+3
	jmp !notWinner-


hidden_layer:
.for(var i=0;i<hidden_layer_size;i++){
	.byte $00, $00, $00 //24 bit fixed point
}

output_layer:
.for(var i=0;i<output_layer_size;i++){
	.byte $00, $00, $00 //24 bit fixed point	
}

/*this should be in fe.s but, well, we need it here*/
.align $100
SCREEN_BUFFER:
.for (var i=0;i<$100;i++) {
    .byte $00
}

/*
Load up all the generated data
*/
.import source "../output/biases.asm"
.import source "../output/exp_lut.asm"
.import source "../output/t_x1.asm"
.import source "../output/t_x2.asm"
