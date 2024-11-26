# Memory Manager Test Implementation
.include "../../src/core/memory_manager.s"  # Include the memory manager implementation
.include "../../src/common/constants.s"     # Include shared constants

.text
.globl main
main:
    # Print starting message
    li $v0, 4
    la $a0, test_init
    syscall
    
    # Run all tests
    jal run_tests
    
    # Exit program
    li $v0, 10
    syscall

run_tests:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Test 1: Initialization
    jal initialize_memory_manager
    bnez $v0, test1_fail
    
    la $a0, test_pass
    la $a1, test1_msg
    jal print_result
    
    # Test 2: Add Valid Region
    li $a0, 0x10000000    # Start address
    li $a1, 1024          # Size
    li $a2, 0x7           # RWX permissions
    jal add_memory_region
    bnez $v0, test2_fail
    
    la $a0, test_pass
    la $a1, test2_msg
    jal print_result
    
    # Test 3: Invalid Region
    li $a0, 0x20000000    # Start address
    li $a1, -1            # Invalid size
    li $a2, 0x7           # RWX permissions
    jal add_memory_region
    beqz $v0, test3_fail
    
    la $a0, test_pass
    la $a1, test3_msg
    jal print_result
    
    # Test 4: Validate Access
    li $a0, 0x10000100    # Address within valid region
    li $a1, 0x2           # Read permission
    jal validate_memory_access
    bnez $v0, test4_fail
    
    la $a0, test_pass
    la $a1, test4_msg
    jal print_result
    
    # All tests completed successfully
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

test1_fail:
    la $a0, test_fail
    la $a1, test1_msg
    jal print_result
    # Continue with next test
    j test2_start

test2_fail:
    la $a0, test_fail
    la $a1, test2_msg
    jal print_result
    # Continue with next test
    j test3_start

test3_fail:
    la $a0, test_fail
    la $a1, test3_msg
    jal print_result
    # Continue with next test
    j test4_start

test4_fail:
    la $a0, test_fail
    la $a1, test4_msg
    jal print_result
    # Return from tests
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Test start points
test2_start:
    # Test 2: Add Valid Region
    li $a0, 0x10000000
    li $a1, 1024
    li $a2, 0x7
    jal add_memory_region
    bnez $v0, test2_fail
    j test3_start

test3_start:
    # Test 3: Invalid Region
    li $a0, 0x20000000
    li $a1, -1
    li $a2, 0x7
    jal add_memory_region
    beqz $v0, test3_fail
    j test4_start

test4_start:
    # Test 4: Validate Access
    li $a0, 0x10000100
    li $a1, 0x2
    jal validate_memory_access
    bnez $v0, test4_fail
    # Return from tests if we get here
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

print_result:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Print status (PASS/FAIL)
    li $v0, 4
    la $a0, ($a0)  # Load message address
    syscall
    
    # Print test message
    move $a0, $a1
    syscall
    
    # Print newline
    li $v0, 11
    li $a0, 10
    syscall
    
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

.data
    # Test Messages
    test_init:     .asciiz "\nTesting Memory Manager Initialization\n"
    test_add:      .asciiz "\nTesting Add Memory Region\n"
    test_validate: .asciiz "\nTesting Memory Validation\n"
    test_pass:     .asciiz "PASS: "
    test_fail:     .asciiz "FAIL: "
    
    # Test Cases
    test1_msg:     .asciiz "Initialize memory manager\n"
    test2_msg:     .asciiz "Add valid memory region\n"
    test3_msg:     .asciiz "Detect invalid region size\n"
    test4_msg:     .asciiz "Validate memory access\n"
