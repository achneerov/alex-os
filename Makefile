CC := clang
LD := $(shell command -v ld.lld 2>/dev/null || echo /opt/homebrew/opt/lld/bin/ld.lld)
CFLAGS := --target=x86_64-unknown-none-elf -ffreestanding -fno-stack-protector \
          -fno-pic -fno-pie -mno-red-zone -mgeneral-regs-only \
          -fno-asynchronous-unwind-tables -std=c11 -O2 -Wall -Wextra -Werror

.PHONY: all run clean
all: build/alex-os.img

build:
	mkdir -p build

build/boot.bin: boot.S | build
	$(CC) --target=x86_64-unknown-none-elf -c $< -o build/boot.o
	$(LD) --image-base=0 -Ttext=0x7c00 --oformat=binary -e _start build/boot.o -o $@

build/kernel.bin: kernel.c linker.ld | build
	$(CC) $(CFLAGS) -c kernel.c -o build/kernel.o
	$(LD) -T linker.ld --oformat=binary build/kernel.o -o $@

build/alex-os.img: build/boot.bin build/kernel.bin
	dd if=/dev/zero of=$@ bs=512 count=33
	dd if=build/boot.bin of=$@ conv=notrunc
	dd if=build/kernel.bin of=$@ bs=512 seek=1 conv=notrunc

run: build/alex-os.img
	qemu-system-x86_64 -accel tcg -m 128M -drive format=raw,file=$< \
	    -display none -serial mon:stdio -no-reboot -no-shutdown

clean:
	rm -rf build
