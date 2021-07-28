#
#MAKEFILE FOR Q!D!64!
#Copyright 2019 Zig/Defame
#
SHELL := /bin/bash

help: ## This help
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"

all: clean disk.d64 ## clean up and make the disk image

install: ## Install dependencies (miniconda) and create conda environment
		bin/miniconda.sh
		bin/setup.sh

test: ## Run Python unit tests
		bin/run.sh nose2 test

tinn-fe/src/demo.prg:  tinn-fe/src/demo.asm ## compile c64 demo
		kick $<

disk.d64: tinn-fe/src/demo.prg ## create complete c64 disk demo
		c1541 -format "defame,2a" d64 $@
		cd tinn-fe/src;wine ~/Applications/exomizer-3.1.0/win32/exomizer.exe sfx basic -n demo.prg 
		c1541 -attach $@ -write tinn-fe/src/a.out "start" 
		c1541 -attach $@ -write tinn-fe/src/greets.prg "01"
		c1541 -attach $@ -write tinn-fe/src/noter.prg "02"
		c1541 -attach $@ -write tinn-fe/src/draw.prg "03"
# 		c1541 -attach $@ -write tinn-fe/src/demo.prg "q!d!64! by defame" 
# 		c1541 -attach $@ -write tinn-fe/src/intro.prg "01"
# 		c1541 -attach $@ -write tinn-fe/rsrc/e000-music.prg "02"
# 		c1541 -attach $@ -write tinn-fe/rsrc/logo.prg "03"
# 		c1541 -attach $@ -write tinn-fe/rsrc/brain.prg "04"
#		c1541 -attach $@ -write rsrc/readme.prg "invitro readme!"

clean: ## Clean up
		rm tinn-fe/src/*.sym tinn-fe/src/*.prg *.d64

run:	disk.d64 ## run the d64
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

build_screens: ## make the screen datafiles using petscii packer
		kick tinn-fe/ui//screens.asm
		kick tinn-fe/ui/packer.asm
		mv tinn-fe/ui/col01_packed.prg tinn-fe/rsrc/col01_packed.prg
		mv tinn-fe/ui/col02_packed.prg tinn-fe/rsrc/col02_packed.prg
		mv tinn-fe/ui/col03_packed.prg tinn-fe/rsrc/col03_packed.prg
		mv tinn-fe/ui/col04_packed.prg tinn-fe/rsrc/col04_packed.prg
		mv tinn-fe/ui/col05_packed.prg tinn-fe/rsrc/col05_packed.prg
		mv tinn-fe/ui/col06_packed.prg tinn-fe/rsrc/col06_packed.prg
		mv tinn-fe/ui/col07_packed.prg tinn-fe/rsrc/col07_packed.prg
		mv tinn-fe/ui/col08_packed.prg tinn-fe/rsrc/col08_packed.prg
		mv tinn-fe/ui/col09_packed.prg tinn-fe/rsrc/col09_packed.prg
		mv tinn-fe/ui/col10_packed.prg tinn-fe/rsrc/col10_packed.prg
		mv tinn-fe/ui/scr01_packed.prg tinn-fe/rsrc/scr01_packed.prg
		mv tinn-fe/ui/scr02_packed.prg tinn-fe/rsrc/scr02_packed.prg
		mv tinn-fe/ui/scr03_packed.prg tinn-fe/rsrc/scr03_packed.prg
		mv tinn-fe/ui/scr04_packed.prg tinn-fe/rsrc/scr04_packed.prg
		mv tinn-fe/ui/scr05_packed.prg tinn-fe/rsrc/scr05_packed.prg
		mv tinn-fe/ui/scr06_packed.prg tinn-fe/rsrc/scr06_packed.prg
		mv tinn-fe/ui/scr07_packed.prg tinn-fe/rsrc/scr07_packed.prg
		mv tinn-fe/ui/scr08_packed.prg tinn-fe/rsrc/scr08_packed.prg
		mv tinn-fe/ui/scr09_packed.prg tinn-fe/rsrc/scr09_packed.prg
		mv tinn-fe/ui/scr10_packed.prg tinn-fe/rsrc/scr10_packed.prg
		rm tinn-fe/ui/col01.prg
		rm tinn-fe/ui/col02.prg
		rm tinn-fe/ui/col03.prg
		rm tinn-fe/ui/col04.prg
		rm tinn-fe/ui/col05.prg
		rm tinn-fe/ui/col06.prg
		rm tinn-fe/ui/col07.prg
		rm tinn-fe/ui/col08.prg
		rm tinn-fe/ui/col09.prg
		rm tinn-fe/ui/col10.prg
		rm tinn-fe/ui/scr01.prg
		rm tinn-fe/ui/scr02.prg
		rm tinn-fe/ui/scr03.prg
		rm tinn-fe/ui/scr04.prg
		rm tinn-fe/ui/scr05.prg
		rm tinn-fe/ui/scr06.prg
		rm tinn-fe/ui/scr07.prg
		rm tinn-fe/ui/scr08.prg
		rm tinn-fe/ui/scr09.prg
		rm tinn-fe/ui/scr10.prg

train_mnist: ##train mnist
		bin/run.sh main.py "data/mnist.data" "tinn-fe/rsrc/mnist.asm"

convert: ##convert quick draw files into training dataset
		bin/run.sh convert.py "data" "data"

train_qd: ##train quick draw dataset
		bin/run.sh main.py "data/training.data" "tinn-fe/rsrc/qd.asm"
