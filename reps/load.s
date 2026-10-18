#include "textflag.h"

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

TEXT ·read_4x3(SB), NOSPLIT|NOFRAME, $0-32
    
pre_abi:
    MOVD ZR, R0
    MOVD buf+0(FP), R2
    MOVD count+24(FP), R3

loop:
    MOVW (R2), R8
    MOVW 4(R2), R8
    MOVW 8(R2), R8
    ADD $12, R0, R0
    CMP R0, R3
    BGT loop
    RET

TEXT ·read_8x3(SB), NOSPLIT|NOFRAME, $0-32
    
pre_abi:
    MOVD ZR, R0
    MOVD buf+0(FP), R2
    MOVD count+24(FP), R3

loop:
    MOVD (R2), R8
    MOVD 8(R2), R8
    MOVD 16(R2), R8
    ADD $24, R0, R0
    CMP R0, R3
    BGT loop
    RET

TEXT ·read_16x3(SB), NOSPLIT|NOFRAME, $0-32
    
pre_abi:
    MOVD ZR, R0
    MOVD buf+0(FP), R2
    MOVD count+24(FP), R3

loop:
    VLD1 (R2), [V0.B16, V1.B16, V2.B16]
    ADD $48, R0, R0
    CMP R0, R3
    BGT loop
    RET

TEXT ·read_32x3(SB), NOSPLIT|NOFRAME, $0-32
    
pre_abi:
    MOVD ZR, R0
    MOVD buf+0(FP), R2
    MOVD count+24(FP), R3
    // WORD $0x2598e3ef // ptrue
    WORD $0xd500303b // smstart sm
    // WORD $0xd500333f // smstart

loop:
    // LD1D (R2), P0/Z, Z0.D
    WORD $0xa4170ff2
    ADD $96, R0, R0
    CMP R0, R3
    BGT loop
    RET

