#include <stdint.h>

#define COM1_TRANSMIT_PORT   0x3F8
#define COM1_STATUS_PORT     0x3FD
#define UART_TRANSMIT_READY  (1u << 5)

void outb(uint8_t value, uint16_t address) {
    __asm__ volatile ("outb %0, %1" : : "a"(value), "d"(address));
}

uint8_t inb(uint16_t address) {
    uint8_t value;
    __asm__ volatile ("inb %1, %0" : "=a"(value) : "d"(address));
    return value;
}

static void serial_write(const char *text) {
    while (*text) {
        while (!(inb(COM1_STATUS_PORT) & UART_TRANSMIT_READY)) {}
        outb((uint8_t)*text, COM1_TRANSMIT_PORT);
        text++;
    }
}

// Our bootloader enters here in 64-bit mode with a stack already set up.
__attribute__((section(".text.entry")))
void kmain(void) {
    serial_write("Welcome to alex os\r\n");
}
