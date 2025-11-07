.section .data
    matrix_a: .long 1, 2, 3, 4
    matrix_b: .long 5, 6, 7, 8

.section .bss
    result: .space 16          # 2x2 matrix of ints

.section .text
.global _start

matrix_multiply:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi
    subl $4, %esp              # Local variable for temp
    
    movl 8(%ebp), %esi         # ESI = matrix a
    movl 12(%ebp), %edi        # EDI = matrix b
    movl 16(%ebp), %ebx        # EBX = result
    
    xorl %ecx, %ecx            # i = 0
    
i_loop:
    cmpl $2, %ecx
    jge i_end
    
    xorl %edx, %edx            # j = 0
    
j_loop:
    cmpl $2, %edx
    jge j_end
    
    movl $0, -4(%ebp)          # sum = 0
    xorl %eax, %eax            # k = 0
    
k_loop:
    cmpl $2, %eax
    jge k_end
    
    # Calculate a[i][k] offset: (i*2 + k)*4
    pushl %eax
    movl %ecx, %eax
    shll $1, %eax              # i * 2
    addl (%esp), %eax          # + k
    movl (%esi,%eax,4), %eax   # a[i][k]
    
    # Calculate b[k][j] offset: (k*2 + j)*4
    movl (%esp), %ebp          # k
    shll $1, %ebp              # k * 2
    addl %edx, %ebp            # + j
    imull (%edi,%ebp,4), %eax  # a[i][k] * b[k][j]
    
    movl %ebp, %ebp            # Restore EBP
    movl 4(%esp), %ebp
    addl %eax, -4(%ebp)        # sum += product
    
    popl %eax
    incl %eax                  # k++
    jmp k_loop
    
k_end:
    # Store result[i][j]
    movl %ecx, %eax
    shll $1, %eax
    addl %edx, %eax
    movl -4(%ebp), %ebp
    movl 16(%ebp), %ebp
    movl %ebp, (%ebx,%eax,4)
    movl 4(%esp), %ebp
    
    incl %edx                  # j++
    jmp j_loop
    
j_end:
    incl %ecx                  # i++
    jmp i_loop
    
i_end:
    addl $4, %esp
    popl %edi
    popl %esi
    popl %ebx
    popl %ebp
    ret

_start:
    pushl $result
    pushl $matrix_b
    pushl $matrix_a
    call matrix_multiply
    addl $12, %esp
    
    # Exit
    movl $1, %eax
    movl $0, %ebx
    int $0x80
