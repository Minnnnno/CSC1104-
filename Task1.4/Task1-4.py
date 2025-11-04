Total_instructions = 0
Execution_time = 0.0
Clock_cycle_time = float(input("Enter the value of clock cycle time (in second): "))

Instruction1_count = int(input("Enter the counts of type 1 intstruction: "))
CPI1 = float(input("Enter the CPI of type 1 instruction: "))

Instruction2_count = int(input("Enter the counts of type 2 intstruction: "))
CPI2 = float(input("Enter the CPI of type 2 instruction: "))

Instruction3_count = int(input("Enter the counts of type 3 intstruction: "))
CPI3 = float(input("Enter the CPI of type 3 instruction: "))

Instruction4_count = int(input("Enter the counts of type 4 intstruction: "))
CPI4 = float(input("Enter the CPI of type 4 instruction: "))

Total_instructions += Instruction1_count * CPI1
Total_instructions += Instruction2_count * CPI2
Total_instructions += Instruction3_count * CPI3
Total_instructions += Instruction4_count * CPI4

Execution_time = Total_instructions * Clock_cycle_time
print(f"The execution time of this software program is {Execution_time}")