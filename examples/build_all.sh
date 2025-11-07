#!/bin/bash
# Build script for all assembly examples

echo "Building all x86 assembly examples..."
echo "======================================"

# Counter for statistics
total=0
success=0
failed=0

for file in *.s; do
    if [ -f "$file" ]; then
        name="${file%.s}"
        echo -n "Building $name... "
        total=$((total + 1))
        
        # Assemble
        if as --32 "$file" -o "$name.o" 2>/dev/null; then
            # Link
            if ld -m elf_i386 "$name.o" -o "$name" 2>/dev/null; then
                echo "✓ Success"
                success=$((success + 1))
                # Clean up object file
                rm "$name.o"
            else
                echo "✗ Link failed"
                failed=$((failed + 1))
            fi
        else
            echo "✗ Assemble failed"
            failed=$((failed + 1))
        fi
    fi
done

echo ""
echo "======================================"
echo "Build Summary:"
echo "  Total:   $total"
echo "  Success: $success"
echo "  Failed:  $failed"
echo ""

if [ $failed -eq 0 ]; then
    echo "All examples built successfully!"
    echo ""
    echo "To run an example:"
    echo "  ./01_hello_world"
    echo ""
    echo "To check exit code:"
    echo "  ./02_sum_array && echo \"Exit code: \$?\""
else
    echo "Some examples failed to build."
    echo "Make sure you have 32-bit build tools installed:"
    echo "  sudo apt-get install gcc-multilib"
fi
