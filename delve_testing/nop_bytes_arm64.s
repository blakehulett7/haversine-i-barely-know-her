#include "textflag.h"

// We use NOFRAME and NOSPLIT because the prologue, epilogue, and 
// stack-split checks are explicitly handled within your instruction stream·
TEXT ·nop_bytes(SB), NOSPLIT|NOFRAME, $0-0
    
pre_abi:
    MOVD buf+0(FP), R0           // R0 = slice data pointer (8 bytes)
    MOVD ZR, R1                  // R1 = iterator           (8 bytes)
    MOVD count+24(FP), R2        // R2 = count loop limit   (8 bytes)

start:
    MOVD 16(g), R16
    CMP R16, RSP
    BLS morestack_block          // 34(PC) -> Points to the stack growth block
    MOVD.W R30, -64(RSP)         // Allocate 64-byte frame, save Link Register
    MOVD R29, -8(RSP)            // Save Frame Pointer
    SUB $8, RSP, R29             // Set up new Frame Pointer
    JMP loop_check               // 1(PC) -> Fallthrough/Jump to loop condition

loop_check:
    CMP R1, R2                   // Compare i and limit
    BGT safe_write               // 2(PC) -> If limit > i, enter loop
    JMP epilogue                 // 14(PC) -> Else, exit loop and go to epilogue

safe_write:
    JMP 1(PC)
    JMP loop_increment           // 1(PC) -> Go to increment

loop_increment:
    ADD $1, R1, R1               // i++
    JMP loop_check               // -17(PC) -> Loop back to condition check

epilogue:
    MOVD -8(RSP), R29            // Restore Frame Pointer
    MOVD.P 64(RSP), R30          // Restore Link Register and deallocate stack
    RET

panic_block:
    CALL ·goPanicIndex(SB)  // Call out-of-bounds panic
    NOOP

morestack_block:
    STP (R0, R1), 8(RSP)         // Save registers before growing stack
    STP (R2, R3), 24(RSP)
    MOVD R30, R3
    CALL runtime·morestack_noctxt(SB) // Request larger stack
    LDP 8(RSP), (R0, R1)         // Restore registers
    LDP 24(RSP), (R2, R3)
    JMP start                    // Retry function from the top
