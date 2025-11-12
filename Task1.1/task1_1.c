#include <stdio.h>      // for printf, scanf
#include <time.h>       // for clock(), CLOCKS_PER_SEC

int main(void) {

    char choice;                                                            //// variable to store user's Y/N input 

    
    do {
        unsigned long  n;                                                   // use unsigned long for large positive numbers that user might input
        unsigned long  i;                                                   // loop variable
        int is_prime = 1;                                                   // assume the number is prime first

        printf("Enter a number: ");                                         //prompt user to enter a number
        if (scanf("%lu", &n) != 1) {                                        //reads user input stored in n, expected to read an unsigned long int
            return 1;  
        }

        if (n < 2LU) {                                                      //As numbers below 2 are not prime numbers, we can say that if n < 2, it is not prime
            printf("The keyed-in number %lu is not a prime number\n", n);   //prints out that input user keyed in is not prime
            printf("[Timing] Prime check executed in N/A (no computation)\n");
        } else {

          
            clock_t start_time = clock();                                   //start measurement

            for (i = 2; i * i <= n; i++) {                                  //check for every possible divisor i starting from 2 to n^2
                if (n % i == 0) {                                           //check if n is divisible by i, if reminder is 0, means it divides evenly, which means is not a prime
                    is_prime = 0;                                           //is_prime is false, hence is_prime=0
                    break;                                                  //stops loop
                }
            }

          
            clock_t end_time = clock();                                     //end measurement   
            double execution_time = (double)(end_time - start_time) * 1e6 / CLOCKS_PER_SEC;

            if (is_prime == 0) {                                            //if is_prime ==0 
                printf("The keyed-in number %lu is not a prime number\n", n); //Print out the message "The keyed-in number xxx is not a prime number "
            } else {                                                        //else
                printf("The keyed-in number %lu is  a prime number\n", n);  // just print the number if prime
            }

            printf("[Timing] Prime check executed in %.3f microseconds\n", execution_time);
        }

        
        // Ask user if they want to run the program again (Y/N)-
        printf("\nDo you want to run the program again? (Y/N): ");
        scanf(" %c", &choice);                                              // note the leading space to consume leftover newline

    } while (choice == 'Y' || choice == 'y');                               // repeats if user enters Y or y

    printf("Program terminated. \n");
    return 0;
}
