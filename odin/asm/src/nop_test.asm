.global _NOP4x1AllBytesASM
.global _NOP4x3AllBytesASM
.global _NOP4x9AllBytesASM
.global _NOPx1AllBytesASM
.global _NOPx3AllBytesASM
.global _NOPx9AllBytesASM
.global _NOPx18AllBytesASM
.text

_NOP4x1AllBytesASM:
    mov x2, #0
.nloop:
    .word 0xd503201f
    add x2, x2, #1
    cmp x2, x1
    b.lo .nloop
    ret

_NOP4x3AllBytesASM:
    mov x2, #0
.floop:
    .word 0xd503201f
    .word 0xd503201f
    .word 0xd503201f
    add x2, x2, #1
    cmp x2, x1
    b.lo .floop
    ret

_NOP4x9AllBytesASM:
    mov x2, #0
.mloop:
    .word 0xd503201f
    .word 0xd503201f
    .word 0xd503201f
    .word 0xd503201f
    .word 0xd503201f
    .word 0xd503201f
    .word 0xd503201f
    .word 0xd503201f
    .word 0xd503201f
    add x2, x2, #1
    cmp x2, x1
    b.lo .mloop
    ret

_NOPx1AllBytesASM:
    mov x2, #0
.oloop:
    nop
    add x2, x2, #1
    cmp x2, x1
    b.lo .nloop
    ret

_NOPx3AllBytesASM:
    mov x2, #0
.tloop:
    nop
    nop
    nop
    add x2, x2, #1
    cmp x2, x1
    b.lo .nloop
    ret

_NOPx9AllBytesASM:
    mov x2, #0
.lloop:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add x2, x2, #1
    cmp x2, x1
    b.lo .lloop
    ret

_NOPx18AllBytesASM:
    mov x2, #0
.llloop:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add x2, x2, #1
    cmp x2, x1
    b.lo .llloop
    ret

