# Calling Conventions (Linux 32-bit)

## Overview

Calling conventions define how functions receive parameters, return values, and manage registers. Following these conventions ensures compatibility and correct program behavior.

## Stack Fundamentals

### What is a Stack?

A **stack** is a LIFO (Last In, First Out) data structure used as temporary storage in RAM.

```
High Memory
    ↓
┌──────────┐
│          │ ← %esp (Stack Pointer)
├──────────┤
│  Data 3  │  ← Last pushed
├──────────┤
│  Data 2  │
├──────────┤
│  Data 1  │  ← First pushed
├──────────┤
│          │
└──────────┘
    ↑
Low Memory
```

### Stack Operations

**Push**: Add data to stack (moves ESP down)
```assembly
pushl %eax             # ESP -= 4, then store EAX at (ESP)
# Equivalent to:
subl $4, %esp
movl %eax, (%esp)
```

**Pop**: Remove data from stack (moves ESP up)
```assembly
popl %ebx              # Load (ESP) into EBX, then ESP += 4
# Equivalent to:
movl (%esp), %ebx
addl $4, %esp
```

## Parameter Passing

### Rule 1: Parameters on Stack (Right to Left)

Parameters are pushed onto the stack **from right to left**.

```c
// C code
int result = function(arg1, arg2, arg3);
```

```assembly
# Assembly equivalent
pushl arg3             # Push rightmost argument first
pushl arg2             # Push middle argument
pushl arg1             # Push leftmost argument
call function          # Call the function
addl $12, %esp         # Clean up stack (3 * 4 bytes)
# Result is in %eax
```

### Example: Three-Parameter Function
```c
int add_three(int a, int b, int c) {
    return a + b + c;
}

int main() {
    int result = add_three(10, 20, 30);
}
```

```assembly
# main function
main:
    pushl $30          # c = 30
    pushl $20          # b = 20
    pushl $10          # a = 10
    call add_three
    addl $12, %esp     # Clean up (3 params × 4 bytes)
    # result is in %eax
    ret

add_three:
    pushl %ebp
    movl %esp, %ebp
    
    # Access parameters
    movl 8(%ebp), %eax     # a (first parameter)
    addl 12(%ebp), %eax    # b (second parameter)
    addl 16(%ebp), %eax    # c (third parameter)
    # Result in %eax
    
    popl %ebp
    ret
```

### Stack Frame for Function Call
```
Higher addresses
    ┌──────────────┐
    │   arg3       │ 16(%ebp)
    ├──────────────┤
    │   arg2       │ 12(%ebp)
    ├──────────────┤
    │   arg1       │ 8(%ebp)
    ├──────────────┤
    │ return addr  │ 4(%ebp)
    ├──────────────┤
    │  old %ebp    │ ← %ebp (current frame)
    ├──────────────┤
    │  local1      │ -4(%ebp)
    ├──────────────┤
    │  local2      │ -8(%ebp)
    ├──────────────┤
    │              │ ← %esp (stack top)
    └──────────────┘
Lower addresses
```

## Parameter Types and Sizes

### Rule 2: Minimum 4-Byte Alignment

All parameters occupy **at least 4 bytes** on the stack.

| C Type     | Size   | Stack Space |
|------------|--------|-------------|
| `char`     | 1 byte | 4 bytes     |
| `short`    | 2 bytes| 4 bytes     |
| `int`      | 4 bytes| 4 bytes     |
| `long`     | 4 bytes| 4 bytes     |
| `pointer`  | 4 bytes| 4 bytes     |
| `float`    | 4 bytes| 4 bytes     |
| `double`   | 8 bytes| 8 bytes     |

### Example: Char and Short Parameters
```c
int func(char c, short s, int i) {
    return c + s + i;
}
```

```assembly
func:
    pushl %ebp
    movl %esp, %ebp
    
    movsbl 8(%ebp), %eax   # char c (occupies 4 bytes, use sign-extend)
    movsw 12(%ebp), %ecx   # short s (occupies 4 bytes)
    addl %ecx, %eax
    addl 16(%ebp), %eax    # int i
    
    popl %ebp
    ret
```

### Rule 3: Arrays and Matrices (Pass by Reference)

Vectors (arrays) and matrices are **always passed by reference** (pointer).

```c
void process_array(int arr[], int size) {
    arr[0] = 100;
}
```

```assembly
process_array:
    pushl %ebp
    movl %esp, %ebp
    
    movl 8(%ebp), %eax     # %eax = pointer to array
    movl $100, (%eax)      # arr[0] = 100
    
    popl %ebp
    ret
```

### Rule 4: Structs (Pass by Value)

Structures are passed **by value**, meaning the entire struct is copied onto the stack.

```c
struct Point {
    int x;
    int y;
};

int distance(struct Point p) {
    return p.x + p.y;
}
```

```assembly
# Calling code
# Assume point at -8(%ebp)
pushl -4(%ebp)         # Push y (high address first)
pushl -8(%ebp)         # Push x (low address first)
call distance
addl $8, %esp          # Clean up (struct size = 8 bytes)

distance:
    pushl %ebp
    movl %esp, %ebp
    
    movl 8(%ebp), %eax     # p.x
    addl 12(%ebp), %eax    # p.y
    
    popl %ebp
    ret
```

## Register Usage Conventions

### Rule 5: Preserved Registers

| Register Type      | Registers              | Rule                              |
|--------------------|------------------------|-----------------------------------|
| **Callee-saved**   | `%ebp`, `%esp`        | Always saved implicitly           |
| **Callee-saved**   | `%ebx`, `%esi`, `%edi`| Must be saved if modified         |
| **Caller-saved**   | `%eax`, `%ecx`, `%edx`| Can be freely modified            |

### Callee-Saved Example
```assembly
my_function:
    pushl %ebp             # Save frame pointer
    movl %esp, %ebp        # Set up new frame
    
    # Save callee-saved registers if we'll use them
    pushl %ebx
    pushl %esi
    
    # Use registers freely
    movl $100, %ebx
    movl $200, %esi
    # ... do work ...
    
    # Restore callee-saved registers
    popl %esi
    popl %ebx
    
    popl %ebp
    ret
```

### Caller-Saved Example
```assembly
main:
    movl $42, %ecx         # Using %ecx
    
    # If we need %ecx after the call, save it first
    pushl %ecx             # Save %ecx (caller's responsibility)
    
    call some_function     # May modify %eax, %ecx, %edx
    
    popl %ecx              # Restore %ecx
    # Now %ecx still has 42
```

## Return Values

### Rule 6: Return in %eax

All return values are placed in **%eax**.

```assembly
# Return an integer
my_function:
    movl $42, %eax         # Return 42
    ret

# Return result of computation
calculate:
    movl 8(%ebp), %eax     # Get parameter
    imull $5, %eax         # Multiply by 5
    # Result already in %eax
    ret
```

### Returning 64-bit Values
For values larger than 32 bits, use `%edx:%eax` pair:
- `%eax` holds low 32 bits
- `%edx` holds high 32 bits

```assembly
# Return 64-bit value
get_large_number:
    movl $0x12345678, %eax     # Low 32 bits
    movl $0x9ABCDEF0, %edx     # High 32 bits
    ret
```

## Stack Alignment

### Rule 7: 4-Byte Alignment

The stack must always be aligned to **4-byte boundaries**.

```assembly
# Good: 12 bytes of local variables (multiple of 4)
function1:
    pushl %ebp
    movl %esp, %ebp
    subl $12, %esp         # 3 local int variables
    # ...
    movl %ebp, %esp
    popl %ebp
    ret

# Bad: 6 bytes of local variables (not multiple of 4)
function2:
    pushl %ebp
    movl %esp, %ebp
    subl $6, %esp          # WRONG! Must be multiple of 4
    # Should be $8 instead
```

## Local Variables

### Rule 8: Stack Alignment for Locals

Local variables follow the same alignment rules as struct members:

| Type       | Size    | Alignment Required |
|------------|---------|-------------------|
| `char`     | 1 byte  | 1-byte (any addr) |
| `short`    | 2 bytes | 2-byte (mult of 2)|
| `int`      | 4 bytes | 4-byte (mult of 4)|
| `pointer`  | 4 bytes | 4-byte (mult of 4)|
| `double`   | 8 bytes | 4-byte (mult of 4)|

### Example: Local Variables
```c
void func() {
    char c;        // 1 byte
    int i;         // 4 bytes
    short s;       // 2 bytes
}
```

```assembly
func:
    pushl %ebp
    movl %esp, %ebp
    
    # Allocate local variables (must align to 4 bytes)
    # Layout: [padding][s:2][padding:2][i:4][c:1][padding:3]
    # Total: 12 bytes (multiple of 4)
    subl $12, %esp
    
    # Access locals
    movb $'A', -12(%ebp)   # c (1 byte at -12)
    movl $100, -8(%ebp)    # i (4 bytes at -8)
    movw $5, -4(%ebp)      # s (2 bytes at -4)
    
    movl %ebp, %esp
    popl %ebp
    ret
```

## Complete Function Template

```assembly
my_function:
    # Prologue: Set up stack frame
    pushl %ebp                # Save old frame pointer
    movl %esp, %ebp           # Set up new frame pointer
    
    # Save callee-saved registers (if needed)
    pushl %ebx
    pushl %esi
    pushl %edi
    
    # Allocate local variables (must be multiple of 4)
    subl $16, %esp            # 16 bytes of local variables
    
    # Access parameters:
    # 8(%ebp)  = first parameter
    # 12(%ebp) = second parameter
    # 16(%ebp) = third parameter
    # etc.
    
    # Access local variables:
    # -4(%ebp)  = first local
    # -8(%ebp)  = second local
    # -12(%ebp) = third local
    # etc.
    
    # Function body
    movl 8(%ebp), %eax        # Get first parameter
    addl 12(%ebp), %eax       # Add second parameter
    # Result in %eax
    
    # Epilogue: Clean up and return
    movl %ebp, %esp           # Deallocate local variables
    popl %edi                 # Restore callee-saved registers
    popl %esi
    popl %ebx
    popl %ebp                 # Restore old frame pointer
    ret                       # Return (result in %eax)
```

## Common Patterns

### Pattern 1: Void Function (No Return Value)
```assembly
void_function:
    pushl %ebp
    movl %esp, %ebp
    
    # Do work...
    
    popl %ebp
    ret                        # %eax not set
```

### Pattern 2: Leaf Function (No Calls)
```assembly
# Doesn't call other functions, doesn't need frame pointer
leaf_function:
    movl 4(%esp), %eax        # Get parameter directly
    addl $10, %eax            # Do computation
    ret                        # Return result
```

### Pattern 3: Function with Multiple Returns
```assembly
check_value:
    pushl %ebp
    movl %esp, %ebp
    
    movl 8(%ebp), %eax
    cmpl $0, %eax
    jl negative
    je zero
    # positive
    movl $1, %eax
    jmp end
negative:
    movl $-1, %eax
    jmp end
zero:
    movl $0, %eax
end:
    popl %ebp
    ret
```

## Summary of Conventions

1. **Parameters**: Pushed right-to-left on stack
2. **Small types**: char/short occupy 4 bytes on stack
3. **Arrays/matrices**: Passed by reference
4. **Structs**: Passed by value
5. **Preserved registers**: `%ebp`, `%esp` (always), `%ebx`, `%esi`, `%edi` (if used)
6. **Scratch registers**: `%eax`, `%ecx`, `%edx` (can be freely modified)
7. **Return value**: Always in `%eax`
8. **Stack alignment**: Must be multiple of 4 bytes
9. **Local variables**: Follow struct alignment rules
10. **Caller cleans stack**: After function returns, caller adjusts `%esp`

These conventions ensure that functions can be composed correctly and that code from different sources can work together.
