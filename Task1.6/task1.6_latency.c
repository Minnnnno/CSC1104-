#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <time.h>

// Time Measure
double get_elapsed(struct timespec start, struct timespec end) {
    return (end.tv_sec - start.tv_sec) *1000.0 + (end.tv_nsec - start.tv_nsec) / 1e6 ;
}

// Page Table
int8_t PAGE[32] = 
{
    9, 1, 14, 10, -1, 13, 8, 15, -1, 30,                // Page 0-9
    18, -1, 21, 27, -1, 22, 29, -1, 19, 26,             // Page 10-19
    17, 25, -1, 31, 20, 0, 5, 4, -1, -1,                // Page 20-29
    3, 2                                                // Page 30-31
};

static void clear_buffer(void) {                        // Cleaning function that ensure next input reads clean and unpolluted input
    int ch;
    while ((ch = getchar()) != '\n' && ch != EOF) { /* discard */}
}

bool check_entry(char bit[]) {                          // Content check if contain only 0 or 1
    for(int i = 0; bit[i] != '\0'; i++)                 // Starting to bit i, if the bit is not a null terminator
    {
        if (bit[i] != '0' && bit[i] != '1')             // Check if the bit is not 0 and 1
        {
            printf("Invalid bit input, Please only Enter 0 and 1\n");   // Print error message
            return false;                                               // Content check failed
        }
    }
    return true;                                                        // Content check passed
}

void get_virtual_page(char vpn[6], char offset[9])                  // Asking for user input
{
    bool flag = false;                                              // Initialise flag to be false

    // ---- VPN (5 bits) ----
    do {
        printf("Enter 5-bit Virtual Page Number (eg: 10111): ");            
        scanf("%5s", vpn);                                              // Take in the first 5 input keyed in
        clear_buffer();                                                 // Cleaning function that ensure next input read clean and unpolluted data
        if (strlen(vpn) != 5) {                                         // Perform content length check
            printf("Invalid length, please enter exactly 5 bits.\n");   // Failed, print error message
            continue;                                                   // Immediately proceed to ask user for new input without performing content check                      
        }
        flag = check_entry(vpn);                                        // flag will store the result of content check either fail or pass
    } while (!flag);                                                    // while data is invalid

    // ---- Offset (8 bits) ----
    flag = false;                                                       // Reset flag to false to perform 2nd check

    do {
        printf("Enter 8-bit Offset value (eg: 01101111): ");
        scanf("%8s", offset);                                           // Take in the first 8 input keyed in
        clear_buffer();                                                 
        if (strlen(offset) != 8) {                                      // Perform content length check
            printf("Invalid length, please enter exactly 8 bits.\n");   // Failed, print error message
            continue;                                                   // Immediately proceed to ask user for new input without performing content check
        }
        flag = check_entry(offset);                                     // Perform content check, flag indicate the result of the check
    } while (!flag);                                                    // While data is invalid

}

int16_t bin_to_dec(const char *bitstring)                                // Function to convert binary to decimal
{
    return (int)strtol(bitstring, NULL, 2);                             // Produce the result of computation of conversion
}

int16_t get_addr(int8_t page_num, int16_t offset){                      // Function to combine vpn/frame with offset
    return(int16_t)((page_num << 8)|offset);                            // Produce the result of computation of result
}

int translate_to_frame_page(int vpn){                                   // Function to translate vpn into frame from page table
    return(PAGE[vpn]);                                                  // Produce the result of frame 
}

static void print_addr (int16_t value)                                  // Function to output address with readability
{
    //Print 13-bits
    for (int i = 12; i >= 0; --i)                                       // Start from LSB to MSB
    {
        putchar(((value >> i) & 1)? '1' : '0');                         // AND the bit[i] with 1, if 1 then putchar '1', else put char '0'
        if (i == 8 || i == 4) putchar (' ');                            // Include a space for readbility for offset in address
    }
    putchar('\n');                                                      // New Line
}


int main()
{
    char vpn_bits[6];                                                   // 5 vpn bit + 1 null terminator
    char offset_bits[9];                                                // 8 offset bit + 1 null terminator

    get_virtual_page(vpn_bits, offset_bits);                            // Calling function to obtain valid data input for vpn_bits, offset_bits


    
    // Convert bit-strings to integers
    int8_t vpn = bin_to_dec(vpn_bits);                                      // Convert the result of input from base 2 to base 10 in memory
    int16_t offset = bin_to_dec(offset_bits);                                   // Convert the result of input from base 2 to base 10 in memory       

    struct timespec start,end;
    int iterations = 1000000;
    // --- Start timer ---
    clock_gettime(CLOCK_MONOTONIC_RAW, &start);
    for (int i = 0; i < iterations; i++) {
        // 13-bit virtual address      <-5 bits->|<-8 bits->
        int16_t v_addr = get_addr(vpn, offset);                                     // Call function to produce virtual address with vpn and offset

        //printf("The virtual memory address you keyed in is:  ");            
        //print_addr(v_addr);                                                 // Call function to output the virtual address neatly

        // Check existence in page and translate via page table
        int8_t frame = translate_to_frame_page(vpn);

        if (frame < 0)                                                      // Perform page existence check
        {
            printf("Page does not exist, Virtual page number %d not in memory.\n", vpn);    // Print error message if it do not exist
            return 0;                                                       // Terminate the program
        }

        // 13-bit physical address      <- 5 bits ->|<- 8 bits->
        int16_t p_addr = get_addr(frame, offset);                           // Call function to produce physical address with frame and offset

        //printf("Physical memory address after paging is: ");
        //print_addr(p_addr);                                                 // Call function to output physical address neatly
    }
    // --- End timer ---
    clock_gettime(CLOCK_MONOTONIC_RAW, &end);
    double elapsed = get_elapsed(start,end);
    printf(" Total time taken to execute %d times = %.9f milliseconds\n", iterations, elapsed);
    printf(" Average Latency = %.9f milliseconds\n", elapsed/iterations);
    return 0;                                                           // Terminate the program
}
