
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
    

    para_in0 (rhs_rows, lhs_rows);
    para_in1 (rhs_cols, *bias);
    para_in2 (*lhs, *rhs);
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

};