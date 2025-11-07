.section .data
    array: .long 64, 34, 25, 12, 22, 11, 90
    size: .long 7

.section .text
.global _start

bubble_sort:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi
    
    movl 8(%ebp), %esi         # ESI = array pointer
    movl 12(%ebp), %ecx        # ECX = size
    decl %ecx                  # ECX = size - 1
    
    xorl %edi, %edi            # i = 0
    
outer_loop:
    cmpl %ecx, %edi
    jge sort_end
    
    xorl %ebx, %ebx            # j = 0
    
inner_loop:
    movl %ecx, %edx
    subl %edi, %edx            # EDX = size - i - 1
    cmpl %edx, %ebx
    jge inner_end
    
    # Compare arr[j] and arr[j+1]
    movl (%esi,%ebx,4), %eax   # EAX = arr[j]
    movl 4(%esi,%ebx,4), %edx  # EDX = arr[j+1]
    cmpl %edx, %eax
    jle no_swap                # If arr[j] <= arr[j+1], skip swap
    
    # Swap
    movl %edx, (%esi,%ebx,4)   # arr[j] = arr[j+1]
    movl %eax, 4(%esi,%ebx,4)  # arr[j+1] = temp
    
no_swap:
    incl %ebx                  # j++
    jmp inner_loop
    
inner_end:
    incl %edi                  # i++
    jmp outer_loop
    
sort_end:
    popl %edi
    popl %esi
    popl %ebx
    popl %ebp
    ret

_start:
    pushl size
    pushl $array
    call bubble_sort
    addl $8, %esp
    
    # Exit
    movl $1, %eax
    movl $0, %ebx
    int $0x80
