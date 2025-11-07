# Subroutines (Functions) in Assembly

## Overview

A **subroutine** is a set of machine instructions that performs a specific task and can be called from any point in a program or from the subroutine itself (recursion).

## Why Use Subroutines?

### Advantages
- **Code reuse**: Same code used multiple times without duplication
- **Modularity**: Code is more structured and organized
- **Maintainability**: Easier to update and debug
- **Abstraction**: Hide implementation details

### Disadvantages
- **Performance overhead**: Call/return instructions take time
- **Parameter passing**: Adds execution time
- **Complexity**: Requires additional hardware support

## Types of Subroutines

### 1. Unilevel (Leaf Functions)
- Called from main program only
- Don't call other functions
- Simplest type

### 2. Multilevel
- Can call other subroutines
- Form a call hierarchy
- Most common type

### 3. Recursive
- Call themselves (directly or indirectly)
- Require careful stack management
- Each call creates new stack frame

## Subroutine Components

### 1. Parameters
Data passed to the subroutine:
- **By value**: Copy of data
- **By reference**: Address of data (pointer)

### 2. Local Variables
Variables that exist only during subroutine execution

### 3. Invocation (Call)
Transferring control to the subroutine

### 4. Return Result
Value(s) returned to caller

### 5. Body
The actual code of the subroutine

## Stack Frame Structure

```
Higher addresses
    ┌──────────────────┐
    │   Parameter N    │ 8+4(N-1)(%ebp)
    ├──────────────────┤
    │      ...         │
    ├──────────────────┤
    │   Parameter 2    │ 12(%ebp)
    ├──────────────────┤
    │   Parameter 1    │ 8(%ebp)
    ├──────────────────┤
    │  Return Address  │ 4(%ebp)
    ├──────────────────┤
    │   Old %ebp       │ ← %ebp (current frame pointer)
    ├──────────────────┤
    │  Saved %ebx      │ -4(%ebp) (if callee-saved reg used)
    ├──────────────────┤
    │  Saved %esi      │ -8(%ebp)
    ├──────────────────┤
    │  Saved %edi      │ -12(%ebp)
    ├──────────────────┤
    │   Local var 1    │ -16(%ebp)
    ├──────────────────┤
    │   Local var 2    │ -20(%ebp)
    ├──────────────────┤
    │       ...        │
    ├──────────────────┤
    │                  │ ← %esp (stack pointer)
    └──────────────────┘
Lower addresses
```

## Standard Function Template

```assembly
function_name:
    # Prologue: Set up stack frame
    pushl %ebp                # Save old frame pointer
    movl %esp, %ebp           # Set up new frame pointer
    
    # Save callee-saved registers (if needed)
    pushl %ebx
    pushl %esi
    pushl %edi
    
    # Allocate local variables (must be multiple of 4)
    subl $N, %esp             # N = space for local variables
    
    # Function body
    # - Access parameters: 8(%ebp), 12(%ebp), etc.
    # - Access locals: -4(%ebp), -8(%ebp), etc.
    # - Perform computations
    # - Set return value in %eax
    
    # Epilogue: Clean up and return
    addl $N, %esp             # Deallocate locals (or use: movl %ebp, %esp)
    popl %edi                 # Restore callee-saved registers
    popl %esi
    popl %ebx
    popl %ebp                 # Restore old frame pointer
    ret                       # Return to caller
```

## Simple Examples

### Example 1: Function with No Parameters
```c
int get_magic_number() {
    return 42;
}
```

```assembly
get_magic_number:
    movl $42, %eax            # Return value in %eax
    ret                       # No prologue/epilogue needed
```

### Example 2: Function with One Parameter
```c
int double_value(int x) {
    return x * 2;
}
```

```assembly
double_value:
    pushl %ebp
    movl %esp, %ebp
    
    movl 8(%ebp), %eax        # Get parameter x
    shll $1, %eax             # Multiply by 2
    
    popl %ebp
    ret
```

### Example 3: Function with Multiple Parameters
```c
int add_three(int a, int b, int c) {
    return a + b + c;
}
```

```assembly
add_three:
    pushl %ebp
    movl %esp, %ebp
    
    movl 8(%ebp), %eax        # Get a
    addl 12(%ebp), %eax       # Add b
    addl 16(%ebp), %eax       # Add c
    
    popl %ebp
    ret
```

**Calling code**:
```assembly
    pushl $30                 # Push c (rightmost)
    pushl $20                 # Push b
    pushl $10                 # Push a (leftmost)
    call add_three
    addl $12, %esp            # Clean up stack (3 params × 4 bytes)
    # Result in %eax
```

### Example 4: Function with Local Variables
```c
int compute(int x, int y) {
    int temp1 = x * 2;
    int temp2 = y * 3;
    return temp1 + temp2;
}
```

```assembly
compute:
    pushl %ebp
    movl %esp, %ebp
    subl $8, %esp             # Allocate 2 local variables
    
    # temp1 = x * 2
    movl 8(%ebp), %eax
    shll $1, %eax
    movl %eax, -4(%ebp)       # Store temp1
    
    # temp2 = y * 3
    movl 12(%ebp), %eax
    leal (%eax,%eax,2), %eax  # EAX = EAX * 3
    movl %eax, -8(%ebp)       # Store temp2
    
    # return temp1 + temp2
    movl -4(%ebp), %eax
    addl -8(%ebp), %eax
    
    movl %ebp, %esp           # Deallocate locals
    popl %ebp
    ret
```

## Parameter Passing Methods

### Pass by Value
```c
void increment(int x) {
    x = x + 1;  // Only modifies local copy
}
```

```assembly
increment:
    pushl %ebp
    movl %esp, %ebp
    
    movl 8(%ebp), %eax
    incl %eax                 # Modify local copy (doesn't affect caller)
    
    popl %ebp
    ret
```

### Pass by Reference (Pointer)
```c
void increment_ref(int *x) {
    *x = *x + 1;  // Modifies original value
}
```

```assembly
increment_ref:
    pushl %ebp
    movl %esp, %ebp
    
    movl 8(%ebp), %eax        # Get pointer
    movl (%eax), %edx         # Load value
    incl %edx                 # Increment
    movl %edx, (%eax)         # Store back
    
    popl %ebp
    ret
```

**Calling code**:
```assembly
    leal variable, %eax       # Get address of variable
    pushl %eax                # Pass pointer
    call increment_ref
    addl $4, %esp             # Clean up
```

### Arrays (Always by Reference)
```c
int sum_array(int arr[], int size) {
    int sum = 0;
    for (int i = 0; i < size; i++) {
        sum += arr[i];
    }
    return sum;
}
```

```assembly
sum_array:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    
    movl 8(%ebp), %edx        # EDX = arr (pointer)
    movl 12(%ebp), %ecx       # ECX = size
    xorl %eax, %eax           # sum = 0
    xorl %ebx, %ebx           # i = 0
    
loop:
    cmpl %ecx, %ebx
    jge end_loop
    
    addl (%edx,%ebx,4), %eax  # sum += arr[i]
    incl %ebx
    jmp loop
    
end_loop:
    popl %ebx
    popl %ebp
    ret
```

## Preserving Registers

### Caller-Saved Registers
**Caller** must save if needed after call: `%eax`, `%ecx`, `%edx`

```assembly
caller:
    movl $10, %ecx            # Using %ecx
    
    # Need to preserve %ecx across call
    pushl %ecx                # Save %ecx
    call some_function        # May modify %ecx
    popl %ecx                 # Restore %ecx
    
    # %ecx still has original value
```

### Callee-Saved Registers
**Callee** must save and restore if modified: `%ebx`, `%esi`, `%edi`, `%ebp`, `%esp`

```assembly
callee:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx                # Save %ebx
    pushl %esi                # Save %esi
    
    # Use %ebx and %esi freely
    movl $100, %ebx
    movl $200, %esi
    
    # Restore before returning
    popl %esi
    popl %ebx
    popl %ebp
    ret
```

## Recursive Functions

### Example 1: Factorial
```c
int factorial(int n) {
    if (n <= 1)
        return 1;
    else
        return n * factorial(n - 1);
}
```

```assembly
factorial:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    
    movl 8(%ebp), %ebx        # EBX = n
    
    # Base case: n <= 1
    cmpl $1, %ebx
    jg recursive_case
    
base_case:
    movl $1, %eax             # return 1
    jmp end
    
recursive_case:
    # Recursive call: factorial(n-1)
    decl %ebx
    pushl %ebx                # Push n-1
    call factorial
    addl $4, %esp             # Clean up
    
    # Multiply n * factorial(n-1)
    movl 8(%ebp), %ebx        # Restore n
    imull %ebx, %eax          # EAX = n * factorial(n-1)
    
end:
    popl %ebx
    popl %ebp
    ret
```

### Example 2: Fibonacci
```c
int fib(int n) {
    if (n <= 1)
        return n;
    return fib(n-1) + fib(n-2);
}
```

```assembly
fib:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    
    movl 8(%ebp), %eax        # EAX = n
    
    # Base case: n <= 1
    cmpl $1, %eax
    jle base_case
    
recursive_case:
    # Call fib(n-1)
    decl %eax
    pushl %eax
    call fib
    addl $4, %esp
    movl %eax, %ebx           # Save fib(n-1)
    
    # Call fib(n-2)
    movl 8(%ebp), %eax
    subl $2, %eax
    pushl %eax
    call fib
    addl $4, %esp
    
    # Return fib(n-1) + fib(n-2)
    addl %ebx, %eax
    jmp end
    
base_case:
    # return n (already in %eax)
    
end:
    popl %ebx
    popl %ebp
    ret
```

## Advanced Examples

### Example 1: Swap Function
```c
void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}
```

```assembly
swap:
    pushl %ebp
    movl %esp, %ebp
    
    movl 8(%ebp), %ecx        # ECX = pointer to a
    movl 12(%ebp), %edx       # EDX = pointer to b
    
    movl (%ecx), %eax         # EAX = *a (temp)
    movl (%edx), %ebx         # EBX = *b
    movl %ebx, (%ecx)         # *a = *b
    movl %eax, (%edx)         # *b = temp
    
    popl %ebp
    ret
```

### Example 2: String Length
```c
int strlen(const char *str) {
    int len = 0;
    while (*str != '\0') {
        len++;
        str++;
    }
    return len;
}
```

```assembly
strlen:
    pushl %ebp
    movl %esp, %ebp
    
    movl 8(%ebp), %ecx        # ECX = str
    xorl %eax, %eax           # len = 0
    
loop:
    cmpb $0, (%ecx)           # Check if *str == '\0'
    je end_loop
    
    incl %eax                 # len++
    incl %ecx                 # str++
    jmp loop
    
end_loop:
    popl %ebp
    ret
```

### Example 3: Structure Parameter
```c
struct Point {
    int x;
    int y;
};

int distance_squared(struct Point p) {
    return p.x * p.x + p.y * p.y;
}
```

```assembly
distance_squared:
    pushl %ebp
    movl %esp, %ebp
    
    # Struct passed by value: x at 8(%ebp), y at 12(%ebp)
    movl 8(%ebp), %eax        # EAX = p.x
    imull %eax, %eax          # EAX = x * x
    
    movl 12(%ebp), %ecx       # ECX = p.y
    imull %ecx, %ecx          # ECX = y * y
    
    addl %ecx, %eax           # EAX = x*x + y*y
    
    popl %ebp
    ret
```

**Calling code**:
```assembly
    # Push struct members (right to left in memory)
    pushl point_y             # Push y
    pushl point_x             # Push x
    call distance_squared
    addl $8, %esp             # Clean up (struct size)
```

### Example 4: Matrix Function
```c
void matrix_add(int a[3][3], int b[3][3], int result[3][3]) {
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            result[i][j] = a[i][j] + b[i][j];
        }
    }
}
```

```assembly
matrix_add:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi
    
    movl 8(%ebp), %esi        # ESI = a
    movl 12(%ebp), %edi       # EDI = b
    movl 16(%ebp), %ebx       # EBX = result
    
    xorl %ecx, %ecx           # i = 0
    
outer_loop:
    cmpl $3, %ecx
    jge end_outer
    
    xorl %edx, %edx           # j = 0
    
inner_loop:
    cmpl $3, %edx
    jge end_inner
    
    # Calculate offset: (i * 3 + j) * 4
    movl %ecx, %eax
    imull $3, %eax
    addl %edx, %eax
    
    # result[i][j] = a[i][j] + b[i][j]
    movl (%esi,%eax,4), %ebp  # a[i][j]
    addl (%edi,%eax,4), %ebp  # + b[i][j]
    movl %ebp, (%ebx,%eax,4)  # store to result[i][j]
    
    incl %edx
    jmp inner_loop
    
end_inner:
    incl %ecx
    jmp outer_loop
    
end_outer:
    popl %edi
    popl %esi
    popl %ebx
    popl %ebp
    ret
```

## Leaf vs Non-Leaf Functions

### Leaf Function (No Frame Needed)
```assembly
# Simple function that doesn't call others
leaf_function:
    movl 4(%esp), %eax        # Get parameter directly from stack
    addl $10, %eax            # Do computation
    ret                       # Return (no prologue/epilogue)
```

### Non-Leaf Function (Frame Required)
```assembly
# Function that calls other functions
non_leaf_function:
    pushl %ebp                # Must set up frame
    movl %esp, %ebp
    
    # Call other function
    pushl $10
    call other_function
    addl $4, %esp
    
    popl %ebp
    ret
```

## Best Practices

1. **Always preserve callee-saved registers** if you modify them
2. **Clean up the stack** after function calls (caller's responsibility)
3. **Return value in %eax** (convention)
4. **Align stack to 4 bytes** (or 16 bytes for modern systems)
5. **Use frame pointer** for functions with local variables or calls
6. **Document your functions** with comments about parameters and return value
7. **Test recursive functions** with base cases

## Common Mistakes

1. **Forgetting to clean up stack** after call
2. **Not preserving callee-saved registers**
3. **Wrong parameter access offsets**
4. **Stack misalignment**
5. **Infinite recursion** (missing or wrong base case)
6. **Modifying caller-saved registers** without saving them first

## Summary

- **Subroutines** enable code reuse and modularity
- **Stack frames** manage parameters, return addresses, and local variables
- **Calling convention** defines parameter passing and register usage
- **Prologue** sets up the stack frame
- **Epilogue** cleans up before returning
- **Recursion** requires careful stack management
- **Parameters** accessed at positive offsets from %ebp
- **Local variables** accessed at negative offsets from %ebp
- **Return value** always in %eax

Understanding subroutines is essential for writing modular, maintainable assembly code.
