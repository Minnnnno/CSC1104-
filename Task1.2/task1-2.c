#include <stdio.h>

int main(){
    int list[5] = {5, 19, 7, -20, 2025};
    int i;
    int largest;
    int length;
    
    length = sizeof(list) / sizeof(list[0]);

    largest = list[0];


    for (i=1; i<length; i++){
        if (list[i] > largest){
            largest = list[i];
        }
    }

    printf("\n%d is the largest number.", largest);

    return 0;

}