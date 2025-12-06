#############################################################
# DOOM LITE — UART Animated Slow Version (No GPU)
#
# UART MMIO: 0xFFFFF000
#
# Player = 'P' moves right
# Demon  = 'D' moves left
# Collision → "BOOM! YOU DIED"
#
# Uses all implemented instructions naturally:
# ADDI, ADD, SUB, AND, OR, XOR
# SLT, SLTU
# SLL, SRL, SRA
# SLLI, SRLI, SRAI
# ANDI, ORI, XORI, SLTI, SLTIU
# LUI, LW, SW
# BEQ, JAL
#############################################################

    .section .text
    .globl _start

    .equ UART, 0xFFFFF000
    .equ RAMT, 0x00000040

#############################################################
# Init UART + small ALU test (uses every instruction at least once)
#############################################################
_start:
    LUI  x1,0xFFFFF      # x1 = UART base
    ADDI x1,x1,0

    # ALU usage prelude
    ADDI x20,x0,5
    ADDI x21,x0,3
    ADD  x22,x20,x21
    SUB  x23,x22,x21
    AND  x24,x20,x21
    OR   x25,x20,x21
    XOR  x26,x20,x21
    SLT  x27,x20,x21
    SLTU x28,x21,x20

    ANDI x24,x24,1
    ORI  x25,x25,1
    XORI x26,x26,2
    SLTI x27,x20,10
    SLTIU x28,x20,2

    SLLI x20,x20,1
    SRLI x20,x20,1
    SRAI x23,x23,1

    SLL  x29,x21,x21
    SRL  x29,x29,x21
    SRA  x23,x23,x21

    LUI  x30,0
    ADDI x30,x30,RAMT
    SW   x22,0(x30)
    LW   x31,0(x30)

#############################################################
# Print banner
#############################################################
    ADDI x2,x0,'D';SW x2,0(x1)
    ADDI x2,x0,'O';SW x2,0(x1)
    ADDI x2,x0,'O';SW x2,0(x1)
    ADDI x2,x0,'M';SW x2,0(x1)
    ADDI x2,x0,' ';SW x2,0(x1)
    ADDI x2,x0,'L';SW x2,0(x1)
    ADDI x2,x0,'I';SW x2,0(x1)
    ADDI x2,x0,'T';SW x2,0(x1)
    ADDI x2,x0,'E';SW x2,0(x1)
    ADDI x2,x0,10 ;SW x2,0(x1)

#############################################################
# Game state variables
#############################################################
    ADDI x2,x0,0        # player_pos
    ADDI x3,x0,10       # demon_pos
    ADDI x4,x0,'.'      # dot
    ADDI x5,x0,'P'      # player char
    ADDI x6,x0,'D'      # demon char
    ADDI x7,x0,11       # world length

#############################################################
# Main loop
#############################################################
game_loop:

    SUB x8,x3,x2
    BEQ x8,x0,death      # collision → death

#############################################################
# Clear terminal using ANSI escape (ESC[2J ESC[H])
#############################################################
clear_screen:
    ADDI x9,x0,27 ; SW x9,0(x1)
    ADDI x9,x0,'['; SW x9,0(x1)
    ADDI x9,x0,'2'; SW x9,0(x1)
    ADDI x9,x0,'J'; SW x9,0(x1)
    ADDI x9,x0,27 ; SW x9,0(x1)
    ADDI x9,x0,'['; SW x9,0(x1)
    ADDI x9,x0,'H'; SW x9,0(x1)

#############################################################
# Render frame
#############################################################
    ADDI x8,x0,0

print_frame:
    BEQ x8,x2,draw_player
    BEQ x8,x3,draw_demon

    ADD x10,x4,x0 ; SW x10,0(x1)  # dot
    JAL x0,next_char

draw_player:
    ADD x10,x5,x0 ; SW x10,0(x1)
    JAL x0,next_char

draw_demon:
    ADD x10,x6,x0 ; SW x10,0(x1)

next_char:
    ADDI x8,x8,1
    SLT  x11,x8,x7
    BEQ  x11,x0,end_line
    JAL  x0,print_frame

end_line:
    ADDI x10,x0,10 ;SW x10,0(x1)

#############################################################
# DELAY – very fast
#############################################################
delay:
    ADDI x13,x0,2045   # small delay constant
delay_loop:
    ADDI x13,x13,-1
    BEQ  x13,x0,move_step
    JAL  x0,delay_loop
    
#############################################################
# Movement
#############################################################
move_step:
    ADDI x2,x2,1     # P right
    ADDI x3,x3,-1    # D left
    JAL x0,game_loop


#############################################################
# GAME OVER SCREEN
#############################################################
death:
    ADDI x10,x0,10 ;SW x10,0(x1)
    ADDI x10,x0,'B';SW x10,0(x1)
    ADDI x10,x0,'O';SW x10,0(x1)
    ADDI x10,x0,'O';SW x10,0(x1)
    ADDI x10,x0,'M';SW x10,0(x1)
    ADDI x10,x0,'!';SW x10,0(x1)
    ADDI x10,x0,' ';SW x10,0(x1)
    ADDI x10,x0,'Y';SW x10,0(x1)
    ADDI x10,x0,'O';SW x10,0(x1)
    ADDI x10,x0,'U';SW x10,0(x1)
    ADDI x10,x0,' ';SW x10,0(x1)
    ADDI x10,x0,'D';SW x10,0(x1)
    ADDI x10,x0,'I';SW x10,0(x1)
    ADDI x10,x0,'E';SW x10,0(x1)
    ADDI x10,x0,'D';SW x10,0(x1)
    ADDI x10,x0,10 ;SW x10,0(x1)

halt:
    BEQ x0,x0,halt    # infinite loop
    