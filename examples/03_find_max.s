.section .data
    array: .long 5, 12, -4, 23, 3
    size: .long 5

.section .text
.global _start

find_max:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    
    movl 8(%ebp), %edx         # EDX = array pointer
    movl 12(%ebp), %ecx        # ECX = size
    
    movl (%edx), %eax          # max = arr[0]
    movl $1, %ebx              # i = 1
    
max_loop:
    cmpl %ecx, %ebx
    jge max_end
    
    movl (%edx,%ebx,4), %esi   # ESI = arr[i]
    cmpl %eax, %esi            # Compare arr[i] with max
    jle skip_update            # If arr[i] <= max, skip
    
    movl %esi, %eax            # max = arr[i]
    
skip_update:
    incl %ebx                  # i++
    jmp max_loop
    
max_end:
    popl %ebx
    popl %ebp
    ret

_start:
    pushl size
    pushl $array
    call find_max
    addl $8, %esp
    
    # Exit with max value
    movl %eax, %ebx
    movl $1, %eax
    int $0x80
