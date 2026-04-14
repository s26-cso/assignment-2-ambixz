.text
.globl main

.globl fopen
.globl fclose
.globl fseek
.globl ftell
.globl fgetc
.globl printf

main:
    addi sp, sp, -64

    sd ra, 56(sp)
    sd s0, 48(sp)
    sd s1, 40(sp)
    sd s2, 32(sp)
    sd s3, 24(sp)
    sd s4, 16(sp)

    # fopen("input.txt", "r")
    la a0, filename
    la a1, mode
    la t0, fopen
    jalr ra, 0(t0)

    # Save file pointer in callee-saved register s2
    addi s2, a0, 0       
    beq s2, zero, print_no

    # fseek(file, 0, SEEK_END)
    addi a0, s2, 0
    addi a1, zero, 0
    addi a2, zero, 2
    la t0, fseek
    jalr ra, 0(t0)

    # ftell(file)
    addi a0, s2, 0
    la t0, ftell
    jalr ra, 0(t0)

    addi s0, a0, 0       # s0 = n (file length)

    # Trim trailing newlines/carriage returns using s3 (callee-saved)
    addi s3, s0, -1

check_last:
    bltz s3, done_trim

    addi a0, s2, 0
    addi a1, s3, 0
    addi a2, zero, 0
    la t0, fseek
    jalr ra, 0(t0)

    addi a0, s2, 0
    la t0, fgetc
    jalr ra, 0(t0)

    addi t2, zero, 10    # '\n'
    beq a0, t2, trim

    addi t2, zero, 13    # '\r'
    beq a0, t2, trim

    jal zero, done_trim

trim:
    addi s0, s0, -1
    addi s3, s3, -1
    jal zero, check_last

done_trim:
    addi s1, zero, 0     # s1 = left index = 0
    addi s0, s0, -1      # s0 = right index = size - 1

loop:
    bge s1, s0, is_palindrome

    # Read left char
    addi a0, s2, 0
    addi a1, s1, 0
    addi a2, zero, 0
    la t0, fseek
    jalr ra, 0(t0)

    addi a0, s2, 0
    la t0, fgetc
    jalr ra, 0(t0)
    
    # Save left char in s4
    andi s4, a0, 0xFF    

    # Read right char
    addi a0, s2, 0
    addi a1, s0, 0
    addi a2, zero, 0
    la t0, fseek
    jalr ra, 0(t0)

    addi a0, s2, 0
    la t0, fgetc
    jalr ra, 0(t0)
    
    # Right char in t4
    andi t4, a0, 0xFF    

    # Compare characters
    bne s4, t4, not_palindrome

    addi s1, s1, 1
    addi s0, s0, -1

    jal zero, loop

is_palindrome:
    la a0, yes_str
    la t0, printf
    jalr ra, 0(t0)
    jal zero, cleanup

not_palindrome:
print_no:
    la a0, no_str
    la t0, printf
    jalr ra, 0(t0)

cleanup:
    beq s2, zero, skip_close

    addi a0, s2, 0
    la t0, fclose
    jalr ra, 0(t0)

skip_close:
    # Restore saved registers
    ld s4, 16(sp)
    ld s3, 24(sp)
    ld s2, 32(sp)
    ld s1, 40(sp)
    ld s0, 48(sp)
    ld ra, 56(sp)

    addi sp, sp, 64

    addi a0, zero, 0
    jalr zero, 0(ra)

.data
filename: .asciz "input.txt"
mode:     .asciz "r"

yes_str:  .asciz "Yes\n"
no_str:   .asciz "No\n"
