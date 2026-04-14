.text
    .globl main
    .globl atoi
    .globl printf

main:
    # 1. Save ra and s-registers
    addi sp, sp, -64
    sd   ra, 56(sp)
    sd   s0, 48(sp)
    sd   s1, 40(sp)
    sd   s2, 32(sp)
    sd   s3, 24(sp)
    sd   s4, 16(sp)
    sd   s5, 8(sp)
    sd   s6, 0(sp)

    # if argc <= 1 -> done_empty
    addi t0, a0, -1
    blez t0, done_empty

    # s0 = n = argc - 1
    addi s0, a0, -1
    
    # Save argv to s5 (callee-saved, safe from atoi)
    addi s5, a1, 0

    # Save old SP to s6 so we can easily restore it later
    addi s6, sp, 0

    # allocate stack space: arr (4n) + result (4n) + stack (4n) = 12n bytes
    slli t1, s0, 2       # 4n
    add  t2, t1, t1      # 8n
    add  t3, t2, t1      # 12n
    
    # Align dynamic allocation to 16 bytes
    addi t3, t3, 15
    andi t3, t3, -16
    sub  sp, sp, t3

    # pointers:
    addi s1, sp, 0       # arr base
    slli t1, s0, 2
    add  s2, s1, t1      # result base
    add  s3, s2, t1      # stack base

    addi s4, zero, 1     
    
fill_loop:
    bgt  s4, s0, fill_done

    slli t6, s4, 3       # offset = i * 8
    add  t7, s5, t6
    ld   a0, 0(t7)       # a0 = argv[i]

    jal  ra, atoi        

    # idx = s4 - 1
    addi t5, s4, -1
    slli t8, t5, 2
    add  t9, s1, t8
    sw   a0, 0(t9)       # arr[idx] = result of atoi

    addi s4, s4, 1
    jal  zero, fill_loop

fill_done:
    addi t0, zero, 0
init_loop:
    bge  t0, s0, init_done
    slli t1, t0, 2
    add  t2, s2, t1
    addi t3, zero, -1
    sw   t3, 0(t2)
    addi t0, t0, 1
    jal  zero, init_loop

init_done:

    addi s4, zero, -1    # s4 = stack top
    addi t0, s0, -1      # t0 = i = n-1

main_loop:
    bltz t0, main_done

    # load arr[i]
    slli t1, t0, 2
    add  t2, s1, t1
    lw   t3, 0(t2)       # t3 = arr[i]

while_loop:
    bltz s4, while_done

    # stack[top]
    slli t4, s4, 2
    add  t5, s3, t4
    lw   t6, 0(t5)       # t6 = index from stack

    # arr[stack[top]]
    slli t7, t6, 2
    add  t8, s1, t7
    lw   t9, 0(t8)       # t9 = arr[stack[top]]

    ble  t9, t3, pop_stack
    jal  zero, while_done

pop_stack:
    addi s4, s4, -1
    jal  zero, while_loop

while_done:
    # if stack not empty -> result[i] = stack[top]
    bltz s4, skip_assign

    slli t4, s4, 2
    add  t5, s3, t4
    lw   t6, 0(t5)       # stack[top]

    slli t7, t0, 2
    add  t8, s2, t7
    sw   t6, 0(t8)       # result[i] = stack[top]

skip_assign:
    # push i
    addi s4, s4, 1
    slli t4, s4, 2
    add  t5, s3, t4
    sw   t0, 0(t5)

    addi t0, t0, -1
    jal  zero, main_loop

main_done:

    addi s4, zero, 0

print_loop:
    bge  s4, s0, print_done

    slli t1, s4, 2
    add  t2, s2, t1
    lw   a1, 0(t2)       # value to print

    la   a0, fmt         # "%d "
    jal  ra, printf

    addi s4, s4, 1
    jal  zero, print_loop

print_done:
    la   a0, nl
    jal  ra, printf

end_program:
    # 2. Restore original SP before dynamic allocation
    addi sp, s6, 0

    # Restore s-registers and ra
    ld   ra, 56(sp)
    ld   s0, 48(sp)
    ld   s1, 40(sp)
    ld   s2, 32(sp)
    ld   s3, 24(sp)
    ld   s4, 16(sp)
    ld   s5, 8(sp)
    ld   s6, 0(sp)
    addi sp, sp, 64

    addi a0, zero, 0
    jalr zero, 0(ra)

done_empty:
    la   a0, nl
    jal  ra, printf
    jal  zero, end_program

    .data
fmt: .asciz "%d "
nl:  .asciz "\n"