# Quick Reference Card

## Compile & Run Single File

```bash
# Assemble
as --32 filename.s -o filename.o

# Link
ld -m elf_i386 filename.o -o filename

# Run
./filename

# Check exit code
echo $?
```

## One-liner

```bash
as --32 01_hello_world.s -o temp.o && ld -m elf_i386 temp.o -o temp && ./temp && echo "Exit: $?" && rm temp temp.o
```

## Debug with GDB

```bash
# Compile with symbols
as --32 -g filename.s -o filename.o
ld -m elf_i386 filename.o -o filename

# Debug
gdb ./filename
```

### Essential GDB Commands

```gdb
break _start      # Set breakpoint at entry
run              # Start program
stepi            # Step one instruction (into calls)
nexti            # Step one instruction (over calls)
info reg         # Show all registers
info reg eax     # Show specific register
x/10x $esp       # Examine 10 words on stack
x/s $ecx         # Show string at ECX
print $eax       # Print register value in decimal
print/x $eax     # Print register value in hex
disas           # Disassemble current function
continue         # Continue execution
quit             # Exit GDB
```

## Register Quick Reference

```
%eax - Accumulator, return value
%ebx - Base (callee-saved)
%ecx - Counter
%edx - Data
%esi - Source index (callee-saved)
%edi - Destination index (callee-saved)
%ebp - Base pointer (callee-saved)
%esp - Stack pointer
```

## System Calls (32-bit Linux)

```assembly
# Exit
movl $1, %eax      # sys_exit
movl $0, %ebx      # exit code
int $0x80

# Write
movl $4, %eax      # sys_write
movl $1, %ebx      # stdout
leal msg, %ecx     # buffer
movl $len, %edx    # length
int $0x80

# Read
movl $3, %eax      # sys_read
movl $0, %ebx      # stdin
leal buf, %ecx     # buffer
movl $size, %edx   # max bytes
int $0x80
```

## Common Patterns

### Function Prologue
```assembly
pushl %ebp
movl %esp, %ebp
subl $N, %esp      # Allocate N bytes locals
```

### Function Epilogue
```assembly
movl %ebp, %esp    # or: addl $N, %esp
popl %ebp
ret
```

### Call Function
```assembly
pushl arg3         # Right to left
pushl arg2
pushl arg1
call function
addl $12, %esp     # Clean stack (3 args * 4)
# Result in %eax
```

### Loop Pattern
```assembly
movl $10, %ecx
loop_start:
    # body
    decl %ecx
    jnz loop_start
```

### Array Access
```assembly
leal array, %esi
movl (%esi,%ecx,4), %eax   # array[ecx]
```

### Zero Register
```assembly
xorl %eax, %eax    # Fastest way
```

## Addressing Modes

```assembly
$10              # Immediate
%eax             # Register
var              # Direct
(%eax)           # Indirect
8(%ebp)          # Base + displacement
(%ebx,%ecx,4)    # Base + index*scale
8(%ebx,%ecx,4)   # Full: base + index*scale + disp
```

## Conditional Jumps

```assembly
je/jz    # Equal / Zero
jne/jnz  # Not equal / Not zero
jl       # Less (signed)
jg       # Greater (signed)
jle      # Less or equal (signed)
jge      # Greater or equal (signed)
jb       # Below (unsigned)
ja       # Above (unsigned)
jbe      # Below or equal (unsigned)
jae      # Above or equal (unsigned)
```

## Data Declarations

```assembly
.section .data
    byte_val: .byte 10
    word_val: .word 100
    long_val: .long 1000
    string: .asciz "Hello"
    array: .long 1, 2, 3, 4, 5

.section .bss
    buffer: .space 256
```

## Size Suffixes

```assembly
movb  # Byte (8-bit)
movw  # Word (16-bit)
movl  # Long (32-bit)
```

## Example: If-Else

```assembly
cmpl $10, %eax
jle else_label
    # if body
    jmp endif
else_label:
    # else body
endif:
```

## Example: For Loop

```assembly
movl $0, %ecx      # i = 0
for_start:
    cmpl $10, %ecx
    jge for_end
    # body
    incl %ecx
    jmp for_start
for_end:
```

## Troubleshooting

### Segmentation Fault?
- Check stack alignment (4-byte boundaries)
- Verify array bounds
- Check pointer validity
- Ensure proper register preservation

### Wrong Result?
- Step through with GDB
- Check register values at each step
- Verify addressing mode calculations
- Check signed vs unsigned operations

### Won't Assemble?
- Check syntax (AT&T vs Intel)
- Verify instruction exists
- Check operand sizes match
- Ensure labels are defined

### Won't Link?
- Make sure `.global _start` is present
- Check for undefined symbols
- Verify correct linker command
- Use `ld`, not `gcc` for these examples
