#include "textflag.h"

// We use NOFRAME and NOSPLIT because the prologue, epilogue, and 
// stack-split checks are explicitly handled within your instruction stream·
TEXT ·read_x1(SB), NOSPLIT|NOFRAME, $0-32
    
pre_abi:
    MOVD buf+0(FP), R2
    MOVD count+24(FP), R3

loop:
    MOVD (R2), R0
    SUBS $1, R3
    BGT loop
    RET

TEXT ·read_x2(SB), NOSPLIT|NOFRAME, $0-32
    
pre_abi:
    MOVD buf+0(FP), R2
    MOVD count+24(FP), R3

loop:
    MOVD (R2), R0
    MOVD (R2), R0
    SUBS $2, R3
    BGT loop
    RET

TEXT ·read_x3(SB), NOSPLIT|NOFRAME, $0-32
    
pre_abi:
    MOVD buf+0(FP), R2
    MOVD count+24(FP), R3

loop:
    MOVD (R2), R0
    MOVD (R2), R0
    MOVD (R2), R0
    SUBS $3, R3
    BGT loop
    RET

TEXT ·read_x4(SB), NOSPLIT|NOFRAME, $0-32
    
pre_abi:
    MOVD buf+0(FP), R2
    MOVD count+24(FP), R3

loop:
    MOVD (R2), R0
    MOVD (R2), R0
    MOVD (R2), R0
    MOVD (R2), R0
    SUBS $4, R3
    BGT loop
    RET

