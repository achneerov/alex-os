.intel_syntax noprefix
    mov sp, 0x7c00
    mov si, offset disk_packet
    mov ah, 0x42
    int 0x13
    mov ax, 0x1000
    mov ds, ax
    mov ss, ax
    mov esp, 0xfffc
    .byte 0xea
    .word 0, 0x1000

.balign 4
disk_packet:
    .byte 16, 0
    .word 1
    .word 0, 0x1000
    .quad 1

.org 510
.word 0xaa55
