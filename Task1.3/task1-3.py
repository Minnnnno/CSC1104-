key = int(input("Enter a number: "))
list = [1, 4, 7, 10 , 15]
found = False

for i in range(len(list)):
    for j in range(i+1, len(list)):
        if list[i] + list[j] == key:
            print("There are two numbers in the list summing to the keyed-in number", key)
            found = True
            break
    if found:
        break
    
if not found:
    print("There are no two numbers in the list summing to the keyed-in number", key)               