.section .text

.globl drawing_draw_pixel

drawing_draw_pixel:
    x .req r0
    y .req r1
    colour .req r2
    framebuffer_container .req r3

    width .req r4
    height .req r5
    bit_depth .req r6
    framebuffer .req r7
    offset .req r8

    // get framebuffer resolution
    ldr width, [framebuffer_container, #0]
    ldr height, [framebuffer_container, #4]
    ldr bit_depth, [framebuffer_container, #20]
    ldr framebuffer, [framebuffer_container, #32]

    // get pixel offset
    // (x + (y * width)) * pixel size
    mla offset, y, width, x
    lsl offset, #1

    // set pixel
    strh colour, [framebuffer, offset]

    .unreq x
    .unreq y
    .unreq colour
    .unreq framebuffer_container

    .unreq width
    .unreq height
    .unreq bit_depth
    .unreq framebuffer
    .unreq offset

    mov pc, lr

.globl drawing_draw_square

drawing_draw_square:
    x .req r0
    y .req r1
    colour .req r2
    width .req r3
    framebuffer_container .req r4

    x_max .req r5
    y_max .req r6
    y_start .req r7

    push {lr}

    // calculate limits
    add x_max, x, width
    add y_max, y, width

    mov y_start, y

    // draw square
    x_axis_loop$:
        
        mov y, y_start

        y_axis_loop$:
            
            push {x, y, colour, framebuffer_container, x_max, y_max, y_start}
            mov r3, framebuffer_container
            bl drawing_draw_pixel
            pop {x, y, colour, framebuffer_container, x_max, y_max, y_start}

            add y, #1
            cmp y, y_max
            bne y_axis_loop$

        add x, #1
        cmp x, x_max
        bne x_axis_loop$

    .unreq x
    .unreq y
    .unreq colour
    .unreq width
    .unreq framebuffer_container

    .unreq x_max
    .unreq y_max
    .unreq y_start

    pop {lr}
    mov pc, lr

.globl drawing_test

drawing_test:
    x .req r0
    y .req r1
    colour .req r2
    x_max .req r3
    y_max .req r4
    width .req r5
    height .req r6
    bit_depth .req r7
    framebuffer_container .req r8

    push {lr}

    // framebuffer config
    ldr width, =1920 // x resolution
    ldr height, =1080 // y resolution
    ldr bit_depth, =16 // bit depth

    // initiate framebuffer
    push {width, height, bit_depth}
    mov r0, width
    mov r1, height
    mov r2, bit_depth
    bl framebuffer_init
    mov framebuffer_container, r0
    teq framebuffer_container, #0
    beq drawing_test_error$
    pop {width, height, bit_depth}

    mov colour, #0

    $loop:
        // draw square
        ldr r0, =710 // x
        ldr r1, =290 // y
        mov r2, colour
        ldr r3, =500 // width
        mov r4, framebuffer_container
        push {colour, framebuffer_container}
        bl drawing_draw_square
        pop {colour, framebuffer_container}

        // wait
        ldr r0, =0xf4240 // 1 second delay
        push {colour, framebuffer_container}
        bl timer_wait
        pop {colour, framebuffer_container}

        // change colour
        add colour, #2048 // red
        add colour, #32 // green
        add colour, #1 // blue

        b $loop

    .unreq x
    .unreq y
    .unreq colour
    .unreq x_max
    .unreq y_max
    .unreq width
    .unreq height
    .unreq bit_depth
    .unreq framebuffer_container

    pop {lr}
    mov pc, lr

    drawing_test_error$:
        bl led_debug
