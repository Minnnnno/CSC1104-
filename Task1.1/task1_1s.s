    .text
    .global main
    .extern printf
    .extern scanf

main:
    //  Prologue (function setup)
    stp     x29, x30, [sp, -32]!        // Save frame pointer (x29) & return address (x30) onto stack
    mov     x29, sp                     // Establish new frame pointer for current stack frame
    stp     x19, x20, [sp, 16]          // Save registers x19 and x20 for later restoration (used for n, i)

    //  Prompt user for input 
    ldr     x0, =prompt                 // Load address of prompt string "Enter a number: " into x0 (1st arg)
    bl      printf                      // Call printf(prompt)

    // Read input using scanf("%lu", &n)
    ldr     x0, =fmt_u                  // Load address of format string "%lu" into x0 (1st arg)
    ldr     x1, =n                      // Load address of variable n into x1 (2nd arg)
    bl      scanf                       // Call scanf("%lu", &n)
    cmp     w0, #1                      // Compare scanf return value with 1 (success means 1 value read)
    b.ne    bad_input                   // If not equal, branch to bad_input (invalid input)

    //  Load n into register 
    ldr     x19, =n                     // Load address of n into x19
    ldr     x19, [x19]                  // Load actual value of n into x19

    //  Check if (n < 2)
    mov     x0, #2                      // Load 2 into x0
    cmp     x19, x0                     // Compare n with 2
    b.lo    not_prime                   // If n < 2 → branch to not_prime

    //  Initialize i = 2 
    mov     x20, #2                     // Set i = 2 (we’ll test divisibility starting from 2)

// 
// Loop: while (i * i <= n)
//          if (n % i == 0) → not prime
// 

loop_check:
    // Compute i*i and compare with n
    mul     x21, x20, x20               // x21 = i * i
    cmp     x21, x19                    // Compare (i*i) with n
    b.gt    is_prime                    // If i*i > n → no divisors found, number is prime

    // Compute remainder manually 
    //but here we division by repeated subtraction
    mov     x22, x19                    // Copy n into x22 (n_copy)
rem_loop:
    cmp     x22, x20                    // Compare n_copy with i
    b.lt    rem_done                    // If n_copy < i, remainder found
    sub     x22, x22, x20               // n_copy -= i  (subtract divisor repeatedly)
    b       rem_loop                    // Loop until remainder < i

rem_done:
    cbz     x22, not_prime              //If remainder == 0 → divisible → not prime

    // Increment i and repeat loop 
    add     x20, x20, #1                // i++
    b       loop_check                  // Repeat the check with next i


// If loop exits → number is prime 
is_prime:
    ldr     x0, =msg_prime              // Load address of "The keyed-in number ... is a prime number\n"
    mov     x1, x19                     // Move n into x1 (printf argument)
    bl      printf                      // Call printf(msg_prime, n)
    b       done                        // Jump to function exit


// Not a prime number
not_prime:
    ldr     x0, =msg_not                // Load address of "The keyed-in number ... is not a prime number\n"
    mov     x1, x19                     // Move n into x1 (printf argument)
    bl      printf                      // Call printf(msg_not, n)
    b       done                        // Jump to function exit


//Bad input handler
bad_input:
    mov     w0, #1                      // Return 1 to indicate invalid input
    ldp     x19, x20, [sp, 16]          // Restore saved registers
    ldp     x29, x30, [sp], 32          // Restore frame pointer & return address; pop stack
    ret                                 // Return to caller


//Function exit (normal return) 
done:
    mov     w0, #0                      // Return 0 (successful)
    ldp     x19, x20, [sp, 16]          // Restore registers x19, x20
    ldp     x29, x30, [sp], 32          // Restore frame pointer & link register
    ret                                 // Return to caller


// 
// Data Section (strings and variables)
// 
    .section .rodata
    .align  3
fmt_u:      .asciz  "%lu"               // Format string for unsigned long input
prompt:     .asciz  "Enter a number: "  // Input prompt for user
msg_prime:  .asciz  "The keyed-in number %lu is a prime number\n"
msg_not:    .asciz  "The keyed-in number %lu is not a prime number\n"

    .bss
    .align  3
n:          .skip   8                   // Reserve 8 bytes in memory for variable n
