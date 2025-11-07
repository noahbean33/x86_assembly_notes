# Control Flow in Assembly

## Overview

Control flow structures in high-level languages (if, while, for) are implemented using conditional jumps and labels in assembly.

## IF-THEN-ELSE Statement

### C Model
```c
if (condition) {
    // BODY-IF
} else {
    // BODY-ELSE
}
```

### Assembly Pattern
```assembly
    # Evaluate condition
    # Jump if condition fails
    j<opposite_condition> else_label
    
if_body:
    # BODY-IF
    jmp endif
    
else_label:
    # BODY-ELSE
    
endif:
    # Continue...
```

### Example 1: Simple If-Else
```c
if (x > 10) {
    y = 1;
} else {
    y = 0;
}
```

```assembly
    # Assume x in %eax
    cmpl $10, %eax         # Compare x with 10
    jle else_label         # Jump if x <= 10 (opposite of >)
    
if_body:
    movl $1, %ebx          # y = 1
    jmp endif
    
else_label:
    movl $0, %ebx          # y = 0
    
endif:
    # Continue with y in %ebx
```

### Example 2: If Without Else
```c
if (x < 0) {
    x = -x;
}
```

```assembly
    # Assume x in %eax
    cmpl $0, %eax          # Compare x with 0
    jge endif              # Jump if x >= 0 (skip if body)
    
if_body:
    negl %eax              # x = -x
    
endif:
    # Continue...
```

### Example 3: Nested If
```c
if (x > 0) {
    if (x < 100) {
        y = x;
    }
}
```

```assembly
    # Assume x in %eax
    cmpl $0, %eax          # Compare x with 0
    jle endif_outer        # Jump if x <= 0
    
outer_if:
    cmpl $100, %eax        # Compare x with 100
    jge endif_inner        # Jump if x >= 100
    
inner_if:
    movl %eax, %ebx        # y = x
    
endif_inner:
endif_outer:
    # Continue...
```

## WHILE Loop

### C Model
```c
while (condition) {
    // BODY-WHILE
}
```

### Assembly Pattern
```assembly
while_start:
    # Evaluate condition
    # Jump if condition fails
    j<opposite_condition> end_while
    
    # BODY-WHILE
    
    jmp while_start        # Loop back
    
end_while:
    # Continue...
```

### Example 1: Simple While Loop
```c
int sum = 0;
int i = 0;
while (i < 10) {
    sum += i;
    i++;
}
```

```assembly
    xorl %eax, %eax        # sum = 0
    xorl %ecx, %ecx        # i = 0
    
while_start:
    cmpl $10, %ecx         # Compare i with 10
    jge end_while          # Jump if i >= 10
    
while_body:
    addl %ecx, %eax        # sum += i
    incl %ecx              # i++
    jmp while_start        # Loop back
    
end_while:
    # sum is in %eax
```

### Example 2: While Loop with Array
```c
int arr[10];
int i = 0;
while (i < 10) {
    arr[i] = i * 2;
    i++;
}
```

```assembly
    leal array, %ebx       # EBX = base address
    xorl %ecx, %ecx        # i = 0
    
while_start:
    cmpl $10, %ecx         # Compare i with 10
    jge end_while          # Jump if i >= 10
    
while_body:
    movl %ecx, %eax        # EAX = i
    shll $1, %eax          # EAX = i * 2
    movl %eax, (%ebx,%ecx,4)  # arr[i] = i * 2
    incl %ecx              # i++
    jmp while_start        # Loop back
    
end_while:
```

## DO-WHILE Loop

### C Model
```c
do {
    // BODY-DO-WHILE
} while (condition);
```

### Assembly Pattern
```assembly
do_while_start:
    # BODY-DO-WHILE
    
    # Evaluate condition
    # Jump if condition succeeds
    j<condition> do_while_start
    
    # Continue...
```

**Key difference**: Body executes at least once (no initial condition check).

### Example: Do-While Loop
```c
int i = 0;
do {
    i++;
} while (i < 10);
```

```assembly
    xorl %ecx, %ecx        # i = 0
    
do_while_start:
    incl %ecx              # i++
    cmpl $10, %ecx         # Compare i with 10
    jl do_while_start      # Jump if i < 10
    
    # Continue with i in %ecx
```

## FOR Loop

### C Model
```c
for (initialization; condition; increment) {
    // BODY-FOR
}
```

### Assembly Pattern
```assembly
    # Initialization
    
for_start:
    # Evaluate condition
    # Jump if condition fails
    j<opposite_condition> end_for
    
    # BODY-FOR
    
    # Increment
    jmp for_start          # Loop back
    
end_for:
    # Continue...
```

### Example 1: Simple For Loop
```c
int sum = 0;
for (int i = 0; i < 10; i++) {
    sum += i;
}
```

```assembly
    xorl %eax, %eax        # sum = 0
    xorl %ecx, %ecx        # i = 0 (initialization)
    
for_start:
    cmpl $10, %ecx         # Compare i with 10
    jge end_for            # Jump if i >= 10
    
for_body:
    addl %ecx, %eax        # sum += i
    incl %ecx              # i++ (increment)
    jmp for_start          # Loop back
    
end_for:
    # sum is in %eax
```

### Example 2: For Loop with Array Sum
```c
int arr[5] = {5, 2, -4, 1, 3};
int sum = 0;
for (int i = 0; i < 5; i++) {
    sum += arr[i];
}
```

```assembly
    leal array, %edx       # EDX = address of array
    xorl %eax, %eax        # sum = 0
    xorl %ecx, %ecx        # i = 0
    
for_start:
    cmpl $5, %ecx          # Compare i with 5
    jge end_for            # Jump if i >= 5
    
for_body:
    addl (%edx,%ecx,4), %eax   # sum += arr[i]
    incl %ecx              # i++
    jmp for_start          # Loop back
    
end_for:
    # sum is in %eax
```

### Example 3: Nested For Loops (2D Array)
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
    
outer_for:
    cmpl $3, %ecx          # Compare i with 3
    jge end_outer
    
    xorl %edx, %edx        # j = 0
    
inner_for:
    cmpl $4, %edx          # Compare j with 4
    jge end_inner
    
inner_body:
    # Calculate matrix[i][j] address: base + (i*4 + j)*4
    movl %ecx, %eax
    shll $2, %eax          # i * 4
    addl %edx, %eax        # i * 4 + j
    
    # Calculate value: i + j
    movl %ecx, %esi
    addl %edx, %esi        # i + j
    
    # Store value
    movl %esi, (%ebx,%eax,4)   # matrix[i][j] = i + j
    
    incl %edx              # j++
    jmp inner_for
    
end_inner:
    incl %ecx              # i++
    jmp outer_for
    
end_outer:
```

## SWITCH Statement

### C Model
```c
switch (x) {
    case 0:
        // Case 0
        break;
    case 1:
        // Case 1
        break;
    case 2:
        // Case 2
        break;
    default:
        // Default
}
```

### Assembly Pattern (Jump Table)
```assembly
    # Assume x in %eax
    cmpl $2, %eax          # Check if x > max_case
    ja default_case        # Out of range, go to default
    
    # Jump table lookup
    jmp *jump_table(,%eax,4)
    
.section .rodata
jump_table:
    .long case_0
    .long case_1
    .long case_2
    
.section .text
case_0:
    # Code for case 0
    jmp end_switch
    
case_1:
    # Code for case 1
    jmp end_switch
    
case_2:
    # Code for case 2
    jmp end_switch
    
default_case:
    # Default code
    
end_switch:
```

### Example: Switch with Simple Cases
```c
int result;
switch (x) {
    case 0:
        result = 10;
        break;
    case 1:
        result = 20;
        break;
    case 2:
        result = 30;
        break;
    default:
        result = -1;
}
```

```assembly
    # Assume x in %eax
    cmpl $2, %eax
    ja default_case
    
    jmp *jump_table(,%eax,4)
    
case_0:
    movl $10, %ebx
    jmp end_switch
    
case_1:
    movl $20, %ebx
    jmp end_switch
    
case_2:
    movl $30, %ebx
    jmp end_switch
    
default_case:
    movl $-1, %ebx
    
end_switch:
    # result is in %ebx
```

## BREAK and CONTINUE

### Break in Loop

**Break**: Exit the loop immediately

```c
for (int i = 0; i < 10; i++) {
    if (i == 5) break;
    // ...
}
```

```assembly
    xorl %ecx, %ecx
    
for_start:
    cmpl $10, %ecx
    jge end_for
    
    cmpl $5, %ecx          # Check if i == 5
    je end_for             # Break: jump to end
    
    # ... loop body ...
    
    incl %ecx
    jmp for_start
    
end_for:
```

### Continue in Loop

**Continue**: Skip rest of iteration, go to next iteration

```c
for (int i = 0; i < 10; i++) {
    if (i % 2 == 0) continue;
    // ... only for odd numbers
}
```

```assembly
    xorl %ecx, %ecx
    
for_start:
    cmpl $10, %ecx
    jge end_for
    
    testl $1, %ecx         # Check if odd
    jz continue_point      # Continue: skip to increment
    
    # ... loop body (only for odd) ...
    
continue_point:
    incl %ecx
    jmp for_start
    
end_for:
```

## Comparison Operators Summary

### Signed Comparisons
| C Operator | After CMP | Jump Instruction |
|------------|-----------|------------------|
| `a == b`   | `cmpl b, a` | `je` / `jz` |
| `a != b`   | `cmpl b, a` | `jne` / `jnz` |
| `a < b`    | `cmpl b, a` | `jl` |
| `a <= b`   | `cmpl b, a` | `jle` |
| `a > b`    | `cmpl b, a` | `jg` |
| `a >= b`   | `cmpl b, a` | `jge` |

### Unsigned Comparisons
| C Operator | After CMP | Jump Instruction |
|------------|-----------|------------------|
| `a == b`   | `cmpl b, a` | `je` / `jz` |
| `a != b`   | `cmpl b, a` | `jne` / `jnz` |
| `a < b`    | `cmpl b, a` | `jb` |
| `a <= b`   | `cmpl b, a` | `jbe` |
| `a > b`    | `cmpl b, a` | `ja` |
| `a >= b`   | `cmpl b, a` | `jae` |

## Compound Conditions

### AND Condition
```c
if (a > 0 && b < 10) {
    // body
}
```

```assembly
    # Short-circuit evaluation
    cmpl $0, %eax          # Check a > 0
    jle endif              # If false, skip entire if
    
    cmpl $10, %ebx         # Check b < 10
    jge endif              # If false, skip if body
    
if_body:
    # body
    
endif:
```

### OR Condition
```c
if (a < 0 || b > 100) {
    // body
}
```

```assembly
    # Short-circuit evaluation
    cmpl $0, %eax          # Check a < 0
    jl if_body             # If true, execute body
    
    cmpl $100, %ebx        # Check b > 100
    jle endif              # If false, skip body
    
if_body:
    # body
    
endif:
```

## Optimized Patterns

### Pattern 1: Conditional Move (CMOV)
```c
result = (a > b) ? a : b;  // max(a, b)
```

```assembly
    # Using cmov (if supported)
    movl %eax, %ecx        # ECX = a
    cmpl %ebx, %eax        # Compare a with b
    cmovle %ebx, %ecx      # If a <= b, ECX = b
    # result in %ecx
```

### Pattern 2: Loop with Decrement
```c
for (int i = 10; i > 0; i--) {
    // body
}
```

```assembly
    movl $10, %ecx
    
for_start:
    testl %ecx, %ecx       # Check if i == 0
    jz end_for
    
    # body
    
    decl %ecx
    jmp for_start
    
end_for:
```

### Pattern 3: Early Exit from Function
```c
int func(int x) {
    if (x < 0) return -1;
    if (x == 0) return 0;
    return 1;
}
```

```assembly
func:
    pushl %ebp
    movl %esp, %ebp
    
    movl 8(%ebp), %eax     # Get parameter x
    
    cmpl $0, %eax
    jl return_minus_one
    je return_zero
    
    # return 1
    movl $1, %eax
    jmp func_end
    
return_minus_one:
    movl $-1, %eax
    jmp func_end
    
return_zero:
    movl $0, %eax
    
func_end:
    popl %ebp
    ret
```

## Common Mistakes to Avoid

1. **Wrong jump condition**: Use opposite of C condition after CMP
   ```c
   if (x > 10)  // Jump if NOT greater (jle)
   ```

2. **Signed vs Unsigned**: Use correct jump instruction
   ```assembly
   # Signed: jl, jle, jg, jge
   # Unsigned: jb, jbe, ja, jae
   ```

3. **Forgetting to jump past else**: Always include `jmp endif` at end of if-body

4. **Not preserving registers**: Save registers used in loop body if needed later

## Summary

- **If-else**: Evaluate condition, jump on opposite condition, implement both branches
- **While**: Check condition at start, loop back at end
- **Do-while**: Execute body first, check condition at end
- **For**: Initialize, check condition, execute body, increment, loop back
- **Switch**: Use jump table for efficient multi-way branch
- **Break**: Jump to loop end
- **Continue**: Jump to loop start (after increment)
- **Compound conditions**: Use short-circuit evaluation

Understanding control flow patterns is essential for translating high-level logic to assembly.
