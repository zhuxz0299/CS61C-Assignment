.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:
    # Prologue
    addi sp, sp, -16
    sw s0, 12(sp)
    sw s1, 8(sp)
    sw s2, 4(sp)
    sw s3, 0(sp)

    mv s0, a0   # start of vector
    mv s1, a1   # number of elements in vector
    li t1, 1    # 1
    blt s1, t1, error_ret

loop_start:
    lw s2, 0(s0)    # largest element
    li s3, 0        # index of largest element
    li t0, 0        # loop start from index 0

loop_continue:
    addi t0, t0, 1          # index 0 has been count
    beq t0, s1, loop_end    # out of range
    slli t1, t0, 2          # address offset
    add t2, s0, t1          # element address
    lw t3, 0(t2)            # load element
    bge s2, t3, loop_continue
    mv s2, t3
    mv s3, t0
    j loop_continue

loop_end:
    mv a0, s3

    # Epilogue
    lw s0, 12(sp)
    lw s1, 8(sp)
    lw s2, 4(sp)
    lw s3, 0(sp)
    addi sp, sp, 16

    ret

error_ret:
    li a1, 77
    call exit2