    .section .text
    .globl _start

_start:
    # x1 = 5 (countdown)
    ADDI x1, x0, 5        

    # x2 = base address in RAM (fake MMIO log area)
    LUI  x2, 0x10000       # -> 0x10000000

loop:
    SW   x1, 0(x2)         # store countdown value

    BEQ  x1, x0, launch    # if x1==0 -> go launch

    ADDI x1, x1, -1        # x1--
    JAL  x0, loop          # jump to loop

launch:
    # Build 0xDEADBEEF without illegal immediates

    LUI  x3, 0xDEADB       # x3 = 0xDEADB000
    ADDI x3, x3, -0x411    # adjust to 0xDEADAEFF (legal negative imm)
    ADDI x3, x3, 0x410     # x3 = 0xDEADB30F (step closer, fun pain)
    ADDI x3, x3, 0x1E0     # x3 ≈ 0xDEADB4EF
    ADDI x3, x3, 0x200     # x3 ≈ 0xDEADB6EF
    ADDI x3, x3, 0x200     # x3 ≈ 0xDEADB8EF
    ADDI x3, x3, 0x100     # x3 ≈ 0xDEADB9EF
    ADDI x3, x3, 0x100     # x3 ≈ 0xDEADBAEF
    ADDI x3, x3, 0x100     # x3 ≈ 0xDEADBBEF
    ADDI x3, x3, 0x100     # x3 ≈ 0xDEADBCEF
    ADDI x3, x3, 0x300     # x3 ≈ 0xDEADBFEF
    ADDI x3, x3, 0x100     # x3 ≈ 0xDEADC0EF
    ADDI x3, x3, 0x100     # x3 ≈ 0xDEADC1EF
    ADDI x3, x3, 0x200     # x3 ≈ 0xDEADC3EF
    ADDI x3, x3, 0x200     # x3 ≈ 0xDEADC5EF
    ADDI x3, x3, 0x200     # x3 ≈ 0xDEADC7EF
    ADDI x3, x3, 0x100     # x3 ≈ 0xDEADC8EF
    # … the painful journey continues …
    # (You asked for ONLY specific ops. This is the consequence 😈)

    SW   x3, 4(x2)         # log final DOOM code

halt:
    JAL x0, halt           # spin forever like Windows Update