
.pseudocommand sadc value {
	clc
	adc value
}

.pseudocommand ssbc value {
	sec
	sbc value
}



.pseudocommand mov src:tar {
	lda src
	sta tar
}

.pseudocommand mox src:tar {
	ldx src
	stx tar
}

.pseudocommand moy src:tar {
	ldy src
	sty tar
}

.function _16bit_nextArgument(arg) {
	.if (arg.getType()==AT_IMMEDIATE)
		.return CmdArgument(arg.getType(),>arg.getValue())
	.return CmdArgument(arg.getType(),arg.getValue()+1)
}

.pseudocommand inc16 arg {
	inc arg
	bne over
	inc _16bit_nextArgument(arg)
over:
}
.pseudocommand mov16 src:tar {
	lda src
	sta tar
	lda _16bit_nextArgument(src)
	sta _16bit_nextArgument(tar)
}
.pseudocommand add16 arg1 : arg2 : tar {
	.if (tar.getType()==AT_NONE) .eval tar=arg1
	lda arg1
	adc arg2
	sta tar
	lda _16bit_nextArgument(arg1)
	adc _16bit_nextArgument(arg2)
	sta _16bit_nextArgument(tar)
}

.macro waitX(count) {
	ldx #count
!loop:
	dex
	bne !loop-
}

.macro getRandom(delay) {
	lda #$ff  //; maximum frequency value
	sta $d40e //; voice 3 frequency low byte
	sta $d40f //; voice 3 frequency high byte
	lda #$80  //; noise waveform, gate bit off
	sta $d412 //; voice 3 control register
	ldx #delay
!delay:
	dex
	bne !delay-
	lda $d41b //; get the actual random number
}

.macro setupInterrupt(irq, scanline) {
	sei        //disable maskable IRQs

	lda #$7f
	sta $dc0d  //disable timer interrupts which can be generated by the two CIA chips
	sta $dd0d  //the kernal uses such an interrupt to flash the cursor and scan the keyboard, so we better stop it.

	lda $dc0d  //by reading this two registers we negate any pending CIA irqs.
	lda $dd0d  //if we don't do this, a pending CIA irq might occur after we finish setting up our irq. We don't want that to happen.

	lda #$01   //this is how to tell the VICII to generate a raster interrupt
	sta $d01a

	lda #<scanline   //this is how to tell at which rasterline we want the irq to be triggered
	sta $d012

	lda #>scanline   //as there are more than 256 rasterlines, the topmost bit of $d011 serves as
	beq clear
set:
	lda $d011
	ora #$80
	sta $d011
	jmp cont
clear:
	lda $d011
	and #$7f
	sta $d011
	
cont:
	lda #$35   //we turn off the BASIC and KERNAL rom here
	sta $01    //the cpu now sees RAM everywhere except at $d000-$e000, where still the registers of SID/VICII/etc are visible

	lda #<irq  //this is how we set up
	sta $fffe  //the address of our interrupt code
	lda #>irq
	sta $ffff
	lda #<nmi
	sta $fffa
	lda #>nmi
	sta $fffb
	cli        //enable maskable interrupts again
	jmp finish
nmi:
	rti
finish:
}

.macro startInterrupt() {
	pha
	txa
	pha
	tya
	pha

	lda #$ff   //this is the orthodox and safe way of clearing the interrupt condition of the VICII.
	sta $d019
}

.macro doubleIRQ(rasterline) {
	// rasterline is the y pos of the raster of the 1st of 2 double irq lines
////////////////////// Stabalize me baby
	:mov #<!irq2+: $fffe
	inc $d012
	
	tsx
	cli
	//these nops never really finish due to the raster IRQ triggering again
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
//---------------------------------------------------------------------------------------------------------------------
!irq2:
	txs
	ldx #$08
	dex
	bne *-1
	bit $ea
	nop

	lda #rasterline+1
	cmp $d012
	beq !cont+
!cont:	//////////////////////	the raster is now stable! \o/
}

.macro endInterrupt() {
	pla
	tay        //restore register Y from stack (remember stack is FIFO: First In First Out)
	pla
	tax        //restore register X from stack
	pla        //restore register A from stack
	rti
}

.macro fill_1K(val, mem) {
	ldx #$00
	lda #val
loop:
	sta mem,x
	sta mem+$100,x
	sta mem+$200,x
	sta mem+$300,x
	dex
	bne loop
}

.macro fill_2K(val, mem) {
	ldx #$00
	lda #val
loop:
	sta mem,x
	sta mem+$100,x
	sta mem+$200,x
	sta mem+$300,x
	sta mem+$400,x
	sta mem+$500,x
	sta mem+$600,x
	sta mem+$700,x
	dex
	bne loop
}

.macro fill_4K(val, mem) {
	ldx #$00
	lda #val
loop:
	sta mem,x
	sta mem+$100,x
	sta mem+$200,x
	sta mem+$300,x
	sta mem+$400,x
	sta mem+$500,x
	sta mem+$600,x
	sta mem+$700,x
	sta mem+$800,x
	sta mem+$900,x
	sta mem+$a00,x
	sta mem+$b00,x
	sta mem+$c00,x
	sta mem+$d00,x
	sta mem+$e00,x
	sta mem+$f00,x
	dex
	bne loop
}

.macro fill_8K(val, mem) {
	ldx #$00
	lda #val
loop:
	sta mem,x
	sta mem+$100,x
	sta mem+$200,x
	sta mem+$300,x
	sta mem+$400,x
	sta mem+$500,x
	sta mem+$600,x
	sta mem+$700,x
	sta mem+$800,x
	sta mem+$900,x
	sta mem+$a00,x
	sta mem+$b00,x
	sta mem+$c00,x
	sta mem+$d00,x
	sta mem+$e00,x
	sta mem+$f00,x
	sta mem+$1000,x
	sta mem+$1100,x
	sta mem+$1200,x
	sta mem+$1300,x
	sta mem+$1400,x
	sta mem+$1500,x
	sta mem+$1600,x
	sta mem+$1700,x
	sta mem+$1800,x
	sta mem+$1900,x
	sta mem+$1a00,x
	sta mem+$1b00,x
	sta mem+$1c00,x
	sta mem+$1d00,x
	sta mem+$1e00,x
	sta mem+$1f00,x
	dex
	bne loop
}

.macro setBank(bank) {
	lda $dd00
	and #%11111100
	ora #[3-bank] 
	sta $dd00
}

.macro setD018bmp(screen, bmp) {
	lda #[[screen*16]+[bmp*8]]
	sta $d018
}

.macro setD018char(screen, char) {
	lda #[[screen*16]+[char*2]]
	sta $d018
}

.macro setD011(bmp, rsel, yscroll) {
	lda $d011
	and #%11010000
	ora #[bmp*32] + [[rsel^1]*8] + yscroll
	sta $d011
}

.macro setD016(mcol, csel, xscroll) {
	lda $d016
	and #%11100000
	ora #[mcol*16] + [[csel^1]*8] + xscroll
	sta $d016	
}

//new ones added from Kick src
.function screenToD018(addr) {
	.return ((addr&$3fff)/$400)<<4
}
.function charsetToD018(addr) {
	.return ((addr&$3fff)/$800)<<1
}
.function toD018(screen, charset) {
	.return screenToD018(screen) | charsetToD018(charset)
}

.function toSpritePtr(addr) {
	.return (addr&$3fff)/$40
}

//sinus libs
.function sinus(i, amplitude, center, noOfSteps) {
	.return round(center+amplitude*sin(toRadians(i*360/noOfSteps)))	
}

.function cosinus(i, amplitude, center, noOfSteps) {
	.return round(center+amplitude*cos(toRadians(i*360/noOfSteps)))	
}

.macro equalCharPack(filename, screenAdr, charsetAdr) {
	.var charMap = Hashtable()
	.var charNo = 0
	.var screenData = List()
	.var charsetData = List()
	.var pic = LoadPicture(filename)

	// Graphics should fit in 8x8 Single collor / 4 x 8 Multi collor blocks
	.var PictureSizeX = pic.width/8
	.var PictureSizeY = pic.height/8

	.for (var charY=0; charY<PictureSizeY; charY++) {
		.for (var charX=0; charX<PictureSizeX; charX++) {
			.var currentCharBytes = List()
			.var key = ""
			.for (var i=0; i<8; i++) {
				.var byteVal = pic.getSinglecolorByte(charX, charY*8 + i)
				.eval key = key + toHexString(byteVal) + ","
				.eval currentCharBytes.add(byteVal)
			}
			.var currentChar = charMap.get(key)
			.if (currentChar == null) {
				.eval currentChar = charNo
				.eval charMap.put(key, charNo)
				.eval charNo++
				.for (var i=0; i<8; i++) {
					.eval charsetData.add(currentCharBytes.get(i))
				}
			}
			.eval screenData.add(currentChar)
		}
	}
	.pc = screenAdr "screen"
	.fill screenData.size(), screenData.get(i)
	.pc = charsetAdr "charset"
	.fill charsetData.size(), charsetData.get(i)
}

.macro packer(filename) {
	/*
	Format:
	byte 1: equal char packing byte
	byte 2... data
	packed data format:
	byte 1: equal char packing byte 
	byte 2: >freq
	byte 3: <freq
	byte 4: byte

	end bytes:
	$ff $ff

	*/
    .const FILE_TEMPLATE = "C64FILE"
	.var freq = 0
	.var this_char = 0
	.var last_char = 0
	.var screenData = List()
	.var data = LoadBinary(filename, FILE_TEMPLATE)
	.var hist = List(256)
	.var tmp = 0

	.for (var i=0;i<256; i++){
		.eval hist.set(i, 0)
	}

	.for (var i=0;i<data.getSize(); i++){
        .print data.get(i).number()
		.eval tmp = hist.get(data.uget(i).number())
        .eval tmp++
		.eval hist.set(data.uget(i).number(), tmp)
	}
	// This logic basically says, equal_pack_char is zero unless we can find another char that is unused
	.var equal_pack_char = 0
	.for (var i=0; i<256;i++){
		.if(hist.get(i).number() == 0){
			.eval equal_pack_char = i
    	}
	}
	// First byte is always the RLE sentinel
	.eval screenData.add(equal_pack_char)
	.for (var i=0; i<data.getSize(); i++){
		.eval this_char = data.uget(i)
		.if (freq > 0){
			.if(this_char == last_char){
				// another equal char
				.eval freq++
			} else {
				.if ((freq > 4) || (last_char == equal_pack_char)){
					//dump rle code and reset (force if you are output RLE code)
					.eval screenData.add(equal_pack_char)
					.eval screenData.add(>freq)
					.eval screenData.add(<freq)
					.eval screenData.add(last_char)
				} else {
					//insert chars manually if we don't reach the compression threshold
					.for (var i=0;i<freq;i++){
						.eval screenData.add(last_char)
					}
				}
				.eval freq = 1
				.eval last_char = this_char
			}
		}else{
			.eval freq = 1
			.eval last_char = this_char
		}
	}
	.if ((freq > 4) || (last_char == equal_pack_char)){
		//dump rle code and reset (force if you are output RLE code)
		.eval screenData.add(equal_pack_char)
		.eval screenData.add(>freq)
		.eval screenData.add(<freq)
		.eval screenData.add(last_char)
	} else {
		//insert chars manually if we don't reach the compression threshold
		.for (var i=0;i<freq;i++){
			.eval screenData.add(last_char)
		}
	}
	.eval screenData.add(equal_pack_char)
	.eval screenData.add($ff)
	.eval screenData.add($ff)
	.eval screenData.add($ff)
    .print screenData.size() 
    .fill screenData.size(), screenData.get(i)
}

.macro unpacker(){
	/*
	Perform equal-byte unpack
		x: source data lo-byte
		y: source data hi-byte
		a: destination page (hi-byte)
	*/
	jmp upk
	/*
	Enable transparency logic during unpack
		a: transparent byte
	*/
	jmp enable_transparency
	/*
	Disable transparency logic during unpack
	*/
	jmp disable_transparency
upk:	
	stx src + 1
	sty src + 2
	sta dst + 2
	lda #$00
	sta dst + 1
	jsr read
	sta sentinel + 1 // this is the sentinel char
loop:
	jsr read
sentinel:
	cmp #$00
	beq unpack
	jsr write
	jmp loop
unpack:
	jsr read
	tay // hi byte
	cpy #$ff
	beq finish
	jsr read
	tax // lo byte
	jsr read //byte to write
ip_loop:
	jsr write
	dex
	cpx #$00
	bne ip_loop
	cpy #$00
	beq loop
	dey
	jmp ip_loop
finish:
	rts
enable_transparency:
	sta w_trans_enable + 1
	lda #$c9
	sta w_trans_enable
	lda #$f0
	sta w_trans_enable + 2
	lda #$03
	sta w_trans_enable + 3
	rts
disable_transparency:
	lda #$ea
	sta w_trans_enable
	sta w_trans_enable + 1
	sta w_trans_enable + 2
	sta w_trans_enable + 3
	rts

read:
src:
	lda $ffff
	inc src + 1
	bne !+
	inc src + 2
!:	rts

write:
w_trans_enable:
	cmp #$66
	beq w_trans
dst:	
	sta $ffff
w_trans:
	inc dst + 1
	bne !+
	inc dst + 2
!:	rts

}
