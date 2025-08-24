.section .text

gpio_get_address:
    ldr r0, =0x20200000
    mov pc, lr

.globl gpio_set_function

gpio_set_function:
    pin_number .req r0
    pin_function .req r1

    pin_function_address .req r2
    temp .req r3

    push {lr}

    // validate inputs
    cmp pin_number, #53
    cmpls pin_function, #7
    bhi gpio_set_function_finally$

    // get gpio base address
    push {pin_number}
    bl gpio_get_address
    mov pin_function_address, r0
    pop {pin_number}
    
    // get address for gpio pin function
    mov temp, pin_number
    loop$:
        cmp temp, #9
        subhi temp, #10
        addhi pin_function_address, #4
        bhi loop$

    // configure gpio pin function
    add temp, temp, lsl #1
    lsl pin_function, temp
    str pin_function, [pin_function_address]

    .unreq pin_number
    .unreq pin_function

    .unreq pin_function_address
    .unreq temp

    gpio_set_function_finally$:
        pop {lr}
        mov pc, lr

.globl gpio_set

gpio_set:
    pin_number .req r0
    pin_value .req r1

    pin_bank .req r2
    gpio_address .req r3
    bitset .req r4

    push {lr}

    // validate input
    cmp pin_number, #53
    bhi gpio_set_finally$

    // get gpio base address
    push {pin_number}
    bl gpio_get_address
    mov gpio_address, r0
    pop {pin_number}

    // get the gpio pin bank
    lsr pin_bank, pin_number, #5
    lsl pin_bank, #2
    add gpio_address, pin_bank

    // get bit set
    and pin_number, #31
    mov bitset, #1
    lsl bitset, pin_number

    // set or clear gpio pin
    teq pin_value, #0
    streq bitset, [gpio_address, #40]
    strne bitset, [gpio_address, #28]

    .unreq pin_number
    .unreq pin_value
    
    .unreq pin_bank
    .unreq gpio_address
    .unreq bitset

    gpio_set_finally$:
        pop {lr}
        mov pc, lr
