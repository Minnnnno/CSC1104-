#include <stdio.h>                                                              
#include <time.h>


static inline double secdiff(struct timespec a, struct timespec b)              // Function to calculate the time taken between two timestamps
{
    return (b.tv_sec - a.tv_sec) + (b.tv_nsec - a.tv_nsec)/1e9;                 // (end_seconds - start_seconds) + (end_nanos - start_nanos)/1e9 = total seconds
}

int main()
{                                                                               // Program entry point; returns 0 on success

    struct timespec ts_start, ts_end;                                           // Variables to hold start and end timestamps
    clock_gettime(CLOCK_MONOTONIC, &ts_start);                                  // Start timer

    int list[5] = {5, 19, 7, -20, 2025};                                        // The input array of integers
    int i;                                                                      // Loop counter
    int largest;                                                                // Store current largest value found
    int length;                                                                 // Length of array
    
    length = sizeof(list) / sizeof(list[0]);                                    // Compute number of elements in the array

    largest = list[0];                                                          // Initialise 'largest' to the first element


    for (i=1; i<length; i++){                                                   // Loop over remaining elements
        if (list[i] > largest){                                                 // If current element is greater than 'largest'
            largest = list[i];                                                  // update 'largest' with current element
        }
    }

    printf("\n%d is the largest number.\n", largest);                           // Print the result of the largest number found

    clock_gettime(CLOCK_MONOTONIC, &ts_end);                                    // End timer
    printf("Processing time: %.6f ms\n", secdiff(ts_start, ts_end)*1e3);        // Print out the time taken and convert second to milliseconds

    return 0;                                                                   // Indicate successful program termination

}

