import time

PAGE = [
    9, 1, 14, 10, None, 13, 8, 15, None, 30,
    18, None, 21, 27, -1, 22, 29, None, 19, 26,
    17, 25, None, 31, 20, 0, 5, 4, None, None,
    3, 2
]

def check_entry(bit_str):
    return all(bit in ('0', '1') for bit in bit_str)


def get_virt_page_from_file(f):
    """
    Read ONE vpn/offset pair from an open file object `f`.
    Returns (vpn_str, offset_str) or (None, None) on EOF.
    """
    vpn = f.readline()
    if not vpn:  # EOF
        return None, None
    vpn = vpn.strip()

    offset = f.readline()
    if not offset:  # EOF / incomplete pair
        return None, None
    offset = offset.strip()

    # Basic validation (optional but good for safety)
    if len(vpn) != 5 or not check_entry(vpn):
        print(f"Invalid VPN in inputs.txt: {vpn!r}")
        return None, None

    if len(offset) != 8 or not check_entry(offset):
        print(f"Invalid offset in inputs.txt: {offset!r}")
        return None, None

    return vpn, offset


def bin_to_dec(bit_str):
    return int(bit_str, 2)


def get_addr(pagenum, offset):
    return ((pagenum << 8) | offset)


def print_addr(value, bits=13):
    bin_str = format(value, f"0{bits}b")
    grouped = f"{bin_str[:5]} {bin_str[5:9]} {bin_str[9:]}"
    print(grouped)


def translate_frame(vpn):
    return PAGE[vpn]


def main():
    iterations = 1000  # target number of runs

    try:
        f = open("inputs.txt", "r")
    except OSError as e:
        print("Error opening inputs.txt:", e)
        return

    # start the timer (includes file reading + computation + printing)
    start = time.perf_counter()

    actual_runs = 0

    for _ in range(iterations):
        vpn_bits, offset_bits = get_virt_page_from_file(f)
        if vpn_bits is None:
            # No more data in file or invalid entry
            break

        # Store value in base 10
        vpn = bin_to_dec(vpn_bits)
        offset = bin_to_dec(offset_bits)

        # Virtual address
        v_addr = get_addr(vpn, offset)
        print("The virtual memory address you keyed in is: ", end="")
        print_addr(v_addr)

        # Page table lookup
        frame = translate_frame(vpn)

        if frame is None or frame == -1:
            print(f"Page does not exist, Virtual page number {vpn} not in memory.")
            # still count this run, but stop further computation
            actual_runs += 1
            break

        # Physical Address computation
        p_addr = get_addr(frame, offset)

        print("Physical memory address after paging is: ", end="")
        print_addr(p_addr)

        actual_runs += 1

    # end timer
    end = time.perf_counter()
    f.close()

    if actual_runs == 0:
        print("No valid input pairs found in inputs.txt.")
        return

    elapsed = end - start  # in seconds
    total_ms = elapsed * 1000.0
    avg_ms = total_ms / actual_runs

    print(f"\nTotal time taken for {actual_runs} runs: {total_ms:.6f} ms")
    print(f"Average execution time: {avg_ms:.6f} ms")


if __name__ == "__main__":
    main()
