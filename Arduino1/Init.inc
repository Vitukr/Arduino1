/*
 * Init.inc
 *
 *  Created: 20.01.2019 12:13:39
 *   Author: Vit
 */ 

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
