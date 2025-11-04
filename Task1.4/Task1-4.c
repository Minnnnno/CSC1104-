#include <stdio.h>

int main(){
    long Instruction1_count, Instruction2_count, Instruction3_count, Instruction4_count;
    double CPI1, CPI2, CPI3, CPI4;
    double Clock_cycle_time, Execution_time;
    double Total_instructions = 0.0;

    printf("Enter the value of clock cycle time (in second): ");
    scanf("%lf", &Clock_cycle_time);

    printf("Enter the counts of type 1 instruction: ");
    scanf("%ld", &Instruction1_count);
    printf("Enter the CPI of type 1 instruction: ");
    scanf("%lf", &CPI1);

    printf("Enter the counts of type 2 instruction: ");
    scanf("%ld", &Instruction2_count);
    printf("Enter the CPI of type 2 instruction: ");
    scanf("%lf", &CPI2);

    printf("Enter the counts of type 3 instruction: ");
    scanf("%ld", &Instruction3_count);
    printf("Enter the CPI of type 3 instruction: ");
    scanf("%lf", &CPI3);

    printf("Enter the counts of type 4 instruction: ");
    scanf("%ld", &Instruction4_count);
    printf("Enter the CPI of type 4 instruction: ");
    scanf("%lf", &CPI4);
    
    Total_instructions += Instruction1_count * CPI1;
    Total_instructions += Instruction2_count * CPI2;
    Total_instructions += Instruction3_count * CPI3;
    Total_instructions += Instruction4_count * CPI4;

    Execution_time = Total_instructions * Clock_cycle_time;
    printf("The execution time of this software program is %lf second.", Execution_time);
}
