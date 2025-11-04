#include <stdio.h>

int main(void) {
    int  n;                                                        // use unsigned long for large positive numbers that user might input
    unsigned long  i;                                                       // loop variable
    int is_prime = 1;                                                       // assume the number is prime first

    printf("Enter a number: ");                                                 //prompt user to enter a number
    if (scanf("%lu", &n) != 1) {                                               //reads user input stored in n, expected to read an unsigned long int
        return 1;  
    }

    if (n < 2LU) {                                                             //As numbers below 2 are not prime numbers, we can say that if n < 2, it is not prime
        printf("The keyed-in number %lu is not a prime number\n", n);       //prints out that input user keyed in is not prime
        return 0;                                                            //end program
    }

    
    for (i = 2; i * i <= n; i++) {                                          //check for every possible divisor i starting from 2 to n^2
        if (n % i == 0) {                                                   //check if n is divisible by i, if reminder is 0, means it divides evenly, which means is not a prime
            is_prime = 0;                                                   //is_prime is false, hence is_prime=0
            break;                                                          //stops loop
        }
    }

    if (is_prime == 0) {                                                    //if is_prime ==0 
        printf("The keyed-in number %lu is not a prime number\n", n);      //Print out the message "The keyed-in number xxx is not a prime number "
    } else {                                                                //else
        printf("The keyed-in number %lu is  a prime number\n", n);                                                // just print the number if prime
    }

    return 0;                                                               //end program
}