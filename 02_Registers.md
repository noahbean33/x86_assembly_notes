# x86 Registers

## Register Overview

In 32-bit x86 assembly, there are 8 general-purpose registers, each 32 bits wide. These registers can also be accessed as 16-bit or 8-bit subregisters for compatibility with older code.

## General Purpose Registers

```
┌─────────────────────────────────────────────────────┐
│                 32-bit Register                     │
│                    (EAX, EBX...)                    │
│  31                              16 15            0 │
│  ┌───────────────────────────────┬────────────────┐│
│  │      Extended (upper 16)      │  AX (lower 16) ││
│  └───────────────────────────────┴────────────────┘│
│                                   ┌────────┬───────┐│
│                                   │ AH (8) │ AL(8) ││
│                                   └────────┴───────┘│
└─────────────────────────────────────────────────────┘
```

## The 8 General Purpose Registers

### 1. **EAX (Accumulator Register)**
- **Primary use**: Arithmetic operations, function return values
- **Sub-registers**: `AX` (16-bit), `AH` (high 8-bit), `AL` (low 8-bit)
- **Convention**: Return values are always placed in `%eax`

```assembly
movl $42, %eax         # EAX = 42
movw $10, %ax          # AX = 10 (lower 16 bits)
movb $5, %al           # AL = 5 (lower 8 bits)
movb $3, %ah           # AH = 3 (bits 8-15)
```

### 2. **EBX (Base Register)**
- **Primary use**: Base pointer for memory access
- **Sub-registers**: `BX`, `BH`, `BL`
- **Convention**: Callee-saved (must be preserved if modified)

```assembly
leal buffer, %ebx      # EBX points to buffer
movl (%ebx), %eax      # Load value from address in EBX
```

### 3. **ECX (Counter Register)**
- **Primary use**: Loop counters, shift/rotate operations
- **Sub-registers**: `CX`, `CH`, `CL`
- **Convention**: Can be modified freely in subroutines

```assembly
movl $10, %ecx         # ECX = 10 (loop counter)
loop:
    # ... loop body ...
    decl %ecx          # Decrement counter
    jnz loop           # Jump if not zero
```

### 4. **EDX (Data Register)**
- **Primary use**: I/O operations, extended arithmetic (multiplication/division)
- **Sub-registers**: `DX`, `DH`, `DL`
- **Convention**: Can be modified freely in subroutines

```assembly
movl $100, %eax
movl $5, %ebx
mull %ebx              # EAX = 100 * 5, EDX = high 32 bits
```

### 5. **ESI (Source Index)**
- **Primary use**: String/array operations (source pointer)
- **No sub-registers**: Only 32-bit access
- **Convention**: Callee-saved (must be preserved if modified)

```assembly
leal source_array, %esi    # ESI points to source
movl (%esi), %eax          # Load from source
addl $4, %esi              # Move to next element
```

### 6. **EDI (Destination Index)**
- **Primary use**: String/array operations (destination pointer)
- **No sub-registers**: Only 32-bit access
- **Convention**: Callee-saved (must be preserved if modified)

```assembly
leal dest_array, %edi      # EDI points to destination
movl %eax, (%edi)          # Store to destination
addl $4, %edi              # Move to next element
```

### 7. **EBP (Base Pointer)**
- **Primary use**: Frame pointer for accessing local variables and parameters
- **Convention**: Callee-saved, used for stack frame management
- **Special**: Should not be used for general computation

```assembly
pushl %ebp                 # Save old base pointer
movl %esp, %ebp            # Set up new frame
subl $16, %esp             # Allocate local variables
# Access parameters: 8(%ebp), 12(%ebp)...
# Access locals: -4(%ebp), -8(%ebp)...
movl %ebp, %esp            # Deallocate locals
popl %ebp                  # Restore old base pointer
```

### 8. **ESP (Stack Pointer)**
- **Primary use**: Points to top of stack
- **Convention**: Always preserved, automatically managed
- **Special**: Modified by `push`, `pop`, `call`, `ret`

```assembly
pushl %eax                 # ESP -= 4, store EAX at (ESP)
popl %ebx                  # Load (ESP) to EBX, ESP += 4
```

## Register Summary Table

| Register | Purpose                  | Callee-Saved? | Sub-registers    |
|----------|--------------------------|---------------|------------------|
| `%eax`   | Accumulator, return val  | No            | `%ax, %ah, %al`  |
| `%ebx`   | Base pointer            | **Yes**       | `%bx, %bh, %bl`  |
| `%ecx`   | Counter                 | No            | `%cx, %ch, %cl`  |
| `%edx`   | Data, I/O               | No            | `%dx, %dh, %dl`  |
| `%esi`   | Source index            | **Yes**       | None             |
| `%edi`   | Destination index       | **Yes**       | None             |
| `%ebp`   | Base/frame pointer      | **Yes**       | None             |
| `%esp`   | Stack pointer           | **Yes**       | None             |

## Register Access Examples

### Example 1: Full 32-bit Access
```assembly
movl $0x12345678, %eax     # EAX = 0x12345678
```

### Example 2: 16-bit Access (Lower Half)
```assembly
movl $0x12345678, %eax     # EAX = 0x12345678
movw $0xABCD, %ax          # EAX = 0x1234ABCD
```

### Example 3: 8-bit Access (Lower Byte)
```assembly
movl $0x12345678, %eax     # EAX = 0x12345678
movb $0xFF, %al            # EAX = 0x123456FF
```

### Example 4: 8-bit Access (Upper Byte)
```assembly
movl $0x12345678, %eax     # EAX = 0x12345678
movb $0xAB, %ah            # EAX = 0x1234AB78
```

## Programmer's Visualization

```
         31      24 23      16 15      8 7       0
        ┌──────────┬──────────┬─────────┬────────┐
%eax    │          │          │   %ah   │  %al   │
        └──────────┴──────────┴─────────┴────────┘
                              └──────────────────┘
                                      %ax

         31      24 23      16 15      8 7       0
        ┌──────────┬──────────┬─────────┬────────┐
%ebx    │          │          │   %bh   │  %bl   │
        └──────────┴──────────┴─────────┴────────┘
                              └──────────────────┘
                                      %bx

         31      24 23      16 15      8 7       0
        ┌──────────┬──────────┬─────────┬────────┐
%ecx    │          │          │   %ch   │  %cl   │
        └──────────┴──────────┴─────────┴────────┘
                              └──────────────────┘
                                      %cx

         31      24 23      16 15      8 7       0
        ┌──────────┬──────────┬─────────┬────────┐
%edx    │          │          │   %dh   │  %dl   │
        └──────────┴──────────┴─────────┴────────┘
                              └──────────────────┘
                                      %dx

         31                                      0
        ┌────────────────────────────────────────┐
%esi    │              (32-bit only)             │
        └────────────────────────────────────────┘

         31                                      0
        ┌────────────────────────────────────────┐
%edi    │              (32-bit only)             │
        └────────────────────────────────────────┘

         31                                      0
        ┌────────────────────────────────────────┐
%ebp    │         (Frame Pointer)                │
        └────────────────────────────────────────┘

         31                                      0
        ┌────────────────────────────────────────┐
%esp    │         (Stack Pointer)                │
        └────────────────────────────────────────┘
```

## Special Purpose Registers

### EIP (Instruction Pointer)
- **Not directly accessible** by normal instructions
- Modified by: `jmp`, `call`, `ret`, and conditional jumps
- Points to the next instruction to execute

### EFLAGS (Status Register)
- Contains condition codes and control flags
- Modified automatically by arithmetic and logical instructions
- Read by conditional jump instructions

## Important Condition Code Flags

| Flag | Name         | Set When                          |
|------|--------------|-----------------------------------|
| CF   | Carry        | Unsigned overflow                 |
| ZF   | Zero         | Result is zero                    |
| SF   | Sign         | Result is negative (MSB = 1)      |
| OF   | Overflow     | Signed overflow                   |
| PF   | Parity       | Even number of 1s in result       |

## Calling Convention (Linux 32-bit)

### Caller-Saved Registers (Scratch Registers)
Can be freely modified in a subroutine:
- `%eax` (also used for return value)
- `%ecx`
- `%edx`

### Callee-Saved Registers (Preserved Registers)
Must be saved and restored if modified:
- `%ebx`
- `%esi`
- `%edi`
- `%ebp` (frame pointer)
- `%esp` (stack pointer)

### Example: Preserving Registers
```assembly
my_function:
    # Save callee-saved registers
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi
    
    # Function body - can use %ebx, %esi, %edi
    movl $100, %ebx
    # ... do work ...
    
    # Restore callee-saved registers
    popl %edi
    popl %esi
    popl %ebx
    popl %ebp
    ret
```

## Common Register Usage Patterns

### Pattern 1: Simple Arithmetic
```assembly
movl $10, %eax
movl $20, %ebx
addl %ebx, %eax        # EAX = 30
```

### Pattern 2: Array Access
```assembly
leal array, %esi       # ESI = base address
movl $0, %ecx          # ECX = index
movl (%esi,%ecx,4), %eax   # EAX = array[0]
incl %ecx
movl (%esi,%ecx,4), %eax   # EAX = array[1]
```

### Pattern 3: Loop with Counter
```assembly
movl $10, %ecx         # Counter = 10
loop_start:
    # ... loop body ...
    decl %ecx          # Counter--
    jnz loop_start     # Continue if counter != 0
```

### Pattern 4: Function Call Setup
```assembly
# Prepare arguments (right to left)
pushl $30              # 3rd argument
pushl $20              # 2nd argument
pushl $10              # 1st argument
call my_function       # Call function
addl $12, %esp         # Clean up stack (3 * 4 bytes)
# Result is in %eax
```

## Register Best Practices

1. **Use EAX for return values** - This is the standard convention
2. **Preserve callee-saved registers** - Save and restore %ebx, %esi, %edi, %ebp
3. **Use ECX for loop counters** - It's designed for this purpose
4. **Use ESI/EDI for array operations** - They're optimized for this
5. **Don't modify ESP directly** - Use push/pop for stack operations
6. **Don't use EBP for general computation** - It's for stack frames

## Summary

- **8 general-purpose registers** in 32-bit x86
- **Sub-register access** for backwards compatibility (16-bit, 8-bit)
- **Calling convention** determines which registers must be preserved
- **EAX** is special: used for return values
- **ESP** and **EBP** manage the stack
- **ESI** and **EDI** are for array/string operations
- Understanding register usage is crucial for efficient assembly programming
