.section .data
    array: .long 5, 2, -4, 1, 3
    size: .long 5

.section .text
.global _start

sum_array:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    
    movl 8(%ebp), %edx         # EDX = array pointer
    movl 12(%ebp), %ecx        # ECX = size
    xorl %eax, %eax            # sum = 0
    xorl %ebx, %ebx            # i = 0
    
sum_loop:
    cmpl %ecx, %ebx
    jge sum_end
    
    addl (%edx,%ebx,4), %eax   # sum += arr[i]
    incl %ebx                  # i++
    jmp sum_loop
    
sum_end:
    popl %ebx
    popl %ebp
    ret

_start:
    # Call sum_array
    pushl size
    pushl $array
    call sum_array
    addl $8, %esp
    
    # Exit with result
    movl %eax, %ebx            # Exit code = result
    movl $1, %eax              # syscall: exit
    int $0x80
