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
