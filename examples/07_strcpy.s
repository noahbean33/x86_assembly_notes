.section .data
    source: .asciz "Hello!"

.section .bss
    destination: .space 100

.section .text
.global _start

strcpy:
    pushl %ebp
    movl %esp, %ebp
    pushl %esi
    pushl %edi
    
    movl 8(%ebp), %edi         # EDI = dest
    movl 12(%ebp), %esi        # ESI = src
    
strcpy_loop:
    movb (%esi), %al           # Load byte from source
    movb %al, (%edi)           # Store byte to destination
    
    testb %al, %al             # Check if null terminator
    jz strcpy_end
    
    incl %esi                  # Advance source
    incl %edi                  # Advance destination
    jmp strcpy_loop
    
strcpy_end:
    popl %edi
    popl %esi
    popl %ebp
    ret

_start:
    pushl $source
    pushl $destination
    call strcpy
    addl $8, %esp
    
    # Exit
    movl $1, %eax
    movl $0, %ebx
    int $0x80
