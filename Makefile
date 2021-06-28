#
#MAKEFILE FOR Q!D!64!
#Copyright 2019 Zig/Defame
#
SHELL := /bin/bash

help: ## This help
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"

all: disk.d64

install: ## Install dependencies (miniconda) and create conda environment
		bin/miniconda.sh
		bin/setup.sh

test: ## Run Python unit tests
		bin/run.sh nose2 test

tinn-fe/src/fe.prg: tinn-fe/src/fe.asm
		kick $<

tinn-fe/src/demo.prg:  tinn-fe/src/demo.asm ## compile c64 demo
		kick $<

disk.d64: tinn-fe/src/demo.prg ## create complete c64 disk demo
		c1541 -format "defame,2a" d64 $@
		c1541 -attach $@ -write tinn-fe/src/demo.prg "start" 
		c1541 -attach $@ -write tinn-fe/src/greets.prg "01"
		c1541 -attach $@ -write tinn-fe/src/noter.prg "02"
# 		c1541 -attach $@ -write tinn-fe/src/demo.prg "q!d!64! by defame" 
# 		c1541 -attach $@ -write tinn-fe/src/intro.prg "01"
# 		c1541 -attach $@ -write tinn-fe/rsrc/e000-music.prg "02"
# 		c1541 -attach $@ -write tinn-fe/rsrc/logo.prg "03"
# 		c1541 -attach $@ -write tinn-fe/rsrc/brain.prg "04"
#		c1541 -attach $@ -write rsrc/readme.prg "invitro readme!"

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

build_screens: ## make the screen datafiles using petscii packer
		kick data/screens.asm
		kick data/packer.asm
		mv data/col01_packed.prg tinn-fe/rsrc/col01_packed.prg
		mv data/col02_packed.prg tinn-fe/rsrc/col02_packed.prg
		mv data/col03_packed.prg tinn-fe/rsrc/col03_packed.prg
		mv data/col04_packed.prg tinn-fe/rsrc/col04_packed.prg
		mv data/col05_packed.prg tinn-fe/rsrc/col05_packed.prg
		mv data/col06_packed.prg tinn-fe/rsrc/col06_packed.prg
		mv data/col07_packed.prg tinn-fe/rsrc/col07_packed.prg
		mv data/col08_packed.prg tinn-fe/rsrc/col08_packed.prg
		mv data/scr01_packed.prg tinn-fe/rsrc/scr01_packed.prg
		mv data/scr02_packed.prg tinn-fe/rsrc/scr02_packed.prg
		mv data/scr03_packed.prg tinn-fe/rsrc/scr03_packed.prg
		mv data/scr04_packed.prg tinn-fe/rsrc/scr04_packed.prg
		mv data/scr05_packed.prg tinn-fe/rsrc/scr05_packed.prg
		mv data/scr06_packed.prg tinn-fe/rsrc/scr06_packed.prg
		mv data/scr07_packed.prg tinn-fe/rsrc/scr07_packed.prg
		mv data/scr08_packed.prg tinn-fe/rsrc/scr08_packed.prg
		rm data/col01.prg
		rm data/col02.prg
		rm data/col03.prg
		rm data/col04.prg
		rm data/col05.prg
		rm data/col06.prg
		rm data/col07.prg
		rm data/col08.prg
		rm data/scr01.prg
		rm data/scr02.prg
		rm data/scr03.prg
		rm data/scr04.prg
		rm data/scr05.prg
		rm data/scr06.prg
		rm data/scr07.prg
		rm data/scr08.prg
