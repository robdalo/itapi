.globl framebuffer_init

framebuffer_init:
    xRes .req r0
    yRes .req r1
    bitDepth .req r2
    configAddress .req r3
    adjustedConfigAddress .req r4
    channel .req r5
    response .req r6

    push {lr}

    // configure screen resolution
    ldr configAddress, =framebuffer_config
    str xRes, [configAddress, #0]
    str yRes, [configAddress, #4]
    str xRes, [configAddress, #8]
    str yRes, [configAddress, #12]
    str bitDepth, [configAddress, #20]

    // adjust config address and set channel
    add adjustedConfigAddress, configAddress, #0x40000000
    mov channel, #1

    // write framebuffer request to mailbox
    push {xRes, yRes, bitDepth, configAddress, adjustedConfigAddress}
    mov r0, adjustedConfigAddress
    mov r1, channel
    bl mailbox_write
    pop {xRes, yRes, bitDepth, configAddress, adjustedConfigAddress}
    
    // read framebuffer request response from mailbox
    push {xRes, yRes, bitDepth, configAddress, adjustedConfigAddress}
    mov r0, channel
    bl mailbox_read
    mov response, r0
    pop {xRes, yRes, bitDepth, configAddress, adjustedConfigAddress}
    
    // check request was successful
    teq response, #0
    movne r0, #0
    bne led_debug
    // bne framebuffer_init_finally$

    ldr r0, =framebuffer_config
    
    framebuffer_init_finally$:
    
        // unassign variable names
        .unreq xRes
        .unreq yRes
        .unreq bitDepth
        .unreq configAddress
        .unreq adjustedConfigAddress
        .unreq channel
        .unreq response

        pop {lr}
        mov pc, lr

.globl framebuffer_test

framebuffer_test:
    configAddress .req r0
    framebuffer .req r1
    xRes .req r2
    yRes .req r3
    bitDepth .req r4
    x .req r5
    y .req r6
    colour .req r7

    push {lr}

    // framebuffer config
    ldr xRes, =1920 // x resolution
    ldr yRes, =1080 // y resolution
    ldr bitDepth, =16 // bit depth

    // initiate framebuffer
    push {xRes, yRes, bitDepth}
    mov r0, xRes
    mov r1, yRes
    mov r2, bitDepth
    bl framebuffer_init
    teq configAddress, #0
    beq framebuffer_init_error$
    pop {xRes, yRes, bitDepth}

    // render test graphics to framebuffer
    render$:
        ldr framebuffer, [configAddress, #32]
        mov y, yRes
        mov colour, #7
        drawRow$:
            mov x, xRes
            drawPixel$:
                strh colour, [framebuffer]
                add framebuffer, #2
                sub x, #1
                teq x, #0
                bne drawPixel$
            sub y, #1
            teq y, #0
            bne drawRow$
        b render$

    // unassign variable names
    .unreq configAddress
    .unreq framebuffer
    .unreq xRes
    .unreq yRes
    .unreq bitDepth
    .unreq x
    .unreq y
    .unreq colour

    pop {lr}
    mov pc, lr

    framebuffer_init_error$:
        bl led_debug

.section .data

.align 4

.globl framebuffer_config

framebuffer_config:
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
