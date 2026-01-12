    # 1. Basic Arithmetic & Logic
    addi x1, x0, 10     # x1 = 10
    addi x2, x0, 20     # x2 = 20
    add x3, x1, x2      # x3 = 30
    sub x4, x2, x1      # x4 = 10
    and x5, x1, x2      # x5 = 0 (1010 & 10100 = 0)
    or x6, x1, x2       # x6 = 30 (1010 | 10100 = 11110)
    xor x7, x1, x2      # x7 = 30 (1010 ^ 10100 = 11110)

    # 2. SLT / SLTU
    addi x8, x0, -5     # x8 = -5 (0xFF...FB)
    addi x9, x0, 5      # x9 = 5
    slt x10, x8, x9     # x10 = 1 (-5 < 5)
    sltu x11, x8, x9    # x11 = 0 (Large unsigned vs 5)

    # I-Type Logic & Sets
    andi x24, x5, 1      # x24 = 0 (0 & 1)
    ori x25, x5, 1       # x25 = 1 (0 | 1)
    xori x26, x25, 3     # x26 = 2 (1 ^ 3)
    slti x27, x8, -1     # x27 = 1 (-5 < -1)
    sltiu x28, x8, 5     # x28 = 0 (Large unsigned vs 5)

    # 3. Shifts
    addi x12, x0, 1     # x12 = 1
    slli x13, x12, 4    # x13 = 16 (1 << 4) I-type
    srli x14, x13, 2    # x14 = 4  (16 >> 2) I-type

    # Register Shifts (R-type)
    addi x29, x0, 1     # Shift amount = 1
    sll x30, x12, x29   # x30 = 2 (1 << 1)
    srl x31, x13, x29   # x31 = 8 (16 >> 1)
    
    # SRA check
    addi x15, x0, -16   # x15 = -16 (0xFF...F0)
    srai x16, x15, 2    # x16 = -4  (0xFF...FC) - Arithmetic shift preserves sign
    srli x17, x15, 2    # x17 = Large positive number (Logical shift fills 0)
    sra x1, x15, x29    # x1 = -8 (-16 >>> 1). Overwrites x1 (was 10)

    # 4. LUI
    lui x18, 1          # x18 = 0x00001000 (4096)
    addi x19, x18, 1    # x19 = 4097

    # 5. Memory
    sw x19, 0(x0)       # Mem[0] = 4097
    lw x20, 0(x0)       # x20 = 4097 (Forwarding or Stall check depending on slot)

    # 6. Control Flow
    beq x19, x20, match # Branch if 4097 == 4097
    addi x21, x0, 173   # 0xAD = 173. Should verify skip.
    
match:
    jal x22, end        # Jump to end. x22 = PC+4
    addi x23, x0, 173

end:
    beq x0, x0, end     # Infinite loop
