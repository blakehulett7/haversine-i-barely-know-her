.global _Cache_4K
.global _Cache_64K
.global _Cache_1M
.global _Cache_16M
.global _Cache_256M
.global _Cache_4G
.text

// x0 is dest ptr, x1 is count

_Cache_4K:
    mov x3, #0
    mov x4, #0xfff
.loop4k:
    and x3, x3, x4
    add x2, x0, x3
    ldr q0, [x2]
    ldr q0, [x2, #16]
    ldr q0, [x2, #32]
    ldr q0, [x2, #48]
    add x3, x3, #64
    subs x1, x1, #64
    b.hi .loop4k
    ret

_Cache_64K:
    mov x3, #0
    mov x4, #0xffff
.loop64k:
    and x3, x3, x4
    add x2, x0, x3
    ldr q0, [x2]
    ldr q0, [x2, #16]
    ldr q0, [x2, #32]
    ldr q0, [x2, #48]
    add x3, x3, #64
    subs x1, x1, #64
    b.hi .loop64k
    ret

_Cache_1M:
    mov x3, #0
    mov x4, #0xfffff
.loop1m:
    and x3, x3, x4
    add x2, x0, x3
    ldr q0, [x2]
    ldr q0, [x2, #16]
    ldr q0, [x2, #32]
    ldr q0, [x2, #48]
    add x3, x3, #64
    subs x1, x1, #64
    b.hi .loop1m
    ret

_Cache_16M:
    mov x3, #0
    mov x4, #0xffffff
.loop16m:
    and x3, x3, x4
    add x2, x0, x3
    ldr q0, [x2]
    ldr q0, [x2, #16]
    ldr q0, [x2, #32]
    ldr q0, [x2, #48]
    add x3, x3, #64
    subs x1, x1, #64
    b.hi .loop16m
    ret

_Cache_256M:
    mov x3, #0
    mov x4, #0xfffffff
.loop256m:
    and x3, x3, x4
    add x2, x0, x3
    ldr q0, [x2]
    ldr q0, [x2, #16]
    ldr q0, [x2, #32]
    ldr q0, [x2, #48]
    add x3, x3, #64
    subs x1, x1, #64
    b.hi .loop256m
    ret

_Cache_4G:
    mov x3, #0
    mov x4, #0xffffffff
.loop4G:
    and x3, x3, x4
    add x2, x0, x3
    ldr q0, [x2]
    ldr q0, [x2, #16]
    ldr q0, [x2, #32]
    ldr q0, [x2, #48]
    add x3, x3, #64
    subs x1, x1, #64
    b.hi .loop4G
    ret
