// BIOS loads this sector at 0x7c00. The next 32 sectors hold the kernel.
.intel_syntax noprefix
.section .text
.code16
.global _start
_start:
    .byte 0xea                // Far jump to segment 0, real_mode.
    .word real_mode, 0
real_mode:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    cld
    sti

    // DL holds the boot drive. Read the kernel to physical address 0x10000.
    mov si, offset disk_packet
    mov ah, 0x42
    int 0x13
    jc disk_error
    cli

    // Enable A20 so addresses above 1 MiB don't wrap around.
    in al, 0x92
    or al, 2
    and al, 0xfe
    out 0x92, al
    lgdt [gdt_pointer]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    .byte 0xea                // Far jump to 32-bit code selector.
    .word protected_mode, 0x08

disk_error:
    mov ax, 0x0e45             // Display 'E' if the disk read fails.
    xor bx, bx
    int 0x10
    cli
1:  hlt
    jmp 1b

.code32
protected_mode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax

    // Map the first GiB to identical physical addresses with 2 MiB pages.
    // The three page tables live at 0x1000, 0x2000 and 0x3000.
    mov edi, 0x1000
    xor eax, eax
    mov ecx, 3072
    rep stosd
    mov dword ptr [0x1000], 0x2003
    mov dword ptr [0x2000], 0x3003
    mov edi, 0x3000
    mov eax, 0x83
    mov ecx, 512
map_page:
    stosd
    add edi, 4                // Upper 32 bits are already zero.
    add eax, 0x200000
    loop map_page

    mov eax, cr4
    or eax, 1 << 5            // Enable physical address extensions.
    mov cr4, eax
    mov eax, 0x1000
    mov cr3, eax
    mov ecx, 0xc0000080       // EFER model-specific register.
    rdmsr
    or eax, 1 << 8            // Enable long mode.
    wrmsr
    mov eax, cr0
    or eax, 0x80000000        // Enable paging.
    mov cr0, eax
    .byte 0xea                // Far jump to 64-bit code selector.
    .long long_mode
    .word 0x18

.code64
long_mode:
    mov rsp, 0x90000
    mov eax, 0x10000
    call rax                 // Run the kernel, then halt when it returns.
2:  cli
    hlt
    jmp 2b

.balign 8
gdt:
    .quad 0
    .quad 0x00cf9a000000ffff // 0x08: 32-bit code.
    .quad 0x00cf92000000ffff // 0x10: data.
    .quad 0x00af9a000000ffff // 0x18: 64-bit code.
gdt_pointer:
    .word . - gdt - 1
    .long gdt

.balign 4
disk_packet:
    .byte 16, 0
    .word 32                 // Number of sectors to load.
    .word 0, 0x1000          // Offset 0, segment 0x1000.
    .quad 1                  // Start after this boot sector.

.org 510
.word 0xaa55                 // BIOS boot signature.
