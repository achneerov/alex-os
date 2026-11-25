CC := clang
LD := $(shell command -v ld.lld 2>/dev/null || echo /opt/homebrew/opt/lld/bin/ld.lld)
TARGET := --target=i386-unknown-none-elf -m16
CFLAGS := -ffreestanding -O2

.PHONY: run
run:
	mkdir -p build
	$(CC) $(TARGET) -c boot.S -o build/boot.o
	$(LD) --image-base=0 -Ttext=0x7c00 --oformat=binary build/boot.o -o build/boot.bin
	$(CC) $(TARGET) $(CFLAGS) -c kernel.c -o build/kernel.o
	$(LD) -T linker.ld --oformat=binary build/kernel.o -o build/kernel.bin
	cat build/boot.bin build/kernel.bin > build/alex-os.img
	qemu-system-x86_64 -accel tcg -m 128M -drive format=raw,file=build/alex-os.img \
	    -display none -serial mon:stdio -no-reboot -no-shutdown
