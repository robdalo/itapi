.section .init

.globl _start

_start:
    b main

.section .text

main:
    // set stack pointer
    mov sp, #0x8000

    // framebuffer test
    bl framebuffer_test
