.global _NOPAligned64
.global _NOPAligned4
.global _NOPAligned16
.global _NOPAligned32
.global _NOPAligned60
.text

_NOPAligned64:
    mov x1, #0
.balign 64
.loop1:
    add x1, x1, #1
    cmp x1, x0
    b.lo .loop1
    ret

_NOPAligned4:
    mov x1, #0
.balign 64
    nop
.loop2:
    add x1, x1, #1
    cmp x1, x0
    b.lo .loop2
    ret

_NOPAligned16:
    mov x1, #0
.balign 64
nop
nop
nop
nop
.loop3:
    add x1, x1, #1
    cmp x1, x0
    b.lo .loop3
    ret

_NOPAligned32:
    mov x1, #0
.balign 64
nop
nop
nop
nop
nop
nop
nop
nop
.loop4:
    add x1, x1, #1
    cmp x1, x0
    b.lo .loop4
    ret

_NOPAligned60:
    mov x1, #0
.balign 64
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
.loop5:
    add x1, x1, #1
    cmp x1, x0
    b.lo .loop5
    ret
