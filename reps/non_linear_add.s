#include "textflag.h"

// We use NOFRAME and NOSPLIT because the prologue, epilogue, and 
// stack-split checks are explicitly handled within your instruction stream·
TEXT ·non_linear_add(SB), NOSPLIT|NOFRAME, $0-0

prologue:
    MOVD $100000, R0
    MOVD $10, R2

loop_increment:
    MOVD R2, R1
    ADD $1, R1, R1
    MOVD R2, R1
    ADD $1, R1, R1
    SUBS $1, R0
    BNE loop_increment
    RET
