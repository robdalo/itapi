.section .text

terminal_get_font_address:
    offset .req r0

    baseAddress .req r1

    push {lr}

    ldr baseAddress, =terminal_font_vga_8x16
    ldr r0, [baseAddress, offset]

    .unreq offset

    .unreq baseAddress

    pop {lr}
    mov pc, lr

terminal_draw_char_pixel:
    x .req r0
    y .req r1
    colour .req r2

    framebuffer_container .req r3
    terminal_row .req r4
    terminal_column .req r5

    push {lr}

    // get framebuffer and current position of terminal cursor
    ldr framebuffer_container, =framebuffer_container_current
    ldr terminal_row, =terminal_row_current
    ldr terminal_column, =terminal_column_current
    ldr terminal_row, [terminal_row]
    ldr terminal_column, [terminal_column]

    // account for 16 pixels per char on the y-axis
    // and 8 pixels per char on the x-axis
    lsl terminal_row, #4 // multiply by 16
    lsl terminal_column, #3 // multiply by 8   

    // add current position of terminal cursor
    add y, terminal_row, y
    add x, terminal_column, x

    // add margin
    add y, #40
    add x, #40

    // draw pixel
    bl drawing_draw_pixel

    pop {lr}
    mov pc, lr

terminal_next_column:
    terminal_column_limit .req r0
    terminal_column_current .req r1
    terminal_column .req r2

    push {lr}

    ldr terminal_column_limit, =240
    ldr terminal_column_current, =terminal_column_current
    ldr terminal_column, [terminal_column_current]
    
    add terminal_column, #1
    teq terminal_column, terminal_column_limit
    bleq terminal_next_row
    bleq terminal_next_column_finally$
    
    str terminal_column, [terminal_column_current]

    terminal_next_column_finally$:

        .unreq terminal_column_limit
        .unreq terminal_column_current
        .unreq terminal_column

        pop {lr}
        mov pc, lr

.globl terminal_next_row

terminal_next_row:
    terminal_column_current .req r0
    terminal_column .req r1
    terminal_row_current .req r2
    terminal_row .req r3

    push {lr}

    ldr terminal_column_current, =terminal_column_current
    ldr terminal_column, [terminal_column_current]
    ldr terminal_row_current, =terminal_row_current
    ldr terminal_row, [terminal_row_current]
    
    add terminal_row, #1
    mov terminal_column, #0

    str terminal_column, [terminal_column_current]
    str terminal_row, [terminal_row_current]

    .unreq terminal_column_current
    .unreq terminal_column
    .unreq terminal_row_current
    .unreq terminal_row

    pop {lr}
    mov pc, lr

terminal_print_char:
    ascii_code .req r0

    offset .req r1
    char .req r2
    byte .req r3
    char_x_pixel .req r4
    char_y_pixel .req r5
    bitmask .req r6
    temp .req r7

    push {lr}

    lsl offset, ascii_code, #4 // multiply by 16

    ldr char, =terminal_font_vga_8x16
    add char, offset

    mov offset, #0
    mov char_y_pixel, #0

    char_y_pixel_loop$:

        ldrb byte, [char, offset]
        mov char_x_pixel, #0

        char_x_pixel_loop$:
            mov bitmask, #1
            lsl bitmask, char_x_pixel
            tst byte, bitmask
            beq char_x_pixel_loop_finally$

            // put in parameters
            push {offset, char, byte, char_x_pixel, char_y_pixel}
            mov temp, #7
            sub char_x_pixel, temp, char_x_pixel
            mov r0, char_x_pixel // x
            mov r1, char_y_pixel // y
            ldr r2, =0xffff // white
            bl terminal_draw_char_pixel
            pop {offset, char, byte, char_x_pixel, char_y_pixel}

            char_x_pixel_loop_finally$:
                add char_x_pixel, #1
                teq char_x_pixel, #8
                bne char_x_pixel_loop$
        
        add offset, #1
        add char_y_pixel, #1
        teq char_y_pixel, #16
        bne char_y_pixel_loop$

    // move terminal cursor
    bl terminal_next_column

    .unreq ascii_code

    .unreq offset
    .unreq char
    .unreq byte
    .unreq char_x_pixel
    .unreq char_y_pixel
    .unreq bitmask
    .unreq colour
    .unreq temp

    pop {lr}
    mov pc, lr    

.globl terminal_print_string

terminal_print_string:
    string_address .req r0

    offset .req r1
    ascii_code .req r2

    push {lr}

    mov offset, #0
    ldrb ascii_code, [string_address, offset]
    teq ascii_code, #0
    beq terminal_print_string_finally$

    loop$:
        push {string_address, offset}
        mov r0, ascii_code
        bl terminal_print_char
        pop {string_address, offset}

        add offset, #1
        ldrb ascii_code, [string_address, offset]
        teq ascii_code, #0
        bne loop$

    terminal_print_string_finally$:

        .unreq string_address

        .unreq offset
        .unreq ascii_code

        pop {lr}
        mov pc, lr

.globl terminal_test

terminal_test:
    width .req r0
    height .req r1
    bit_depth .req r2
    framebuffer_container .req r3
    ascii_code .req r4
    ascii_code_end .req r5

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
    beq terminal_test_error$
    pop {width, height, bit_depth}

    // draw characters

    ldr r0, =constant_welcome_message
    bl terminal_print_string

    // move to next line
    bl terminal_next_row

    ldr r0, =constant_ascii_test_message
    bl terminal_print_string

    // move to next line
    bl terminal_next_row

    // perform ascii character test    

    ldr ascii_code, =33 // 33 ASCII character '!'
    ldr ascii_code_end, =255 // 255 * 16

    $loop:
        push {ascii_code, ascii_code_end}
        mov r0, ascii_code
        bl terminal_print_char
        pop {ascii_code, ascii_code_end}
        add ascii_code, #1
        cmp ascii_code, ascii_code_end
        bls $loop

    // move to next line
    bl terminal_next_row

    ldr r0, =constant_ascii_test_complete_message
    bl terminal_print_string        

    .unreq width
    .unreq height
    .unreq bit_depth
    .unreq framebuffer_container
    .unreq ascii_code
    .unreq ascii_code_end

    pop {lr}
    mov pc, lr

    terminal_test_error$:
        bl led_debug

.section .data

.align 4

terminal_row_current:
    .int 0

terminal_column_current:
    .int 0

terminal_font_vga_8x16:
    .incbin "vga_8x16.bin"
