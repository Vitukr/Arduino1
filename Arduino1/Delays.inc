/*
 * Delays.inc
 *
 *  Created: 20.01.2019 12:22:21
 *   Author: Vit
 */ 

; Delay 8 000 cycles
; 1ms at 8.0 MHz
Delay_1ms:
    ldi  timerH, 11
    ldi  timerL, 99
L1: dec  timerL
    brne L1
    dec  timerH
    brne L1
	ret

; Delay 80 000 cycles
; 10ms at 8.0 MHz
Delay_10ms:
    ldi  timerH, 104
    ldi  timerL, 229
L10: dec  timerL
    brne L10
    dec  timerH
    brne L10
	ret
