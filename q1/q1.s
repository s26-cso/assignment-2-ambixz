.text

.globl make_node
.globl insert
.globl get
.globl getAtMost

.globl malloc

make_node:
    # allocate stack
    addi sp, sp, -16

    # save return address
    sd ra , 8(sp)

    # save the passed value on the stack
    sw a0, 0(sp)

    # calling malloc(24)
    addi a0, zero, 24
    jal ra, malloc

    # a0 has the pointer to the new node
    addi t0, a0, 0 # now t0 has the new node's pointer

    # restore passed value
    lw t1, 0(sp)

    # node->val = the passed value(now in t1)
    sw t1, 0(t0)

    # node->left = NULL(we will represent it as zero)
    sd zero, 8(t0)
    # node->right = NULL
    sd zero, 16(t0)

    # putting the node to be returned in a0 so we can return it
    addi a0, t0, 0

    # restore return address
    ld ra, 8(sp)

    # reallocate stack
    addi sp, sp, 16

    #return
    jalr zero, 0(ra)

insert:
    addi sp, sp, -32
    sd   ra, 24(sp)
    sd   a0, 16(sp)   # save root

    beq a0, zero, insert_make

    lw t0, 0(a0)

    blt a1, t0, insert_left
    bgt a1, t0, insert_right

    # equal -> return root
    ld a0, 16(sp)
    jal zero, insert_done


insert_left:
    ld t1, 8(a0)

    addi a0, t1, 0
    jal  ra, insert

    ld t2, 16(sp)     # root
    sd a0, 8(t2)      # root->left = result

    addi a0, t2, 0
    jal zero, insert_done


insert_right:
    ld t1, 16(a0)

    addi a0, t1, 0
    jal  ra, insert

    ld t2, 16(sp)
    sd a0, 16(t2)

    addi a0, t2, 0
    jal zero, insert_done


insert_make:
    addi a0, a1, 0
    jal  ra, make_node


insert_done:
    ld ra, 24(sp)
    addi sp, sp, 32
    jalr zero, 0(ra)


get:
    beq a0, zero, get_not_found

    lw t0, 0(a0)

    beq t0, a1, get_found
    blt a1, t0, get_left
    bgt a1, t0, get_right

get_left:
    ld a0, 8(a0)
    jal zero, get

get_right:
    ld a0, 16(a0)
    jal zero, get

get_found:
    jalr zero, 0(ra)

get_not_found:
    addi a0, zero, 0
    jalr zero, 0(ra)


getAtMost:
    addi t0, a0, 0    # val
    addi t1, a1, 0    # root
    addi t2, zero, -1 # best = -1

loop_gam:
    beq t1, zero, gam_done

    lw t3, 0(t1)

    bgt t3, t0, go_left_gam

    # candidate
    addi t2, t3, 0
    ld t1, 16(t1)   # go right
    jal zero, loop_gam

go_left_gam:
    ld t1, 8(t1)
    jal zero, loop_gam

gam_done:
    addi a0, t2, 0
    jalr zero, 0(ra)