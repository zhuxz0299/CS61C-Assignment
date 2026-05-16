.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    # Prologue
    # length of the vector is less than 1
    li t0, 1
    bge a1, t0, loop_start
    # terminates the program with error code 78.
    li a1, 78
    jal exit2

loop_start:
    li t0, 0 # index

loop_continue:
    beq t0, a1, loop_end
    slli t1, t0, 2 # t1: addr offset
    add t2, a0, t1 # t2: value addr
    lw t3, 0(t2)   # t3: value in array

    bge t3, x0, skip_store
    sw x0, 0(t2)

skip_store:
    addi t0, t0, 1
    j loop_continue

loop_end:


    # Epilogue

    
	ret
