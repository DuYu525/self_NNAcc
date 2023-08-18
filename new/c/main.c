#include <stdio.h>
#include <stdlib.h>

#include <string.h>
#include "ns_libopt.h"
#include "insn.h"
#include "ns_sdk_hal.h"
#include "nuclei_sdk_soc.h"

#include "riscv_nnsupportfunctions.h"

int main (void)
{
    FILE *file = fopen("data.txt","r");
    if (file == NULL){
        printf ("\nUnable to open file\n");
        return 1;
    }

    int lhs_rows = 1024;
    int rhs_rows = 1024;
    int rhs_cols = 1024;
    int feature_size = lhs_rows * rhs_cols;
    int weight_size = rhs_rows * rhs_cols;

    q7_t *lhs = (q7_t*)malloc(sizeof(q7_t) * feature_size);
    q7_t *rhs = (q7_t*)malloc(sizeof(q7_t) * weight_size);

    int i,j = 0;
    while ()

    fclose(file);
    return 0;

}