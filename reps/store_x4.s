#include "textflag.h"

// We use NOFRAME and NOSPLIT because the prologue, epilogue, and 
// stack-split checks are explicitly handled within your instruction stream·
TEXT ·store_x4(SB), NOSPLIT|NOFRAME, $0-32
    
pre_abi:
    MOVD $1, R0
    MOVD buf+0(FP), R2
    MOVD count+24(FP), R3

loop:
    MOVD R0, (R2)
    MOVD R0, (R2)
    MOVD R0, (R2)
    MOVD R0, (R2)
    SUBS $4, R3
    BGT loop
    RET

