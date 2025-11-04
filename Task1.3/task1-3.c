#include <stdio.h>

int main(){
    int list[5] = {1, 4, 7, 10 , 15};
    int len = sizeof(list)/sizeof(list[0]);
    int key, found = 0;
    
    printf("Enter a number: ");
    scanf("%d", &key);

    for (int i=0; i<len; i++){
        for (int j= i+1; j<len; j++){
            if (list[i] + list[j] == key){
                printf("There are two numbers in the list summing to the keyed-in number %d.\n", key);
                found = 1;
                break;
            }
        }
        if (found) break;
    }
    if (!found)
        printf("There are no two numbers in the list summing to the keyed-in number %d.\n", key);

    return 0;
}
