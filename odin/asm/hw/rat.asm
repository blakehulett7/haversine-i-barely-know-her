                    Dest    Src
    mov rax, 1      s0
    mov rbx, 2      s1
    mov rcx, 3      s2
    mov rdx, 4      s3
    add rax, rbx    s4      s0,s1
	add rcx, rdx    s5      s2,s3
	add rax, rcx    s6      s4,s5
    mov rcx, rbx    s1      s1
	inc rax         s7      s6
    dec rcx         s8      s1
    sub rax, rbx    s9      s7,s1
	sub rcx, rdx    s10     s8,s3
	sub rax, rcx    s11     s9,s10
