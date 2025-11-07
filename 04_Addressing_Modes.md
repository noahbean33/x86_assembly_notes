# Addressing Modes

## Overview

Addressing modes specify how operands are accessed in assembly instructions. x86 supports three main addressing modes: **Immediate**, **Register**, and **Memory**.

## Three Main Addressing Modes

### 1. Immediate Addressing

**Format**: `$value`

The operand is a constant value encoded directly in the instruction.

```assembly
movl $10, %eax             # Move constant 10 into EAX
movl $0x2A, %ebx           # Move hexadecimal 0x2A into EBX
movl $-5, %ecx             # Move -5 into ECX
addl $100, %eax            # Add 100 to EAX
```

**Size encoding**:
- 1 byte: `-128` to `127` or `0` to `255`
- 2 bytes: `-32768` to `32767` or `0` to `65535`
- 4 bytes: `-2,147,483,648` to `2,147,483,647` or `0` to `4,294,967,295`

```assembly
movl $0x2A, %eax           # 1-byte immediate: 0x2A
movl $0x2A45, %eax         # 2-byte immediate: 0x2A45
movl $0x2A45D1C3, %eax     # 4-byte immediate: 0x2A45D1C3
```

### 2. Register Addressing

**Format**: `%register`

The operand is in a register.

```assembly
movl %eax, %ebx            # Copy EAX to EBX
addl %ecx, %eax            # Add ECX to EAX
movb %ah, %al              # Copy AH to AL (8-bit)
movw %ax, %bx              # Copy AX to BX (16-bit)
```

**Available registers**: `%eax`, `%ebx`, `%ecx`, `%edx`, `%esi`, `%edi`, `%ebp`, `%esp`

**Sub-registers**: `%ax`, `%ah`, `%al`, `%bx`, `%bh`, `%bl`, `%cx`, `%ch`, `%cl`, `%dx`, `%dh`, `%dl`

### 3. Memory Addressing

**General Format**: `D(Rb, Ri, S)`

**Effective Address** = `Rb + Ri * S + D`

Where:
- **D** = Displacement (constant offset): 0, 1, 2, or 4 bytes
- **Rb** = Base register: any of the 8 general-purpose registers
- **Ri** = Index register: any register except `%esp`
- **S** = Scale factor: 1, 2, 4, or 8

```assembly
# Full format example
movl 8(%ebx,%ecx,4), %eax  # EAX = Memory[EBX + ECX*4 + 8]
```

## Memory Addressing Forms

### Form 1: Direct (Absolute)
**Format**: `address` or `label`

```assembly
movl 0x8048000, %eax       # Load from absolute address
movl value, %ebx           # Load from label 'value'
```

### Form 2: Indirect (Register)
**Format**: `(Rb)`

Effective Address = `Rb`

```assembly
movl (%ebx), %eax          # EAX = Memory[EBX]
movl (%esp), %ecx          # ECX = Memory[ESP] (top of stack)
```

**Example**:
```assembly
leal buffer, %ebx          # EBX = address of buffer
movl (%ebx), %eax          # EAX = first element of buffer
```

### Form 3: Base + Displacement
**Format**: `D(Rb)`

Effective Address = `Rb + D`

```assembly
movl 4(%ebp), %eax         # EAX = Memory[EBP + 4]
movl -8(%ebp), %ebx        # EBX = Memory[EBP - 8]
movl 100(%esi), %ecx       # ECX = Memory[ESI + 100]
```

**Common use**: Accessing struct members and stack variables

```assembly
# Accessing function parameters
movl 8(%ebp), %eax         # First parameter
movl 12(%ebp), %ebx        # Second parameter

# Accessing local variables
movl -4(%ebp), %ecx        # First local variable
movl -8(%ebp), %edx        # Second local variable
```

### Form 4: Base + Index
**Format**: `(Rb, Ri)`

Effective Address = `Rb + Ri`

```assembly
movl (%ebx,%ecx), %eax     # EAX = Memory[EBX + ECX]
```

**Example**: Array access with variable base and index
```assembly
leal array, %ebx           # Base address
movl $5, %ecx              # Index
movl (%ebx,%ecx), %eax     # Access array[5] (byte array)
```

### Form 5: Base + Index + Displacement
**Format**: `D(Rb, Ri)`

Effective Address = `Rb + Ri + D`

```assembly
movl 8(%ebx,%ecx), %eax    # EAX = Memory[EBX + ECX + 8]
movl -4(%esp,%esi), %edx   # EDX = Memory[ESP + ESI - 4]
```

### Form 6: Index + Scale (Base = 0)
**Format**: `(,Ri,S)`

Effective Address = `Ri * S`

```assembly
movl (,%ecx,4), %eax       # EAX = Memory[ECX * 4]
```

**Example**: Access array with scaled index
```assembly
movl $3, %ecx              # Index = 3
movl (,%ecx,4), %eax       # Access int_array[3]
```

### Form 7: Base + Index * Scale
**Format**: `(Rb, Ri, S)`

Effective Address = `Rb + Ri * S`

```assembly
movl (%ebx,%ecx,4), %eax   # EAX = Memory[EBX + ECX*4]
movl (%esi,%edi,8), %edx   # EDX = Memory[ESI + EDI*8]
```

**Common use**: Array access with typed elements

```assembly
# Access int array[i]
leal array, %ebx           # Base address
movl $2, %ecx              # i = 2
movl (%ebx,%ecx,4), %eax   # EAX = array[2] (int = 4 bytes)
```

### Form 8: Full Format (Base + Index * Scale + Displacement)
**Format**: `D(Rb, Ri, S)`

Effective Address = `Rb + Ri * S + D`

```assembly
movl 8(%ebx,%ecx,4), %eax  # EAX = Memory[EBX + ECX*4 + 8]
movl -12(%ebp,%esi,2), %dx # DX = Memory[EBP + ESI*2 - 12]
```

**Common use**: Accessing struct array members

```assembly
# Access struct_array[i].field
# where field is at offset 8 in struct
leal struct_array, %ebx    # Base address
movl $3, %ecx              # i = 3
movl 8(%ebx,%ecx,16), %eax # struct size = 16 bytes, field offset = 8
```

## Addressing Mode Examples

### Example 1: Simple Variable Access
```assembly
.section .data
    value: .long 42

.section .text
    movl value, %eax       # Direct addressing
    addl $10, %eax         # Immediate addressing
    movl %eax, value       # Store back to memory
```

### Example 2: Array Access (int array[])
```assembly
.section .data
    array: .long 10, 20, 30, 40, 50

.section .text
    leal array, %ebx       # EBX = base address
    
    # Access array[0]
    movl (%ebx), %eax      # EAX = 10
    
    # Access array[2]
    movl 8(%ebx), %eax     # EAX = 30 (offset = 2*4)
    
    # Access array[i] where i is in %ecx
    movl $3, %ecx
    movl (%ebx,%ecx,4), %eax  # EAX = array[3] = 40
```

### Example 3: Struct Member Access
```c
struct Point {
    int x;      // offset 0
    int y;      // offset 4
};
struct Point p;
```

```assembly
# Assume %ebx points to struct Point
movl (%ebx), %eax          # EAX = p.x (offset 0)
movl 4(%ebx), %edx         # EDX = p.y (offset 4)

# Modify struct
movl $100, (%ebx)          # p.x = 100
movl $200, 4(%ebx)         # p.y = 200
```

### Example 4: 2D Matrix Access (int matrix[rows][cols])
```c
int matrix[10][20];
// Access matrix[i][j]
```

```assembly
# Effective address: base + (i * num_cols + j) * element_size
# Assume %ebx = base, %ecx = i, %edx = j

leal matrix, %ebx          # Base address
imull $20, %ecx            # ECX = i * num_cols
addl %edx, %ecx            # ECX = i * num_cols + j
movl (%ebx,%ecx,4), %eax   # EAX = matrix[i][j]
```

### Example 5: Stack Frame Access
```assembly
function:
    pushl %ebp
    movl %esp, %ebp
    subl $8, %esp          # Allocate 2 local variables
    
    # Access parameters (positive offsets from %ebp)
    movl 8(%ebp), %eax     # First parameter
    movl 12(%ebp), %ebx    # Second parameter
    
    # Access local variables (negative offsets from %ebp)
    movl %eax, -4(%ebp)    # First local = first param
    movl %ebx, -8(%ebp)    # Second local = second param
    
    movl %ebp, %esp
    popl %ebp
    ret
```

## Common Patterns and Use Cases

### Pattern 1: Array Traversal
```assembly
# Traverse int array[10]
leal array, %esi           # ESI = base address
movl $0, %ecx              # ECX = index

loop:
    cmpl $10, %ecx
    jge end_loop
    
    # Access array[ecx]
    movl (%esi,%ecx,4), %eax
    # ... process element ...
    
    incl %ecx
    jmp loop
    
end_loop:
```

### Pattern 2: String Operations
```assembly
# Copy string (char*)
leal source, %esi          # Source pointer
leal dest, %edi            # Destination pointer

copy_loop:
    movb (%esi), %al       # Load byte from source
    movb %al, (%edi)       # Store byte to destination
    
    testb %al, %al         # Check for null terminator
    jz done
    
    incl %esi              # Advance source
    incl %edi              # Advance destination
    jmp copy_loop
    
done:
```

### Pattern 3: Struct Array Access
```c
struct Record {
    int id;         // offset 0
    int value;      // offset 4
    char name[8];   // offset 8
};                  // total size: 16 bytes

struct Record records[100];
```

```assembly
# Access records[i].value
leal records, %ebx         # Base address
movl $5, %ecx              # i = 5
movl 4(%ebx,%ecx,16), %eax # records[5].value
                            # offset = 4, scale = 16 (struct size)
```

### Pattern 4: Nested Loops (Matrix)
```assembly
# Process matrix[i][j] (rows x cols)
movl $0, %ecx              # i = 0
outer_loop:
    cmpl $rows, %ecx
    jge end_outer
    
    movl $0, %edx          # j = 0
inner_loop:
    cmpl $cols, %edx
    jge end_inner
    
    # Calculate offset: (i * cols + j) * 4
    movl %ecx, %eax
    imull $cols, %eax
    addl %edx, %eax
    # Access matrix[i][j]
    movl matrix(,%eax,4), %ebx
    # ... process element ...
    
    incl %edx
    jmp inner_loop
    
end_inner:
    incl %ecx
    jmp outer_loop
    
end_outer:
```

## Addressing Mode Restrictions

1. **No two memory operands**: Cannot have memory-to-memory operations
   ```assembly
   # INVALID:
   movl (%eax), (%ebx)    # Cannot move from memory to memory
   
   # VALID:
   movl (%eax), %ecx      # Load to register first
   movl %ecx, (%ebx)      # Then store to memory
   ```

2. **ESP as index register**: Cannot use `%esp` as index register
   ```assembly
   # INVALID:
   movl (%ebx,%esp,4), %eax
   
   # VALID:
   movl (%ebx,%esi,4), %eax
   ```

3. **Scale factors**: Only 1, 2, 4, or 8
   ```assembly
   # INVALID:
   movl (%ebx,%ecx,3), %eax   # 3 is not a valid scale
   
   # VALID:
   movl (%ebx,%ecx,4), %eax   # 4 is valid
   ```

## Summary Table

| Addressing Mode | Format | Effective Address | Example |
|-----------------|--------|-------------------|---------|
| Immediate | `$val` | N/A | `movl $10, %eax` |
| Register | `%reg` | N/A | `movl %eax, %ebx` |
| Direct | `addr` | `addr` | `movl 0x1234, %eax` |
| Indirect | `(Rb)` | `Rb` | `movl (%ebx), %eax` |
| Base+Disp | `D(Rb)` | `Rb + D` | `movl 8(%ebp), %eax` |
| Base+Index | `(Rb,Ri)` | `Rb + Ri` | `movl (%ebx,%ecx), %eax` |
| Index+Scale | `(,Ri,S)` | `Ri * S` | `movl (,%ecx,4), %eax` |
| Base+Index+Disp | `D(Rb,Ri)` | `Rb + Ri + D` | `movl 8(%ebx,%ecx), %eax` |
| Base+Index*Scale | `(Rb,Ri,S)` | `Rb + Ri*S` | `movl (%ebx,%ecx,4), %eax` |
| Full Format | `D(Rb,Ri,S)` | `Rb + Ri*S + D` | `movl 8(%ebx,%ecx,4), %eax` |

## Key Takeaways

1. **Three main types**: Immediate, Register, Memory
2. **Memory addressing is flexible**: Supports complex addressing with base, index, scale, and displacement
3. **Scale factors** (1, 2, 4, 8) correspond to data type sizes
4. **Common uses**:
   - Base+Disp: Stack variables, struct members
   - Base+Index*Scale: Array access
   - Full format: Struct array members, matrix access
5. **Know the restrictions**: No mem-to-mem, no %esp as index, limited scales
