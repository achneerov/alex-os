SECTIONS
{
    .text : {
        *(.text.entry)
        *(.text)
        *(.rodata*)
    }
    .pad 511 : { BYTE(0) }
}
