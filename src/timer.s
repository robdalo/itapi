.section .text

.globl timer_wait

timer_wait:
    time .req r0

    timer_address .req r1
    lower .req r2
    upper .req r3
    limit .req r4

    push {lr}

    // get base address
    ldr timer_address, =timer_base_address
    ldr timer_address, [timer_address]
    
    // get end time
    ldrd lower, upper, [timer_address, #4]
    add limit, lower, time

    // loop until end time reached
    loop$:
        ldrd lower, upper, [timer_address, #4]
        cmp lower, limit
        blt loop$

    .unreq time
    
    .unreq timer_address
    .unreq lower
    .unreq upper
    .unreq limit

    pop {lr}
    mov pc, lr

.section .rodata

timer_base_address:
    .int 0x20003000
