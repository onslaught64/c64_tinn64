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

tinn-fe/src/demo.prg:  tinn-fe/src/demo.asm
		kick $<

disk.d64: tinn-fe/src/fe.prg tinn-fe/src/demo.prg
		c1541 -format "defame,2a" d64 $@
		c1541 -attach $@ -write tinn-fe/src/fe.prg "test-front-end" 
# 		c1541 -attach $@ -write tinn-fe/src/demo.prg "q!d!64! by defame" 
# 		c1541 -attach $@ -write tinn-fe/src/intro.prg "01"
# 		c1541 -attach $@ -write tinn-fe/rsrc/e000-music.prg "02"
# 		c1541 -attach $@ -write tinn-fe/rsrc/logo.prg "03"
# 		c1541 -attach $@ -write tinn-fe/rsrc/brain.prg "04"
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
