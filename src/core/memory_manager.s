# Memory Manager Implementation

.text
# Make the functions global so they can be accessed from the test file
.globl initialize_memory_manager
.globl add_memory_region
.globl validate_memory_access

# Initialize Memory Manager
# Input: None
# Output: $v0 - Status code (0 for success)
initialize_memory_manager:
    # Function prologue
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Print initialization message
    li $v0, 4
    la $a0, msgInitialize
    syscall
    
    # Clear memory map
    la $t0, memoryMap          # Load base address
    lw $t1, mapEntryCount      # Load entry count
    li $t2, 0                  # Clear value
    
clear_loop:
    sw $t2, 0($t0)            # Clear start address
    sw $t2, 4($t0)            # Clear size
    sw $t2, 8($t0)            # Clear flags
    sw $t2, 12($t0)           # Clear checksum
    addi $t0, $t0, 16         # Move to next entry
    addi $t1, $t1, -1         # Decrement counter
    bnez $t1, clear_loop      # Continue if not done
    
    # Function epilogue
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    li $v0, 0                 # Return success
    jr $ra

# Add Memory Region
# Input: 
#   $a0 - Start address
#   $a1 - Size
#   $a2 - Flags
# Output: 
#   $v0 - Status code
#   $v1 - Region index if successful
add_memory_region:
    # Function prologue
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    # Validate inputs
    bltz $a1, invalid_input   # Size must be positive
    
    # Find free entry
    la $s0, memoryMap         # Load base address
    lw $s1, mapEntryCount     # Load entry count
    li $t0, 0                 # Entry index
    
find_free_entry:
    lw $t1, 8($s0)           # Load flags
    beqz $t1, entry_found    # If flags == 0, entry is free
    addi $s0, $s0, 16        # Next entry
    addi $t0, $t0, 1         # Increment index
    bge $t0, $s1, map_full   # Check if we've reached the end
    j find_free_entry
    
entry_found:
    # Store region information
    sw $a0, 0($s0)           # Store start address
    sw $a1, 4($s0)           # Store size
    sw $a2, 8($s0)           # Store flags
    
    # Calculate and store checksum
    add $t1, $a0, $a1        # Add start + size
    xor $t1, $t1, $a2        # XOR with flags
    sw $t1, 12($s0)          # Store checksum
    
    # Return success
    li $v0, 0                # Success status
    move $v1, $t0            # Return entry index
    j add_region_exit
    
map_full:
    li $v0, 1                # Error: map full
    li $v1, -1
    j add_region_exit
    
invalid_input:
    li $v0, 2                # Error: invalid input
    li $v1, -1
    
add_region_exit:
    # Function epilogue
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

# Validate Memory Access
# Input:
#   $a0 - Address to validate
#   $a1 - Access type (flags)
# Output:
#   $v0 - Status code (0 for valid access)
validate_memory_access:
    # Function prologue
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Initialize variables
    la $t0, memoryMap         # Load base address
    lw $t1, mapEntryCount     # Load entry count
    li $t2, 0                 # Entry counter
    
validate_loop:
    # Load entry data
    lw $t3, 0($t0)           # Load start address
    lw $t4, 4($t0)           # Load size
    lw $t5, 8($t0)           # Load flags
    
    # Check if address is in range
    sub $t6, $a0, $t3        # Calculate offset from start
    bltz $t6, next_entry     # If negative, try next entry
    bge $t6, $t4, next_entry # If beyond size, try next entry
    
    # Check permissions
    and $t6, $t5, $a1        # Check if requested access is allowed
    beqz $t6, access_denied  # If not allowed, return error
    
    # Access allowed
    li $v0, 0
    j validate_exit
    
next_entry:
    addi $t0, $t0, 16        # Move to next entry
    addi $t2, $t2, 1         # Increment counter
    blt $t2, $t1, validate_loop # Continue if not at end
    
access_denied:
    li $v0, 3                # Error: invalid access
    
validate_exit:
    # Function epilogue
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

.data
    # Memory Map Structure
    memoryMap:      .space 1024    # Main memory map array
    mapEntrySize:   .word 16       # Size of each map entry (16 bytes)
    mapEntryCount:  .word 64       # Maximum number of memory regions (1024/16)
    
    # Status Flags (used in entry flags field)
    FLAG_ALLOCATED: .word 0x00000001    # Memory region is allocated
    FLAG_READABLE:  .word 0x00000002    # Memory region is readable
    FLAG_WRITABLE:  .word 0x00000004    # Memory region is writable
    FLAG_EXECUTABLE:.word 0x00000008    # Memory region is executable
    
    # Error Codes
    ERR_SUCCESS:    .word 0
    ERR_FULL:       .word 1
    ERR_INVALID:    .word 2
    ERR_OVERFLOW:   .word 3
    
    # Debug Messages
    msgInitialize:  .asciiz "Initializing Memory Manager...\n"
    msgAddRegion:   .asciiz "Adding memory region: "
    msgError:       .asciiz "Error: "
