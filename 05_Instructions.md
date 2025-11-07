# x86 Instructions Reference

## Instruction Format

x86 instructions follow this general pattern:

```assembly
opcode[size]  source, destination
```

- **opcode**: The operation to perform (mov, add, sub, etc.)
- **size**: Suffix indicating operand size
  - `b` = byte (8-bit)
  - `w` = word (16-bit)
  - `l` = long (32-bit)
- **operands**: Source and destination (in that order for AT&T syntax)

## Data Movement Instructions

### MOV - Move Data

**Format**: `mov[bwl] source, dest`

Copies data from source to destination. Does not affect flags.

```assembly
movl $42, %eax             # EAX = 42
movl %eax, %ebx            # EBX = EAX
movl %eax, var             # var = EAX
movl var, %ebx             # EBX = var
movb $'A', %al             # AL = 'A'
movw $100, %ax             # AX = 100
```

**Restrictions**:
- Cannot move memory to memory
- Cannot move immediate to memory directly (with some exceptions)

### MOVZ - Move with Zero Extension

**Format**: `movz[bw][wl] source, dest`

Copies data and zero-extends to fill destination.

```assembly
# Move byte to long with zero extension
movzbl %al, %eax           # EAX = 0x000000AL

# Example:
movb $0xFF, %al            # AL = 0xFF
movzbl %al, %eax           # EAX = 0x000000FF (unsigned)
```

**Common uses**:
- Converting unsigned char to int
- Converting unsigned short to int

### MOVS - Move with Sign Extension

**Format**: `movs[bw][wl] source, dest`

Copies data and sign-extends to fill destination.

```assembly
# Move byte to long with sign extension
movsbl %al, %eax           # EAX = sign-extended AL

# Example:
movb $0xFF, %al            # AL = 0xFF (-1 in signed)
movsbl %al, %eax           # EAX = 0xFFFFFFFF (-1)

movb $0x7F, %al            # AL = 0x7F (127)
movsbl %al, %eax           # EAX = 0x0000007F (127)
```

**Common uses**:
- Converting signed char to int
- Converting signed short to int

### LEA - Load Effective Address

**Format**: `lea[l] source, dest`

Computes address of source operand and stores it in destination. Does not access memory.

```assembly
leal array, %eax           # EAX = address of array
leal 8(%ebp), %eax         # EAX = EBP + 8
leal (%ebx,%ecx,4), %eax   # EAX = EBX + ECX*4
```

**Common uses**:
- Getting addresses of variables
- Efficient arithmetic (multiplication by 2, 3, 4, 5, 8, 9)

```assembly
# Multiply by 3
leal (%eax,%eax,2), %ebx   # EBX = EAX + EAX*2 = EAX*3

# Multiply by 5
leal (%eax,%eax,4), %ebx   # EBX = EAX + EAX*4 = EAX*5
```

### PUSH - Push onto Stack

**Format**: `push[lw] source`

Decrements %esp by operand size, then stores source at (%esp).

```assembly
pushl %eax                 # ESP -= 4, store EAX at (ESP)
pushl $10                  # ESP -= 4, store 10 at (ESP)
pushl var                  # ESP -= 4, store var at (ESP)
```

Equivalent to:
```assembly
subl $4, %esp
movl %eax, (%esp)
```

### POP - Pop from Stack

**Format**: `pop[lw] dest`

Loads value from (%esp) into dest, then increments %esp by operand size.

```assembly
popl %eax                  # Load (ESP) to EAX, ESP += 4
```

Equivalent to:
```assembly
movl (%esp), %eax
addl $4, %esp
```

### XCHG - Exchange

**Format**: `xchg[bwl] op1, op2`

Swaps values of two operands.

```assembly
xchgl %eax, %ebx           # Swap EAX and EBX
xchgb %al, %ah             # Swap AL and AH
```

## Arithmetic Instructions

### ADD - Addition

**Format**: `add[bwl] source, dest`

Adds source to dest, stores result in dest. Sets flags.

```assembly
addl $10, %eax             # EAX = EAX + 10
addl %ebx, %eax            # EAX = EAX + EBX
addl var, %eax             # EAX = EAX + var
```

**Flags set**: CF, ZF, SF, OF, PF

### SUB - Subtraction

**Format**: `sub[bwl] source, dest`

Subtracts source from dest, stores result in dest. Sets flags.

```assembly
subl $10, %eax             # EAX = EAX - 10
subl %ebx, %eax            # EAX = EAX - EBX
subl var, %eax             # EAX = EAX - var
```

**Flags set**: CF, ZF, SF, OF, PF

### INC - Increment

**Format**: `inc[bwl] dest`

Adds 1 to dest. Does not affect CF flag.

```assembly
incl %eax                  # EAX = EAX + 1
incl var                   # var = var + 1
```

### DEC - Decrement

**Format**: `dec[bwl] dest`

Subtracts 1 from dest. Does not affect CF flag.

```assembly
decl %eax                  # EAX = EAX - 1
decl var                   # var = var - 1
```

### NEG - Negate

**Format**: `neg[bwl] dest`

Negates dest (two's complement). dest = -dest.

```assembly
movl $10, %eax
negl %eax                  # EAX = -10 = 0xFFFFFFF6
```

### MUL - Unsigned Multiply

**Format**: `mul[bwl] source`

Unsigned multiplication. Result depends on size:

**Byte multiply** (`mulb`):
- AX = AL * source

**Word multiply** (`mulw`):
- DX:AX = AX * source

**Long multiply** (`mull`):
- EDX:EAX = EAX * source

```assembly
# Multiply EAX by 5
movl $10, %eax
movl $5, %ebx
mull %ebx                  # EDX:EAX = 10 * 5 = 50
                           # EAX = 50, EDX = 0
```

### IMUL - Signed Multiply

**Format**: `imul[bwl] source` or `imul[bwl] source, dest` or `imul[bwl] immediate, source, dest`

Three forms:

**Form 1**: Single operand (like MUL)
```assembly
imull %ebx                 # EDX:EAX = EAX * EBX (signed)
```

**Form 2**: Two operands
```assembly
imull %ebx, %eax           # EAX = EAX * EBX (32-bit result)
```

**Form 3**: Three operands
```assembly
imull $10, %ebx, %eax      # EAX = EBX * 10
```

### DIV - Unsigned Division

**Format**: `div[bwl] divisor`

Unsigned division. Operands depend on size:

**Byte division** (`divb`):
- AL = AX / divisor (quotient)
- AH = AX % divisor (remainder)

**Word division** (`divw`):
- AX = DX:AX / divisor
- DX = DX:AX % divisor

**Long division** (`divl`):
- EAX = EDX:EAX / divisor
- EDX = EDX:EAX % divisor

```assembly
movl $100, %eax
movl $0, %edx              # Zero high 32 bits
movl $7, %ebx
divl %ebx                  # EAX = 100/7 = 14, EDX = 100%7 = 2
```

### IDIV - Signed Division

**Format**: `idiv[bwl] divisor`

Signed division. Same format as DIV but treats values as signed.

```assembly
movl $-100, %eax
cltd                       # Sign-extend EAX into EDX
movl $7, %ebx
idivl %ebx                 # EAX = -100/7 = -14, EDX = -100%7 = -2
```

### Special Division Instructions

**CDQ** - Convert Double to Quad
```assembly
cltd                       # EDX:EAX = sign-extended EAX
```

Use before IDIV to properly sign-extend the dividend.

## Logical Instructions

### AND - Bitwise AND

**Format**: `and[bwl] source, dest`

Performs bitwise AND. dest = dest & source.

```assembly
movl $0xFF, %eax           # EAX = 0x000000FF
andl $0x0F, %eax           # EAX = 0x0000000F
```

**Common use**: Masking bits

```assembly
# Keep only lower 8 bits
andl $0xFF, %eax
```

### OR - Bitwise OR

**Format**: `or[bwl] source, dest`

Performs bitwise OR. dest = dest | source.

```assembly
movl $0xF0, %eax           # EAX = 0x000000F0
orl $0x0F, %eax            # EAX = 0x000000FF
```

**Common use**: Setting bits

```assembly
# Set bit 5
orl $0x20, %eax
```

### XOR - Bitwise XOR

**Format**: `xor[bwl] source, dest`

Performs bitwise XOR. dest = dest ^ source.

```assembly
movl $0xFF, %eax           # EAX = 0x000000FF
xorl $0x0F, %eax           # EAX = 0x000000F0
```

**Common use**: Zeroing a register (very efficient)

```assembly
xorl %eax, %eax            # EAX = 0 (fastest way!)
```

### NOT - Bitwise NOT

**Format**: `not[bwl] dest`

Inverts all bits in dest. dest = ~dest.

```assembly
movl $0x0F, %eax           # EAX = 0x0000000F
notl %eax                  # EAX = 0xFFFFFFF0
```

### TEST - Logical Compare

**Format**: `test[bwl] source, dest`

Performs bitwise AND but only sets flags (doesn't store result).

```assembly
testl %eax, %eax           # Check if EAX is zero
jz is_zero                 # Jump if zero

testl $1, %eax             # Check if bit 0 is set
jnz is_odd                 # Jump if not zero (odd number)
```

### CMP - Compare

**Format**: `cmp[bwl] source, dest`

Computes dest - source but only sets flags (doesn't store result).

```assembly
cmpl $10, %eax             # Compare EAX with 10
je equal                   # Jump if equal
jl less                    # Jump if less
jg greater                 # Jump if greater
```

**Flag behavior**:
- ZF = 1 if equal
- CF = 1 if dest < source (unsigned)
- SF != OF if dest < source (signed)

## Shift and Rotate Instructions

### SHL/SAL - Shift Left (Logical/Arithmetic)

**Format**: `shl[bwl] count, dest` or `sal[bwl] count, dest`

Shifts dest left by count bits. Fills with zeros.

```assembly
movl $5, %eax              # EAX = 5 (binary: 101)
shll $2, %eax              # EAX = 20 (binary: 10100)

# Variable shift
movl $3, %ecx
shll %cl, %eax             # Shift by CL (lower 8 bits of ECX)
```

**Effect**: Multiplies by 2^count

### SHR - Shift Right (Logical)

**Format**: `shr[bwl] count, dest`

Shifts dest right by count bits. Fills with zeros (unsigned).

```assembly
movl $20, %eax             # EAX = 20 (binary: 10100)
shrl $2, %eax              # EAX = 5 (binary: 101)
```

**Effect**: Divides by 2^count (unsigned)

### SAR - Shift Right (Arithmetic)

**Format**: `sar[bwl] count, dest`

Shifts dest right by count bits. Fills with sign bit (signed).

```assembly
movl $-20, %eax
sarl $2, %eax              # EAX = -5 (sign preserved)
```

**Effect**: Divides by 2^count (signed)

### ROL - Rotate Left

**Format**: `rol[bwl] count, dest`

Rotates dest left by count bits. Bits shifted out go to the right.

```assembly
movl $0x12345678, %eax
roll $8, %eax              # EAX = 0x34567812
```

### ROR - Rotate Right

**Format**: `ror[bwl] count, dest`

Rotates dest right by count bits. Bits shifted out go to the left.

```assembly
movl $0x12345678, %eax
rorl $8, %eax              # EAX = 0x78123456
```

## Control Flow Instructions

### JMP - Unconditional Jump

**Format**: `jmp target`

Jump to target address.

```assembly
jmp loop_start             # Always jump to loop_start
```

### Conditional Jumps

Based on flags set by previous comparison or arithmetic operation.

| Instruction | Condition | Description | Use After |
|-------------|-----------|-------------|-----------|
| `je` / `jz` | ZF = 1 | Jump if equal/zero | CMP |
| `jne` / `jnz` | ZF = 0 | Jump if not equal/not zero | CMP |
| `jl` / `jnge` | SF ≠ OF | Jump if less (signed) | CMP |
| `jle` / `jng` | ZF=1 or SF≠OF | Jump if less or equal (signed) | CMP |
| `jg` / `jnle` | ZF=0 and SF=OF | Jump if greater (signed) | CMP |
| `jge` / `jnl` | SF = OF | Jump if greater or equal (signed) | CMP |
| `jb` / `jnae` / `jc` | CF = 1 | Jump if below (unsigned) | CMP |
| `jbe` / `jna` | CF=1 or ZF=1 | Jump if below or equal (unsigned) | CMP |
| `ja` / `jnbe` | CF=0 and ZF=0 | Jump if above (unsigned) | CMP |
| `jae` / `jnb` / `jnc` | CF = 0 | Jump if above or equal (unsigned) | CMP |
| `js` | SF = 1 | Jump if sign (negative) | TEST |
| `jns` | SF = 0 | Jump if not sign (positive) | TEST |
| `jo` | OF = 1 | Jump if overflow | ADD/SUB |
| `jno` | OF = 0 | Jump if not overflow | ADD/SUB |

### Examples:
```assembly
# Signed comparison
cmpl $10, %eax
jl less_than_10            # Jump if EAX < 10 (signed)
jg greater_than_10         # Jump if EAX > 10 (signed)
je equal_to_10             # Jump if EAX == 10

# Unsigned comparison
cmpl $10, %eax
jb below_10                # Jump if EAX < 10 (unsigned)
ja above_10                # Jump if EAX > 10 (unsigned)

# Test for zero
testl %eax, %eax
jz is_zero                 # Jump if EAX == 0

# Test bit
testl $0x80, %eax
jnz bit_set                # Jump if bit 7 is set
```

## Subroutine Instructions

### CALL - Call Subroutine

**Format**: `call target`

Pushes return address onto stack, then jumps to target.

```assembly
call my_function           # Push EIP, jump to my_function
# Execution continues here after function returns
```

Equivalent to:
```assembly
pushl %eip + size_of_call_instruction
jmp my_function
```

### RET - Return from Subroutine

**Format**: `ret` or `ret immediate`

Pops return address from stack and jumps to it. Optional immediate specifies additional bytes to pop.

```assembly
ret                        # Pop return address, jump to it
ret $8                     # Also pop 8 bytes from stack (Windows convention)
```

## No-Operation

### NOP - No Operation

**Format**: `nop`

Does nothing. Used for alignment and timing.

```assembly
nop                        # One-byte instruction that does nothing
```

## Common Instruction Patterns

### Pattern 1: Zero a Register
```assembly
xorl %eax, %eax            # Fastest way to zero EAX
```

### Pattern 2: Copy a Register
```assembly
movl %eax, %ebx            # Copy EAX to EBX
```

### Pattern 3: Load Address
```assembly
leal buffer, %eax          # EAX = address of buffer
```

### Pattern 4: Swap Two Registers
```assembly
xchgl %eax, %ebx           # Swap EAX and EBX
```

### Pattern 5: Multiply by Power of 2
```assembly
shll $3, %eax              # EAX = EAX * 8
```

### Pattern 6: Divide by Power of 2 (Unsigned)
```assembly
shrl $2, %eax              # EAX = EAX / 4 (unsigned)
```

### Pattern 7: Absolute Value
```assembly
# Compute abs(EAX)
movl %eax, %edx
sarl $31, %edx             # EDX = all 1s if negative, 0 if positive
xorl %edx, %eax
subl %edx, %eax            # EAX = |EAX|
```

### Pattern 8: Min/Max
```assembly
# Compute min(EAX, EBX) -> EAX
cmpl %ebx, %eax
jle skip
movl %ebx, %eax
skip:
```

## Summary

### Data Movement
- `mov`: Copy data
- `movz`/`movs`: Move with extension
- `lea`: Load effective address
- `push`/`pop`: Stack operations

### Arithmetic
- `add`/`sub`: Addition and subtraction
- `inc`/`dec`: Increment and decrement
- `mul`/`imul`: Multiplication
- `div`/`idiv`: Division
- `neg`: Negate

### Logical
- `and`/`or`/`xor`/`not`: Bitwise operations
- `test`/`cmp`: Comparison (sets flags only)

### Shift/Rotate
- `shl`/`shr`/`sar`: Shift operations
- `rol`/`ror`: Rotate operations

### Control Flow
- `jmp`: Unconditional jump
- `je`, `jne`, `jl`, `jg`, etc.: Conditional jumps
- `call`/`ret`: Subroutine operations

Understanding these instructions is fundamental to reading and writing x86 assembly code.
