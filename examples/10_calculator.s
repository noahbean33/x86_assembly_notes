.section .text
.global _start

add:
    movl 4(%esp), %eax
    addl 8(%esp), %eax
    ret

subtract:
    movl 4(%esp), %eax
    subl 8(%esp), %eax
    ret

multiply:
    movl 4(%esp), %eax
    imull 8(%esp), %eax
    ret

calculate:
    pushl %ebp
    movl %esp, %ebp
    
    # Push parameters for function call
    pushl 12(%ebp)             # b
    pushl 8(%ebp)              # a
    
    # Call function pointer
    call *16(%ebp)
    
    addl $8, %esp
    
    popl %ebp
    ret

_start:
    # Call calculate(10, 5, add)
    pushl $add
    pushl $5
    pushl $10
    call calculate
    addl $12, %esp
    
    # Result in EAX = 15
    
    # Exit
    movl %eax, %ebx
    movl $1, %eax
    int $0x80
