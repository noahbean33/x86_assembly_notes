.section .data
    test_string: .asciz "Hello, Assembly!"

.section .text
.global _start

strlen:
    pushl %ebp
    movl %esp, %ebp
    
    movl 8(%ebp), %ecx         # ECX = string pointer
    xorl %eax, %eax            # length = 0
    
strlen_loop:
    cmpb $0, (%ecx,%eax)       # Check if str[len] == '\0'
    je strlen_end
    
    incl %eax                  # len++
    jmp strlen_loop
    
strlen_end:
    popl %ebp
    ret

_start:
    pushl $test_string
    call strlen
    addl $4, %esp
    
    # Exit with string length
    movl %eax, %ebx
    movl $1, %eax
    int $0x80
