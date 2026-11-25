.intel_syntax noprefix
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    cld
    sti
    mov si, offset disk_packet
    mov ah, 0x42
    int 0x13
    jc disk_error
    cli
    cld
    mov ax, 0x1000
    mov ds, ax
    mov ss, ax
    mov esp, 0xfffc
    .byte 0xea
    .word 0, 0x1000

disk_error:
    mov ax, 0x0e45
    xor bx, bx
    int 0x10
    cli
1:  hlt
    jmp 1b

.balign 4
disk_packet:
    .byte 16, 0
    .word 1
    .word 0, 0x1000
    .quad 1

.org 510
.word 0xaa55
