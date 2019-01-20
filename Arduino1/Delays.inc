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

; Delay 240 000 cycles
; 15ms at 16.0 MHz
Delay_15ms:
    ldi  r18, 2
    ldi  r19, 56
    ldi  r20, 174
L15: dec  r20
    brne L15
    dec  r19
    brne L15
    dec  r18
    brne L15
	ret


; Delay 800 000 cycles
; 50ms at 16.0 MHz
Delay_50ms:
    ldi  r18, 5
    ldi  r19, 15
    ldi  r20, 242
L50: dec  r20
    brne L50
    dec  r19
    brne L50
    dec  r18
    brne L50
	ret

; Delay 1 040 000 cycles
; 65ms at 16.0 MHz
Delay_65ms:
    ldi  r18, 6
    ldi  r19, 71
    ldi  r20, 161
L65: dec  r20
    brne L65
    dec  r19
    brne L65
    dec  r18
    brne L65
    ret


; Delay 1 600 000 cycles
; 100ms at 16.0 MHz
Delay_100ms:
    ldi  r18, 9
    ldi  r19, 30
    ldi  r20, 229
L100: dec  r20
    brne L100
    dec  r19
    brne L100
    dec  r18
    brne L100
    ret

; Delay 7 680 000 cycles
; 480ms at 16.0 MHz
Delay_480ms:
    ldi  r18, 39
    ldi  r19, 246
    ldi  r20, 236
L480: dec  r20
    brne L480
    dec  r19
    brne L480
    dec  r18
    brne L480
	ret
