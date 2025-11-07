# x86 Assembly Architecture

## Overview

The x86 assembly architecture consists of several key components that work together to execute programs at the machine level.

## Architecture Components

```
┌─────────────────────────────────────────┐
│              CPU                        │
│                                         │
│  ┌──────────┐     ┌──────────────┐    │
│  │   EIP    │     │   EFLAGS     │    │
│  │ (PC)     │     │   (CC)       │    │
│  └──────────┘     └──────────────┘    │
│                                         │
│  ┌────────────────────────────────┐   │
│  │      General Registers         │   │
│  │  EAX, EBX, ECX, EDX            │   │
│  │  ESI, EDI, EBP, ESP            │   │
│  └────────────────────────────────┘   │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│            MEMORY                       │
│                                         │
│  ┌──────────────┐                      │
│  │ Instructions │  (Code)               │
│  ├──────────────┤                      │
│  │    Data      │  (User Data)          │
│  ├──────────────┤                      │
│  │    Stack     │  (Subroutine Mgmt)   │
│  ├──────────────┤                      │
│  │   OS Data    │                      │
│  └──────────────┘                      │
└─────────────────────────────────────────┘
```

## Key Components

### 1. EIP (Extended Instruction Pointer)
- **Program Counter**: Points to the next instruction to be executed
- Automatically incremented after each instruction
- Modified by jumps and calls

### 2. General Purpose Registers
- **Very fast** access compared to memory
- Used as temporary variables
- 8 registers in 32-bit x86: `%eax`, `%ebx`, `%ecx`, `%edx`, `%esi`, `%edi`, `%ebp`, `%esp`

### 3. EFLAGS (Condition Codes)
- **Status Register**: Stores information about the last instruction executed
- Used for conditional branching
- Important flags:
  - `ZF` (Zero Flag): Set if result is zero
  - `SF` (Sign Flag): Set if result is negative
  - `CF` (Carry Flag): Set on unsigned overflow
  - `OF` (Overflow Flag): Set on signed overflow

### 4. Memory
- **Byte-addressable**: Each byte has a unique address
- **Little Endian**: Least significant byte stored at lowest address
- **Segments**:
  - **Code**: Program instructions
  - **Data**: Global and static variables
  - **Stack**: Local variables, function calls, return addresses
  - **OS Data**: Operating system reserved

### 5. Stack
- **LIFO** structure (Last In, First Out)
- Grows **downward** in memory (from high to low addresses)
- Managed by `%esp` (Stack Pointer)
- Operations:
  - `push`: Add data to stack (decrements %esp)
  - `pop`: Remove data from stack (increments %esp)

## Memory Model

### Address Space (32-bit)
```
0xFFFFFFFF ┌──────────────┐
           │   Kernel     │
           │   Space      │
0xC0000000 ├──────────────┤
           │    Stack     │ ← %esp (grows down)
           │      ↓       │
           │              │
           │      ↑       │
           │    Heap      │
           ├──────────────┤
           │    Data      │ (Global/Static)
           ├──────────────┤
           │    Code      │ (Instructions)
0x08048000 ├──────────────┤
           │   Reserved   │
0x00000000 └──────────────┘
```

## Data Types

### Basic Types
| Type       | Size    | Example Values         |
|------------|---------|------------------------|
| `byte`     | 1 byte  | -128 to 127           |
| `word`     | 2 bytes | -32,768 to 32,767     |
| `long`     | 4 bytes | -2³¹ to 2³¹-1         |
| `quad`     | 8 bytes | -2⁶³ to 2⁶³-1         |

### Unsigned Types
| Type       | Size    | Range                 |
|------------|---------|------------------------|
| `byte`     | 1 byte  | 0 to 255              |
| `word`     | 2 bytes | 0 to 65,535           |
| `long`     | 4 bytes | 0 to 4,294,967,295    |

## Little Endian Byte Order

```
Memory:    0x100  0x101  0x102  0x103
Value:     0x12   0x34   0x56   0x78

Represents: 0x78563412 (least significant byte first)
```

### Example:
```assembly
# Store 0x12345678 at address 0x1000
movl $0x12345678, 0x1000

# Memory layout:
# 0x1000: 78
# 0x1001: 56
# 0x1002: 34
# 0x1003: 12
```

## Instruction Execution Cycle

1. **Fetch**: EIP points to next instruction, CPU fetches it
2. **Decode**: CPU determines what operation to perform
3. **Execute**: CPU performs the operation
4. **Update**: Condition codes and registers updated
5. **Increment**: EIP advances to next instruction (unless it's a jump/call)

## Example Program Structure

```assembly
.section .data
    # Global variables go here
    message: .asciz "Hello, World!"
    number: .long 42

.section .bss
    # Uninitialized data
    buffer: .space 100

.section .text
.global _start

_start:
    # Program code goes here
    movl $1, %eax          # System call number (sys_exit)
    movl $0, %ebx          # Exit code
    int $0x80              # Make system call
```

## Assembly Syntax (AT&T vs Intel)

This course uses **AT&T syntax** (GNU Assembler):

| Feature          | AT&T Syntax          | Intel Syntax         |
|------------------|----------------------|----------------------|
| Operand order    | `src, dest`          | `dest, src`          |
| Register prefix  | `%eax`               | `eax`                |
| Immediate prefix | `$10`                | `10`                 |
| Memory           | `(%eax)`             | `[eax]`              |
| Size suffix      | `movl`               | `mov dword`          |

### Examples:
```assembly
# AT&T Syntax
movl $5, %eax          # Move 5 into eax
movl (%ebx), %eax      # Move value at address in ebx to eax
addl %ecx, %eax        # Add ecx to eax

# Intel Syntax (for reference)
mov eax, 5             # Move 5 into eax
mov eax, [ebx]         # Move value at address in ebx to eax
add eax, ecx           # Add ecx to eax
```

## Key Concepts

### 1. Register Usage
- Registers are the fastest storage available
- Limited number (8 general purpose in 32-bit)
- Must be managed carefully in complex programs

### 2. Memory Access
- Slower than register access
- Byte-addressable with various addressing modes
- Must respect alignment for optimal performance

### 3. Stack Management
- Critical for subroutine calls
- Stores return addresses and local variables
- Must be kept aligned (typically 4-byte or 16-byte alignment)

### 4. Condition Codes
- Set automatically by most instructions
- Read by conditional jumps
- Essential for implementing control flow

## Summary

The x86 architecture provides:
- Fast register-based computation
- Flexible memory addressing
- Stack support for subroutines
- Condition codes for control flow
- Little-endian byte ordering
- Backwards compatibility with 16-bit and 8-bit modes

Understanding these fundamentals is essential for writing efficient assembly code.
