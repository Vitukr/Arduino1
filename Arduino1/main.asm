;
; Arduino1.asm
;
; Created: 05.01.2019 20:02:43
; Author : Vit
;


; Replace with your application code

	.def temp = R16
	.def common = R17
	.def sys = R18

	.def digit0 = r19
	.def digit1 = r20
	.def twoPoints = r21
	.def inMacro = r22
	.def timerH = r23
	.def timerL = r24
	.def halfSecond = r25

;=================================================================
.dseg
// Values of 4 digits in indicator
//Digit_display:		.byte 4
blink:				.byte 1
buttons:			.byte 3
Seconds:			.byte 1
Minutes:			.byte 1
Hours:				.byte 1
LeftButton:			.byte 1
RightButton:		.byte 4
CurrentRightButton: .byte 1
Seconds5:			.byte 1
TicTac:				.byte 1
;=================================================================
.cseg
.org 0 rjmp Reset
.org 0x0002 jmp EXT_INT0 ; IRQ0 Handler
.org 0x0004 jmp EXT_INT1 ; IRQ1 Handler
//.org 0x0006 jmp PCINT0 ; PCINT0 Handler
//.org 0x0008 jmp PCINT1_INT ; PCINT1 Handler
//.org 0x000A jmp PCINT2 ; PCINT2 Handler
.org 0x001A rjmp TIM1_OVF

#include "Macros.inc"

Reset: // Предустановки
				ldi temp, high(RAMEND) // Инициализируем стек
				out sph, temp
				ldi temp, low(RAMEND)
				out spl, temp  
				cli

				eor temp, temp
				sts LeftButton, temp
				sts RightButton, temp
				;ldi temp, 1
				sts RightButton + 1, temp
				sts RightButton + 2, temp
				sts RightButton + 3, temp
				sts CurrentRightButton, temp
				ldi temp, 2
				sts Seconds5, temp

				ldi temp, 0
				sts Seconds, temp
				sts Minutes, temp
				sts Hours, temp
				
				rcall Init_TIMER1
				rcall Init_PORTS
				rcall Init_Ext_Interups

				/*ldi common, 0b00000110		
				out PortC, common*/

				eor halfSecond, halfSecond
				
				rcall Timer_restart
				sei
;*********************************************************
;MAIN 0x00D
;*********************************************************
Main:   
				lds common, RightButton
				cpi common, 2				; turn off display
				breq EndMain

				lds temp, Seconds5
				cpi temp, 0
				breq showDigits
				rcall DisplayMenu
				rjmp EndMain

				showDigits:
				rcall DisplayTwoPoints
				rcall Display 

				;rjmp EndMain
EndMain: ;================================================
				rjmp Main

;*********************************************************
Timer_restart:			; 0.5 sec 
				ldi temp, $85
				sts TCNT1H, temp
				ldi temp, $EE
				sts TCNT1L, temp	
				ret
;=========================================================
#include "Init.inc"

#include "Interupts.inc"

#include "Menu.inc"

#include "Display.inc"

#include "Delays.inc"

#include "Constants.inc"
;========================*/