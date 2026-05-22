#include "textflag.h"

// func readCPUTimer() uint64
// $0-8 means: 0 bytes of local stack frame, 8 bytes of return arguments.
TEXT ·readCPUTimer(SB), NOSPLIT, $0-8
    ISB $15            // Instruction Synchronization Barrier (serializes execution)
    MRS CNTVCT_EL0, R0 // Move system register CNTVCT_EL0 into register R0
    MOVD R0, ret+0(FP) // Copy R0 into the Go return value slot on the frame pointer
    RET
