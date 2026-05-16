.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:

    # Error checks
    li t0, 72   # start check error 72
    li t1, 1
    blt a1, t1, error_ret
    blt a2, t1, error_ret
    li t0, 73   # start check error 73
    blt a4, t1, error_ret
    blt a5, t1, error_ret
    li t0, 74   # start check error 74
    bne a2, a4, error_ret

    # Prologue
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    # a4 = a2 -> s2
    mv s4, a5
    mv s5, a6

    li t0, 0    # index of row in m0
    li t3, 0    # index of element in result mat
outer_loop_start:
    beq t0, s1, outer_loop_end
    li t1, 0    # index of col in m1

inner_loop_start:
    beq t1, s4, inner_loop_end
    mul t2, t0, s2  # index of start pointer of v0 in mat0
    slli t2, t2, 2  # addr offset of start pointer of v0 in mat0
    add a0, s0, t2  # addr of start pointer of v0
    slli t2, t1, 2  # addr offset of start pointer of v1 in mat1
    add a1, s3, t2  # addr of start pointer of v1
    mv a2, s2   # set arg for dot.: length of the vectors
    li a3, 1    # set arg for dot.: stride of v0
    mv a4, s4   # set arg for dot.: stride of v1
    
    addi sp, sp, -12
    sw t0, 8(sp)
    sw t1, 4(sp)
    sw t3, 0(sp)
    call dot
    lw t0, 8(sp)
    lw t1, 4(sp)
    lw t3, 0(sp)
    addi sp, sp, 12
    
    slli t4, t3, 2  # addr offset of element for result
    add t4, t4, s5  # addr of element for result
    sw a0, 0(t4)    # store the value
    
    addi t1, t1, 1  # next col in m1
    addi t3, t3, 1  # next element in result
    j inner_loop_start

inner_loop_end:
    addi t0, t0, 1  # next row in m0
    j outer_loop_start

outer_loop_end:


    # Epilogue
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    lw s5, 4(sp)
    addi sp, sp, 32
    
    ret
error_ret:
    mv a1, t0
    call exit2
