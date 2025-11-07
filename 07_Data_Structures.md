# Data Structures in Assembly

## Overview

Structured data types (vectors, matrices, structs) are stored contiguously in memory. Understanding how to access these structures is crucial for assembly programming.

## Vectors (1D Arrays)

### Declaration in C
```c
type name[size];  // Indexed starting at 0
```

### Memory Layout

Elements are stored in **consecutive memory locations**.

```
Address:     @V    @V+4   @V+8   @V+12  @V+16
           ┌──────┬──────┬──────┬──────┬──────┐
int V[5]:  │  5   │  2   │  -4  │  1   │  3   │
           └──────┴──────┴──────┴──────┴──────┘
Index:        0      1      2      3      4
```

### Access Formula

**Address of element V[i]** = `@V + i * element_size`

Where:
- `@V` = base address (same as `&V[0]`)
- `i` = index
- `element_size` = size of each element in bytes

### Examples by Type

| Declaration | Element Size | Array Size | Address of element i |
|-------------|--------------|------------|----------------------|
| `char A[12];` | 1 byte | 12 bytes | `@A + i` |
| `char *B[80];` | 4 bytes | 320 bytes | `@B + i*4` |
| `double C[1024];` | 8 bytes | 8 KB | `@C + i*8` |
| `int *D[5];` | 4 bytes | 20 bytes | `@D + i*4` |
| `int E[100];` | 4 bytes | 400 bytes | `@E + i*4` |

### Assembly Access Examples

#### Example 1: Access by Constant Index
```c
int arr[10];
int x = arr[3];
```

```assembly
leal array, %ebx       # EBX = base address
movl 12(%ebx), %eax    # EAX = arr[3] (offset = 3*4 = 12)
```

#### Example 2: Access by Variable Index
```c
int arr[10];
int i = 5;
int x = arr[i];
```

```assembly
leal array, %ebx       # EBX = base address
movl $5, %ecx          # ECX = i = 5
movl (%ebx,%ecx,4), %eax   # EAX = arr[i]
```

#### Example 3: Array Traversal
```c
int arr[5] = {5, 2, -4, 1, 3};
int sum = 0;
for (int i = 0; i < 5; i++) {
    sum += arr[i];
}
```

```assembly
.section .data
array: .long 5, 2, -4, 1, 3

.section .text
    leal array, %edx       # EDX = base address
    xorl %eax, %eax        # sum = 0
    xorl %ecx, %ecx        # i = 0
    
loop:
    cmpl $5, %ecx
    jge end_loop
    
    addl (%edx,%ecx,4), %eax   # sum += arr[i]
    incl %ecx
    jmp loop
    
end_loop:
    # sum is in %eax
```

#### Example 4: Modify Array Element
```c
int arr[10];
arr[3] = 100;
```

```assembly
leal array, %ebx       # EBX = base address
movl $100, 12(%ebx)    # arr[3] = 100
```

#### Example 5: Character Array (String)
```c
char str[8] = {'a', 'b', 'f', 'd', 'k', '\0'};
char c = str[3];
```

```assembly
leal string, %ebx      # EBX = base address
movb 3(%ebx), %al      # AL = str[3] = 'd'
```

## Matrices (2D Arrays)

### Declaration in C
```c
type name[NumRows][NumColumns];  // Indexed starting at (0,0)
```

### Memory Layout

Stored **by rows** in consecutive memory locations (row-major order).

```c
int matrix[3][4] = {
    {1,  2,  3,  4},   // Row 0
    {5,  6,  7,  8},   // Row 1
    {9, 10, 11, 12}    // Row 2
};
```

```
Memory Layout (row-major):
┌────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┐
│ 1  │ 2  │ 3  │ 4  │ 5  │ 6  │ 7  │ 8  │ 9  │ 10 │ 11 │ 12 │
└────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┘
  [0][0]  [0][1] [0][2] [0][3] [1][0] [1][1] ...        [2][3]
```

### Access Formula

**Address of element A[i][j]** = `@A + (i * NumColumns + j) * element_size`

Where:
- `@A` = base address
- `i` = row index
- `j` = column index
- `NumColumns` = number of columns
- `element_size` = size of each element

### Examples by Type

| Declaration | Element Size | Matrix Size | Address of (i,j) |
|-------------|--------------|-------------|------------------|
| `char A[80][25];` | 1 byte | 2000 bytes | `@A + i*25 + j` |
| `char *B[80][10];` | 4 bytes | 3200 bytes | `@B + (i*10+j)*4` |
| `double C[1024][100];` | 8 bytes | 800 KB | `@C + (i*100+j)*8` |
| `int *D[5][90];` | 4 bytes | 1800 bytes | `@D + (i*90+j)*4` |
| `int E[100][30];` | 4 bytes | 12000 bytes | `@E + (i*30+j)*4` |

### Assembly Access Examples

#### Example 1: Access Constant Indices
```c
int matrix[10][20];
int x = matrix[2][5];
```

```assembly
leal matrix, %ebx      # EBX = base address
# Offset = (2*20 + 5)*4 = 45*4 = 180
movl 180(%ebx), %eax   # EAX = matrix[2][5]
```

#### Example 2: Access Variable Indices
```c
int matrix[10][20];
int i = 2, j = 5;
int x = matrix[i][j];
```

```assembly
leal matrix, %ebx      # EBX = base address
movl $2, %ecx          # ECX = i = 2
movl $5, %edx          # EDX = j = 5

# Calculate offset: (i * 20 + j) * 4
imull $20, %ecx        # ECX = i * NumColumns
addl %edx, %ecx        # ECX = i * NumColumns + j
movl (%ebx,%ecx,4), %eax   # EAX = matrix[i][j]
```

#### Example 3: Nested Loops (Process All Elements)
```c
int matrix[3][4];
for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 4; j++) {
        matrix[i][j] = i + j;
    }
}
```

```assembly
leal matrix, %ebx      # EBX = base address
xorl %ecx, %ecx        # i = 0

outer_loop:
    cmpl $3, %ecx
    jge end_outer
    
    xorl %edx, %edx    # j = 0
    
inner_loop:
    cmpl $4, %edx
    jge end_inner
    
    # Calculate offset
    movl %ecx, %eax
    imull $4, %eax     # i * NumColumns
    addl %edx, %eax    # i * NumColumns + j
    
    # Calculate value: i + j
    movl %ecx, %esi
    addl %edx, %esi
    
    # Store value
    movl %esi, (%ebx,%eax,4)   # matrix[i][j] = i + j
    
    incl %edx
    jmp inner_loop
    
end_inner:
    incl %ecx
    jmp outer_loop
    
end_outer:
```

#### Example 4: Sum All Elements
```c
int matrix[3][4];
int sum = 0;
for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 4; j++) {
        sum += matrix[i][j];
    }
}
```

```assembly
leal matrix, %ebx      # EBX = base address
xorl %eax, %eax        # sum = 0
xorl %ecx, %ecx        # i = 0

outer_loop:
    cmpl $3, %ecx
    jge end_outer
    
    xorl %edx, %edx    # j = 0
    
inner_loop:
    cmpl $4, %edx
    jge end_inner
    
    # Calculate offset and add
    movl %ecx, %esi
    imull $4, %esi
    addl %edx, %esi
    addl (%ebx,%esi,4), %eax   # sum += matrix[i][j]
    
    incl %edx
    jmp inner_loop
    
end_inner:
    incl %ecx
    jmp outer_loop
    
end_outer:
    # sum is in %eax
```

#### Example 5: Optimized Linear Access
```c
// Instead of nested loops, use single loop
int matrix[3][4];  // 12 total elements
int sum = 0;
for (int k = 0; k < 12; k++) {
    sum += *((int*)matrix + k);
}
```

```assembly
leal matrix, %ebx      # EBX = base address
xorl %eax, %eax        # sum = 0
xorl %ecx, %ecx        # k = 0

loop:
    cmpl $12, %ecx
    jge end_loop
    
    addl (%ebx,%ecx,4), %eax   # sum += matrix[k]
    incl %ecx
    jmp loop
    
end_loop:
```

## 3D Arrays (Matrices)

### Declaration in C
```c
type name[Dim1][Dim2][Dim3];
```

### Access Formula

**Address of element A[i][j][k]** = `@A + ((i * Dim2 + j) * Dim3 + k) * element_size`

### Example: 3D Array Access
```c
int cube[2][3][4];  // 2 layers, 3 rows, 4 columns
int x = cube[1][2][3];
```

```assembly
leal cube, %ebx        # EBX = base address

# i=1, j=2, k=3, Dim2=3, Dim3=4
movl $1, %ecx          # i
imull $3, %ecx         # i * Dim2
addl $2, %ecx          # i * Dim2 + j
imull $4, %ecx         # (i * Dim2 + j) * Dim3
addl $3, %ecx          # (i * Dim2 + j) * Dim3 + k

movl (%ebx,%ecx,4), %eax   # EAX = cube[1][2][3]
```

## Structures (Structs)

### Declaration in C
```c
struct Name {
    type1 field1;
    type2 field2;
    ...
};
```

### Characteristics
- **Heterogeneous**: Different data types
- **Contiguous**: Stored in consecutive memory
- **Named access**: Fields accessed by name/offset

### Example 1: Simple Structure
```c
struct Point {
    int x;       // offset 0
    int y;       // offset 4
};              // total size: 8 bytes

struct Point p;
p.x = 10;
p.y = 20;
```

```assembly
# Assume %ebx points to struct Point
movl $10, (%ebx)       # p.x = 10 (offset 0)
movl $20, 4(%ebx)      # p.y = 20 (offset 4)
```

### Example 2: Nested Structure
```c
struct Person {
    int age;        // offset 0
    char name[10];  // offset 4
    int id;         // offset 14 (but aligned to 16)
};                  // total size: 20 bytes (with padding)
```

```assembly
# Assume %ebx points to struct Person
movl $25, (%ebx)       # person.age = 25
movb $'J', 4(%ebx)     # person.name[0] = 'J'
movl $12345, 16(%ebx)  # person.id = 12345 (aligned)
```

### Example 3: Array of Structures
```c
struct Point {
    int x;
    int y;
};  // 8 bytes

struct Point points[10];
points[3].x = 100;
```

```assembly
leal points, %ebx      # EBX = base address
# points[3].x: offset = 3 * 8 + 0 = 24
movl $100, 24(%ebx)
# points[3].y: offset = 3 * 8 + 4 = 28
movl $200, 28(%ebx)
```

#### Alternative: Using Index Register
```assembly
leal points, %ebx      # EBX = base address
movl $3, %ecx          # ECX = index = 3
# points[3].x
movl $100, (%ebx,%ecx,8)     # offset within struct = 0
# points[3].y
movl $200, 4(%ebx,%ecx,8)    # offset within struct = 4
```

## Data Alignment

### Alignment Rules (Linux 32-bit)

**Primitive data type requiring k bytes must be at address that's a multiple of k.**

| Type | Size | Alignment Required |
|------|------|-------------------|
| `char` | 1 byte | 1-byte (any address) |
| `short` | 2 bytes | 2-byte (multiple of 2) |
| `int` | 4 bytes | 4-byte (multiple of 4) |
| `pointer` | 4 bytes | 4-byte (multiple of 4) |
| `float` | 4 bytes | 4-byte (multiple of 4) |
| `double` | 8 bytes | 4-byte (Linux-32) or 8-byte (Linux-64) |

### Why Alignment Matters
1. **Performance**: Aligned access is faster
2. **Cache**: Unaligned data may span cache lines
3. **Virtual memory**: Data shouldn't cross page boundaries

### Structure Alignment

**Structure alignment requirement k** = largest alignment of any member

**Rules**:
1. Each member must be aligned according to its type
2. Structure size must be multiple of k
3. Compiler inserts padding to ensure alignment

### Example 1: Structure with Padding
```c
struct Example1 {
    char c;     // 1 byte at offset 0
    int i;      // 4 bytes at offset 4 (padded)
    short s;    // 2 bytes at offset 8
};              // size: 12 (padded to multiple of 4)
```

```
Memory layout:
Offset:  0    1    2    3    4    5    6    7    8    9   10   11
       ┌────┬─────────────┬──────────────────┬────────────┬─────────┐
       │ c  │  padding    │        i         │     s      │ padding │
       └────┴─────────────┴──────────────────┴────────────┴─────────┘
Size: 1 + 3 (pad) + 4 + 2 + 2 (pad) = 12 bytes
```

### Example 2: Order Affects Size
```c
// Poor ordering
struct Bad {
    char c1;    // 1 byte
    int i;      // 4 bytes (3 bytes padding before)
    char c2;    // 1 byte
};              // Total: 12 bytes (with padding)

// Good ordering
struct Good {
    int i;      // 4 bytes
    char c1;    // 1 byte
    char c2;    // 1 byte
};              // Total: 8 bytes (with padding)
```

```
Bad layout (12 bytes):
┌────┬─────────────┬──────────────────┬────┬─────────┐
│ c1 │  padding    │        i         │ c2 │ padding │
└────┴─────────────┴──────────────────┴────┴─────────┘
 1      3              4                1       3

Good layout (8 bytes):
┌──────────────────┬────┬────┬─────────┐
│        i         │ c1 │ c2 │ padding │
└──────────────────┴────┴────┴─────────┘
       4             1    1       2
```

### Accessing Aligned Structures
```c
struct Aligned {
    int a;      // offset 0
    char b;     // offset 4
    // padding: 3 bytes
    double c;   // offset 8 (Linux-32: multiple of 4, Linux-64: multiple of 8)
};
```

```assembly
# Accessing members (Linux-32)
# Assume %ebp points to struct
movl (%ebp), %eax          # a (offset 0)
movb 4(%ebp), %al          # b (offset 4)
fldl 8(%ebp)               # c (offset 8) - load double to FPU
```

## Practical Examples

### Example 1: Function Processing Array
```c
int sum_array(int *arr, int size) {
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
    
    movl 8(%ebp), %edx     # EDX = arr (pointer)
    movl 12(%ebp), %ecx    # ECX = size
    xorl %eax, %eax        # sum = 0
    xorl %ebx, %ebx        # i = 0
    
loop:
    cmpl %ecx, %ebx
    jge end_loop
    
    addl (%edx,%ebx,4), %eax   # sum += arr[i]
    incl %ebx
    jmp loop
    
end_loop:
    popl %ebp
    ret
```

### Example 2: Matrix Transpose
```c
void transpose(int src[3][3], int dst[3][3]) {
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            dst[j][i] = src[i][j];
        }
    }
}
```

```assembly
transpose:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi
    
    movl 8(%ebp), %esi     # ESI = src
    movl 12(%ebp), %edi    # EDI = dst
    xorl %ecx, %ecx        # i = 0
    
outer:
    cmpl $3, %ecx
    jge end_outer
    
    xorl %edx, %edx        # j = 0
    
inner:
    cmpl $3, %edx
    jge end_inner
    
    # Calculate src[i][j] offset
    movl %ecx, %eax
    imull $3, %eax
    addl %edx, %eax
    movl (%esi,%eax,4), %ebx   # EBX = src[i][j]
    
    # Calculate dst[j][i] offset
    movl %edx, %eax
    imull $3, %eax
    addl %ecx, %eax
    movl %ebx, (%edi,%eax,4)   # dst[j][i] = src[i][j]
    
    incl %edx
    jmp inner
    
end_inner:
    incl %ecx
    jmp outer
    
end_outer:
    popl %edi
    popl %esi
    popl %ebx
    popl %ebp
    ret
```

## Summary

### Vectors
- **Formula**: `address = base + index * element_size`
- Use scaled indexing: `(%base,%index,scale)`

### Matrices
- **Formula**: `address = base + (row * num_cols + col) * element_size`
- Row-major order storage
- Nested loops for 2D access

### 3D Arrays
- **Formula**: `address = base + ((i * Dim2 + j) * Dim3 + k) * element_size`

### Structures
- Members at fixed offsets
- Compiler adds padding for alignment
- Member order affects total size

### Alignment
- Primitives align to their size
- Structures align to largest member
- Size must be multiple of alignment

Understanding data structure layout is essential for efficient memory access in assembly programming.
