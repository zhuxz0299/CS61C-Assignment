.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -24
    sw ra, 20(sp)
    sw s0, 16(sp)
    sw s1, 12(sp)
    sw s2, 8(sp)
    sw s3, 4(sp)
    sw s4, 0(sp)

    mv s1, a1       # s1: pointer to int represent rows
    mv s2, a2       # s2: pointer to int represent columns

    # open the file: get the file descriptor
    mv a1, a0       # set filepath for fopen
    li a2, 0        # readonly for fopen
    call fopen
    li t0, 90       # error code
    blt a0, x0, error_ret
    mv s0, a0       # s0: file descriptor

    # read num of rows to mem
    mv a1, s0       # set file descriptor for fread
    mv a2, s1       # set pointer to buffer of rows num
    li a3, 4        # read 4 bytes as a int
    call fread
    li t0, 91       # error code
    li t1, 4        # expect to read 4 bytes as a int
    bne a0, t1, error_ret

    # read num of cols to mem
    mv a1, s0       # set file descriptor for fread
    mv a2, s2       # set pointer to buffer of columns num
    li a3, 4        # read 4 bytes as a int
    call fread
    li t0, 91       # error code
    li t1, 4        # expect to read 4 bytes as a int
    bne a0, t1, error_ret

    # malloc mem for matrix
    lw t1, 0(s1)    # num of rows
    lw t2, 0(s2)    # num of columns
    mul t0, t1, t2  # number of int to malloc
    slli a0, t0, 2  # number of byte to malloc
    call malloc
    li t0, 88       # error code of malloc
    beq a0, x0, error_ret
    mv s3, a0       # s3: pointer to the allocated heap mem, for matrix

    # read matrix to mem
    mv a1, s0       # set file descriptor for fread
    mv a2, s3       # set pointer to buffer of matrix
    lw t1, 0(s1)    # num of rows
    lw t2, 0(s2)    # num of columns
    mul t0, t1, t2  # number of int to read
    slli a3, t0, 2  # number of byte to read
    mv s4, a3       # s4: temporarily store the number of byte to read
    call fread
    li t0, 91       # error code
    bne a0, s4, error_ret

    # close the file
    mv a1, s0       # set file descriptor for fclose
    call fclose
    li t0, 92       # error code of fclose
    bne a0, x0, error_ret
	
    # return pointer to matrix
    mv a0, s3
    
    # Epilogue
    lw ra, 20(sp)
    lw s0, 16(sp)
    lw s1, 12(sp)
    lw s2, 8(sp)
    lw s3, 4(sp)
    lw s4, 0(sp)
    addi sp, sp, 24

    ret
error_ret:
    mv a1, t0
    call exit2