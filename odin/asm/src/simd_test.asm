.global _Read_4x3
.global _Read_8x3
.global _Read_16x2
.global _Read_16x3
.global _Read_32x2
.global _Read_32x3
.global _Read_64x3
.text

_Read_4x3:
.loop4:
    ldr w2, [x0]
    ldr w2, [x0]
    ldr w2, [x0]
    subs x1, x1, #12
    b.hi .loop4
    ret

_Read_8x3:
.loop8:
    ldr x2, [x0]
    ldr x2, [x0]
    ldr x2, [x0]
    subs x1, x1, #24
    b.hi .loop8
    ret

_Read_16x2:
.loop16x2:
    ldr q0, [x0]
    ldr q0, [x0]
    subs x1, x1, #32
    b.hi .loop16x2
    ret

_Read_16x3:
.loop16:
    ldr q0, [x0]
    ldr q0, [x0]
    ldr q0, [x0]
    subs x1, x1, #48
    b.hi .loop16
    ret

_Read_32x2:
.loop32x2:
    ldp q0, q1, [x0]
    ldp q0, q1, [x0]
    subs x1, x1, #64
    b.hi .loop32x2
    ret


_Read_32x3:
.loop32:
    ldp q0, q1, [x0]
    ldp q0, q1, [x0]
    ldp q0, q1, [x0]
    subs x1, x1, #96
    b.hi .loop32
    ret

_Read_64x3:
    smstart sm
.loop64:
    ldr z0, [x0]
    ldr z0, [x0]
    ldr z0, [x0]
    subs x1, x1, #192
    b.hi .loop64
    smstop sm
    ret
