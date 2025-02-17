TOP=../..
include $(TOP)/Make.default

PROGS=\
	vdp1.com\
	vdp99a.com\
	vdp99b.com\
	vdp99irq.com\
	vdpvram.com\
	vdp99m1a.com\
	anim1.com\
	text.com\
	vdp99m2a.com

ASM_FLAGS+=-I $(Z80_RETRO_CPM_REPO)/lib -I $(Z80_RETRO_CPM_REPO)/libnouveau

all: $(PROGS)

clean:
	rm -f *.lst *.bin *.com *.hex *.sym

DATE := $(shell date --rfc-3339=seconds)
GIT_VERSION := $(shell git describe --long --dirty; git show -s --format='%ci')
%.com: %.asm
	cat $< | sed -e "s/@@DATE@@/$(DATE)/g" -e "s/@@GIT_VERSION@@/$(GIT_VERSION)/g" | z80asm - -o $@ --list=$(basename $@).lst --label=$(basename $@).sym $(ASM_FLAGS)

world: clean all

