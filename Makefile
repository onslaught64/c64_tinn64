#
#MAKEFILE FOR Q!D!64!
#Copyright 2019 Zig/Defame
#
CONDAENV=demo
#
#MAKEFILE FOR Q!D!64!
#Copyright 2019 Zig/Defame
#
SPIN=tinn-fe/spindle/spin

all: disk.d64

tinn-fe/src/intro.prg: tinn-fe/src/intro.asm
		kick $<

tinn-fe/src/fe.prg: tinn-fe/src/fe.asm
		kick $<

disk.d64: tinn-fe/script tinn-fe/src/fe.prg tinn-fe/src/intro.prg
		${SPIN} -vv -o $@ -a tinn-fe/dirart.txt -d 0 -t "-QUICK!DRAW!64!-" -e 1000 $<
		#c1541 -attach $@ -write rsrc/readme.prg "invitro readme!"

clean:
		rm tinn-fe/src/*.sym tinn-fe/src/*.prg *.d64

run:	disk.d64
		x64 disk.d64 >/dev/null

test-layout:
		kick tinn-fe/test/test-layout.asm
		x64 tinn-fe/test/test-layout.prg

test-math:
		kick tinn-fe/test/test-math.asm
		x64 tinn-fe/test/test-layout.prg

test-nn:
		kick tinn-fe/test/test-nn.asm
		x64 tinn-fe/test/test-layout.prg

cats:
		bin/cats.sh ${CONDAENV}

mnist:
		bin/mnist.sh ${CONDAENV}

quckdraw:
		bin/quickdraw.sh ${CONDAENV}

