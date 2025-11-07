.section .data
    # Create linked list: 10 -> 20 -> 30 -> NULL
    node3: .long 30, 0         # data=30, next=NULL
    node2: .long 20, node3     # data=20, next=node3
    node1: .long 10, node2     # data=10, next=node2

.section .text
.global _start

sum_list:
    pushl %ebp
    movl %esp, %ebp
    
    movl 8(%ebp), %ecx         # ECX = head pointer
    xorl %eax, %eax            # sum = 0
    
list_loop:
    testl %ecx, %ecx           # Check if head == NULL
    jz list_end
    
    addl (%ecx), %eax          # sum += head->data
    movl 4(%ecx), %ecx         # head = head->next
    jmp list_loop
    
list_end:
    popl %ebp
    ret

_start:
    pushl $node1
    call sum_list
    addl $4, %esp
    
    # Exit with sum (should be 60)
    movl %eax, %ebx
    movl $1, %eax
    int $0x80
