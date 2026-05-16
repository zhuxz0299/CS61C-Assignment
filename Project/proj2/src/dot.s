.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:
    li t0, 1
    blt a2, t0, error_ret_75
    blt a3, t0, error_ret_76
    blt a4, t0, error_ret_76
    # Prologue
    addi sp, sp, -16
    sw s0, 12(sp)
    sw s1, 8(sp)
    sw s2, 4(sp)
    sw s3, 0(sp)

    li t0, 0    # index of v0
    li t1, 0    # index of v1
    li t2, 0    # counter
    li s3, 0    # sum
loop_start:
    beq t2, a2, loop_end

    slli t3, t0, 2  # addr shift of v0
    add t3, t3, a0  # addr of element in v0
    lw s0, 0(t3)    # element in v0
    slli t3, t1, 2  # addr shift of v1
    add t3, t3, a1  # addr of element in v1
    lw s1, 0(t3)    # element in v1
    mul t4, s0, s1  # calc the product
    add s3, s3, t4  # add the product

    add t0, t0, a3
    add t1, t1, a4
    addi t2, t2, 1
    j loop_start

loop_end:
    mv a0, s3

    # Epilogue
    lw s0, 12(sp)
    lw s1, 8(sp)
    lw s2, 4(sp)
    lw s3, 0(sp)
    addi sp, sp, 16
    
    ret
error_ret_75:
    li a1, 75
    call exit2

error_ret_76:
    li a1, 76
    call exit2