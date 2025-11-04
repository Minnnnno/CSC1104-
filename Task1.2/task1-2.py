list = [5, 19, 7, -20, 2025]

largest = list[0]

for i in list:
    print(i)
    if i > largest:
        largest = i

print(largest, "is the largest number")