/*
 * Interupts.inc
 *
 *  Created: 20.01.2019 12:05:40
 *   Author: Vit
 */ 

EXT_INT0:
cli
lds sys, LeftButton
inc sys
cpi sys, 5
brne exitInt0
eor sys, sys

exitInt0:
sts LeftButton, sys 
ldi temp, 0
sts CurrentRightButton, temp
; event
ldi sys, 2
sts Seconds5, sys
sei
reti

;=====================================================
EXT_INT1:
cli
rcall MenuL
; event
ldi sys, 2
sts Seconds5, sys
sei
reti

;=====================================================
TIM1_OVF:		; 0.5 second
				cli
				SwapBitInRegister twoPoints, 0
				inc halfSecond
				cpi halfSecond, 2
				brne Continue
				; ========== 1 sec ============
				TimerAddSecond
				eor halfSecond, halfSecond

				; display menu
				lds temp, Seconds5
				cpi temp, 0
				breq Continue
				dec temp
				sts Seconds5, temp

				Continue:
				; get temperature
				lds temp, SecondsTemperature
				cpi temp, 0
				breq getT
				dec temp
				sts SecondsTemperature, temp

				getT:

				; =============================
				rcall Timer_restart
				sei
				reti

