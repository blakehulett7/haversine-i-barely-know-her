.global _RATAdd
.global _RATMovAdd
.text

_RATAdd:
.aloop:
    add x1, x1, #1
    add x1, x1, #1
    subs x0, x0, #1
    b.ne .aloop
    ret

_RATMovAdd:
.bloop:
    mov x1, x0
    add x1, x1, #1
    mov x1, x0
    add x1, x1, #1
    subs x0, x0, #1
    b.ne .bloop
    ret
