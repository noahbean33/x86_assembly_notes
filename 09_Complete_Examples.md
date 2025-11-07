# Complete Assembly Examples

## Overview

This document provides complete, working assembly programs demonstrating various concepts. Each example includes C code and corresponding assembly implementation.

---

## Example 1: Hello World

### C Version
```c
#include <stdio.h>

int main() {
    printf("Hello, World!\n");
    return 0;
}
```

### Assembly Version
```assembly
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
```

---

## Example 2: Sum of Array

### C Version
```c
int sum_array(int arr[], int size) {
    int sum = 0;
    for (int i = 0; i < size; i++) {
        sum += arr[i];
    }
    return sum;
}

int main() {
    int numbers[] = {5, 2, -4, 1, 3};
    int result = sum_array(numbers, 5);
    return result;
}
```

### Assembly Version
```assembly
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
```

---

## Example 3: Find Maximum in Array

### C Version
```c
int find_max(int arr[], int size) {
    int max = arr[0];
    for (int i = 1; i < size; i++) {
        if (arr[i] > max) {
            max = arr[i];
        }
    }
    return max;
}
```

### Assembly Version
```assembly
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
```

---

## Example 4: Bubble Sort

### C Version
```c
void bubble_sort(int arr[], int size) {
    for (int i = 0; i < size - 1; i++) {
        for (int j = 0; j < size - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                int temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }
}
```

### Assembly Version
```assembly
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
```

---

## Example 5: Factorial (Recursive)

### C Version
```c
int factorial(int n) {
    if (n <= 1)
        return 1;
    return n * factorial(n - 1);
}
```

### Assembly Version
```assembly
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
```

---

## Example 6: String Length

### C Version
```c
int strlen(const char *str) {
    int len = 0;
    while (str[len] != '\0') {
        len++;
    }
    return len;
}
```

### Assembly Version
```assembly
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
```

---

## Example 7: String Copy

### C Version
```c
void strcpy(char *dest, const char *src) {
    int i = 0;
    while (src[i] != '\0') {
        dest[i] = src[i];
        i++;
    }
    dest[i] = '\0';
}
```

### Assembly Version
```assembly
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
```

---

## Example 8: Matrix Multiplication

### C Version
```c
void matrix_multiply(int a[2][2], int b[2][2], int result[2][2]) {
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            result[i][j] = 0;
            for (int k = 0; k < 2; k++) {
                result[i][j] += a[i][k] * b[k][j];
            }
        }
    }
}
```

### Assembly Version
```assembly
.section .data
    matrix_a: .long 1, 2, 3, 4
    matrix_b: .long 5, 6, 7, 8

.section .bss
    result: .space 16          # 2x2 matrix of ints

.section .text
.global _start

matrix_multiply:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi
    subl $4, %esp              # Local variable for temp
    
    movl 8(%ebp), %esi         # ESI = matrix a
    movl 12(%ebp), %edi        # EDI = matrix b
    movl 16(%ebp), %ebx        # EBX = result
    
    xorl %ecx, %ecx            # i = 0
    
i_loop:
    cmpl $2, %ecx
    jge i_end
    
    xorl %edx, %edx            # j = 0
    
j_loop:
    cmpl $2, %edx
    jge j_end
    
    movl $0, -4(%ebp)          # sum = 0
    xorl %eax, %eax            # k = 0
    
k_loop:
    cmpl $2, %eax
    jge k_end
    
    # Calculate a[i][k] offset: (i*2 + k)*4
    pushl %eax
    movl %ecx, %eax
    shll $1, %eax              # i * 2
    addl (%esp), %eax          # + k
    movl (%esi,%eax,4), %eax   # a[i][k]
    
    # Calculate b[k][j] offset: (k*2 + j)*4
    movl (%esp), %ebp          # k
    shll $1, %ebp              # k * 2
    addl %edx, %ebp            # + j
    imull (%edi,%ebp,4), %eax  # a[i][k] * b[k][j]
    
    movl %ebp, %ebp            # Restore EBP
    movl 4(%esp), %ebp
    addl %eax, -4(%ebp)        # sum += product
    
    popl %eax
    incl %eax                  # k++
    jmp k_loop
    
k_end:
    # Store result[i][j]
    movl %ecx, %eax
    shll $1, %eax
    addl %edx, %eax
    movl -4(%ebp), %ebp
    movl 16(%ebp), %ebp
    movl %ebp, (%ebx,%eax,4)
    movl 4(%esp), %ebp
    
    incl %edx                  # j++
    jmp j_loop
    
j_end:
    incl %ecx                  # i++
    jmp i_loop
    
i_end:
    addl $4, %esp
    popl %edi
    popl %esi
    popl %ebx
    popl %ebp
    ret

_start:
    pushl $result
    pushl $matrix_b
    pushl $matrix_a
    call matrix_multiply
    addl $12, %esp
    
    # Exit
    movl $1, %eax
    movl $0, %ebx
    int $0x80
```

---

## Example 9: Binary Search

### C Version
```c
int binary_search(int arr[], int size, int target) {
    int left = 0;
    int right = size - 1;
    
    while (left <= right) {
        int mid = left + (right - left) / 2;
        
        if (arr[mid] == target)
            return mid;
        else if (arr[mid] < target)
            left = mid + 1;
        else
            right = mid - 1;
    }
    
    return -1;  // Not found
}
```

### Assembly Version
```assembly
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
```

---

## Example 10: Calculator (Function Pointers)

### C Version
```c
int add(int a, int b) { return a + b; }
int subtract(int a, int b) { return a - b; }
int multiply(int a, int b) { return a * b; }

int calculate(int a, int b, int (*operation)(int, int)) {
    return operation(a, b);
}
```

### Assembly Version
```assembly
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
```

---

## Example 11: Linked List Traversal

### C Version
```c
struct Node {
    int data;
    struct Node *next;
};

int sum_list(struct Node *head) {
    int sum = 0;
    while (head != NULL) {
        sum += head->data;
        head = head->next;
    }
    return sum;
}
```

### Assembly Version
```assembly
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
```

---

## Building and Running Examples

### Using GAS (GNU Assembler) on Linux

```bash
# Assemble
as --32 example.s -o example.o

# Link
ld -m elf_i386 example.o -o example

# Run
./example

# Check exit code
echo $?
```

### Using NASM on Linux

```bash
# Assemble
nasm -f elf32 example.asm -o example.o

# Link
ld -m elf_i386 example.o -o example

# Run
./example
```

### Debugging with GDB

```bash
# Compile with debug symbols
as --32 -g example.s -o example.o
ld -m elf_i386 example.o -o example

# Debug
gdb ./example

# GDB commands:
# break _start    - Set breakpoint
# run             - Run program
# step            - Step one instruction
# info registers  - Show register values
# x/10x $esp      - Examine stack
# continue        - Continue execution
```

---

## Summary

These examples demonstrate:
- **Basic I/O**: Hello World
- **Array operations**: Sum, max, sort
- **Recursion**: Factorial
- **String manipulation**: Length, copy
- **Matrix operations**: Multiplication
- **Search algorithms**: Binary search
- **Function pointers**: Calculator
- **Data structures**: Linked list

Each example follows proper calling conventions and demonstrates real-world assembly programming techniques.
