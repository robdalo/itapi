gpio_get_address:
    ldr r0, =0x20200000
    mov pc, lr

.globl gpio_set_function

gpio_set_function:
    pinNum .req r0
    pinFunc .req r1
    pinFuncAddress .req r2
    temp .req r3

    push {lr}

    // validate inputs
    cmp pinNum, #53
    cmpls pinFunc, #7
    bhi gpio_set_function_finally$

    // get gpio base address
    push {pinNum}
    bl gpio_get_address
    mov pinFuncAddress, r0
    pop {pinNum}
    
    // get address for gpio pin function
    mov temp, pinNum
    loop$:
        cmp temp, #9
        subhi temp, #10
        addhi pinFuncAddress, #4
        bhi loop$

    // configure gpio pin function
    add temp, temp, lsl #1
    lsl pinFunc, temp
    str pinFunc, [pinFuncAddress]

    // unassign variable names
    .unreq pinNum
    .unreq pinFunc
    .unreq pinFuncAddress
    .unreq temp

    gpio_set_function_finally$:
        pop {lr}
        mov pc, lr

.globl gpio_set

gpio_set:
    pinNum .req r0
    pinVal .req r1
    pinBank .req r2
    gpioAddress .req r3
    bitset .req r4

    push {lr}

    // validate input
    cmp pinNum, #53
    bhi gpio_set_finally$

    // get gpio base address
    push {pinNum}
    bl gpio_get_address
    mov gpioAddress, r0
    pop {pinNum}

    // get the gpio pin bank
    lsr pinBank, pinNum, #5
    lsl pinBank, #2
    add gpioAddress, pinBank

    // get bit set
    and pinNum, #31
    mov bitset, #1
    lsl bitset, pinNum

    // set or clear gpio pin
    teq pinVal, #0
    streq bitset, [gpioAddress, #40]
    strne bitset, [gpioAddress, #28]

    .unreq pinNum
    .unreq pinVal
    .unreq pinBank
    .unreq gpioAddress
    .unreq bitset

    gpio_set_finally$:
        pop {lr}
        mov pc, lr
