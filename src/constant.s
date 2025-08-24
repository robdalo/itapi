.section .rodata

.align 0

.globl constant_welcome_message

constant_welcome_message:
    .asciz "Welcome to itapi..."

.globl constant_ascii_test_message

constant_ascii_test_message:
    .asciz "Attempting ASCII character test..."

.globl constant_ascii_test_complete_message

constant_ascii_test_complete_message:
    .asciz "ASCII character test complete..."