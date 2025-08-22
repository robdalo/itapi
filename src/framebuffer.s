.globl framebuffer_init

framebuffer_init:
    width .req r0
    height .req r1
    bit_depth .req r2

    framebuffer_container .req r3
    channel .req r4
    response .req r5

    push {lr}

    // configure screen resolution
    ldr framebuffer_container, =framebuffer_container_current
    str width, [framebuffer_container, #0]
    str height, [framebuffer_container, #4]
    str width, [framebuffer_container, #8]
    str height, [framebuffer_container, #12]
    str bit_depth, [framebuffer_container, #20]

    // adjust framebuffer container address for consumption by gpu
    // set mailbox channel
    add framebuffer_container, #0x40000000
    mov channel, #1

    // write framebuffer request to mailbox
    push {channel}
    mov r0, framebuffer_container
    mov r1, channel
    bl mailbox_write
    pop {channel}
    
    // read framebuffer request response from mailbox
    push {channel}
    mov r0, channel
    bl mailbox_read
    mov response, r0
    pop {channel}
    
    // check request was successful
    teq response, #0
    movne r0, #0
    bne framebuffer_init_finally$

    ldr r0, =framebuffer_container_current
    
    framebuffer_init_finally$:

        .unreq width
        .unreq height
        .unreq bit_depth

        .unreq framebuffer_container
        .unreq channel
        .unreq response

        pop {lr}
        mov pc, lr  

.globl framebuffer_test

framebuffer_test:
    width .req r0
    height .req r1
    bit_depth .req r2
    framebuffer_container .req r3
    framebuffer .req r4
    x .req r5
    y .req r6
    colour .req r7

    push {lr}

    // framebuffer config
    ldr width, =1920 // x axis
    ldr height, =1080 // y axis
    ldr bit_depth, =16 // bit depth

    // initiate framebuffer
    push {width, height}
    mov r0, width
    mov r1, height
    mov r2, bit_depth
    bl framebuffer_init
    mov framebuffer_container, r0
    teq framebuffer_container, #0
    beq framebuffer_test_error$
    pop {width, height}

    // render test pixels to framebuffer
    render$:
        ldr framebuffer, [framebuffer_container, #32]
        mov y, height
        mov colour, #7
        draw_row$:
            mov x, width
            draw_pixel$:
                strh colour, [framebuffer]
                add framebuffer, #2
                sub x, #1
                teq x, #0
                bne draw_pixel$
            sub y, #1
            teq y, #0
            bne draw_row$
        b render$

    .unreq width
    .unreq height
    .unreq bit_depth
    .unreq framebuffer_container
    .unreq framebuffer    
    .unreq x
    .unreq y
    .unreq colour

    pop {lr}
    mov pc, lr

    framebuffer_test_error$:
        bl led_debug

.section .data

.align 4

.globl framebuffer_container_current

framebuffer_container_current:
    .int 0 // 0 - width
    .int 0 // 4 - height
    .int 0 // 8 - virtual width
    .int 0 // 12 - virtual height
    .int 0 // 16 - gpu pitch
    .int 0 // 20 - bit depth
    .int 0 // 24 - x
    .int 0 // 28 - y
    .int 0 // 32 - gpu pointer
    .int 0 // 36 - gpu size
