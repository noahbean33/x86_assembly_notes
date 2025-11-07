# Assembly Code Examples

This directory contains 11 working x86 assembly examples demonstrating various programming concepts.

## Examples List

1. **01_hello_world.s** - Basic I/O with system calls
2. **02_sum_array.s** - Array traversal and summation
3. **03_find_max.s** - Finding maximum value in array
4. **04_bubble_sort.s** - Bubble sort algorithm
5. **05_factorial.s** - Recursive factorial calculation
6. **06_strlen.s** - String length calculation
7. **07_strcpy.s** - String copy implementation
8. **08_matrix_multiply.s** - 2x2 matrix multiplication
9. **09_binary_search.s** - Binary search algorithm
10. **10_calculator.s** - Function pointers and calculator
11. **11_linked_list.s** - Linked list traversal

## Building and Running (Linux)

### Using GAS (GNU Assembler)

```bash
# Assemble
as --32 01_hello_world.s -o 01_hello_world.o

# Link
ld -m elf_i386 01_hello_world.o -o 01_hello_world

# Run
./01_hello_world

# Check exit code
echo $?
```

### Build All Examples (Bash Script)

```bash
#!/bin/bash
for file in *.s; do
    name="${file%.s}"
    echo "Building $name..."
    as --32 "$file" -o "$name.o"
    ld -m elf_i386 "$name.o" -o "$name"
    rm "$name.o"
done
echo "Done!"
```

### Build Script (PowerShell - Windows with WSL)

```powershell
Get-ChildItem -Filter *.s | ForEach-Object {
    $name = $_.BaseName
    Write-Host "Building $name..."
    wsl as --32 $_.Name -o "$name.o"
    wsl ld -m elf_i386 "$name.o" -o $name
    wsl rm "$name.o"
}
Write-Host "Done!"
```

## Debugging with GDB

```bash
# Compile with debug symbols
as --32 -g 01_hello_world.s -o 01_hello_world.o
ld -m elf_i386 01_hello_world.o -o 01_hello_world

# Start debugger
gdb ./01_hello_world

# Useful GDB commands:
(gdb) break _start          # Set breakpoint
(gdb) run                   # Run program
(gdb) stepi                 # Step one instruction
(gdb) info registers        # Show all registers
(gdb) x/10x $esp           # Examine stack
(gdb) x/s $ecx             # Examine string at ECX
(gdb) continue             # Continue execution
(gdb) quit                 # Exit GDB
```

## Expected Results

### 01_hello_world.s
```
Output: Hello, World!
Exit code: 0
```

### 02_sum_array.s
```
Array: [5, 2, -4, 1, 3]
Sum: 7
Exit code: 7
```

### 03_find_max.s
```
Array: [5, 12, -4, 23, 3]
Max: 23
Exit code: 23
```

### 04_bubble_sort.s
```
Input: [64, 34, 25, 12, 22, 11, 90]
Sorted: [11, 12, 22, 25, 34, 64, 90]
Exit code: 0
```

### 05_factorial.s
```
factorial(5) = 120
Exit code: 120
```

### 06_strlen.s
```
String: "Hello, Assembly!"
Length: 16
Exit code: 16
```

### 07_strcpy.s
```
Source: "Hello!"
Destination: "Hello!" (copied)
Exit code: 0
```

### 08_matrix_multiply.s
```
Matrix A: [[1,2], [3,4]]
Matrix B: [[5,6], [7,8]]
Result: [[19,22], [43,50]]
Exit code: 0
```

### 09_binary_search.s
```
Array: [1, 3, 5, 7, 9, 11, 13, 15]
Target: 7
Index: 3
Exit code: 3
```

### 10_calculator.s
```
calculate(10, 5, add) = 15
Exit code: 15
```

### 11_linked_list.s
```
List: 10 -> 20 -> 30 -> NULL
Sum: 60
Exit code: 60
```

## Modifying Examples

To modify an example:

1. Edit the `.s` file with your changes
2. Reassemble and link:
   ```bash
   as --32 modified_file.s -o modified_file.o
   ld -m elf_i386 modified_file.o -o modified_file
   ```
3. Run and test:
   ```bash
   ./modified_file
   echo $?
   ```

## Common Issues

### "cannot find -lc" or similar errors
These examples use direct system calls and don't link against libc. Make sure you're using:
```bash
ld -m elf_i386  # NOT gcc
```

### "Exec format error"
Make sure you're assembling for 32-bit:
```bash
as --32 file.s -o file.o
ld -m elf_i386 file.o -o file
```

### Wrong exit codes
Remember that exit codes are modulo 256:
- Exit code 260 appears as 4 (260 % 256)
- Exit code -1 appears as 255

## Using with NASM

If you prefer NASM syntax, convert the AT&T syntax:

**GAS (AT&T)**:
```assembly
movl $5, %eax
addl %ebx, %eax
```

**NASM (Intel)**:
```assembly
mov eax, 5
add eax, ebx
```

Build with NASM:
```bash
nasm -f elf32 file.asm -o file.o
ld -m elf_i386 file.o -o file
```

## Learning Path

### Beginner
1. Start with `01_hello_world.s`
2. Study `02_sum_array.s` and `03_find_max.s`
3. Practice with `06_strlen.s`

### Intermediate
1. Analyze `04_bubble_sort.s`
2. Understand `05_factorial.s` (recursion)
3. Study `07_strcpy.s`

### Advanced
1. Dissect `08_matrix_multiply.s`
2. Study `09_binary_search.s`
3. Understand `10_calculator.s` (function pointers)
4. Analyze `11_linked_list.s` (data structures)

## Additional Resources

- [Parent Documentation](../README.md)
- [Instructions Reference](../05_Instructions.md)
- [Calling Conventions](../03_Conventions.md)
- [Data Structures](../07_Data_Structures.md)

## License

Educational use - part of x86 Assembly Programming Course
