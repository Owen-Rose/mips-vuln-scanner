.data
    # UI Messages
    welcome:     .asciiz "\nSecure Digital Store\n"
    menu_text:   .asciiz "\n1. Add Funds\n2. Purchase Item\n3. Check Balance\n4. Exit\nChoice: "
    add_prompt:  .asciiz "Enter amount to add ($): "
    cost_prompt: .asciiz "\nEnter item cost ($): "
    qty_prompt:  .asciiz "Enter quantity: "
    bal_msg:     .asciiz "\nCurrent Balance: $"
    success:     .asciiz "\nPurchase successful!\n"
    insuf:       .asciiz "\nInsufficient funds!\n"
    newline:     .asciiz "\n"

    # Account data
    balance:     .word 0           # Current balance
    max_bal:     .word 1000000     # Maximum allowed balance

.text
.globl main

main:
    li $v0, 4
    la $a0, welcome
    syscall

show_menu:
    # Display menu
    li $v0, 4
    la $a0, menu_text
    syscall
    
    # Get choice
    li $v0, 5
    syscall
    
    beq $v0, 1, add_funds
    beq $v0, 2, purchase
    beq $v0, 3, show_balance
    beq $v0, 4, exit_prog
    j show_menu

add_funds:
    # Prompt for amount
    li $v0, 4
    la $a0, add_prompt
    syscall
    
    # Get amount
    li $v0, 5
    syscall
    move $t0, $v0        # Amount to add
    
    # Load current balance
    lw $t1, balance
    
    # Check if both numbers are negative (vulnerability #1)
    bgez $t0, do_add    # If amount is positive, just add it
    bgez $t1, do_add    # If current balance is positive, just add it
    
    # Both numbers are negative, add them with unsigned add to allow overflow
    addu $t2, $t1, $t0
    j store_result

do_add:
    # Regular addition for other cases
    addu $t2, $t1, $t0

store_result:
    # Store new balance
    sw $t2, balance
    j show_balance

purchase:
    # Get item cost
    li $v0, 4
    la $a0, cost_prompt
    syscall
    
    li $v0, 5
    syscall
    move $t0, $v0    # Cost per item
    
    # Get quantity
    li $v0, 4
    la $a0, qty_prompt
    syscall
    
    li $v0, 5
    syscall
    move $t1, $v0    # Quantity
    
    # Calculate total (vulnerability #2)
    mul $t2, $t0, $t1    # Total cost can overflow
    bltz $t2, success_purchase  # If overflow makes it negative, allow purchase!
    
    # Check if enough funds
    lw $t3, balance
    bgt $t2, $t3, insufficient
    
success_purchase:
    # Perform purchase
    lw $t3, balance
    sub $t3, $t3, $t2
    sw $t3, balance
    
    # Show success
    li $v0, 4
    la $a0, success
    syscall
    j show_menu

insufficient:
    li $v0, 4
    la $a0, insuf
    syscall
    j show_menu

show_balance:
    li $v0, 4
    la $a0, bal_msg
    syscall
    
    lw $a0, balance
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    j show_menu

exit_prog:
    li $v0, 10
    syscall