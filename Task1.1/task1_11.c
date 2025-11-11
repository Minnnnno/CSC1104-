#define _POSIX_C_SOURCE 200809L   // ensure clock_gettime and CLOCK_* are exposed
#include <stdio.h>      // for printf, scanf
#include <time.h>       // for clock_gettime(), struct timespec

static inline double secdiff(struct timespec a, struct timespec b) {          // Calculates the difference between two timestamps (in seconds)
    return (b.tv_sec - a.tv_sec) + (b.tv_nsec - a.tv_nsec) / 1e9;               // Used to measure elapsed time with nanosecond precision
}
#ifndef MONO_CLOCK
  #ifdef CLOCK_MONOTONIC_RAW
    #define MONO_CLOCK CLOCK_MONOTONIC_RAW    // high-res, monotonic
  #elif defined(CLOCK_MONOTONIC)
    #define MONO_CLOCK CLOCK_MONOTONIC        // portable fallback
  #else
    #define MONO_CLOCK 0
  #endif
#endif

int main(void) {

    char choice;                                                            //// variable to store user's Y/N input 

    
    do {
        unsigned long  n;                                                   // use unsigned long for large positive numbers that user might input
        unsigned long  i;                                                   // loop variable
        int is_prime = 1;                                                   // assume the number is prime first

        int valid_input;                                                    // variable to track if input is valid (mirrors pseudocode's valid_input)

        // === Input validation loop (matches pseudocode) ===
        do {
            printf("Enter a number: ");                                     //prompt user to enter a number
            valid_input = scanf("%lu", &n);                                 //reads user input stored in n, expected to read an unsigned long int

            if (valid_input != 1) {                                         // check if user entered a valid number
                printf("Invalid input! Please enter a number.\n");          // notify user of invalid input
                while (getchar() != '\n');                                  // clear the input buffer
                valid_input = 0;                                            // mark as invalid (same idea as pseudocode)
            } else {
                valid_input = 1;                                            // mark as valid
            }
        } while (valid_input == 0);                                         // repeat until valid number is entered

        if (n < 2LU) {                                                      //As numbers below 2 are not prime numbers, we can say that if n < 2, it is not prime
            printf("The keyed-in number %lu is not a prime number\n", n);   //prints out that input user keyed in is not prime
            printf("[Timing] Prime check executed in N/A (no computation)\n");
        } else {

          
            struct timespec t0, t1;
            clock_gettime(MONO_CLOCK, &t0);                                   //start measurement

            for (i = 2; i * i <= n; i++) {                                  //check for every possible divisor i starting from 2 to n^2
                if (n % i == 0) {                                           //check if n is divisible by i, if reminder is 0, means it divides evenly, which means is not a prime
                    is_prime = 0;                                           //is_prime is false, hence is_prime=0
                    break;                                                  //stops loop
                }
            }


          
            clock_gettime(MONO_CLOCK, &t1);                              //stop timing     
            double execution_time = secdiff(t0, t1) * 1000.0;

            if (is_prime == 0) {                                            //if is_prime ==0 
                printf("The keyed-in number %lu is not a prime number\n", n); //Print out the message "The keyed-in number xxx is not a prime number "
            } else {                                                        //else
                printf("The keyed-in number %lu is  a prime number\n", n);  // just print the number if prime
            }

            printf("[Timing] Prime check executed in %.3f milliseconds\n", execution_time);
        }

        
        // Ask user if they want to run the program again (Y/N)-
        printf("\nDo you want to run the program again? (Y/N): ");
        scanf(" %c", &choice);                                              // note the leading space to consume leftover newline

    } while (choice == 'Y' || choice == 'y');                               // repeats if user enters Y or y

    printf("Program terminated. \n");
    return 0;
}
