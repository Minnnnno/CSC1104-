import dis
import time

PAGE = [
    9, 1, 14, 10, -1, 13, 8, 15, -1, 30,
    18, -1, 21, 27, -1, 22, 29, -1, 19, 26,
    17, 25, -1, 31, 20, 0, 5, 4, -1, -1,
    3, 2
]

def check_entry(bit_str):
    return all(bit in ('0', '1')for bit in bit_str)

# # Instruction Count for check_entry function
# count1 = len(list(dis.Bytecode(check_entry)))
# print("Total Python bytecode instruction:",count1)

def get_virt_addr():

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

# # Insturction count for get_virt_addr function
# count2 = len(list(dis.Bytecode(get_virt_addr)))
# print("Total Python bytecode instruction:",count2)

# def bin_to_dec(bit_str):
#     return int(bit_str,2)

def print_addr(value, bits=13):
    bin_str = format(value, f"0{bits}b")
    grouped = f"{bin_str[:5]} {bin_str[5:9]} {bin_str[9:]}"
    print(grouped)

# # Instruction count for Print_addr function
# count3 = len(list(dis.Bytecode(print_addr)))
# print("Total Python bytecode instruction:",count3)

def main():
    vpn_bits, offset_bits = get_virt_addr()
    start = time.perf_counter()       # start the timer
    

    # Declare variable with base 2
    vpn = int(vpn_bits,2)
    offset = int(offset_bits,2)

    # vpn = bin_to_dec(vpn_bits)
    # offset = bin_to_dec(offset_bits)

    v_addr = (vpn << 8) | offset


    print("\nVirtual memory address entered:")
    print_addr(v_addr)      # Print in form of binary
    # print(v_addr)           # Print in form of decimal

    # Page table lookup
    frame = PAGE[vpn]
    if frame < 0 or frame > 31:
        print(f" Page fault! Virtual page {vpn} not in memory")
        return
    
    # Physical Address computation
    p_addr = (frame << 8) | offset

    print("Physical memory address after paging: ")
    print_addr(p_addr)

    # # Instruction count for Main Program
    # count4 = len(list(dis.Bytecode(main)))
    # print("Total Python bytecode instruction:",count4)

    # # Instruction count for calling the main
    # count5 = len(list(dis.Bytecode(__name__)))
    # print("Total Python bytecode instruction:",count5)

    # Stop the timer
    end = time.perf_counter()
    print(f"Procssing time: {end - start:.6f} seconds")
    

if __name__ == "__main__":
    main()
