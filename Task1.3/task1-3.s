    .text
    .global main
    .type main, %function

main:
    stp     x29, x30, [sp, -16]!        // prologue
    mov     x29, sp

    sub     sp, sp, #16                 // locals: [sp] key(int), [sp+8] found(int)
    mov     w0, #0
    str     w0, [sp, #8]                // found = 0

    // printf("Enter a number: ");
    adrp    x0, prompt
    add     x0, x0, :lo12:prompt
    bl      printf

    // scanf("%d", &key);
    adrp    x0, fmt
    add     x0, x0, :lo12:fmt
    mov     x1, sp
    bl      scanf

    // list setup
    adrp    x4, list
    add     x4, x4, :lo12:list          // x4 = &list[0]
    mov     w5, #5                       // len = 5
    mov     w6, #0                       // i = 0

outer:
    cmp     w6, w5
    b.ge    after_loops

    add     w7, w6, #1                   // j = i + 1
inner:
    cmp     w7, w5
    b.ge    next_i

    lsl     x1, x6, #2
    ldr     w1, [x4, x1]                 // list[i]
    lsl     x2, x7, #2
    ldr     w2, [x4, x2]                 // list[j]
    add     w3, w1, w2                   // sum
    ldr     w1, [sp]                     // key
    cmp     w3, w1
    b.ne    inc_j

    // match: printf(yes, key) and set found=1
    adrp    x0, msg_yes
    add     x0, x0, :lo12:msg_yes
    ldr     w1, [sp]
    bl      printf
    mov     w0, #1
    str     w0, [sp, #8]
    b       done

inc_j:
    add     w7, w7, #1
    b       inner

next_i:
    add     w6, w6, #1
    b       outer

after_loops:
    ldr     w0, [sp, #8]                 // found?
    cmp     w0, #0
    b.ne    done

    // not found: printf(no, key)
    adrp    x0, msg_no
    add     x0, x0, :lo12:msg_no
    ldr     w1, [sp]
    bl      printf

done:
    add     sp, sp, #16
    ldp     x29, x30, [sp], 16
    mov     w0, #0
    ret

    .data
prompt: .asciz "Enter a number: "
fmt:    .asciz "%d"
msg_yes:.asciz "There are two numbers in the list summing to the keyed-in number %d\n"
msg_no: .asciz "There are no two numbers in the list summing to the keyed-in number %d\n"

    .align 2
list:   .word 1, 4, 7, 10, 15

    .size main, .-main
