ENTRY(kmain)

SECTIONS
{
    /* Load 32 sectors (16 KiB) at this address. */
    . = 0x10000;
    .text : { *(.text.entry) *(.text .text.*) }
    .rodata : { *(.rodata .rodata.*) }
    .data : { *(.data .data.*) }
    .bss : { *(.bss .bss.*) *(COMMON) }
    ASSERT(. <= 0x14000, "Kernel exceeds the bootloader's 16 KiB limit")
    /DISCARD/ : { *(.eh_frame*) *(.note*) *(.comment*) }
}
