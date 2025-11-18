#include <stdio.h>
#include <time.h>

static inline double secdiff(struct timespec a, struct timespec b)                                          // Functions to calculate the time taken between two timestamps
{
    return (b.tv_sec - a.tv_sec) + (b.tv_nsec - a.tv_nsec)/1e9;                                             // (end_seconds - start_seconds) + (end_nanos - start_nanos)/1e9 = total seconds
}

int main()                                                                                                  // Program entry point; returns 0 on success
{
    int list[5] = {1, 4, 7, 10, 15};                                                                        // Define a fixed array of 5 integers
    int len = sizeof(list)/sizeof(list[0]);                                                                 // Compute number of elements in the array
    int key;                                                                                                // Key = Store the user's target sum
    int found = 0;                                                                                          // Flag called Found to mark whether a valid pair is found (0 = not found yet)
    int valid;                                                                                              // Flag for input validation
    
    do
    {
        printf("Enter a number: ");                                                                         // Prompt user to input a sum value
        valid = scanf("%d", &key);                                                                          // Read an integer from stdin into 'key' 
        if (valid != 1)                                                                                     // If scanf did NOT successfully read one integer
        {
            printf("Invalid input! Please enter an integer.\n");                                            // Print this if input is not an integer
            while (getchar() != '\n');                                                                      // clear invalid input from buffer     
        }
    } while (valid != 1);                                                                                   // Loop continues until scanf successfuly reads one integer

    struct timespec ts_start, ts_end;                                                                       // Variables to hold start and end timestamps
    clock_gettime(CLOCK_MONOTONIC, &ts_start);                                                              // Start timer

    for (int i=0; i<len; i++){                                                                              // Outer loop: Pick first element (i)
        for (int j= i+1; j<len; j++){                                                                       // Inner Loop: Pick second element (j) after (i)
            if (list[i] + list[j] == key){                                                                  // Check if the pair at (i) and (j) sums exactly to the user's key
                printf("There are two numbers in the list summing to the keyed-in number %d.\n", key);      // Print this if successful
                found = 1;                                                                                  // Set found flag to true
                break;                                                                                      // Exit inner loop
            }
        }
        if (found) break;                                                                                   // Exit outer loop if found flag is true
    }
    if (!found)                                                                                             // If all pairs does not match user input
        printf("There are no two numbers in the list summing to the keyed-in number %d.\n", key);           // Print this when unsucessful

    clock_gettime(CLOCK_MONOTONIC, &ts_end);                                                                // End timer
    printf("Processing time: %.6f ms\n", secdiff(ts_start, ts_end)*1e3);                                    // Print out the time taken and convert second to milliseconds

    return 0;                                                                                               // Indicate successful program termination
}
