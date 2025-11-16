 .text
    .global main                           // export main() so linker can find program entry
    .extern printf                         // printf is provided by libc
    .extern scanf                          // scanf is provided by libc
    .extern clock_gettime                 //we call clock_gettime() from libc

//Constants
.equ MONO_CLOCK, 1                        // CLOCK_MONOTONIC = 1 (for clock_gettime)
// timespec layout (two 64-bit fields)
.equ TS_SEC_OFF,   0                      // offset of tv_sec  (seconds)
.equ TS_NSEC_OFF,  8                      // offset of tv_nsec (nanoseconds)
.equ TS_SIZE,     16                      // sizeof(struct timespec) = 16 bytes

main:
    // Prologue
    stp     x29, x30, [sp, -96]!         // Save frame pointer & LR, and reserve stack space (ADDED: bigger frame for 2 timespecs)
    mov     x29, sp                      // Set up frame pointer
    stp     x19, x20, [sp, 16]           // Save x19/x20 (we use them across calls)

    // Prompt user and read n (unsigned long)
    ldr     x0, =prompt                  // Load address of "Enter a number: "
    bl      printf                       // Print the prompt

    ldr     x0, =fmt_u                   // Load address of "%lu"
    ldr     x1, =n                       // x1 = &n
    bl      scanf                        // Read the number
    cmp     w0, #1                       // Did scanf read exactly 1 item?
    b.ne    bad_input                    // If not, print error and exit

    ldr     x19, =n                      // Load variable n into x19 (we use x19 for n)
    ldr     x19, [x19]

    // n < 2  → not prime (fast path, no timing since there's no heavy work)
    mov     x0, #2                      // x0 = 2 (the smallest prime)
    cmp     x19, x0                     // compare n (in x19) with 2
    b.lo    print_not_prime_no_timing   // if n < 2, branch to fast no-timing path

    // i = 2 
    mov     x20, #2

    // Start timing with clock_gettime(CLOCK_MONOTONIC)
    mov     x0, #MONO_CLOCK              // arg0 = CLOCK_MONOTONIC
    add     x1, x29, #32                 // arg1 = &t0 (our start timespec on the stack)
    bl      clock_gettime                // record t0

// Trial division loop: check divisors i where (i*i) <= n
loop_check:
    // if (i*i > n) → n is prime
    mul     x21, x20, x20                // x21 = i*i
    cmp     x21, x19
    b.gt    is_prime

    // Compute r = n % i using hardware divide 
    udiv    x23, x19, x20                // x23 = n / i (quotient)
    msub    x22, x23, x20, x19           // x22 = n - (x23 * i)  (remainder)
    cbz     x22, not_prime               // if remainder == 0 → divisible → not prime

    add     x20, x20, #1                 // i++
    b       loop_check

// Not prime path
not_prime:
    // Stop timing right after we know the result
    mov     x0, #MONO_CLOCK
    add     x1, x29, #48                 // &t1 (end timespec)
    bl      clock_gettime                // record t1

    // Print the result first
    ldr     x0, =msg_not                //x0 = address of msg_not format string
    mov     x1, x19                     // x1 = n (the user-keyed input value)
    bl      printf                      // call printf(msg_not, n)

    b       show_elapsed_ms              // jump to compute & display elapsed time

// Prime path
is_prime:
    // Stop timing
    mov     x0, #MONO_CLOCK             // x0 = CLOCK_MONOTONIC (constant defined above)
    add     x1, x29, #48                // x1 = &t1 (end timespec at FP + 48)
    bl      clock_gettime               // call clock_gettime(MONO_CLOCK, &t1)

    // Print the result first
    ldr     x0, =msg_prime              // x0 = address of msg_prime format string
    mov     x1, x19                     // x1 = n, the original input number
    bl      printf                      // printf(msg_prime, n)

    b       show_elapsed_ms             // jump to timing display code

// Compute and print elapsed milliseconds from t0, t1
// us = (t1.sec - t0.sec)*1e6 + (t1.nsec - t0.nsec)/1e3
show_elapsed_ms:
    // seconds diff → x2
    ldr     x2, [x29, #48 + TS_SEC_OFF]  // t1.tv_sec
    ldr     x3, [x29, #32 + TS_SEC_OFF]  // t0.tv_sec
    sub     x2, x2, x3                   // x2 = (t1 - t0).sec

    // nanoseconds diff → x4
    ldr     x4, [x29, #48 + TS_NSEC_OFF] // t1.tv_nsec
    ldr     x5, [x29, #32 + TS_NSEC_OFF] // t0.tv_nsec
    sub     x4, x4, x5                   // x4 = (t1 - t0).nsec

    // Convert seconds to double in d0 and scale by 1000 (sec → ms)
    scvtf   d0, x2                       // d0 = (double)seconds
    ldr     x6, =k_1000
    ldr     d1, [x6]
    fmul    d0, d0, d1                   // d0 *= 1000.0

    // Convert nanoseconds to double in d2 and scale by 1e-6 (nsec → ms)
    scvtf   d2, x4                       // d2 = (double)nanoseconds
    ldr     x6, =k_1e_minus6
    ldr     d3, [x6]
    fmul    d2, d3, d2                   // d2 = d3 * d2 = 1e-6 * nsec

    // total ms in d0
    fadd    d0, d0, d2                   // d0 = sec(ms) + nsec(ms)

    // Print timing line; printf expects the double in d0 for %f
    ldr     x0, =fmt_time
    bl      printf

    b       done

// Fast path: n < 2  → not prime (no timing printed)
print_not_prime_no_timing:
    ldr     x0, =msg_not                // x0 = address of "not prime" format string
    mov     x1, x19                     // x1 = n (user-keyed number)
    bl      printf                      // print the message
    b       done                        // skip timing logic and exit

// Bad input handling
bad_input:
    ldr     x0, =msg_bad                // x0 = address of invalid-input message
    bl      printf                      // print the error message 

// Epilogue
done:
    ldp     x19, x20, [x29, 16]         // restore saved regs
    ldp     x29, x30, [x29], 96         // tear down frame and return
    ret

// Data (strings + constants + n)
    .section .rodata
    .align  3
fmt_u:      .asciz  "%lu"
prompt:     .asciz  "Enter a number: "
msg_prime:  .asciz  "The keyed-in number %lu is a prime number\n"
msg_not:    .asciz  "The keyed-in number %lu is not a prime number\n"
msg_bad:    .asciz  "Invalid input.\n"
fmt_time:   .asciz  "[Timing] Prime check executed in %.3f microseconds\n"

    .align  3
k_1000:       .double 1000000.0       // sec → microseconds
k_1e_minus6:  .double 0.001           // nsec → microseconds (1e-3)

    .bss
    .align  3
n:          .skip   8                   // storage for input n (unsigned long)
