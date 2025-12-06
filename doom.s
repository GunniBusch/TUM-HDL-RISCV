# DOOM: The RISC-V Port (Light Edition)
# Scene: E1M8 - Phobos Anomaly
# Player: Doomguy (x1) vs Barons of Hell (x2, x3)

.section .text
.globl _start

_start:
    # --- INIT GAME STATE ---
    addi x1, x0, 100    # x1 = Player Health (100%)
    addi x2, x0, 10     # x2 = Baron 1 Health (1000 HP -> scaled to 10)
    addi x3, x0, 10     # x3 = Baron 2 Health (10)
    addi x4, x0, 50     # x4 = Ammo (Shells)
    
    # --- LEVEL START ---
    
main_loop:
    # Check if player is dead
    beq x1, x0, game_over_death
    
    # Check if Barons are dead
    add x5, x2, x3      # x5 = Total Baron Health
    beq x5, x0, victory

    # --- PLAYER TURN ---
    # Shoot Shotgun at Baron 1 if alive
    beq x2, x0, shoot_baron2
shoot_baron1:
    addi x2, x2, -5     # Damage Baron 1 (5 dmg)
    addi x4, x4, -1     # Use 1 shell
    beq x0, x0, enemy_turn

shoot_baron2:
    addi x3, x3, -5     # Damage Baron 2
    addi x4, x4, -1     # Use 1 shell

    # --- ENEMY TURN ---
enemy_turn:
    # Getting hit by fireballs!
    addi x1, x1, -20    # Ouch! (-20 HP)
    
    # Loop back
    jal x0, main_loop

victory:
    # E1M8 Complete! 
    # Store victory code 0x666 in x10
    addi x10, x0, 0x666
    
    # Teleport to Deimos (Infinite Loop)
    jal x0, end_level

game_over_death:
    # You died.
    addi x10, x0, 0xDEAD
    jal x0, end_level

end_level:
    beq x0, x0, end_level
