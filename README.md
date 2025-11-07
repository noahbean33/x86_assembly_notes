# x86 Assembly Programming Course

Complete guide to x86 assembly programming (32-bit) for Linux, covering fundamentals through advanced topics.

## 📚 Course Structure

### Part 1: Foundations

#### [01. Architecture](01_Architecture.md)
- CPU architecture overview
- Memory model and organization
- Registers and instruction pointer
- Condition codes and flags
- Little-endian byte ordering

#### [02. Registers](02_Registers.md)
- General-purpose registers (EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP)
- Register sub-components (16-bit and 8-bit access)
- Register usage conventions
- Caller-saved vs callee-saved registers

#### [03. Calling Conventions](03_Conventions.md)
- Stack fundamentals and operations
- Parameter passing (right-to-left on stack)
- Return values in EAX
- Register preservation rules
- Stack frame structure
- Local variable allocation and alignment

#### [04. Addressing Modes](04_Addressing_Modes.md)
- Immediate addressing (`$value`)
- Register addressing (`%reg`)
- Memory addressing modes:
  - Direct, indirect, base+displacement
  - Base+index, indexed with scale
  - Full format: `D(Rb, Ri, S)`
- Common usage patterns

### Part 2: Instructions

#### [05. Instructions Reference](05_Instructions.md)
- **Data Movement**: MOV, MOVZ, MOVS, LEA, PUSH, POP, XCHG
- **Arithmetic**: ADD, SUB, INC, DEC, NEG, MUL, IMUL, DIV, IDIV
- **Logical**: AND, OR, XOR, NOT, TEST, CMP
- **Shift/Rotate**: SHL, SHR, SAR, ROL, ROR
- **Control Flow**: JMP, conditional jumps (JE, JNE, JL, JG, etc.)
- **Subroutines**: CALL, RET

### Part 3: Control Flow

#### [06. Control Flow Structures](06_Control_Flow.md)
- **IF-THEN-ELSE statements**
  - Simple if, if-else, nested if
- **Loops**
  - WHILE loops
  - DO-WHILE loops
  - FOR loops (with initialization, condition, increment)
- **Switch statements** (jump tables)
- **Break and continue**
- **Compound conditions** (AND, OR)
- Signed vs unsigned comparisons

### Part 4: Data Structures

#### [07. Data Structures](07_Data_Structures.md)
- **Vectors (1D Arrays)**
  - Memory layout and access formula
  - Array traversal patterns
- **Matrices (2D Arrays)**
  - Row-major storage
  - Address calculation: `base + (i*cols + j)*size`
  - Nested loop processing
- **3D Arrays**
- **Structures (Structs)**
  - Member offsets
  - Array of structures
- **Data Alignment**
  - Alignment rules for primitive types
  - Structure padding and alignment
  - Performance implications

### Part 5: Functions

#### [08. Subroutines (Functions)](08_Subroutines.md)
- Subroutine types (leaf, multilevel, recursive)
- Stack frame structure and management
- Function prologue and epilogue
- Parameter passing (by value, by reference)
- Local variable allocation
- Register preservation
- Recursive functions (factorial, fibonacci)
- Advanced examples (strings, matrices, structures)

### Part 6: Complete Examples

#### [09. Complete Working Examples](09_Complete_Examples.md)
- Hello World
- Array operations (sum, find max)
- Bubble sort algorithm
- Factorial (recursive)
- String operations (length, copy)
- Matrix multiplication
- Binary search
- Calculator with function pointers
- Linked list traversal

## 🚀 Quick Start

### Prerequisites
- Linux system (32-bit compatible or with multilib support)
- GNU Assembler (GAS) or NASM
- GCC toolchain
- Basic understanding of C programming

### Setting Up (Ubuntu/Debian)
```bash
# Install 32-bit development tools
sudo apt-get update
sudo apt-get install gcc-multilib g++-multilib
sudo apt-get install nasm gdb

# Verify installation
as --version
ld --version
```

### Your First Assembly Program

**hello.s**:
```assembly
.section .data
    message: .asciz "Hello, Assembly!\n"

.section .text
.global _start

_start:
    # Write to stdout
    movl $4, %eax              # syscall: write
    movl $1, %ebx              # fd: stdout
    leal message, %ecx         # buffer
    movl $17, %edx             # length
    int $0x80

    # Exit
    movl $1, %eax              # syscall: exit
    xorl %ebx, %ebx            # exit code: 0
    int $0x80
```

**Build and run**:
```bash
# Assemble
as --32 hello.s -o hello.o

# Link
ld -m elf_i386 hello.o -o hello

# Run
./hello
```

## 📖 Learning Path

### Beginner (Weeks 1-2)
1. Read Architecture and Registers
2. Understand Addressing Modes
3. Study basic Instructions (MOV, ADD, SUB)
4. Practice with simple examples

### Intermediate (Weeks 3-4)
1. Master Calling Conventions
2. Learn Control Flow structures
3. Work with arrays and loops
4. Write simple functions

### Advanced (Weeks 5-6)
1. Study Data Structures in depth
2. Master function calling and recursion
3. Work with complex examples
4. Optimize code for performance

### Expert (Weeks 7-8)
1. Implement algorithms from scratch
2. Work with system calls
3. Debug complex programs
4. Understand performance implications

## 🛠️ Development Tools

### Assemblers
- **GAS (GNU Assembler)**: AT&T syntax, part of binutils
- **NASM**: Intel syntax, popular alternative

### Linkers
- **ld**: GNU linker

### Debuggers
- **GDB**: GNU debugger with assembly support
- **EDB**: Evan's Debugger (GUI)

### Useful GDB Commands
```gdb
break _start          # Set breakpoint at _start
run                   # Run program
step / stepi          # Step instruction
next / nexti          # Next instruction (skip calls)
info registers        # Show all registers
info registers eax    # Show specific register
x/10x $esp           # Examine 10 words at stack pointer
x/10i $eip           # Disassemble 10 instructions
print $eax           # Print register value
continue             # Continue execution
```

## 📝 AT&T vs Intel Syntax

This course uses **AT&T syntax** (default for GAS on Linux).

| Feature | AT&T Syntax | Intel Syntax |
|---------|-------------|--------------|
| Operand order | `src, dest` | `dest, src` |
| Register prefix | `%eax` | `eax` |
| Immediate prefix | `$10` | `10` |
| Memory reference | `(%eax)` | `[eax]` |
| Size suffix | `movl` | `mov dword` |
| Offset | `4(%eax)` | `[eax+4]` |

**Example**:
```assembly
# AT&T Syntax
movl $5, %eax
addl %ebx, %eax
movl (%ecx), %edx

# Intel Syntax (equivalent)
mov eax, 5
add eax, ebx
mov edx, [ecx]
```

## 🔍 Common Patterns

### Zero a Register
```assembly
xorl %eax, %eax            # Fastest way
```

### Array Access
```assembly
leal array, %ebx           # Base address
movl (%ebx,%ecx,4), %eax   # array[ecx]
```

### Loop Counter
```assembly
movl $10, %ecx             # Counter
loop_start:
    # ... body ...
    decl %ecx
    jnz loop_start
```

### Function Template
```assembly
my_function:
    pushl %ebp
    movl %esp, %ebp
    # ... body ...
    popl %ebp
    ret
```

## 💡 Tips and Best Practices

### Code Organization
1. **Comment liberally**: Explain what each section does
2. **Use meaningful labels**: `loop_start` not `L1`
3. **Align data**: Respect natural alignment boundaries
4. **Document registers**: Note which registers hold what values

### Performance
1. **Use registers**: Faster than memory access
2. **Minimize memory access**: Cache locality matters
3. **Use lea for arithmetic**: Efficient for multiplication by 2, 3, 4, 5, 8, 9
4. **Avoid unnecessary moves**: Reuse register values when possible

### Debugging
1. **Check register preservation**: Callee-saved registers must be restored
2. **Verify stack alignment**: Must be multiple of 4 (or 16)
3. **Use GDB**: Step through and inspect registers
4. **Test edge cases**: Empty arrays, zero values, negative numbers

### Common Mistakes
1. ❌ **Wrong operand order**: Remember AT&T is `src, dest`
2. ❌ **Forgetting size suffixes**: Use `movl`, `movw`, `movb`
3. ❌ **Not preserving registers**: Save callee-saved if modified
4. ❌ **Stack misalignment**: Always align to 4 bytes
5. ❌ **Memory-to-memory moves**: Not allowed in x86

## 📚 Additional Resources

### Books
- "Programming from the Ground Up" by Jonathan Bartlett
- "Professional Assembly Language" by Richard Blum
- "The Art of Assembly Language" by Randall Hyde

### Online Resources
- [x86 Instruction Reference](https://www.felixcloutier.com/x86/)
- [Linux System Call Table](https://syscalls.kernelgrok.com/)
- [Intel Software Developer Manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)

### Practice Platforms
- [Compiler Explorer](https://godbolt.org/) - See C to assembly translation
- [OnlineGDB](https://www.onlinegdb.com/) - Online assembly testing
- [pwn.college](https://pwn.college/) - Assembly challenges

## 🎯 Project Ideas

### Beginner
1. Calculator (add, subtract, multiply, divide)
2. Temperature converter (C to F)
3. Simple array operations

### Intermediate
1. Sorting algorithms (bubble, insertion, selection)
2. String manipulation library
3. Basic data structure implementations

### Advanced
1. Simple shell (like the ARM example)
2. Math library (sqrt, trigonometry)
3. Memory allocator
4. Mini compiler/interpreter

## 🤝 Contributing

This is a learning resource. Feel free to:
- Add more examples
- Improve explanations
- Fix errors or typos
- Suggest additional topics

## 📄 License

This educational material is provided for learning purposes.

## 🙏 Acknowledgments

Based on course materials from Lucas Bazilio (Udemy) and adapted for comprehensive x86 assembly learning.

---

**Start your journey**: Begin with [01. Architecture](01_Architecture.md) →