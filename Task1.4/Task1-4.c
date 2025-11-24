#include <stdio.h>
#include <time.h>

// Helper function to compute time difference (no change)
static inline double secdiff(struct timespec a, struct timespec b){
    return (b.tv_sec - a.tv_sec) + (b.tv_nsec - a.tv_nsec)/1e9;
}

// --- Helper functions for input validation ---
double get_double(const char *prompt) {
    double value;
    int valid;
    do {
        printf("%s", prompt);
        valid = scanf("%lf", &value);
        while (getchar() != '\n'); // clear input buffer
        if (valid != 1) {
            printf("Invalid input. Please enter a valid number.\n");
        }
    } while (valid != 1);
    return value;
}

long get_long(const char *prompt) {
    long value;
    int valid;
    do {
        printf("%s", prompt);
        valid = scanf("%ld", &value);
        while (getchar() != '\n'); // clear input buffer
        if (valid != 1) {
            printf("Invalid input. Please enter a valid integer.\n");
        }
    } while (valid != 1);
    return value;
}

int main(void){
    long Instruction1_count, Instruction2_count, Instruction3_count, Instruction4_count;
    double CPI_1, CPI_2, CPI_3, CPI_4, Clock_cycle_time, Execution_time, Total_clock_cycle = 0.0;

    // --- Input phase (validated) ---
    Clock_cycle_time = get_double("Enter the value of clock cycle time (in second): ");
    Instruction1_count = get_long("Enter the counts of type 1 instruction: ");
    CPI_1 = get_double("Enter the CPI of type 1 instruction: ");
    Instruction2_count = get_long("Enter the counts of type 2 instruction: ");
    CPI_2 = get_double("Enter the CPI of type 2 instruction: ");
    Instruction3_count = get_long("Enter the counts of type 3 instruction: ");
    CPI_3 = get_double("Enter the CPI of type 3 instruction: ");
    Instruction4_count = get_long("Enter the counts of type 4 instruction: ");
    CPI_4 = get_double("Enter the CPI of type 4 instruction: ");

    // --- Computation phase (timed) ---
    struct timespec t0, t1;
    clock_gettime(CLOCK_MONOTONIC_RAW, &t0);   // start timing

    Total_clock_cycle = Instruction1_count*CPI_1
                      + Instruction2_count*CPI_2
                      + Instruction3_count*CPI_3
                      + Instruction4_count*CPI_4;
    Execution_time = Total_clock_cycle * Clock_cycle_time;

    clock_gettime(CLOCK_MONOTONIC_RAW, &t1);   // end timing

    // --- Output phase ---
    printf("\nThe execution time of this software program is %lf second.\n", Execution_time);
    printf("Processing time: %.6f ms\n", secdiff(t0,t1)*1e3);

    return 0;
}
