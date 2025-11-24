// ==================Header==========================================

    .text       // start of code section
    .global main    // makes the main label visible to the linker so it becomes the program's entry point; allows main to be exported and called by external code 
    .extern printf 
    .extern scanf
    .extern clock_gettime       // tells the assembler that these functions are defined elsewhere in (libc). it will be linked against them with gcc 

    .equ CLOCK_MONOTONIC, 1          // constant for clock_gettime() to get the processing time 

// -------------------- DATA --------------------
    .data       // initialized data (readable/writeable memory)
// Prompts and format strings used for printf and scanf
prompt_clk: .asciz "Enter the value of clock cycle time (in second): "  // asciz == ASCII zero terminating string (C-style strings)
prompt_c1:  .asciz "Enter the counts of type 1 instruction: "       
prompt_p1:  .asciz "Enter the CPI of type 1 instruction: "
prompt_c2:  .asciz "Enter the counts of type 2 instruction: "
prompt_p2:  .asciz "Enter the CPI of type 2 instruction: "
prompt_c3:  .asciz "Enter the counts of type 3 instruction: "
prompt_p3:  .asciz "Enter the CPI of type 3 instruction: "
prompt_c4:  .asciz "Enter the counts of type 4 instruction: "
prompt_p4:  .asciz "Enter the CPI of type 4 instruction: "
fmt_ld:     .asciz "%ld"          // format for long integers
fmt_lf:     .asciz "%lf"          // format for doubles
fmt_out:    .asciz "The execution time of this software program is %lf second.\n"
fmt_time:   .asciz "Processing time: %.6f ms\n"

// -------------------- BSS (variables) --------------------
    .bss    // section for uninitialised variables (RAM space only; not stored in file)
    .balign 8   // align the next data on an 8-byte boundary (needed for double and long) -> ensure starting address is a multiple of 8
Instruction1_count: .skip 8     // skip 8 = reserve 8 bytes for each variable eg. long Instruction1_count
Instruction2_count: .skip 8     // long Instruction2_count
Instruction3_count: .skip 8     // long Instruction3_count
Instruction4_count: .skip 8     // long Instruction4_count
CPI1:               .skip 8     // double CPI1
CPI2:               .skip 8     // double CPI2
CPI3:               .skip 8     // double CPI3
CPI4:               .skip 8     // double CPI4
Clock_cycle_time:   .skip 8     // double clock_cycle_time

// -------------------- CODE --------------------
    .text
main:       // entry point eg. int main()
    // ---------- INPUT PHASE ----------
    ldr x0, =prompt_clk     // x0 = address of string prompt_clk
    bl  printf              // call printf(promptclk)
    ldr x0, =fmt_lf         // x0 = address of fmt_lf
    ldr x1, =Clock_cycle_time   // x1 = address to store input
    bl  scanf                   // call scanf("%lf", &Clock_cycle_time)

    ldr x0, =prompt_c1      // x0 = address of prompt_c1
    bl  printf              // call printf(prompt_c1)
    ldr x0, =fmt_ld         // x0 = address of fmt_ld
    ldr x1, =Instruction1_count     // x1 = addres to store input
    bl  scanf       // call scanf("%ld", &Instruction1_count)
    ldr x0, =prompt_p1      // x0 = address of prompt_p1
    bl  printf              // call printf(prompt_p1)
    ldr x0, =fmt_lf         // x0 = address of fmt_lf
    ldr x1, =CPI1           // x1 = addres to store input
    bl  scanf               // call scanf("%lf", &CPI1)

    ldr x0, =prompt_c2      // x0 = address of prompt_c2
    bl  printf              // call printf(prompt_c2)
    ldr x0, =fmt_ld         // x0 = address of fmt_ld
    ldr x1, =Instruction2_count     // x1 = address to store input
    bl  scanf               // call scanf("%ld", &Instruction2_count)
    ldr x0, =prompt_p2      // x0 = address of prompt_p2
    bl  printf              // call printf(prompt_p2)
    ldr x0, =fmt_lf         // x0 = address of fmt_lf
    ldr x1, =CPI2           // x1 = address to store input
    bl  scanf               // call scanf("%lf", &CPI2)

    ldr x0, =prompt_c3      // x0 = address of prompt_c3
    bl  printf              // call printf(prompt_c3)
    ldr x0, =fmt_ld         // x0 = address of fmt_ld
    ldr x1, =Instruction3_count     // x1 = address to store input (Instruction3_count)
    bl  scanf               // call scanf("%ld", &Instruction3_count)
    ldr x0, =prompt_p3      // x0 = address of prompt_p3
    bl  printf              // call printf(prompt_p3)
    ldr x0, =fmt_lf         // x0 = address of fmt_lf
    ldr x1, =CPI3           // x1 = address to store input(CPI3) 
    bl  scanf               // call scanf("%lf", &CPI3)

    ldr x0, =prompt_c4      // x0 = address of prompt_c4
    bl  printf              // call printf(prompt_c4)
    ldr x0, =fmt_ld         // x0 = address of fmt_ld
    ldr x1, =Instruction4_count     // x1 = address of Instruction4_count
    bl  scanf               // call scanf("%ld", &Instruction4_count)
    ldr x0, =prompt_p4      // x0 = address of prompt_p4
    bl  printf              // call printf(prompt_p4)
    ldr x0, =fmt_lf         // x0 = address of fmt_lf
    ldr x1, =CPI4           // x1 = addres of CPI4
    bl  scanf               // call scanf("%lf", &CPI4)

    // ---------- TIMING START ----------
    sub sp, sp, #32                // reserve 32 bytes space in stack for 2 × struct timespec (t0,t1); 16 bytes each
    mov x0, #CLOCK_MONOTONIC       // argument1 : the clock type constant  (x0 = 1) -> CLOCK_MONOTONIC is already defined in the header 
    mov x1, sp                     // argument 2: pointer to where to store result (t0 struct) -> stores the stack pointer value (top of the stack) to the register x1
    bl  clock_gettime              // clock_gettime(CLOCK_MONOTONIC, &t0)

    // ---------- COMPUTATION ----------
    fmov d20, xzr                  // total = 0.0 -> resets accumulator d20 to 0.0    (assign accumulator register d20 to the zero register value --> 0.0)

    // term1
    ldr x1, =Instruction1_count    // x1 = address of Instruction1_count
    ldr x0, [x1]                   // x0 = value of Instruction1_count
    scvtf d0, x0                   // convert int 64 to double
    ldr x1, =CPI1                  // x1 = address of CPI1
    ldr d1, [x1]                   // d1 = value of CPI1
    fmul d0, d0, d1                // d0 = d0 * d1  (total clock cycle needed = Instruction1_count * CPI1)
    fadd d20, d20, d0              // accumulate total: d20 = d20 + d0 (total += total clock cycles needed for instruction1)

    // term2
    ldr x1, =Instruction2_count    // x1 = address of Instruction2_count
    ldr x0, [x1]                   // x0 = value of Instruction2_count
    scvtf d0, x0                   // convert int 64 to double 
    ldr x1, =CPI2                  // x1 = address of CPI2
    ldr d1, [x1]                   // d1 = value of x1
    fmul d0, d0, d1                // d0 = d0 * d1 (total clock cycle needed = Instruction2_count * CPI2)
    fadd d20, d20, d0              // d20 = d20 + d0 (total += total clock cycles needed for instruction2) 

    // term3
    ldr x1, =Instruction3_count    // x1 = address of Instruction_count3
    ldr x0, [x1]                   // x0 = value of x1 
    scvtf d0, x0                   // convert int 64 to double 
    ldr x1, =CPI3                  // x1 = address of CPI3
    ldr d1, [x1]                   // d1 = value of x1 (cpi3) 
    fmul d0, d0, d1                // d0 = d0 * d1 (total clock cycles needed for instruction3 = Intruction3_count * CPI3)
    fadd d20, d20, d0              // d20 = d20 + d0 (total += total clock cycles needed for instruction3)

    // term4
    ldr x1, =Instruction4_count    // x1 = address of Instruction4_count
    ldr x0, [x1]                   // x0 = value of x1 (instruction4_count)
    scvtf d0, x0                   // convert int64 to double 
    ldr x1, =CPI4                  // x1 = address of CPI4
    ldr d1, [x1]                   // d1 = value of x1 (CPI4)
    fmul d0, d0, d1                // d0 = d0 * d1  (total clock cycles needed for instruction4 = instcution4_count * CPI4)
    fadd d20, d20, d0              // d20 = Total_instructions  (total += toal clock cycles needed for instruction4)

    // Execution_time = Total_instructions * Clock_cycle_time
    ldr x1, =Clock_cycle_time      // x1 = address of Clock_cycle_time
    ldr d1, [x1]                   // d1 = value of x1 
    fmul d0, d20, d1               // d0 = d20 * d1 (Execution_time =Total_instructions * Clock_cycle_time) 
    // ---------- TIMING END ----------
    mov x0, #CLOCK_MONOTONIC       // argument1 : the clock type constant  
    add x1, sp, #16                // x1 = stack pointer + 16 computes the address of the second timespec (t1), which starts 16 bytes above the stack pointer, and puts that address into x1.
    bl  clock_gettime              // clock_gettime(CLOCK_MONOTONIC, &t1)

    // ---------- PRINT RESULTS ----------
    // print execution time first
    ldr x0, =fmt_out               // x0 = address of fmt_out
    bl  printf                     // call printf(fmt_out)

    // calculate (t1 - t0)
    ldr x2, [sp, #16]              // t1.tv_sec -> load value 16 bytes above stack pointer 
    ldr x3, [sp, #0]               // t0.tv_sec -> load value at top of stack pointer 
    sub x2, x2, x3                 // sec diff  -> t1 = t1 - t0 
    ldr x4, [sp, #24]              // t1.tv_nsec convert t1 to nanoseconds
    ldr x5, [sp, #8]               // t0.tv_nsec convert t0 to nanoseconds
    sub x4, x4, x5                 // nsec diff -> t1 = t1 - t0 (nano seconds)
    cmp x4, #0                     // compare nsec_diff with 0 -> set flags for comparison 
    b.ge 1f                        // branch if greater or equal, jump to branch 1 
    ldr x6, =1000000000            // load constant 1,000,000,000 into x6 (1 second in nanoseconds)
    add x4, x4, x6                 // borrow adjustment (add 1 second if x4 is -ve)
    sub x2, x2, #1                 // since 1 second is borrowed above, we nid to reduce the seconds count by 1 
1:  // branch target for b.ge 1f
    scvtf d2, x2                   // d2 = sec diff -> convert int x2 to double d2
    scvtf d3, x4                   // d3 = nsec diff -> convert int x4 to double d3
    ldr x6, =1000000000            // store 1000000000 ns to x6
    scvtf d4, x6                   // d4 = 1e9  -> convert to double 
    fdiv d3, d3, d4                // divide d3 by 1e9 to get seconds 
    fadd d2, d2, d3                // total seconds  

    // convert to milliseconds
    mov x6, #1000                // store 1000ms to x6
    scvtf d4, x6                   // convert from int to double 
    fmul d0, d2, d4                // d0 = milliseconds

    ldr x0, =fmt_time               // x0 = addres for fmt_time
    bl  printf                      // printf(fmt_time)

    add sp, sp, #32                // restore stack
    mov x0, #0                     // x0 = 0
    ret
