.section .data
    message: .asciz "Hello, World!\n"

.section .text
.global _start

_start:
    # Write syscall
    movl $4, %eax              # syscall: write
    movl $1, %ebx              # file descriptor: stdout
    leal message, %ecx         # buffer address
    movl $14, %edx             # buffer length
    int $0x80                  # make syscall

    # Exit syscall
    movl $1, %eax              # syscall: exit
    movl $0, %ebx              # exit code: 0
    int $0x80                  # make syscall
