# Task1-4.py
import time

# --- Helper function for validated input ---
def get_float(prompt):
    while True:
        try:
            return float(input(prompt))
        except ValueError:
            print("Invalid input. Please enter a valid number.")

def get_int(prompt):
    while True:
        try:
            return int(input(prompt))
        except ValueError:
            print("Invalid input. Please enter a valid integer.")

# --- Input phase (validated) ---
Clock_cycle_time = get_float("Enter the value of clock cycle time (in second): ")

Instruction1_count = get_int("Enter the counts of type 1 instruction: ")
CPI_1 = get_float("Enter the CPI of type 1 instruction: ")

Instruction2_count = get_int("Enter the counts of type 2 instruction: ")
CPI_2 = get_float("Enter the CPI of type 2 instruction: ")

Instruction3_count = get_int("Enter the counts of type 3 instruction: ")
CPI_3 = get_float("Enter the CPI of type 3 instruction: ")

Instruction4_count = get_int("Enter the counts of type 4 instruction: ")
CPI_4 = get_float("Enter the CPI of type 4 instruction: ")

# --- Computation phase (timed) ---
start = time.perf_counter()  # high-resolution timer

Total_instructions = (
    (Instruction1_count * CPI_1)
    + (Instruction2_count * CPI_2)
    + (Instruction3_count * CPI_3)
    + (Instruction4_count * CPI_4)
)
Execution_time = Total_instructions * Clock_cycle_time

end = time.perf_counter()

# --- Output phase ---
print(f"\nThe execution time of this software program is {Execution_time:.6f} second.")
print(f"Processing time: {(end - start) * 1000:.6f} ms")
