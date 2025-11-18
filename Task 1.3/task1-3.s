    .data
prompt:     .asciz "Enter a number: "         // Input prompt
fmt:        .asciz "%d"                       // scanf format for int
msg_yes:    .asciz "There are two numbers in the list summing to the keyed-in number %d\n"      // Format string for key found printf
msg_no:     .asciz "There are no two numbers in the list summing to the keyed-in number %d\n"   // Format string for key unfound printf
time_fmt:   .asciz "Execution time: %.6f ms\n"  // Format string for the execution time printf

    .align 3                                // 8-byte alignment for .quad
NS_PER_SEC: .quad 1000000000                // 1,000,000,000 ns in one second
NS_PER_MS_D:.double 1000000.0               // 1,000,000 ns in one millisecond

    .align 2
list:   .word 1, 4, 7, 10, 15               // 4-byte aligned ints


    .text                                   // Start of the code (text) section
    .global main                            // Declare 'main' as a global
    .type main, %function                   // Mark 'main' as a function symbol
    .extern printf, scanf, clock_gettime    // printf, scanf, clock_gettimg from libc

main:
    stp     x29, x30, [sp, -16]!            // Save old frame pointer (x29) and return addr (x30) on stack
    mov     x29, sp                         // Establish new frame pointer

    sub     sp, sp, #48                     // Reserve 48 bytes (16-byte aligned) for locals

    // Initialise found = 0
    mov     w0, #0                          // w0 = 0
    str     w0, [sp, #8]                    // found = 0 (at [sp+8])
    
    //=========PROMPT USER===========
    adrp    x0, prompt                      // x0 = high address part of "Enter a number: "
    add     x0, x0, :lo12:prompt            // x0 = &prompt
    bl      printf                          // printf("Enter a number: ")

    //=========READ USER INPUT========
    adrp    x0, fmt                         // x0 = high part of "%d"
    add     x0, x0, :lo12:fmt               // 0 = &"%d"
    mov     x1, sp                          // x1 = &key (store key at [sp])
    bl      scanf                           // scanf("%d", &key)

    //=========START TIMER===========
    // int clock_gettime(clockid_t clk_id, struct timespec *tp);
    mov     w0, #1                          // w0 = CLOCK_MONOTONIC
    add     x1, sp, #16                     // x1 = &start_timespec (struct timespec at [sp+16])
    bl      clock_gettime                   // clock_gettime(CLOCK_MONOTONIC, &start_ts)

    //==========SET UP FOR SEARCH======
    adrp    x4, list                        // x4 = high part of list[]
    add     x4, x4, :lo12:list              // x4 = &list[0] (base address)
    mov     w5, #5                          // w5 = len = 5
    mov     w6, #0                          // w6 = i =0 (outer loop index)

outer:                                      // outer loop: for (i=0; i < len; ++i)
    cmp     w6, w5                          // if (i >= len)
    b.ge    after_loops                     // break

    add     w7, w6, #1                      // w7 = j = i + 1 (inner loop starts after i)

inner:                                      // inner loop: for (j = i+1; j < len; ++j)
    cmp     w7, w5                          // if (j >= len)
    b.ge    next_i                          // go next i

    // Load list[i] into w1
    lsl     x1, x6, #2                      // x1 = i * 4 (byte offset; int = 4 bytes)
    ldr     w1, [x4, x1]                    // w1 = list[i]

    // Load list[j] into w2
    lsl     x2, x7, #2                      // x2 = j * 4
    ldr     w2, [x4, x2]                    // w2 = list[j]

    // sum and compare to key
    add     w3, w1, w2                      // w3 = list[i] + list[j]
    ldr     w1, [sp]                        // w1 = key (from local [sp])
    cmp     w3, w1                          // if (sum == key) ?
    b.ne    inc_j                           // if not equal, j++

    // match: printf(yes, key) and set found=1
    adrp    x0, msg_yes                     // x0 = &msg_yes (upper)
    add     x0, x0, :lo12:msg_yes           // x0 = &msg_yes
    ldr     w1, [sp]                        // w1 = key (for "%d")
    bl      printf                          // printf(msg_yes, key)

    mov     w0, #1                          // w0 = 1
    str     w0, [sp, #8]                    // found = 1
    b       done                            // break out of both loops

inc_j:                                      // j++ and continue inner loop
    add     w7, w7, #1                      // j = j + 1
    b       inner                           // continue outer loop

next_i:                                     // i++ and restart inner loop
    add     w6, w6, #1                      // i = i + 1
    b       outer                           // continue outer loop

after_loops:                                // No early match; check 'found'
    ldr     w0, [sp, #8]                    // w0 = found?
    cmp     w0, #0                          // if (found == 0)
    b.ne    done                            // skip "no" message if found != 0

    // not found: printf(no, key)
    adrp    x0, msg_no                      // x0 = &msg_no (upper)
    add     x0, x0, :lo12:msg_no            // x0 = &msg_no
    ldr     w1, [sp]                        // w1 = key
    bl      printf                          // printf(msg_no, key)

done:                                       
    //==========STOP TIMER=============
    mov     w0, #1                          // w0 = CLOCK_MONOTONIC
    add     x1, sp, #32                     // x1 = &end_timespec (struct at [sp+32])
    bl      clock_gettime                   // clock_gettime(CLOCK_MONOTONIC, &end_ts)

    //===========Diff in Nanoseconds============
    // struct timespec {long tv_sec; long tv_nsec;} (both 64-bit on AArcht64)

    // Load start timespec
    ldr     x10, [sp, #16]                  // x10 = start.tv_sec
    ldr     x11, [sp, #24]                  // x11 = start.tv_nsec

    // Load end timespec
    ldr     x12, [sp, #32]                  // x12 = end.tv_sec
    ldr     x13, [sp, #40]                  // x13 = end.tv_nsec

    // diff_sec = end.tv_sec - start.tv_sec
    sub     x14, x12, x10                   // x14 = diff_sec
    
    // diff_nsec = end.tv_nsec - start.tv_nsec
    sub     x15, x13, x11                   // x15 = diff_nsec

    // total_ns = diff_sec * 1_000_000_000 + diff_nsec
    adrp    x9, NS_PER_SEC                  // Load address of 1,000,000,000 (upper)
    add     x9, x9, :lo12:NS_PER_SEC        // x9 = &NS_PER_MS
    ldr     x9, [x9]                        // x9 = 1_000_000

    mul     x16, x14, x9                    // x16 = diff_sec * 1_000_000_000
    add     x16, x16, x15                   // x16 = total_ns 

    //===========Convert ns to fractional ms============
    scvtf   d0, x16                         // d0 = (double) total_ns
    adrp    x8, NS_PER_MS_D                 // Load address of 1,000,000 (upper)
    add     x8, x8, :lo12:NS_PER_MS_D       // x8 = &NS_PER_MS
    ldr     d1, [x8]                        // x8 = 1_000_000
    fdiv    d0, d0, d1                      // d0 = total_ns / 1e6 (ms, float)

    //============Print Execution Time============      
    adrp    x0, time_fmt                    // x0 = &"Execution timeL %lu ms\n" (upper)
    add     x0, x0, :lo12:time_fmt          // x0 = &time_fmt
    bl      printf                          // printf(time_fmt, ms)

    // Restore frame and return
    add     sp, sp, #48                     // Release local stack space
    ldp     x29, x30, [sp], #16             // Restore frame pointer and return address
    mov     w0, #0                          // return 0
    ret                                     // return to caller
