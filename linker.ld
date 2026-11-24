SECTIONS
{
    . = 0x10000;
    .text : { *(.text.entry) *(.text .rodata*) }
}
