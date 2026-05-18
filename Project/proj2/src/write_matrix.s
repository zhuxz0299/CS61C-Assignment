.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -24
    sw ra, 20(sp)
    sw s0, 16(sp)
    sw s1, 12(sp)
    sw s2, 8(sp)
    sw s3, 4(sp)
    sw s4, 0(sp)

    mv s1, a1       # s1: pointer to the start of the matrix in memory
    mv s2, a2       # s2: num of rows
    mv s3, a3       # s3: num of cols

    # open file
    mv a1, a0       # set filepath arg for 'fopen
    li a2, 1        # set permission as "write" for 'fopen
    call fopen
    li t0, 93       # error code for fopen
    blt a0, x0, error_ret
    mv s0, a0       # s0: file descriptor 

    # malloc 2 int space
    li a0, 8        # num of bytes to malloc for 2 int
    call malloc     # malloc a space for int as buffer
    mv s4, a0       # s4: pointer to address of 2 int in mem
    
    # write row and col
    sw s2, 0(s4)    # write num of rows to mem
    sw s3, 4(s4)    # write num of cols to mem
    mv a1, s0
    mv a2, s4
    li a3, 2
    li a4, 4
    call fwrite     # write num of rows and cols to file together
    li t0, 94       # error code for fwrite
    li t1, 2        # expected num of elements written
    blt a0, t1, error_ret

    # free the mem malloc before
    mv a0, s4
    call free

    # write matrix
    mv a1, s0
    mv a2, s1
    mul a3, s2, s3
    li a4, 4
    call fwrite
    li t0, 94       # error code for fwrite
    mul t1, s2, s3  # expected num of elements written
    blt a0, t1, error_ret

    # close the file
    mv a1, s0
    call fclose
    li t0, 95       # error code for fclose
    bne a0, x0, error_ret

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