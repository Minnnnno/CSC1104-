import time                                                                                     # Import the 'time' module for timing utilities

list = [1, 4, 7, 10 , 15]                                                                       # Define a list of 5 integers
found = False                                                                                   # Flag called found to mark whether a valid pair is found (False = not found yet, True = found)

while True:                                                                                     # Loop until condition is fulfilled and break out of it
    s = input("Enter an integer: ").strip()                                                     # Prompt user to input a sum value, .strip() to remove trailing whitespace
    try:
        key = int(s)                                                                            # Convert user input into an integer
        break
    except ValueError:                                                                          # If user input contains invalid characters, Python raises a ValuError
        print("Invalid input! Please enter an integer.")                                        # Print this 

start_time = time.perf_counter()                                                                # start high-resolution timer

for i in range(len(list)):                                                                      # Outer loop: Pick first element (i)
    for j in range(i+1, len(list)):                                                             # Inner loop: Pick second element (j) after (i)
        if list[i] + list[j] == key:                                                            # Check if the pair at (i) and (j) sums exactly to the user's key
            print("There are two numbers in the list summing to the keyed-in number", key)      # Print this if successful
            found = True                                                                        # Set found flag to true
            break                                                                               # Exit inner loop
    if found:                                                                                   # if found flag = true
        break                                                                                   # Exit outer loop
    
if not found:                                                                                   # If all pairs does not match user input
    print("There are no two numbers in the list summing to the keyed-in number", key)           # Print this when unsucessful

end_time = time.perf_counter()                                                                  # end high_resolution timer
print(f"Processing time: {(end_time - start_time)*1e3:.6f} ms")                           # Compute and print out elapsed time in seconds and convert to milliseconds