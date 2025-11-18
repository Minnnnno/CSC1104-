    .data
list:       .word 5, 19, 7, -20, 2025               // Define an array of 5 integers
len:        .word 5                                 // length of list
msg:        .asciz " is the largest number\n"       // Message
fmt:        .asciz "%d%s"                           // Format string for the printf ("%d%s", integer + string)
timefmt:    .asciz "Processing time: %.6f ms\n"      // Format string for the execution time printf

    .align 3                                        // 8-byte alignment for .quad
NS_PER_SEC: .quad 1000000000                        // 1,000,000,000 ns in one second
NS_PER_MS_D:  .double 1000000.0                     // 1,000,000 ns in one millisecond


    .text                                           // Start of the code (text) section
    .global main                                    // Declare 'main' as a global
    .type main, %function                           // Mark 'main' as a function symbol
    .extern printf, clock_gettime                   // printf/clock from libc
main:                                               // ========= main() entry =========
    // Prologue: create a simple frame (save FP/LR)
    stp     x29, x30, [sp, -16]!                    // Push old frame pointer (x29) and link register (x30)
    mov     x29, sp                                 // Set new frame pointer
    sub     sp, sp, #48                             // locals: start_ts[16], end_ts[16], temp[16]

    // ----------- Start timer -----------
    mov     w0, #1                                  // w0 = CLOCK_MONOTONIC
    mov     x1, sp                                  // x1 = &start_timespec
    bl      clock_gettime                           // clock_gettime(CLOCK_MONOTONIC, &start_ts)

    // ----------- Find the largest number -----------
    ldr     x0, =list                               // x0 = &list (base address of array)
    ldr     x1, =len                                // x1 = &len  (address of the length word)
    ldr     w1, [x1]                                // w1 = len value (32-bit) = number of elements
    ldr     w2, [x0]                                // w2 = list[0] = initialize 'largest' with first element
    mov     w3, #1                                  // w3 = i = 1 = loop index starts from 1 (we already used index 0)

loop:                                               // ---- loop head ----
    cmp     w3, w1                                  // Compare i vs len
    b.ge    done_loop                               // If i >= len, exit loop

    // Load list[i]: address = base + (i * 4). Use scaled register offset with UXTW 2 (zero-extend index, scale by 4)
    ldr     w4, [x0, w3, UXTW #2]                   // w4 = list[i]

    cmp     w4, w2                                  // Compare list[i] to current largest
    b.le    skip_update                             // If list[i] <= largest, skip update
    mov     w2, w4                                  // Otherwise, largest = list[i]
skip_update:
    add     w3, w3, #1                              // i++
    b       loop                                    // Continue loop

done_loop:                                          // ---- loop end ----

    // ----------- Print the largest number -----------
    ldr     x0, =fmt                                // x0 = format string "%d%s"
    // printf arg1 (x1) = largest as int
    // (For varargs, passing in x1 with the value in its low 32 bits is fine.)
    sxtw    x1, w2                                  // Sign-extend w2 to x1 (handles negative numbers properly)
    ldr     x2, =msg                                // x2 = pointer to message string
    bl      printf                                  // printf("%d%s", largest, msg)

    // ----------- Stop timer -----------
    mov     w0, #1                                  // w0 = CLOCK_MONOTONIC
    add     x1, sp, #32                             // x1 = &end_timespec (struct at [sp+32])
    bl      clock_gettime                           // clock_gettime(CLOCK_MONOTONIC, &end_ts)

    //===========Diff in Nanoseconds============
    // struct timespec {long tv_sec; long tv_nsec;} (both 64-bit on AArcht64)

    // Load start timespec
    ldr     x10, [sp, #0]                           // x10 = start.tv_sec
    ldr     x11, [sp, #8]                           // x11 = start.tv_nsec

    // Load end timespec
    ldr     x12, [sp, #32]                          // x12 = end.tv_sec
    ldr     x13, [sp, #40]                          // x13 = end.tv_nsec

    // diff_sec = end.tv_sec - start.tv_sec
    sub     x14, x12, x10                           // x14 = diff_sec
    
    // diff_nsec = end.tv_nsec - start.tv_nsec
    sub     x15, x13, x11                           // x15 = diff_nsec

    // total_ns = diff_sec * 1_000_000_000 + diff_nsec
    adrp    x9, NS_PER_SEC                          // Load address of 1,000,000,000 (upper)
    add     x9, x9, :lo12:NS_PER_SEC                // x9 = &NS_PER_MS
    ldr     x9, [x9]                                // x9 = 1_000_000

    mul     x16, x14, x9                            // x16 = diff_sec * 1_000_000_000
    add     x16, x16, x15                           // x16 = total_ns 

    //===========Convert ns to ms============
    // ms = total_ns/1_000_000
    scvtf   d0, x16                                 // convert ns (int) to double 
    adrp    x8, NS_PER_MS_D                         // Load address of 1,000,000 (upper)
    add     x8, x8, :lo12:NS_PER_MS_D               // x8 = &NS_PER_MS
    ldr     d1, [x8]                                // d1 = 1e6
    fdiv    d0, d0, d1                              // d0 = total_ns /1e6 (ms as double)

    //============Print Execution Time============      
    adrp    x0, timefmt                             // x0 = &"Execution time: %.6f ms\n" (upper)
    add     x0, x0, :lo12:timefmt                   // x0 = &time_fmt
    bl      printf                                  // printf(time_fmt, ms)

    // Restore frame and return
    add     sp, sp, #48
    ldp     x29, x30, [sp], #16                     // Pop FP/LR; adjust stack
    mov     w0, #0                                  // return 0 from main
    ret                                             // Return from mainls
