#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <time.h>

// Page Table
int PAGE[32] = 
{
    9, 1, 14, 10, -1, 13, 8, 15, -1, 30,                // Page 0-9
    18, -1, 21, 27, -1, 22, 29, -1, 19, 26,             // Page 10-19
    17, 25, -1, 31, 20, 0, 5, 4, -1, -1,                // Page 20-29
    3, 2                                                // Page 30-31
};

static void clear_buffer(void) {
    int ch;
    while ((ch = getchar()) != '\n' && ch != EOF) { /* discard */}
}

bool check_entry(char bit[])
{
    for(int i = 0; bit[i] != '\0'; i++)
    {
        if (bit[i] != '0' && bit[i] != '1')
        {
            printf("Invalid bit input, Please only Enter 0 and 1\n");
            return false;
        }
    }
    return true;
}

void get_virtual_addr(char vpn[6], char offset[9]) 
{
    bool flag = false;

    // ---- VPN (5 bits) ----
    do {
        printf("Enter 5-bit Virtual Page Number (eg: 10111): ");
        scanf("%5s", vpn);          // cap at 5 chars
        clear_buffer();               // clear any extra input
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
        scanf("%8s", offset);       // cap at 8 chars
        clear_buffer();
        if (strlen(offset) != 8) {
            printf("Invalid length, please enter exactly 8 bits.\n");
            continue;
        }
        flag = check_entry(offset);
    } while (!flag);

}

int bin_to_dec(const char *bitstring)
{
    return (int)strtol(bitstring, NULL, 2);
}

static void print_addr (uint16_t value)
{
    //Print 13-bits
    for (int i = 12; i >= 0; --i)
    {
        putchar(((value >> i) & 1)? '1' : '0');
        if (i == 8 || i == 4) putchar (' ');
    }
    putchar('\n');
}

int main()
{
    char vpn_bits[6]; 
    char offset_bits[9];

    get_virtual_addr(vpn_bits, offset_bits);
    clock_t start,end;
    start = clock();

    // Convert bit-strings to integers
    int vpn = bin_to_dec(vpn_bits);             // Range from 0 to 31
    int offset = bin_to_dec(offset_bits);       // Range from 0 to 255

    // 13-bit virtual address     |<-5 bits->|<-8 bits->
    uint16_t v_addr = (uint16_t)((vpn << 8) | offset); 

    printf("\nVirtual memory address entered: ");
    print_addr(v_addr);

    // Check existence in page and translate via page table
    int frame = PAGE[vpn];
    if (frame < 0)
    {
        printf("Page not exist! Virtual page number %d not in memory.\n", vpn);
        return 0;
    }

    // Physical Address
    uint16_t p_addr = (uint16_t)((frame << 8) | offset);

    printf("Physical memory address after paging is: ");
    print_addr(p_addr);

    end = clock();     // stop timing
    double time_taken = (double)(end - start) / CLOCKS_PER_SEC;
    printf("Processing time: %.6f seconds\n", time_taken);


    return 0;

}