led_configure:
    pinNum .req r0
    pinFunc .req r1

    push {lr}

    // set gpio pin 16 to output function
    mov pinNum, #16
    mov pinFunc, #1
    bl gpio_set_function

    // unassign variable names
    .unreq pinNum
    .unreq pinFunc

    pop {lr}
    mov pc, lr

.globl led_debug

led_debug:
    flashes .req r0
    delay .req r1

    push {lr}

    // flash led
    mov flashes, #2 // 2 flashes
    ldr delay, =0xf4240 // 1 second delay
    bl led_flash

    .unreq flashes
    .unreq delay

    pop {lr}
    mov pc, lr

.globl led_flash

led_flash:
    flashes .req r0
    delay .req r1
    decrement .req r2

    push {lr}

    // configure gpio pin
    push {flashes, delay}
    bl led_configure
    pop {flashes, delay}

    loop_outer$:
        // wait 5 seconds
        push {flashes, delay}
        ldr r0, =0x4c4b40
        bl timer_wait
        pop {flashes, delay}

        // flash led
        mov decrement, flashes
        loop_inner$:
            // turn gpio pin on
            push {flashes, delay, decrement}
            bl led_on
            pop {flashes, delay, decrement}

            // wait
            push {flashes, delay, decrement}
            mov r0, delay
            bl timer_wait
            pop {flashes, delay, decrement}

            // turn gpio pin off
            push {flashes, delay, decrement}
            bl led_off
            pop {flashes, delay, decrement}

            // wait
            push {flashes, delay, decrement}
            mov r0, delay
            bl timer_wait
            pop {flashes, delay, decrement}

            // decrement
            sub decrement, #1
            teq decrement, #0
            bne loop_inner$

        b loop_outer$

    .unreq flashes
    .unreq delay
    .unreq decrement

    pop {lr}
    mov pc, lr

led_off:
    pinNum .req r0
    pinVal .req r1

    push {lr}

    // turn led off
    mov pinNum, #16
    mov pinVal, #1
    bl gpio_set

    .unreq pinNum
    .unreq pinVal

    pop {lr}
    mov pc, lr

led_on:
    pinNum .req r0
    pinVal .req r1

    push {lr}

    // turn led on
    mov pinNum, #16
    mov pinVal, #0
    bl gpio_set

    .unreq pinNum
    .unreq pinVal

    pop {lr}
    mov pc, lr
