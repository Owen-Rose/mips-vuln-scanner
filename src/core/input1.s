.data
    # UI Messages
    welcome:     .asciiz "\nSecure Note Storage System\n"
    menu_text:   .asciiz "\n1. Create Note\n2. View Note\n3. Exit\nChoice: "
    note_prompt: .asciiz "Enter your secret note: "
    pass_create: .asciiz "Create a password: "
    pass_check:  .asciiz "Enter password: "
    note_saved:  .asciiz "Note saved securely!\n"
    auth_fail:   .asciiz "Incorrect password!\n"
    newline:     .asciiz "\n"

    # Storage
    note_buffer: .space 64         # Space for secret note
    pass_buffer: .space 16         # Space for password
    auth_flag:   .word 0           # Authentication flag - key to the vulnerability

.text
.globl main

main:
    li $v0, 4
    la $a0, welcome
    syscall

show_menu:
    # Show menu
    li $v0, 4
    la $a0, menu_text
    syscall
    
    # Get choice
    li $v0, 5
    syscall
    
    beq $v0, 1, create_note
    beq $v0, 2, view_note
    beq $v0, 3, exit_prog
    j show_menu

create_note:
    # Get password first
    li $v0, 4
    la $a0, pass_create
    syscall
    
    li $v0, 8               # Read password
    la $a0, pass_buffer
    li $a1, 16
    syscall
    
    # Get note
    li $v0, 4
    la $a0, note_prompt
    syscall
    
    li $v0, 8               # Read note
    la $a0, note_buffer
    li $a1, 64             # Allow full buffer size
    syscall
    
    # Clear auth flag
    sw $zero, auth_flag
    
    # Confirm save
    li $v0, 4
    la $a0, note_saved
    syscall
    
    j show_menu

view_note:
    # Reset auth flag
    sw $zero, auth_flag
    
    # Ask for password
    li $v0, 4
    la $a0, pass_check
    syscall
    
    # Read password attempt - VULNERABLE PART
    li $v0, 8
    la $a0, pass_buffer     # Store input at password location
    li $a1, 32             # Allow more input than buffer size!
    syscall                # This can overflow into auth_flag
    
    # Check auth flag
    lw $t0, auth_flag
    beq $t0, 0, auth_failed
    
    # If auth flag is modified, show note
    li $v0, 4
    la $a0, note_buffer
    syscall
    j show_menu

auth_failed:
    li $v0, 4
    la $a0, auth_fail
    syscall
    j show_menu

exit_prog:
    li $v0, 10
    syscall