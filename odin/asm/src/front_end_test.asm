.global _MOVAllBytesASM
.global _NOPAllBytesASM
.global _CMPAllBytesASM
.global _DECAllBytesASM
.text

_MOVAllBytesASM:
    mov x2, #0
.mloop:
    strb w2, [x0, x2]
    add x2, x2, #1
    cmp x2, x1
    b.lo .mloop
    ret

_NOPAllBytesASM:
    mov x2, #0
.nloop:
    .word 0xd503201f
    add x2, x2, #1
    cmp x2, x1
    b.lo .nloop
    ret

_CMPAllBytesASM:
    mov x2, #0
.cloop:
    add x2, x2, #1
    cmp x2, x1
    b.lo .cloop
    ret

_DECAllBytesASM:
.dloop:
    subs x1, x1, #1
    b.ne .dloop
    ret
