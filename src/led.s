.section .text

led_configure:
    pin_number .req r0
    pin_function .req r1

    push {lr}

    // set gpio pin 16 to output function
    mov pin_number, #16
    mov pin_function, #1
    bl gpio_set_function

    .unreq pin_number
    .unreq pin_function

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
    pin_number .req r0
    pin_value .req r1

    push {lr}

    // turn led off
    mov pin_number, #16
    mov pin_value, #1
    bl gpio_set

    .unreq pin_number
    .unreq pin_value

    pop {lr}
    mov pc, lr

led_on:
    pin_number .req r0
    pin_value .req r1

    push {lr}

    // turn led on
    mov pin_number, #16
    mov pin_value, #0
    bl gpio_set

    .unreq pin_number
    .unreq pin_value

    pop {lr}
    mov pc, lr
