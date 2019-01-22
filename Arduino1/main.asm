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
DisplayType:		.byte 1
CurrentRightButton: .byte 1
Seconds5:			.byte 1
TicTac:				.byte 1
DS:					.byte 1
Temperature:		.byte 2
SecondsTemperature:	.byte 1
;MainDisplay:		.byte 1
;=================================================================
.cseg
.org 0 rjmp Reset
.org 0x0002 jmp EXT_INT0 ; IRQ0 Handler
.org 0x0004 jmp EXT_INT1 ; IRQ1 Handler
//.org 0x0006 jmp PCINT0 ; PCINT0 Handler
//.org 0x0008 jmp PCINT1_INT ; PCINT1 Handler
//.org 0x000A jmp PCINT2 ; PCINT2 Handler
.org 0x001A rjmp TIM1_OVF

.equ OneWire = 4 ; PortC bit = 4

#include "Delays.inc"

#include "Macros.inc"

#include "Temperature.inc"

Reset: // Предустановки
				ldi temp, high(RAMEND) // Инициализируем стек
				out sph, temp
				ldi temp, low(RAMEND)
				out spl, temp  
				cli

				eor temp, temp
				sts DisplayType, temp
				sts TicTac, temp
				sts LeftButton, temp
				//sts RightButton, temp
				;sts MainDisplay, temp
				;ldi temp, 1
				/*sts RightButton + 1, temp
				sts RightButton + 2, temp
				sts RightButton + 3, temp*/
				sts CurrentRightButton, temp
				ldi temp, 2
				sts Seconds5, temp
				ldi temp, 10
				sts SecondsTemperature, temp
				ldi temp, 10
				sts Temperature, temp

				ldi temp, 0
				sts Seconds, temp
				sts Minutes, temp
				sts Hours, temp
				
				rcall Init_TIMER1
				rcall Init_PORTS
				rcall Init_Ext_Interups

				OneWireReset
				ClearOneWire
				
				eor halfSecond, halfSecond
				
				rcall Timer_restart
				sei
;*********************************************************
;MAIN 0x00D
;*********************************************************
Main:   

				lds temp, Seconds5
				cpi temp, 0
				breq showOthers
				rcall DisplayMenu
				rjmp EndMain

				showOthers:
				lds temp, DisplayType
				;============================
				cpi temp, 0
				brne mainD1
				; display show time
				rcall DisplayTwoPoints
				rcall Display
				rjmp EndMain

				mainD1:
				cpi temp, 1
				brne mainD2
				; display show time
				rcall DisplayTwoPoints
				rcall Display
				rjmp EndMain

				mainD2:
				cpi temp, 2
				brne mainD3
				; turn off display
				breq EndMain

				mainD3:
				cpi temp, 3
				brne EndMain
				; display show temperature
				/*lds temp, SecondsTemperature
				cpi temp, 0
				breq showTemperature*/
				rcall DisplayTemperature
				rjmp EndMain
				
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
;========================
GetTemperature0:
				/*OneWireReset
				lds temp, DS
				cpi temp, 1
				breq yesDS0
				rjmp NoDS0
				; DS
				yesDS0:*/

				ldi common, $CC
				OneWireWrite common
				ldi common, $44
				OneWireWrite common
				rcall Delay_480ms
				rcall Delay_100ms
				rcall Delay_100ms
				ret

GetTemperature1:
				/*OneWireReset
				lds temp, DS
				cpi temp, 1
				breq yesDS1
				rjmp NoDS1
				; DS
				yesDS1:*/

				ldi common, $CC
				OneWireWrite common
				ldi common, $BE
				OneWireWrite common

				OneWireRead common
				OneWireRead sys

				ComposeTemperature common, sys
				sts Temperature, common
				sts Temperature + 1, sys
				; NoDS
				;NoDS1:
				ret
;=========================================================
#include "Init.inc"

#include "Interupts.inc"

#include "Menu.inc"

#include "Display.inc"

#include "Constants.inc"
