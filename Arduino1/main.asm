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
;=================================================================
.cseg
.org 0 rjmp Reset
.org 0x0002 jmp EXT_INT0 ; IRQ0 Handler
.org 0x0004 jmp EXT_INT1 ; IRQ1 Handler
//.org 0x0006 jmp PCINT0 ; PCINT0 Handler
//.org 0x0008 jmp PCINT1_INT ; PCINT1 Handler
//.org 0x000A jmp PCINT2 ; PCINT2 Handler
.org 0x001A rjmp TIM1_OVF

.macro SwapBitInRegister  ; Using T flag swap bit: @0 = Rd, @1 = bit index				
				bst @0, @1 ; Store bit @1 of temp in T Flag
				SBRC @0, @1
				clt
				SBRS @0, @1
				set
				bld @0, @1 ; Load T Flag into bit @1 of temp
.endmacro

.macro TimerAddSecond
lds temp, Seconds
lds common, Minutes
lds sys, Hours

inc temp				; add 1 second

cpi temp, 60
brne update_second
eor temp, temp			; if not equal
inc common				; add 1 minute

update_second:
sts Seconds, temp

cpi common, 60
brne update_minute
eor common, common
inc sys

update_minute:
sts Minutes, common

cpi sys, 24
brne update_hour
eor sys, sys

update_hour:
sts Hours, sys
.endmacro

.macro GradeNumber // @0 - data_segment (Second), @1 - low_digit, @2 - high_digit data_segment
lds temp, @0
ldi sys, 10
eor timerH, timerH
eor timerL, timerL
loop_divide:
mov timerL, temp
sbc temp, sys
brcs secondigit
inc timerH
rjmp loop_divide
secondigit:
mov @1, timerH
mov @2, timerL
.endmacro

.macro Get_constant // @0 register - number, @1 digits - display number address
ldi ZH,High(@1<<1)
ldi ZL,Low(@1<<1)   ;инициализация массива

mov inMacro, @0
;add inMacro, Low(@1<<1)

/*clr r31      ; Очистить старший байт Z
ldi r30, Low(@1<<1) ; Установить младший байт Z*/

add ZL, inMacro            ;к 0-му адресу массива
ldi inMacro, 0 
adc ZH, inMacro

/*ldi temp, 0             ;прибавление переменной
add ZL, @0            ;к 0-му адресу массива
adc ZH, temp*/

lpm @0, Z                    ;загрузка значения
/*lpm
mov @0, r0*/
.endmacro

Reset: // Предустановки
				ldi temp, high(RAMEND) // Инициализируем стек
				out sph, temp
				ldi temp, low(RAMEND)
				out spl, temp  
				cli

				// test
				/*ldi temp, 2
				ldi ZL,Low(digits*2)   ;инициализация массива
				ldi ZH,High(digits*2)

				ldi sys, 0             ;прибавление переменной
				add ZL, temp            ;к 0-му адресу массива
				adc ZH, sys

				lpm sys, z                    ;загрузка значения
				mov temp, sys
				mov sys, temp*/
				// end test

				ldi temp, 0
				sts Seconds, temp
				sts Minutes, temp
				sts Hours, temp
				
				rcall Init_TIMER1
				rcall Init_PORTS
				rcall Init_Ext_Interups

				ldi common, 0b00000110		
				out PortC, common

				eor halfSecond, halfSecond
				
				rcall Timer_restart
				sei
;*********************************************************
;MAIN 0x00D
;*********************************************************
Main:   
				//rcall Display_test
				rcall DisplayTwoPoints
				rcall Display        ;цикл индикации
EndMain:
				rjmp Main

EXT_INT0:
//cli
ldi temp, 0b00000000
sts TCCR1B, temp
//sei
reti

EXT_INT1:
//cli
ldi temp, 0b00000100
sts TCCR1B, temp
//sei
reti

;========================
/*PCINT1_INT:
cli

in temp, PINC
SBRC temp, 5
rjmp skip_work
do_work:
lds temp, Seconds
eor temp, temp
sts Seconds, temp
ldi temp, 0b00000000
sts TCCR1B, temp

skip_work:
sei
reti*/
;========================

Init_TIMER1:
				ldi temp, 0b00000100
				sts TCCR1B, temp
				ldi temp, 0b00000001
				sts TIMSK1, temp
				rcall Timer_restart
				ret

Init_PORTS:
				ldi temp, 0b00111111
				out DDRB, temp
				ldi temp, 0b11110011	; bits 2 and 3 buttons input
				out DDRD, temp
				ldi temp, 0b00111111
				out DDRC, temp
				ret

Init_Ext_Interups:
				/*ldi temp, 0b00000010
				sts PCICR, temp
				ldi temp, 0b00111000
				sts PCMSK1, temp*/
				ldi temp, 0b00001010
				sts EICRA, temp
				ldi temp, 0b00000011
				out EIMSK, temp
				ret


TIM1_OVF:		; 0.5 second
				cli
				SwapBitInRegister twoPoints, 0
				inc halfSecond
				cpi halfSecond, 2
				brne Continue
				TimerAddSecond
				eor halfSecond, halfSecond
				Continue:
				rcall Timer_restart
				sei
				reti

Timer_restart:			; D9DE 0.5 sec in 20Mhz
				ldi temp, $85
				sts TCNT1H, temp
				ldi temp, $EE
				sts TCNT1L, temp	
				ret

;*********************************************************
Display_test:
				/*ldi common, 0b00100000		; cathode
				out PortB, common     
				rcall Delay_1ms */
				ret
;*********************************************************
DisplayTwoPoints:
				/*cpi twoPoints, 0
				breq NoBlink*/	

				ldi common, 0b00100000		
				out PortC, common
				ldi common, 0b00000000		
				out PortD, common
				rcall Delay_1ms

				SBRS twoPoints, 0
				rjmp NoBlink	
					
				; dot	
				/*ldi common, 0b00000010		
				out PortB, common
				ldi sys, 0b01111111
				out PortD, sys
				rcall Delay_1ms*/

				; two dots
				ldi common, 0b00000000		
				out PortC, common
				rcall Delay_1ms
				NoBlink:
				ret

Display:			; display digits time
           
				eor digit0, digit0
				eor digit1, digit1
				GradeNumber Minutes, digit0, digit1 

				ldi common, 0b10000000		
				out PortD, common	
				mov sys, digit0
				Get_constant sys, digitsG
				or sys, common
				out PortD, sys
				mov temp, digit0
				Get_constant temp, digits
				out PortB, temp
				rcall Delay_1ms				
			      
				ldi common, 0b01000000		
				out PortD, common
				mov sys, digit1
				Get_constant sys, digitsG
				or sys, common
				out PortD, sys
				mov temp, digit1
				Get_constant temp, digits
				out PortB, temp      
				rcall Delay_1ms    			  
			   
				eor digit0, digit0
				eor digit1, digit1
				GradeNumber Seconds, digit0, digit1  
			    
				ldi common, 0b00100000		
				out PortD, common	
				mov sys, digit0
				Get_constant sys, digitsG
				or sys, common
				out PortD, sys
				mov temp, digit0
				Get_constant temp, digits
				out PortB, temp
				rcall Delay_1ms				
			      
				ldi common, 0b00010000		
				out PortD, common
				mov sys, digit1
				Get_constant sys, digitsG
				or sys, common
				out PortD, sys
				mov temp, digit1
				Get_constant temp, digits
				out PortB, temp      
				rcall Delay_1ms   

				ret


;*********************************************************

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

//digits: .db 0b00000010, 0b10011110, 0b00100100, 0b00001100, 0b10011000, 0b01001000, 0b01000000, 0b00011110, 0b00000000, 0b00001000	//anod
//digits: .db 0b10111111, 0b10000110, 0b11011011, 0b11001111, 0b11100110, 0b11101101, 0b11111101, 0b10000111, 0b11111111, 0b11101111		//cathod
//digits: .db 0b11000000, 0b111111001, 0b10100100, 0b10110000, 0b10011001, 0b10010010, 0b10000010, 0b11111000, 0b10000000, 0b10010000		// anod arduino
digitsG: .db 0b00000010, 0b00000010, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000010, 0b00000000, 0b00000000	; PD1
digits: .db 0b000000, 0b100111, 0b001001, 0b000011, 0b100110, 0b010010, 0b010000, 0b000111, 0b000000, 0b000010	; PB5-0