;************************************
; written by: 1o_o7
; date: <2014|11|26>
; version: 1.0
; file saved as: 7-seg-keypad.asm
; for AVR: atmega328p
; clock frequency: 16MHz
;************************************

; Program funcion:----------------------
;
; A driver for a 7-segment display controlled
; by the keypad we coded in Tutorial 7
;---------------------------------------

.include "./m328Pdef.inc"

.def temp         = r16
.def overflows    = r18
.def milliseconds = r19
.def 7segnumber   = r20
.def press        = r21
.def buttonH      = r22

.org 0x0000
  rjmp Reset
.org 0x0002
  rjmp Keypress_int ; the INT0 external interrupt
.org 0x0020
  rjmp timer_overflow_int
.org 0x002A
  rjmp ADC_int      ; The ADC interrupt

numbers:
.db 239 ,1 ,230 ,2 ,217 ,3 ,203 ,4 ,187 ,5 ,155 ,6 ,126 ,255
.db 115 ,7 ,94 ,8 ,62 ,9 ,37 ,0b11110000 ,28 ,0 ,17 ,0b00001111
.db 2 ,0b11000011

segments:   ; there is an initial 0 so can start loop with increment
.db 0,0,0b11000000,1,0b11111001,2,0b10100100,3,0b10110000,4,0b10011001,5 
.db 0b10010010,6,0b10000010,7,0b11111000,8,0b10000000,9,0b10010000,0b11111111
.db 0b10001110,0b11110000,0b10001000,0b00001111,0b10001001,0b11000011,0b11001100,0

.macro delay
   clr overflows
   ldi milliseconds,@0
  sec_count:
   cpse overflows, milliseconds
  rjmp sec_count
.endmacro

.macro 7seg
  ldi ZH,high(2*segments)
  ldi ZL,low(2*segments)
 setdisplay:
  adiw ZH:ZL,1     ; increment Z to get to first number
  lpm temp,Z+      ; load from table and post increment
  clc
  cpse temp,@0     ; compare with button press skip if equal
 rjmp setdisplay   ; and go back and check next number
  lpm temp,Z       ; load segment map from table
  out portB,temp   ; set portB pins (xtal pins don't matter)
  andi temp,0b11000000 ; bitwise AND to set PD7,PD6
  out portD,temp  ; set portD pins
.endmacro

Reset:  

   ldi temp,0b00000011
   out TCCR0B,temp     ; TCNT0 in FCPU/64 mode, 250000 cnts/sec
   ldi temp,249
   out OCR0A, temp     ; top of counter at 250 counts/overflow
                       ;   so overflow occurs every 1/1000 sec
                       ;   this means an overflow every 1ms
   ldi temp,0b00000010 ; 
   out TCCR0A,temp     ; reset clock at top of OCR0A
   sts TIMSK0, temp    ; Enable Timer Overflow Interrupts

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Power Reduction Register PRR
;  PRR=[PRTWI,PRTIM2,PRTIM0,-,PRTIM1,PRSPI,PRUSART0,PRADC] page 42
;  PRADC = 0 in PRR enables the ADC
;;;;;;;;;;;;;;;;;;;;;;;;;;

  lds temp,PRR           ; copy contents of Power Reduction Register
  andi temp,0b11111110   ; logical AND clears bit 0, others unchanged
  sts PRR,temp           ; now the PRADC bit is off which enables ADC

;;;;;;;;;;;;;;;;;;;;;;;;;;
; ADC Multiplexer Selection Register
;  ADMUX=[REFS1,REFS0,ADLAR,-,MUX3,MUX2,MUX1,MUX0] page 248
;  REFS1 = 0, 
;  REFS0 = 1, AVCC is our reference voltage 
;  ADLAR = 1, left adjust the result
;  MUX3:0 = 0, ADC0 is our input pin (which is PC0)
;;;;;;;;;;;;;;;;;;;;;;;;;;

  ldi temp,0b01100000
  sts ADMUX,temp

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Digital Input Disable Register
;  DIDR0 = [-,-,ADC5D,ADC4D,ADC3D,ADC2D,ADC1D,ADC0D] page 251
;  ADC0D = 1 
;  in the DIDR0 register which disables digital input on PC0
;  we use OR so that it doesn't change any of the other bits
;;;;;;;;;;;;;;;;;;;;;;;;;; 

  lds temp,DIDR0         ; load Digital Input Disable register 0
  ori temp,(1<<ADC0D)    ; turn off digital input on PC0
  sts DIDR0,temp         ; and leave the rest alone

;;;;;;;;;;;;;;;;;;;;;;;;;;
; External Interrupt Control Register A
;  EICRA=[-,-,-,-,ISC11,ISC10,ISC01,ISC00] page 71
;  ISC01 = 1
;  ISC00 = 1 
;  to indicate we trigger on a rising edge in to INT0.
;;;;;;;;;;;;;;;;;;;;;;;;;;

  ldi temp,(1<<ISC01)|(1<<ISC00)
  sts EICRA,temp

;;;;;;;;;;;;;;;;;;;;;;;;;;
; External Interrupt Mask Register
;  EIMSK=[-,-,-,-,-,-,INT1,INT0] page 72
;  INT1 = 0
;  INT0 = 1 
;  to indicate we are using the interrupt
;  on the INT0 pin at interrupt address 0x0002
;;;;;;;;;;;;;;;;;;;;;;;;;;

  ldi temp,0b00000001
  out EIMSK,temp

;;;;;;;;;;;;;;;;;;;;;;;;;;
; ADC Control and Status Register A
;  ADCSRA=[ADEN,ADSC,ADATE,ADIF,ADIE,ADPS2,ADPS1,ADPS0] page 249
;  ADEN = 1, enables the ADC
;  ADSC = 0, don't start a conversion yet
;  ADATE = 0, disable autotrigger
;  ADIF = 0, this will be set by hardware when a conversion completes
;  ADIE = 1, enable the ADC Conversion Complete interrupt
;  ADPS2:0 = 111, prescaler factor of 128 between CPU clock and ADC clock
;;;;;;;;;;;;;;;;;;;;;;;;;; 

  ldi temp,0b10001111
  sts ADCSRA,temp

;;;;;;;;;;;;;;;;;;;;;;;;;; 
; ADC Control and Status Register B
;  ADCSRB=[-,ACME,-,-,-,ADTS2,ADTS1,ADTS0] page 251
;  This register has no effect since we have 
;  disabled ADATE
;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set the SREG I bit to
; turn on global interrupts
;;;;;;;;;;;;;;;;;;;;;;;;;;

  sei

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initialize the stack pointer
;;;;;;;;;;;;;;;;;;;;;;;;;;

  ldi temp,low(RAMEND)
  out SPL,temp
  ldi temp,high(RAMEND)
  out SPL,temp

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initialize the ports
;;;;;;;;;;;;;;;;;;;;;;;;;;

  ser temp
  out DDRB,temp          ; set PortB to output
  ldi temp, 0b11111110
  out DDRC,temp          ; set PortC to output, ADC0 input
  ldi temp, 0b11111011
  out DDRD,temp          ; set PortD to output, INT0 input
  clr temp
  out PortB,temp         ; set PortB to 0V
  out PortD,temp         ; set PortD to 0V
  cbi PortD,2            ; PD2 is at 0V
  clr 7segnumber
  ser press

main:
  cpi press,0
  brne wait          ; if no button press just wait
  delay 20           ; delay to allow button to debounce
  lds temp,ADCSRA
  ori temp,(1<<ADSC)
  sts ADCSRA,temp    ; call a single ADC conversion
  7seg 7segnumber    ; display 7segnumber value
  ser press          ; reset press
  wait:
rjmp main

ADC_int:
  push temp            ; save temp since we modify it here
  lds buttonH,ADCH
  ldi ZH,high(2*numbers)
  ldi ZL,low(2*numbers)
  cpi buttonH,0
  breq return          ; if noise triggers don't change 7segnumber
 setkey:
  lpm temp,Z+          ; load from table and post increment
  clc
  cp buttonH,temp      ; compare keypress with the table
  brlo PC+3            ; if ADCH is lower, try again 
  lpm 7segnumber,Z      ; otherwise load keyvalue table
  rjmp return          ; and return
  adiw ZH:ZL,1         ; increment Z
 rjmp setkey           ; and go back to top
 return:
  pop temp             ; restore temp
reti

Keypress_int:
  clr press     ; clr press to indicate button press 
reti

timer_overflow_int: 
  inc overflows   ; increment 1000 times/sec
reti

