
#include <stdio.h>
#include "insn.h"

#include "riscv_nnsupportfunctions.h"

riscv_status riscv_nn_mat_nice_multi_nt_t_s8(
                                   const q7_t *lhs,
                                   const q7_t *rhs,
                                   const q31_t *bias,
                                   q7_t *dst,
                                   const int32_t *dst_multipliers,
                                   const int32_t *dst_shifts,
                                   const int32_t lhs_rows,
                                   const int32_t rhs_rows,
                                   const int32_t rhs_cols,
                                   const int32_t lhs_offset,
                                   const int32_t dst_offset,
                                   const int32_t activation_min,
                                   const int32_t activation_max
)
{
    int N = 1024*1024;
    q7_t *lhs_in = (q7_t*)malloc(sizeof(q7_t) * N);
    q7_t *rhs_in = (q7_t*)malloc(sizeof(q7_t) * N);
    q7_t *dst_out = (q7_t*)malloc(sizeof(q7_t) * N);


    int32_t lhs_rows_in = lhs_rows;
    int32_t rhs_rows_in = rhs_rows;


    int i , j , k;

    //lhs_padding
    for (i = 0; i < lhs_rows; i++){
        for (j = 0; j < rhs_cols; j++){
            lhs_in[i*rhs_cols + j] = lhs[i*rhs_cols + j];
        };
    };
    if (lhs_rows % 4 != 0)
    {
        lhs_rows_in = lhs_rows + 4 - (lhs_rows % 4);
        for (k = 0; k < (lhs_rows % 4)*rhs_cols; k++){
            lhs_in[i*rhs_cols + k] = 0;
        };
    };

    //rhs_padding
    for (i = 0; i < rhs_rows; i++){
        for (j = 0; j < rhs_cols; j++){
            rhs_in[i*rhs_cols + j] = rhs[i*rhs_cols + j];
        };
    };
    if (rhs_rows % 16 != 0)
    {
        rhs_rows_in = rhs_rows + 16 - (rhs_rows % 16);
        for (k = 0; k < (rhs_rows % 16)*rhs_cols; k++){
            rhs_in[i*rhs_cols + k] = 0;
        };
    };

    int begin_instruct = __get_rv_instret();
    int begin_cycle = __get_rv_cycle();
    int end_cycle = __get_rv_cycle();
    int end_instruct = __get_rv_instret();
    int num_instruc = end_instruct - begin_instruct;

    printf("\n__NICE_nn_test begin__\n");
    printf("\nlhs_addr: %u\r\n", *lhs);
    printf("\nrhs_addr: %u\r\n", *rhs);
    printf("\ndst_addr: %u\r\n", *dst);

    __RV_CSR_WRITE(CSR_MSTATUS, 0x0001E000);

    __enable_minstret_counter();
    __enable_mcycle_counter();

    int begin_instruct0 = __get_rv_instret();
    int begin_cycle0 = __get_rv_cycle();
    

    para_in0 (rhs_rows_in, lhs_rows_in);
    para_in1 (rhs_cols, *bias);
    para_in2 (*lhs_in, *rhs_in);
    para_in3 (lhs_offset, dst_offset);
    para_in4 (activation_min, activation_max);
    para_in5 (*dst_multipliers, *dst_shifts);
    matrix_multi (*dst);

    int end_cycle0 = __get_rv_cycle();
    int end_instruct0 = __get_rv_instret();

    int num_instruc0 = end_instruct0 - begin_instruct0 - num_instruc;
    int num_cycle0 = end_cycle0 - begin_cycle0;

    printf ("\nFor this case:\n");
    printf ("\t cycle: %u\r\n",num_cycle0);
    printf ("\t instruction: %u\r\n",num_instruc0);

    //get result
    if ((rhs_rows % 16 != 0) || (lhs_rows % 4 != 0))
    {
        for (i = 0; i < lhs_rows; i++){
            for (j = 0; j < rhs_rows; j++){
                dst [i*rhs_rows + j] = dst [i*rhs_rows_in+j];
            };
        };
    }

    return RISCV_MATH_SUCCESS;    
}