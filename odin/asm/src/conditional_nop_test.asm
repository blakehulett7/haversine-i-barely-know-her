.global _ConditionalNOP
.text

_ConditionalNOP:
    mov x2, #0
.loop:
    ldrb w3, [x0, x2]
    add x2, x2, #1
    tbnz w3, #0, .skip
    nop
.skip:
    cmp x2, x1
    b.lo .loop
    ret
