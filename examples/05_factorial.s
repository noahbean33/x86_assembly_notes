.section .text
.global _start

factorial:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    
    movl 8(%ebp), %ebx         # EBX = n
    
    # Base case: n <= 1
    cmpl $1, %ebx
    jg recursive_case
    
    movl $1, %eax              # return 1
    jmp fact_end
    
recursive_case:
    # factorial(n - 1)
    decl %ebx
    pushl %ebx
    call factorial
    addl $4, %esp
    
    # n * factorial(n-1)
    movl 8(%ebp), %ebx
    imull %ebx, %eax
    
fact_end:
    popl %ebx
    popl %ebp
    ret

_start:
    # Calculate factorial(5)
    pushl $5
    call factorial
    addl $4, %esp
    
    # Exit with result
    movl %eax, %ebx
    movl $1, %eax
    int $0x80
