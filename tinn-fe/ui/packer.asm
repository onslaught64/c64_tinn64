/*
This is a macro for equal char packing.

*/
.macro packer(filename) {
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
        // .print data.get(i).number()
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
    //.print screenData.size() 
    .fill screenData.size(), screenData.get(i)
}
.pc = $2000
.segment Screen01_packed [outPrg="scr01_packed.prg"]
packer("scr01.prg")
.segment Screen02_packed [outPrg="scr02_packed.prg"]
packer("scr02.prg")
.segment Screen03_packed [outPrg="scr03_packed.prg"]
packer("scr03.prg")
.segment Screen04_packed [outPrg="scr04_packed.prg"]
packer("scr04.prg")
.segment Screen05_packed [outPrg="scr05_packed.prg"]
packer("scr05.prg")
.segment Screen06_packed [outPrg="scr06_packed.prg"]
packer("scr06.prg")
.segment Screen07_packed [outPrg="scr07_packed.prg"]
packer("scr07.prg")
.segment Screen08_packed [outPrg="scr08_packed.prg"]
packer("scr08.prg")
.segment Screen09_packed [outPrg="scr09_packed.prg"]
packer("scr09.prg")
.segment Screen10_packed [outPrg="scr10_packed.prg"]
packer("scr10.prg")
.segment Color01_packed [outPrg="col01_packed.prg"]
packer("col01.prg")
.segment Color02_packed [outPrg="col02_packed.prg"]
packer("col02.prg")
.segment Color03_packed [outPrg="col03_packed.prg"]
packer("col03.prg")
.segment Color04_packed [outPrg="col04_packed.prg"]
packer("col04.prg")
.segment Color05_packed [outPrg="col05_packed.prg"]
packer("col05.prg")
.segment Color06_packed [outPrg="col06_packed.prg"]
packer("col06.prg")
.segment Color07_packed [outPrg="col07_packed.prg"]
packer("col07.prg")
.segment Color08_packed [outPrg="col08_packed.prg"]
packer("col08.prg")
.segment Color09_packed [outPrg="col09_packed.prg"]
packer("col09.prg")
.segment Color10_packed [outPrg="col10_packed.prg"]
packer("col10.prg")
