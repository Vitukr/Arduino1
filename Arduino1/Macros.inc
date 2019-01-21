/*
 * Macros.inc
 *
 *  Created: 20.01.2019 12:15:43
 *   Author: Vit
 */ 

.macro SwapBitInRegister  ; Using T flag swap bit: @0 = Rd, @1 = bit index				
				bst @0, @1 ; Store bit @1 of temp in T Flag
				SBRC @0, @1
				clt
				SBRS @0, @1
				set
				bld @0, @1 ; Load T Flag into bit @1 of temp
.endmacro

/*.macro SwapBitInRegister  ; Using T flag swap bit: @0 = Rd, @1 = bit index				
				bst @0, @1 ; Store bit @1 of temp in T Flag
				SBRC @0, @1
				clt
				SBRS @0, @1
				set
				bld @0, @1 ; Load T Flag into bit @1 of temp
.endmacro*/

.macro TimerAddSecond
lds temp, TicTac
cpi temp, 0
breq notictac

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

notictac:
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

add ZL, inMacro            ;к 0-му адресу массива
ldi inMacro, 0 
adc ZH, inMacro

lpm @0, Z                    ;загрузка значения
.endmacro

.macro ComposeTemperature			; @0 - LS BYTE, @1 - MS BYTE, 1111 - are left, return @0 - temperature, @1 - sign
	andi @0, 0b11110000
	andi @1, 0b00001111
	or @0, @1
	eor @1, @1
	sbrc @0, 7
	rjmp negative
	rjmp notnegative
	negative:
	cbr @0, 7
	sbr @1, 0
	notnegative:
.endmacro
