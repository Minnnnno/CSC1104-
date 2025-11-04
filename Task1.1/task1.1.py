# prime_check.py

while True:                                                                   # Creates a loop
    try:                                                                      # attempt this, if fail go to except
        n = int(input("Enter a number: "))                                    # Ask user for input and convert to integer
    except ValueError:
        print("Invalid input. Please enter a number.")                        # if user enter that isnt valid, raises value error and prints out, error message
        continue                                                              # Ask again if user enters letters or symbols

    if n < 2:                                                                 # since 0 and 1 are not prime, if n is less than 2, it is not prime
        print(f"The keyed-in number {n} is not a prime number")               #prints out error message if <2
        exit()                                                             # 0 and 1 are not prime, ask again

    is_prime = True                                                           # Assume prime until proven otherwise

    # Check divisibility from 2 up to sqrt(n)
    i = 2                                                                     #smallest possible factor
    while i * i <= n:                                                         #to find square root of n and the possible prime numbers below it
        if n % i == 0:                                                        #if any of the prime number lower than square root of n can be divisible and give reminder 0, it is not prime
            is_prime = False                                                  #hence not prime number so is_prime is false
            break                                                             # Stop as soon as we find a divisor
        i += 1

    if not is_prime:
        print(f"The keyed-in number {n} is not a prime number")               #if not prime number, print out message                                                            #exit the program when prime not found
        exit()                                                                #exit the program
    else:
        print(f"The key-in number {n} is a prime number")                     # Print the number if it’s prime
        break                                                                 # Exit program when prime is found
