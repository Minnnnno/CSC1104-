#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <time.h>
#include <inttypes.h>
#include <stdint.h>

#define N_RUNS 1000

// Time Measure (ms)
double get_elapsed(struct timespec start, struct timespec end) {
    return (end.tv_sec - start.tv_sec) * 1000.0
         + (end.tv_nsec - start.tv_nsec) / 1e6;
}

// Page Table
int8_t PAGE[32] =
{
    9, 1, 14, 10, -1, 13, 8, 15, -1, 30,                // Page 0-9
    18, -1, 21, 27, -1, 22, 29, -1, 19, 26,             // Page 10-19
    17, 25, -1, 31, 20, 0, 5, 4, -1, -1,                // Page 20-29
    3, 2                                                // Page 30-31
};

// still useful if you ever do interactive stdin versions
static void clear_buffer(void) {
    int ch;
    while ((ch = getchar()) != '\n' && ch != EOF) { /* discard */ }
}

bool check_entry(char bit[]) {                          // Content check if contain only 0 or 1
    for (int i = 0; bit[i] != '\0'; i++) {
        if (bit[i] != '0' && bit[i] != '1') {
            printf("Invalid bit input, Please only Enter 0 and 1\n");
            return false;
        }
    }
    return true;
}

// ---- You are NO LONGER using this for benchmark input, kept only for interactive use ----
void get_virtual_page(char vpn[6], char offset[9])
{
    bool flag = false;

    // ---- VPN (5 bits) ----
    do {
        printf("Enter 5-bit Virtual Page Number (eg: 10111): ");
        scanf("%5s", vpn);
        clear_buffer();
        if (strlen(vpn) != 5) {
            printf("Invalid length, please enter exactly 5 bits.\n");
            continue;
        }
        flag = check_entry(vpn);
    } while (!flag);

    // ---- Offset (8 bits) ----
    flag = false;
    do {
        printf("Enter 8-bit Offset value (eg: 01101111): ");
        scanf("%8s", offset);
        clear_buffer();
        if (strlen(offset) != 8) {
            printf("Invalid length, please enter exactly 8 bits.\n");
            continue;
        }
        flag = check_entry(offset);
    } while (!flag);
}

int8_t bin_to_dec(const char *bitstring) {
    return (int8_t)strtol(bitstring, NULL, 2);
}

int16_t get_addr(int8_t page_num, int16_t offset) {
    return (int16_t)((page_num << 8) | offset);
}

int translate_to_frame_page(int vpn) {
    return PAGE[vpn];
}

static void print_addr(int16_t value) {
    // Print 13 bits
    for (int i = 12; i >= 0; --i) {
        putchar(((value >> i) & 1) ? '1' : '0');
        if (i == 8 || i == 4) putchar(' ');
    }
    putchar('\n');
}

/*
 * run_once:
 *  - Reads ONE vpn + offset from FILE *in (inputs.txt)
 *  - Performs translation
 *  - Prints results to stdout (output handling)
 * Returns 0 on success, non-zero on EOF / error.
 */
int run_once(FILE *in)
{
    char vpn_bits[6];       // 5 bits + '\0'
    char offset_bits[9];    // 8 bits + '\0'

    // ---- Input handling from file (NO human input) ----
    if (fscanf(in, "%5s", vpn_bits) != 1)
        return 1;  // EOF or read error

    if (fscanf(in, "%8s", offset_bits) != 1)
        return 1;  // EOF or read error

    // (Optional) validate bits read from file:
    if (!check_entry(vpn_bits) || !check_entry(offset_bits)) {
        printf("Invalid bits found in inputs.txt\n");
        return 1;
    }

    // ---- Convert bit-strings to integers ----
    int8_t  vpn    = bin_to_dec(vpn_bits);
    int16_t offset = bin_to_dec(offset_bits);

    int16_t v_addr = get_addr(vpn, offset);

    printf("The virtual memory address you keyed in is:  ");
    print_addr(v_addr);

    // ---- Page table lookup ----
    int8_t frame = translate_to_frame_page(vpn);

    if (frame < 0) {
        printf("Page does not exist, Virtual page number %d not in memory.\n",
               vpn);
        return 1;
    }

    // 13-bit physical address      <- 5 bits ->|<- 8 bits->
    int16_t p_addr = get_addr(frame, offset);

    printf("Physical memory address after paging is: ");
    print_addr(p_addr);

    return 0;
}

int main(void)
{
    FILE *in = fopen("inputs.txt", "r");
    if (!in) {
        perror("inputs.txt");
        return 1;
    }

    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC_RAW, &start);

    for (int i = 0; i < N_RUNS; ++i) {
        // We assume inputs.txt has at least N_RUNS pairs.
        // If you want to reuse the same inputs, uncomment this:
        // fseek(in, 0, SEEK_SET);

        if (run_once(in) != 0) {
            fprintf(stderr, "Stopping early at run %d due to EOF or error.\n", i);
            break;
        }
    }

    clock_gettime(CLOCK_MONOTONIC_RAW, &end);
    fclose(in);

    double total_ms = get_elapsed(start, end);
    double avg_ms   = total_ms / N_RUNS;

    printf("\nTotal time for %d runs: %.3f ms\n", N_RUNS, total_ms);
    printf("Average execution time: %.6f ms\n", avg_ms);

    return 0;
}
