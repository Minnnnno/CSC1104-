// a64_exec_time.s
// ARM64 Linux (Raspberry Pi 64-bit): read inputs via scanf/printf and compute execution time
// Execution_time = (Σ count_i * CPI_i) * Clock_cycle_time

    .text
    .global main
    .extern printf
    .extern scanf

// -------------------- DATA --------------------
    .data
prompt_clk:    .asciz "Enter the value of clock cycle time (in second): "
prompt_c1:     .asciz "Enter the counts of type 1 instruction: "
prompt_p1:     .asciz "Enter the CPI of type 1 instruction: "
prompt_c2:     .asciz "Enter the counts of type 2 instruction: "
prompt_p2:     .asciz "Enter the CPI of type 2 instruction: "
prompt_c3:     .asciz "Enter the counts of type 3 instruction: "
prompt_p3:     .asciz "Enter the CPI of type 3 instruction: "
prompt_c4:     .asciz "Enter the counts of type 4 instruction: "
prompt_p4:     .asciz "Enter the CPI of type 4 instruction: "

fmt_ld:        .asciz "%ld"
fmt_lf:        .asciz "%lf"
fmt_out:       .asciz "The execution time of this software program is %lf second.\n"

// -------------------- BSS (variables) --------------------
    .bss
    .balign 8
Instruction1_count:  .skip 8      // long
Instruction2_count:  .skip 8	  // Reserve 8 bytes of space 
Instruction3_count:  .skip 8
Instruction4_count:  .skip 8
CPI1:                .skip 8      // double
CPI2:                .skip 8
CPI3:                .skip 8
CPI4:                .skip 8
Clock_cycle_time:    .skip 8      // double

// -------------------- CODE --------------------
    .text
main:
    // --- Ask & read Clock_cycle_time (double) ---
    ldr x0, =prompt_clk // load address of the lavel prompt_clk into register x0 
    bl  printf // branch and link 

    ldr x0, =fmt_lf
    ldr x1, =Clock_cycle_time
    bl  scanf

    // --- Ask/read Instruction1_count (long) ---
    ldr x0, =prompt_c1
    bl  printf

    ldr x0, =fmt_ld
    ldr x1, =Instruction1_count
    bl  scanf

    // --- Ask/read CPI1 (double) ---
    ldr x0, =prompt_p1
    bl  printf

    ldr x0, =fmt_lf
    ldr x1, =CPI1
    bl  scanf

    // --- Ask/read Instruction2_count ---
    ldr x0, =prompt_c2
    bl  printf

    ldr x0, =fmt_ld
    ldr x1, =Instruction2_count
    bl  scanf

    // --- Ask/read CPI2 ---
    ldr x0, =prompt_p2
    bl  printf

    ldr x0, =fmt_lf
    ldr x1, =CPI2
    bl  scanf

    // --- Ask/read Instruction3_count ---
    ldr x0, =prompt_c3
    bl  printf

    ldr x0, =fmt_ld
    ldr x1, =Instruction3_count
    bl  scanf

    // --- Ask/read CPI3 ---
    ldr x0, =prompt_p3
    bl  printf

    ldr x0, =fmt_lf
    ldr x1, =CPI3
    bl  scanf

    // --- Ask/read Instruction4_count ---
    ldr x0, =prompt_c4
    bl  printf

    ldr x0, =fmt_ld
    ldr x1, =Instruction4_count
    bl  scanf

    // --- Ask/read CPI4 ---
    ldr x0, =prompt_p4
    bl  printf

    ldr x0, =fmt_lf
    ldr x1, =CPI4
    bl  scanf

    // ----------------------------------------------------
    // Compute: Total_instructions = Σ (count_i * CPI_i)
    // Using FP regs (d0..): convert int64 -> double (scvtf), then fmul/fadd.
    // ----------------------------------------------------
    // total = 0.0
    fmov d20, xzr                  // d20 = 0.0

    // Load counts (x-reg) and CPIs (d-reg), accumulate
    // term1
    ldr x1,  =Instruction1_count
    ldr x0,  [x1]                  // x0 = count1 (long)
    scvtf d0, x0                   // Signed convert to Floating Point d0 = (double)count1
    ldr x1,  =CPI1
    ldr d1,  [x1]                  // d1 = CPI1
    fmul d0, d0, d1                // Floating Point Multiply d0 = count1 * CPI1
    fadd d20, d20, d0              // Floating point add total += d0

    // term2
    ldr x1,  =Instruction2_count
    ldr x0,  [x1]
    scvtf d0, x0
    ldr x1,  =CPI2
    ldr d1,  [x1]
    fmul d0, d0, d1
    fadd d20, d20, d0

    // term3
    ldr x1,  =Instruction3_count
    ldr x0,  [x1]
    scvtf d0, x0
    ldr x1,  =CPI3
    ldr d1,  [x1]
    fmul d0, d0, d1
    fadd d20, d20, d0

    // term4
    ldr x1,  =Instruction4_count
    ldr x0,  [x1]
    scvtf d0, x0
    ldr x1,  =CPI4
    ldr d1,  [x1]
    fmul d0, d0, d1
    fadd d20, d20, d0              // d20 = Total_instructions

    // Execution_time = Total_instructions * Clock_cycle_time
    ldr x1, =Clock_cycle_time
    ldr d1, [x1]                   // d1 = Clock_cycle_time
    fmul d0, d20, d1               // d0 = Execution_time  (to pass to printf)

    // Print result: printf(fmt_out, Execution_time)
    ldr x0, =fmt_out               // x0 = format string
    // AArch64 ABI: variadic double arg is passed in d0
    bl  printf

    // return 0
    mov x0, #0
    ret		// return from function 