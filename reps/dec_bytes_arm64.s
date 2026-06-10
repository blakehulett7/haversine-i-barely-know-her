#include "textflag.h"

// We use NOFRAME and NOSPLIT because the prologue, epilogue, and 
// stack-split checks are explicitly handled within your instruction stream·
TEXT ·dec_bytes(SB), NOSPLIT|NOFRAME, $0-0
    
pre_abi:
    MOVD count+24(FP), R0        // R0 = count loop limit   (8 bytes)

loop_increment:
    SUBS $1, R0                  // i++
    BNE loop_increment           // -17(PC) -> Loop back to condition check
    RET
