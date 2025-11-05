.section .data
    prompt: .asciz "$ "    # The null-terminated string for the shell prompt.
    buffer: .space 256     # A 256-byte buffer to store user input.
    argv_ptr: .quad buffer, 0 # An array of pointers for execve's argv.
                              # It holds a pointer to the command string (buffer)
                              # and is terminated by a null pointer (0).

.section .text
.global _start

_start:
    # TODO: Call main function
    # x86-64: use 'call main'

# Main loop of the shell.
main:
    # TODO: Display the "$ " prompt.
    
    # TODO: Read a line of input from the user.
    
    # TODO: Fork and execute the command.
    
    # TODO: Loop back to the start.

# Displays the prompt string to standard output.
display_prompt:
    # TODO: Save callee-saved registers (rbx, rbp, r12-r15)
    
    # TODO: Load the address of the prompt string
    # x86-64: use 'lea' or 'mov' with RIP-relative addressing
    
    # TODO: Call the function to print the string.
    
    # TODO: Restore registers and return.

# Prints a null-terminated string to standard output.
# rdi: Address of the string to print (x86-64 calling convention)
print_string:
    # TODO: Save registers.
    
    # TODO: Find string length (loop through until null terminator)
    # x86-64: Syscall 'write' (syscall number 1)
    # Args: rax=1 (write), rdi=1 (stdout), rsi=string address, rdx=length
    
_print_loop:
    # TODO: Load a byte from the string.
    # TODO: Check if it's the null terminator.
    # TODO: If yes, jump to _end_print.
    # TODO: Otherwise, increment the length counter.
    # TODO: Loop again.

_end_print:
    # TODO: Execute write syscall
    # rax = 1 (write), rdi = 1 (stdout), rsi = string address, rdx = length
    # x86-64: invoke with 'syscall' instruction
    
    # TODO: Restore registers and return.

# Reads a line of user input from stdin into the buffer.
read_input:
    # TODO: Save registers.
    
    # TODO: Prepare for 'read' syscall (syscall number 0)
    # Args: rax=0 (read), rdi=0 (stdin), rsi=buffer address, rdx=256 (max bytes)
    
    # TODO: Execute the system call.
    # x86-64: invoke with 'syscall' instruction
    
    # TODO: Remove the trailing newline character.
    
    # TODO: Restore registers and return.

# Finds and replaces the trailing newline (0xA) with a null terminator (0x0).
strip_input:
    # TODO: Save registers.
    
    # TODO: Initialize loop counter/index to 0.
    # TODO: Load the base address of the buffer.

_strip_loop:
    # TODO: Load a byte from buffer[index].
    # TODO: Is it a newline character (0xa)?
    # TODO: If yes, go replace it (_remove_newline).
    # TODO: Is it a null character (0x0)?
    # TODO: If yes, we're done (_end_loop).
    # TODO: Increment index.
    # TODO: Continue searching.

_remove_newline:
    # TODO: Store a null byte where the newline was.

_end_loop:
    # TODO: Restore registers and return.

# Main command execution logic.
execute_command:
    # TODO: Save registers.
    
    # TODO: Load buffer address to pass to parser.
    # TODO: Call the (stubbed) parser.
    
    # TODO: Check if the command is empty.
    # TODO: If empty, do nothing and return (end_execute).

    # TODO: Fork the current process.
    # TODO: Check the return value of fork().
    # TODO: If 0, we are the child process (child_process).
    # TODO: Otherwise, we are the parent, so we wait (wait_for_child).

child_process:              # This code is only executed by the child.
    # TODO: Prepare for 'execve' syscall (syscall number 59)
    # Args: rax=59, rdi=filename (buffer), rsi=argv (argv_ptr), rdx=envp (NULL/0)
    
    # TODO: Execute the command.
    # x86-64: invoke with 'syscall' instruction
    
    # If execve returns, it means an error occurred.
    # TODO: Exit the child process (syscall number 60)
    # Args: rax=60, rdi=exit code
    # x86-64: invoke with 'syscall' instruction

wait_for_child:             # This code is only executed by the parent.
    # TODO: Execute 'wait4' syscall (syscall number 61)
    # Args: rax=61, rdi=-1 (wait for any child), rsi=NULL (status), rdx=0 (options), r10=0
    # x86-64: invoke with 'syscall' instruction

end_execute:
    # TODO: Restore registers and return to the main loop.

# A placeholder function for parsing commands and arguments.
# In a real shell, this would split the buffer into tokens.
parse_command:
    # TODO: Save link register (not applicable in x86-64, but save rbp if needed).
    
    # TODO: Load the first character of the buffer.
    # TODO: Check if the first character is null.
    # TODO: If not, set return value to 1 (non-empty command).
    # TODO: If it is, set return value to 0 (empty command).
    # x86-64: return value goes in rax
    
    # TODO: Return.

# Creates a child process.
fork_process:
    # TODO: Save registers.
    
    # TODO: Execute 'fork' syscall (syscall number 57)
    # Args: rax=57
    # x86-64: invoke with 'syscall' instruction
    # Returns PID in rax for parent, 0 for child.
    
    # TODO: Restore registers and return.
