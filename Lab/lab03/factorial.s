.globl factorial

.data
n: .word 8

.text
main:
    la t0, n
    lw a0, 0(t0)
    jal ra, factorial

    addi a1, a0, 0
    addi a0, x0, 1
    ecall # Print Result

    addi a1, x0, '\n'
    addi a0, x0, 11
    ecall # Print newline

    addi a0, x0, 10
    ecall # Exit

factorial:
    # YOUR CODE HERE
    addi t1, a0, 0
    addi t2, x0, 1
    addi t3, x0, 1
loop:
    blt t1, t3, return
    mul t2, t2, t3
    addi t3, t3, 1
    jal x0, loop
return:
    addi a0, t2, 0
    jr ra   # jump to ra
