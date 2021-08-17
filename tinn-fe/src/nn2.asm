/*
Labels and config
*/
.label input_layer_size = 256
.label hidden_layer_size = 32
.label output_layer_size = 10

/*
ZEROPAGE:
Note MATH uses $a0 - $ad
*/
.var inl = $b6
.var inh = $b7

.var ptrl = $b0
.var ptrh = $b1

.var datal = $ae
.var datah = $af

.var tmpl = $b2
.var tmpm = $b3
.var tmph = $b4

.var winl = $b8
.var winm = $b9
.var winh = $ba
.var wini = $bb //index

.var neuron_counter = $b2

/*
Functions
*/
push_tmp:
	lda outl
	sta tmpl
	lda outm
	sta tmpm
	lda outh
	sta tmph
	rts

pop_tmp:
	lda tmpl
	sta inbl
	lda tmpm
	sta inbm
	lda tmph
	sta inbh
	rts

output_to_tmp:
	lda (ptrl),y
	sta tmpl
	inc ptrl
	bne !+
	inc ptrh
!:
	lda (ptrl),y
	sta tmpm
	inc ptrl
	bne !+
	inc ptrh
!:
	lda (ptrl),y
	sta tmph
	inc ptrl
	bne !+
	inc ptrh
!:
rts

tmp_to_winner:
	lda tmpl
	sta winl
	lda tmpm
	sta winm
	lda tmph
	sta tmph
	rts

/*
 def fprop(self, in_: [float]) -> None:
        """Forward propagation."""
        # Calculate hidden layer neuron values.
        for i in range(self.nhid):
            s = self.b[0]  # start with bias
            for j in range(self.nips):
                s += in_[j] * self.x1[i][j]
            self.h[i] = self.act(s)
        # Calculate output layer neuron values.
        for i in range(self.nops):
            s = self.b[1]  # start with bias
            for j in range(self.nhid):
                s += self.h[j] * self.x2[i][j]
            self.o[i] = self.act(s)

This is the main function: 
Forward propagate 
The output of this is ZEROPAGE: wini
which contains the index of the winner 
- in the case of MNIST this would represent 
the digit (as HEX) for QD this would be a 
classification of some kind (based on our dataset) 
of doodle.
*/
nn_forward_propagate:
	ldx #$00
	ldy #$00
	// init the zp
	lda t_weights_hidden
	sta datal
	lda t_weights_hidden + 1
	sta datah
	lda #<hidden_layer
	sta ptrl
	lda #>hidden_layer
	sta ptrh
	lda #$00
	sta neuron_counter
loop_hidden_layer:
	jsr clear_all
	/*
	this seems strange, we put the bias into
	the result of the mathlib - because we use result
	feedback as part of the processing loop. so
	by default, the first loop will add the bias
	*/
	lda t_biases
	sta outl
	lda t_biases + 1
	sta outm
	lda t_biases + 2
	sta outh
loop_hidden_perceptron:
	lda SCREEN_BUFFER,x
	beq !skip+
	// process the weights for this input
	jsr feedback
	push_zp_b(datal)
	jsr add
	jmp !finalise+
!skip:
	// skip over the weights for this input
	inc datal
	bne !+
	inc datah
!:
	inc datal
	bne !+
	inc datah
!:
	inc datal
	bne !finalise+
	inc datah
!finalise:
	inx
	cpx #$00
	bne loop_hidden_perceptron
	jsr activation_function
	pop_zp(ptrl)
	dec neuron_counter
	bne loop_hidden_layer
/*
Hidden layer to output layer
*/
	ldx #$00
	ldy #$00
	// init the zp
	lda t_weights_output
	sta datal
	lda t_weights_output + 1
	sta datah
	lda #<output_layer
	sta ptrl
	lda #>output_layer
	sta ptrh
	lda #<hidden_layer
	sta inl
	lda #>hidden_layer
	sta inh
	lda #output_layer_size
	sta neuron_counter
loop_output_layer:
	jsr clear_all
	/*
	this seems strange, we put the bias into
	the result of the mathlib - because we use result
	feedback as part of the processing loop. so
	by default, the first loop will add the bias
	*/
	lda t_biases + 3
	sta tmpl
	lda t_biases + 4
	sta tmpm
	lda t_biases + 5
	sta tmph
loop_output_perceptron:
	push_zp_a(inl)
	push_zp_b(datal)
	jsr mul
	jsr feedback
	jsr pop_tmp
	jsr add
	jsr push_tmp
	inx
	cpx hidden_layer_size
	bne loop_output_perceptron
	lda tmpl
	sta outl
	lda tmpm
	sta outm
	lda tmph
	sta outh
	jsr activation_function
	pop_zp(ptrl)
	dec neuron_counter
	beq !skip+
	jmp loop_output_layer
!skip:

/*
Determine the winner
*/
	lda #<output_layer
	sta ptrl
	lda #>output_layer
	sta ptrh
	
	ldx #$00
	ldy #$00
	jsr output_to_tmp
	jsr tmp_to_winner
	stx wini
win_loop:
	jsr output_to_tmp
	lda winh
	cmp tmph
	bcs win_next
	lda winm
	cmp tmpm
	bcs win_next
	lda winl
	cmp tmpl
	bcs win_next
	jsr tmp_to_winner
	stx wini
win_next:
	inx
	cpx #output_layer_size
	bne win_loop
	rts



/*
self.__lut = []
vals = np.linspace(-11, 11, 256)
for i in range(256):
	tmp = 1 / (1 + math.exp(vals[i] * -1))
	self.__lut.append(FixedPointNumber(tmp))
Solve for this:
Exp LUT range limits
.byte $00,$00,$a8// FLOAT: -11		 SCALAR:-5767168		 HEX:$a8$00$00
.byte $00,$00,$58// FLOAT: 11		 SCALAR:05767168		 HEX:$58$00$00

*/
_return_zero:
	// print("RETURN 0")
	jsr clear_out //0.0
	rts

_return_one:
	// print("RETURN 1")
	jsr clear_out
	lda #$04 //1.0
	sta outh
	rts

activation_function:
	inc $d020
	inc $d021
	jsr feedback
	jsr clear_b
	lda #$2c
	sta inbh
	jsr add
	lda outh
	bit neg_byte
	bne _return_zero
	cmp #$58
	bcs _return_one
_return_sigmoid:
	clc
	.for(var i=0;i<7;i++){
		lsr outh
		ror outm
		//ror outl
	}
	ldx outm
	lda exp_lut_lo,x
	sta outl
	lda exp_lut_mid,x
	sta outm
	lda exp_lut_hi,x
	sta outh
	rts




.align $100
.pc = * "Hidden Layer"
hidden_layer:
.for(var i=0;i<hidden_layer_size;i++){
	.byte $00, $00, $00 //24 bit fixed point
}

.align $100
.pc = * "Output Layer"
output_layer:
.for(var i=0;i<output_layer_size;i++){
	.byte $00, $00, $00 //24 bit fixed point	
}
