help:
	@echo 'For convenience'
	@echo
	@echo 'Available make targets:'
	@grep PHONY: Makefile | cut -d: -f2 | sed '1d;s/^/make/'


AS = as
LD = ld
OBJCOPY = objcopy
OBJDUMP = objdump

bootblocks = hello guess

HELLO_STARTADDR = $(shell \
	objdump -M intel -d hello.elf | \
	nice grep '<start>' | \
	awk '{print "0x"$$1}' \
	2> /dev/null)
GUESS_STARTADDR = $(shell \
	objdump -M intel -d guess.elf | \
	nice grep '<start>' | \
	awk '{print "0x"$$1}' \
	2> /dev/null)

$(bootblocks) : % : %.elf
	$(OBJCOPY) -O binary $< $@

%.elf: %.o
	$(LD) -N -e start -Ttext 0x7C00 $< -o $@

%.o: %.s
	$(AS) $< -o $@


.PHONY: qemu-hello          # boot to hello using qemu
qemu-hello: hello
	qemu-system-i386 -hda hello --nographic


.PHONY: qemu-guess	          # boot to guess using qemu
qemu-guess: guess
	qemu-system-i386 -hda guess --nographic


.PHONY: qemu-gdb-hello      # boot to hello using qemu in debug mode
qemu-gdb-hello: hello
	qemu-system-i386 -hda hello --nographic -s -S

.PHONY: qemu-gdb-guess       # boot to guess using qemu in debug mode
qemu-gdb-guess: guess
	qemu-system-i386 -hda guess --nographic -s -S

.PHONY: gdb-guess            # connect to qemu when running in debug mode (for guess)
gdb-guess: guess
	gdb -ex 'target remote localhost:1234' \
			-ex 'b *$(GUESS_STARTADDR)' \
			-ex 'c'

.PHONY: gdb-hello           # connect to qemu when running in debug mode (for hello)
gdb-hello: hello
	gdb -ex 'target remote localhost:1234' \
			-ex 'b *$(HELLO_STARTADDR)' \
			-ex 'c'

.PHONY: clean               # clean up build environment
clean:
	rm -f *.elf *.o $(bootblocks)