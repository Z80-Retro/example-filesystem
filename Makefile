# Make 'all' first so that it is THE default target.
#
# The :: means that if there is more than one of the same target name 
# then process all the occurrences one after the other.

all:: disk.img

# assume that there will be one .com file that is built for each .asm file
SRC=$(wildcard progs/*/*.asm)
PROGS=$(SRC:%.asm=%.com)
PROG_DIRS=$(sort $(dir $(SRC)))

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


# files to overwrite onto CP/M drive D 
burn3: disk3.img
	@ if [ -z "$(PROGS3)" ]; then\
		echo "PROGS3 is empty, nothing to do!"; \
		false; \
	fi
	@ if [ `hostname` != "$(SD_HOSTNAME)" -o ! -b "$(SD_DEV)" ]; then\
		echo "\nWARNING: You are either NOT logged into $(SD_HOSTNAME) or there is no $(SD_DEV) mounted!\n"; \
		false; \
	fi
	sudo dd if=$< of=$(SD_DEV) bs=512 seek=3x16384 conv=fsync
disk3.img: $(PROGS3)
	@ if [ -z "$(PROGS3)" ]; then\
		echo "PROGS3 is empty, nothing to do!"; \
		false; \
	fi
	rm -f $@
	mkfs.cpm -f $(DISKDEF) $@
	cpmcp -f $(DISKDEF) $@ $^ 0:
ls:: disk3.img
	cpmls -f $(DISKDEF) disk3.img

# files to overwrite onto CP/M drive B
burn1: disk1.img
	@ if [ -z "$(PROGS1)" ]; then\
		echo "PROGS1 is empty, nothing to do!"; \
		false; \
	fi
	@ if [ `hostname` != "$(SD_HOSTNAME)" -o ! -b "$(SD_DEV)" ]; then\
		echo "\nWARNING: You are either NOT logged into $(SD_HOSTNAME) or there is no $(SD_DEV) mounted!\n"; \
		false; \
	fi
	sudo dd if=$< of=$(SD_DEV) bs=512 seek=1x16384 conv=fsync
disk1.img: $(PROGS1)
	@ if [ -z "$(PROGS1)" ]; then\
		echo "PROGS1 is empty, nothing to do!"; \
		false; \
	fi
	rm -f $@
	mkfs.cpm -f $(DISKDEF) $@
	cpmcp -f $(DISKDEF) $@ $^ 0:
ls:: disk1.img
	cpmls -f $(DISKDEF) disk1.img


%.com: %.asm
	make -C $(dir $@) $(notdir $@)

clean:
	rm -f disk.img disk3.img disk1.img
	for i in $(PROG_DIRS); do make -C $$i clean; done


world: clean all
