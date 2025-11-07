.section .data
    sorted_array: .long 1, 3, 5, 7, 9, 11, 13, 15
    size: .long 8
    target: .long 7

.section .text
.global _start

binary_search:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi
    
    movl 8(%ebp), %esi         # ESI = array pointer
    movl 12(%ebp), %ecx        # ECX = size
    movl 16(%ebp), %edi        # EDI = target
    
    xorl %ebx, %ebx            # left = 0
    decl %ecx                  # right = size - 1
    
search_loop:
    cmpl %ecx, %ebx
    jg not_found
    
    # mid = left + (right - left) / 2
    movl %ecx, %eax
    subl %ebx, %eax
    shrl $1, %eax              # (right - left) / 2
    addl %ebx, %eax            # left + (right - left) / 2
    
    # Compare arr[mid] with target
    movl (%esi,%eax,4), %edx   # EDX = arr[mid]
    cmpl %edi, %edx
    je found
    jl search_right
    
search_left:
    # arr[mid] > target: right = mid - 1
    leal -1(%eax), %ecx
    jmp search_loop
    
search_right:
    # arr[mid] < target: left = mid + 1
    leal 1(%eax), %ebx
    jmp search_loop
    
found:
    # Return index (in EAX)
    jmp search_end
    
not_found:
    movl $-1, %eax             # Return -1
    
search_end:
    popl %edi
    popl %esi
    popl %ebx
    popl %ebp
    ret

_start:
    pushl target
    pushl size
    pushl $sorted_array
    call binary_search
    addl $12, %esp
    
    # Exit with result
    movl %eax, %ebx
    movl $1, %eax
    int $0x80
