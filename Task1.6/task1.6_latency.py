import time

PAGE = [
    9, 1, 14, 10, None, 13, 8, 15, None, 30,
    18, None, 21, 27, -1, 22, 29, None, 19, 26,
    17, 25, None, 31, 20, 0, 5, 4, None, None,
    3, 2
]

def check_entry(bit_str):
    return all(bit in ('0', '1')for bit in bit_str)


def get_virt_page():

    # Data Input and validation for vpn
    while True:
        vpn = input("Enter 5-bit virtual page number (eg:10111): ").strip()
        if len(vpn) != 5 or not check_entry(vpn):
            print("Invalid input, Must be exactly 5 bits of 0 and 1.")
        else:
            break

    # Data Input and validation for offset
    while True:
        offset = input("Enter 8-bit Offset value (11001111): ").strip()
        if len(offset) != 8 or not check_entry(offset):
            print("Invalid input, Must be exactly 8 bits of 0 and 1.")
        else:
            break

    return vpn,offset


def bin_to_dec(bit_str):
    return int(bit_str,2)

def get_addr(pagenum, offset):
    return ((pagenum << 8) | offset)

def print_addr(value, bits=13):
    bin_str = format(value, f"0{bits}b")
    grouped = f"{bin_str[:5]} {bin_str[5:9]} {bin_str[9:]}"
    print(grouped)

def translate_frame(vpn):
    return (PAGE[vpn])


def main():
    vpn_bits, offset_bits = get_virt_page()
    
    
    # Store value in base 10 
    vpn = bin_to_dec(vpn_bits)
    offset = bin_to_dec(offset_bits)
    iterations = 1000000

    # start the timer
    start = time.perf_counter()
    
    for _ in range(iterations):
    
        v_addr = get_addr(vpn, offset)
        #print("The virtual memory address you keyed in is: ",end ="")
        #print_addr(v_addr)

        # Page table lookup
        frame = translate_frame(vpn)

        if frame == None:
            print(f" Page does not exist, Virtual page number {vpn} not in memory.")
            return
    
        # Physical Address computation
        p_addr = get_addr(frame, offset)

        #print("Physical memory address after paging is: ", end = "")
        #print_addr(p_addr)
    
    # end timer
    end = time.perf_counter()
    
    elapsed = end-start  # in seconds
    print(f"Total time taken: {elapsed *1000:.6f} ms")
    print(f"Average Latency: {elapsed *1000 /iterations:.6f}ms")


    

if __name__ == "__main__":
    main()
