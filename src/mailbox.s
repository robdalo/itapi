mailbox_get_address:
    ldr r0, =0x2000b880
    mov pc, lr

.globl mailbox_read

mailbox_read:
    channel .req r0
    mail .req r1
    mailboxAddress .req r2
    status .req r3
    temp .req r4

    push {lr}

    // get mailbox address
    push {channel}
    bl mailbox_get_address
    mov mailboxAddress, r0
    pop {channel}

    read_message$:

        // wait for mailbox read status to be OK before reading
        // ready to read is indicated by bit 30 being set to 0, not 1
        wait_read_status$:
            ldr status, [mailboxAddress, #24]
            tst status, #0x40000000
            bne wait_read_status$

        // read message from mailbox
        // discard messages where mailbox channel does not match
        ldr mail, [mailboxAddress, #0]
        and temp, mail, #0xf
        teq channel, temp
        bne read_message$

    // channel matches, get message
    mvn temp, temp
    and r0, mail, temp

    // unassign variable names
    .unreq channel
    .unreq mail
    .unreq mailboxAddress
    .unreq status
    .unreq temp

    pop {lr}
    mov pc, lr

.globl mailbox_write

mailbox_write:
    message .req r0
    channel .req r1
    mail .req r2
    mailboxAddress .req r3
    status .req r4

    push {lr}

    // upper 28 bits represent message
    // lower 4 bits represent mailbox channel
    add mail, message, channel

    // get mailbox address
    push {message}
    bl mailbox_get_address
    mov mailboxAddress, r0
    pop {message}

    // wait for mailbox send status to be OK before sending
    // ready to write is indicated by bit 31 being set to 0, not 1
    wait_write_status$:
        ldr status, [mailboxAddress, #24]
        tst status, #0x80000000
        bne wait_write_status$

    // write message to mailbox
    str mail, [mailboxAddress, #32]

    // unassign variable names
    .unreq message
    .unreq channel
    .unreq mail
    .unreq mailboxAddress
    .unreq status

    pop {lr}
    mov pc, lr
