.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    # Prologue
    addi sp, sp, -36
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw ra, 32(sp)

    # check arguments
    li t0, 89       # error code for incorrect num of args
    li t1, 5        # expect 5 args
    bne a0, t1, error_ret

    # load arguments, each pointer to char occupied 4 bytes
    lw s0, 4(a1)    # s0: path to m0
    lw s1, 8(a1)    # s1: path to m1
    lw s2, 12(a1)    # s2: path to input file
    lw s3, 16(a1)   # s3: path to output file
    mv s4, a2       # s4: print_classification, print if 0

	# =====================================
    # LOAD MATRICES
    # =====================================

    # malloc space for 
    li a0, 24       # malloc space for num of rows and cols in m0, m1, input
    call malloc
    li t0, 88       # error code for malloc
    beq a0, x0, error_ret
    mv s5, a0       # s5: pointer to 6 int space in mem

    # Load pretrained m0
    mv a0, s0
    addi a1, s5, 0
    addi a2, s5, 4
    call read_matrix
    mv s0, a0       # s0: pointer to m0

    # Load pretrained m1
    mv a0, s1
    addi a1, s5, 8
    addi a2, s5, 12
    call read_matrix
    mv s1, a0       # s1: pointer to m1

    # Load input matrix
    mv a0, s2
    addi a1, s5, 16
    addi a2, s5, 20
    call read_matrix
    mv s2, a0       # s2: pointer to input
    # ebreak          # check mem pointed by s0, s1, s2


    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # malloc space for hidden layer
    lw t0, 0(s5)
    lw t1, 20(s5)
    mul a0, t0, t1
    slli a0, a0, 2
    call malloc
    mv s6, a0       # s6: pointer to hidden layer matrix

    # hidden_layer = matmul(m0, input)
    mv a0, s0
    lw a1, 0(s5)
    lw a2, 4(s5)
    mv a3, s2
    lw a4, 16(s5)
    lw a5, 20(s5)
    mv a6, s6
    call matmul
    # ebreak          # check s6 -> hidden_layer

    # relu(hidden_layer)
    lw t0, 0(s5)
    lw t1, 20(s5)
    mul a1, t0, t1
    mv a0, s6
    call relu

    # malloc space for scores
    lw t0, 8(s5)
    lw t1, 20(s5)
    mul a0, t0, t1
    slli a0, a0, 2
    call malloc
    mv s7, a0       # s7: pointer to scores

    # scores = matmul(m1, hidden_layer)
    mv a0, s1
    lw a1, 8(s5)
    lw a2, 12(s5)
    mv a3, s6
    lw a4, 0(s5)
    lw a5, 20(s5)
    mv a6, s7
    call matmul
    # ebreak          # check s7 -> scores

    # free space for hidden layer
    mv a0, s6
    call free

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    mv a0, s3
    mv a1, s7
    lw a2, 8(s5)
    lw a3, 20(s5)
    call write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    mv a0, s7
    lw t0, 8(s5)
    lw t1, 20(s5)
    mul a1, t0, t1
    call argmax
    mv s6, a0   # s6: first index of the largest element

    # Print classification
    bne s4, x0, skip_print
    mv a1, s6
    call print_int

    # Print newline afterwards for clarity
skip_print:
    li a1, 10   # ascii code for '\n'
    call  print_char

    # Free space malloc before (including called func.)
    mv a0, s5
    call free
    mv a0, s0
    call free
    mv a0, s1
    call free
    mv a0, s2
    call free
    mv a0, s7
    call free

    # return Classification
    mv a0, s6

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw ra, 32(sp)
    addi sp, sp, 36

    ret
error_ret:
    mv a1, t0
    call exit2