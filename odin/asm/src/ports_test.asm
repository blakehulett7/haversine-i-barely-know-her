.global _Read_x1
.global _Read_x2
.global _Read_x3
.global _Read_x4
.global _Write_x1
.global _Write_x2
.global _Write_x3
.global _Write_x4
.text

_Read_x1:
.loop1:
    ldr x2, [x0]
    subs x1, x1, #1
    b.hi .loop1
    ret

_Read_x2:
.loop2:
    ldr x2, [x0]
    ldr x2, [x0]
    subs x1, x1, #2
    b.hi .loop2
    ret

_Read_x3:
.loop3:
    ldr x2, [x0]
    ldr x2, [x0]
    ldr x2, [x0]
    subs x1, x1, #3
    b.hi .loop3
    ret

_Read_x4:
.loop4:
    ldr x2, [x0]
    ldr x2, [x0]
    ldr x2, [x0]
    ldr x2, [x0]
    subs x1, x1, #4
    b.hi .loop4
    ret

_Write_x1:
    mov x2, #1
.wloop1:
    str x2, [x0]
    subs x1, x1, #1
    b.hi .wloop1
    ret

_Write_x2:
    mov x2, #1
.wloop2:
    str x2, [x0]
    str x2, [x0]
    subs x1, x1, #2
    b.hi .wloop2
    ret

_Write_x3:
    mov x2, #1
.wloop3:
    str x2, [x0]
    str x2, [x0]
    str x2, [x0]
    subs x1, x1, #3
    b.hi .wloop3
    ret

_Write_x4:
    mov x2, #1
.wloop4:
    str x2, [x0]
    str x2, [x0]
    str x2, [x0]
    str x2, [x0]
    subs x1, x1, #4
    b.hi .wloop4
    ret
