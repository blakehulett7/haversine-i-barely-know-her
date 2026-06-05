#include "textflag.h"

// We use NOFRAME and NOSPLIT because the prologue, epilogue, and 
// stack-split checks are explicitly handled within your instruction stream·
TEXT ·mov_bytes<ABIInternal>(SB), NOSPLIT|NOFRAME, $0-0
    
start:
    MOVD 16(g), R16
    CMP R16, RSP
    BLS morestack_block          // 34(PC) -> Points to the stack growth block
    MOVD.W R30, -64(RSP)         // Allocate 64-byte frame, save Link Register
    MOVD R29, -8(RSP)            // Save Frame Pointer
    SUB $8, RSP, R29             // Set up new Frame Pointer
    
    // Spill incoming Go ABIInternal registers to stack home slots
    MOVD R0, 72(RSP)             // R0 = slice data pointer
    MOVD R1, 80(RSP)             // R1 = slice len
    MOVD R2, 88(RSP)             // R2 = slice cap
    MOVD R3, 96(RSP)             // R3 = count (loop limit)
    
    MOVD ZR, 48(RSP)             // i = 0 (loop iterator)
    MOVD R3, 40(RSP)             // Store limit
    JMP loop_check               // 1(PC) -> Fallthrough/Jump to loop condition

loop_check:
    MOVD 40(RSP), R2             // Load limit into R2
    MOVD 48(RSP), R3             // Load i into R3
    CMP R3, R2                   // Compare i and limit
    BGT loop_body                // 2(PC) -> If limit > i, enter loop
    JMP epilogue                 // 14(PC) -> Else, exit loop and go to epilogue

loop_body:
    MOVD 48(RSP), R0             // R0 = i
    MOVD R0, 32(RSP)             
    MOVD 80(RSP), R1             // R1 = slice len
    MOVD 72(RSP), R2             // R2 = slice data pointer
    CMP R0, R1                   // Bounds check: Compare i and slice len
    BHI safe_write               // 2(PC) -> If len > i, proceed to write
    JMP panic_block              // 10(PC) -> Else, index out of bounds!

safe_write:
    MOVB R0, (R2)(R0)            // buf[i] = byte(i)
    JMP loop_increment           // 1(PC) -> Go to increment

loop_increment:
    MOVD 48(RSP), R2             
    ADD $1, R2, R2               // i++
    MOVD R2, 48(RSP)             
    JMP loop_check               // -17(PC) -> Loop back to condition check

epilogue:
    MOVD -8(RSP), R29            // Restore Frame Pointer
    MOVD.P 64(RSP), R30          // Restore Link Register and deallocate stack
    RET

panic_block:
    CALL runtime·panicIndex(SB)  // Call out-of-bounds panic
    NOOP

morestack_block:
    STP (R0, R1), 8(RSP)         // Save registers before growing stack
    STP (R2, R3), 24(RSP)
    MOVD R30, R3
    CALL runtime·morestack_noctxt(SB) // Request larger stack
    LDP 8(RSP), (R0, R1)         // Restore registers
    LDP 24(RSP), (R2, R3)
    JMP start                    // Retry function from the top
