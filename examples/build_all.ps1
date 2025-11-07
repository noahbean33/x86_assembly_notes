# PowerShell build script for all assembly examples (using WSL)

Write-Host "Building all x86 assembly examples..." -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if WSL is available
try {
    wsl --version | Out-Null
} catch {
    Write-Host "Error: WSL not found. Please install WSL with Ubuntu." -ForegroundColor Red
    Write-Host "Visit: https://docs.microsoft.com/en-us/windows/wsl/install" -ForegroundColor Yellow
    exit 1
}

# Counter for statistics
$total = 0
$success = 0
$failed = 0

Get-ChildItem -Filter *.s | ForEach-Object {
    $name = $_.BaseName
    $file = $_.Name
    Write-Host "Building $name... " -NoNewline
    $total++
    
    # Assemble
    $assembleResult = wsl as --32 $file -o "$name.o" 2>&1
    if ($LASTEXITCODE -eq 0) {
        # Link
        $linkResult = wsl ld -m elf_i386 "$name.o" -o $name 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Success" -ForegroundColor Green
            $success++
            # Clean up object file
            wsl rm "$name.o" 2>$null
        } else {
            Write-Host "✗ Link failed" -ForegroundColor Red
            $failed++
        }
    } else {
        Write-Host "✗ Assemble failed" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Build Summary:" -ForegroundColor Cyan
Write-Host "  Total:   $total" -ForegroundColor White
Write-Host "  Success: $success" -ForegroundColor Green
Write-Host "  Failed:  $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($failed -eq 0) {
    Write-Host "All examples built successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To run an example in WSL:" -ForegroundColor Yellow
    Write-Host "  wsl ./01_hello_world" -ForegroundColor White
    Write-Host ""
    Write-Host "To check exit code:" -ForegroundColor Yellow
    Write-Host "  wsl ./02_sum_array; wsl echo 'Exit code:' `$?" -ForegroundColor White
} else {
    Write-Host "Some examples failed to build." -ForegroundColor Red
    Write-Host "Make sure you have 32-bit build tools installed in WSL:" -ForegroundColor Yellow
    Write-Host "  wsl sudo apt-get install gcc-multilib binutils" -ForegroundColor White
}
