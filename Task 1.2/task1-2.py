import time                                                                 # Import the 'time' module for timing utilities

start_time = time.perf_counter()                                            # start high-resolution timer

list = [5, 19, 7, -20, 2025]                                                # list containing 5 elements

largest = list[0]                                                           # Initialise 'largest' with the first element

for i in list:                                                              # Iterate through each value in the sequence                       
    if i > largest:                                                         # Condition: If current value greater than 'largest'
        largest = i                                                         # Update 'largest' with current value

end_time = time.perf_counter()                                              # end high_resolution timer

print(largest, "is the largest number")                                     # Print the final result after the loop finishes/
print(f"Processing time: {(end_time - start_time)*1e3:.6f} ms")              # Compute and print out elapsed time in seconds and convert to milliseconds to 6 decimal places