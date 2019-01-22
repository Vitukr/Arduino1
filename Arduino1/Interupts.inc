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
; set CurrentRightButton
left0:
cpi sys, 0
brne left1
lds temp, DisplayType
rjmp lbupdate
left1:
cpi sys, 1
brne left2
lds temp, TicTac
rjmp lbupdate
left2:
cpi sys, 2
brne left3
ldi temp, 0
rjmp lbupdate
left3:
cpi sys, 3
brne left4
ldi temp, 0
rjmp lbupdate
left4:

lbupdate:
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

