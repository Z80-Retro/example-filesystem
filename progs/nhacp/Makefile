TOP=../..

SUBDIRS+=\
	util

include $(TOP)/Make.default
-include $(TOP)/Make.local

ASM_FLAGS=-I$(Z80_RETRO_CPM_REPO)/lib


all:: nt.com

clean::
	rm -f *.lst *.bin *.com *.hex *.sym

DATE := $(shell date --rfc-3339=seconds)
GIT_VERSION := $(shell git describe --long --dirty; git show -s --format='%ci')
%.com: %.asm
	cat $< | sed -e "s/@@DATE@@/$(DATE)/g" -e "s/@@GIT_VERSION@@/$(GIT_VERSION)/g" | z80asm - -o $@ --list=$(basename $@).lst --label=$(basename $@).sym $(ASM_FLAGS)

