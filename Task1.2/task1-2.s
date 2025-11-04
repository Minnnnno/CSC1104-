    .data
list:       .word 5, 19, 7, -20, 2025      @ the list of numbers
len:        .word 5                        @ length of list
msg:        .asciz " is the largest number\n"
fmt:        .asciz "%d%s"

    .text
    .global main
main:
    push    {lr}                           @ save link register

    ldr     r0, =list                      @ r0 = address of list
    ldr     r1, =len
    ldr     r1, [r1]                       @ r1 = length (5)
    ldr     r2, [r0]                       @ r2 = largest = list[0]
    mov     r3, #1                         @ i = 1

loop:
    cmp     r3, r1                         @ while (i < length)
    bge     done

    ldr     r4, [r0, r3, LSL #2]           @ r4 = list[i]
    cmp     r4, r2                         @ compare list[i] > largest
    ble     skip
    mov     r2, r4                         @ largest = list[i]
skip:
    add     r3, r3, #1
    b       loop

done:
    @ print result using printf("%d%s", largest, msg)
    ldr     r0, =fmt
    mov     r1, r2
    ldr     r2, =msg
    bl      printf

    pop     {lr}
    bx      lr
