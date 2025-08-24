.section .text

timer_get_address:
    ldr r0, =0x20003000
    mov pc, lr

.globl timer_wait

timer_wait:
    time .req r0

    timer_address .req r1
    lower .req r2
    upper .req r3
    limit .req r4

    push {lr}

    // get timer base address
    push {time}
    bl timer_get_address
    mov timer_address, r0
    pop {time}

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
