# Make 'all' first so that it is THE default target.
#
# The :: means that if there is more than one of the same target name 
# then process all the occurrences one after the other.

all:: disk.img

# assume that there will be one .com file that is built for each .asm file
SRC=$(wildcard progs/*/*.asm)
PROGS=$(SRC:%.asm=%.com)
PROG_DIRS=$(dir $(PROGS))

TOP=.

# include things that might be of interest to more than just this Makefile
include $(TOP)/Make.default
-include $(TOP)/Make.local		# The - on this means ignore it if the file does not exist

burn: disk.img
	@ if [ `hostname` != "$(SD_HOSTNAME)" -o ! -b "$(SD_DEV)" ]; then\
		echo "\nWARNING: You are either NOT logged into $(SD_HOSTNAME) or there is no $(SD_DEV) mounted!\n"; \
		false; \
	fi
	sudo dd if=$< of=$(SD_DEV) bs=512 seek=$(DISK_SLOT)x16384 conv=fsync

ls:: disk.img
	cpmls -f $(DISKDEF) disk.img


disk.img: $(PROGS)
	rm -f $@
	mkfs.cpm -f $(DISKDEF) $@
	cpmcp -f $(DISKDEF) $@ $^ 0:

#progs/example/test1.com:
#	make -C progs/example all

#progs/nhacp/nt.com:
#	make -C progs/nhacp all

#progs/example/test1.com:
#	make -C `dirname $@` all

%.com: %.asm
	make -C $(dir $@) all

clean:
	rm -f disk.img
	for i in $(sort $(PROG_DIRS)); do make -C $$i clean; done


world: clean all
