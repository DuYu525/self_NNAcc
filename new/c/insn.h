#define  _INSN_H_
#ifdef _INSN_H_
#define  _INSN_H_

#ifdef _cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <nuclei_sdk_soc.h>
#include "riscv_nnsupportfunctions.h"


__STATIC_FORCEINLINE void para_in0 (int32_t rhs_rows, int32_t lhs_rows)
{
    asm volatile(
        ".insn r 0x2b, 3, 1, x0, %0, %1"
        : "=r"(zero)
        : "r"(rhs_rows), "r"(lhs_rows)
    );
    return ;
};

__STATIC_FORCEINLINE void para_in1 (int32_t rhs_cols, q31_t *bias)
{
    asm volatile(
        ".insn r 0x2b, 3, 2, x0, %0, %1"
        : "=r"(zero)
        : "r"(rhs_cols), "r"(*bias)
    );
    return ;
};

__STATIC_FORCEINLINE void para_in2 (q7_t *lhs, q7_t *rhs)
{
    asm volatile(
        ".insn r 0x2b, 3, 4, x0, %0, %1"
        : "=r"(zero)
        : "r"(*lhs), "r"(*rhs)
    );
    return ;
};

__STATIC_FORCEINLINE void para_in3 (int32_t lhs_offset, int32_t dst_offset)
{
    asm volatile(
        ".insn r 0x2b, 3, 8, x0, %0, %1"
        : "=r"(zero)
        : "r"(lhs_offset), "r"(dst_offset)
    );
    return ;
};

__STATIC_FORCEINLINE void para_in4 (int32_t activation_min, int32_t activation_max)
{
    asm volatile(
        ".insn r 0x2b, 3, 16, x0, %0, %1"
        : "=r"(zero)
        : "r"(activation_min), "r"(activation_max)
    );
    return ;
};

__STATIC_FORCEINLINE void para_in5 (int32_t *dst_multi, int32_t *dst_shifts)
{
    asm volatile(
        ".insn r 0x2b, 3, 32, x0, %0, %1"
        : "=r"(zero)
        : "r"(*dst_multi), "r"(*dst_shifts)
    );
    return ;
};

__STATIC_FORCEINLINE void matrix_multi (q7_t *dst)
{
    asm volatile(
        ".insn r 0x2b, 1, 64, x0, %0, %1"
        : "=r"(zero)
        : "r"(*dst)
    );
    return ;
};


#ifdef _cplusplus
}
#endif

#endif