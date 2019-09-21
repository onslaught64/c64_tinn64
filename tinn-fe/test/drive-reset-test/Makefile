#
#MAKEFILE FOR Q!D!64!
#Copyright 2019 Zig/Defame
#
SPIN=../../spindle/spin

all: disk.d64

test.prg: test.asm
		kick $<

disk.d64: script test.prg 
		${SPIN} -vv -o $@ -a dirart.txt -d 0 -t "-QUICK!DRAW!64!-" -e 1000 $<
		#c1541 -attach $@ -write rsrc/readme.prg "invitro readme!"

clean:
		rm *.sym *.prg *.d64

run:	disk.d64
		x64 disk.d64 >/dev/null

