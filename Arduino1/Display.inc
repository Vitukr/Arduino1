/*
 * Display.inc
 *
 *  Created: 20.01.2019 12:09:39
 *   Author: Vit
 */ 

;*********************************************************
Display_test:
				/*ldi common, 0b00100000		; cathode
				out PortB, common     
				rcall Delay_1ms */
				ret
;*********************************************************

 ;==========================================================
DisplayTwoPoints:
				SBRS twoPoints, 0
				rjmp NoBlink	
					
				; two dots
				ldi common, 0b00100000		
				out PortC, common
				ldi common, 0b00000000		
				out PortD, common
				rcall Delay_1ms

				NoBlink:
				ldi common, 0b00000000		
				out PortC, common
				ldi common, 0b00000000		
				out PortD, common

				ret

;*********************************************
DisplayTemperature:
				eor digit0, digit0
				eor digit1, digit1
				;GradeNumber Temperature + 1, digit0, digit1
				lds temp, Temperature + 1
				sbrs temp, 0
				rjmp nosign
				; display sign
				ldi common, 0b10000000		
				;out PortD, common	
				/*mov sys, digit0
				Get_constant sys, digitsG
				or sys, common*/
				ldi sys, 0b10000000
				or sys, common
				out PortD, sys
				/*mov temp, digit0
				Get_constant temp, digits*/
				ldi temp, 0b00000000
				out PortB, temp
				rcall Delay_1ms

				nosign:
				; temperature

				;ldi common, 0b10000000		
				;out PortD, common	
				/*mov sys, digit0
				Get_constant sys, digitsG
				or sys, common*/
				ldi sys, 0b00000000
				out PortD, sys
				;mov temp, digit0
				;Get_constant temp, digits
				ldi temp, 0b00000000
				out PortB, temp
				rcall Delay_1ms


				eor digit0, digit0
				eor digit1, digit1
				GradeNumber Temperature, digit0, digit1

				ldi common, 0b01000000		
				;out PortD, common
				mov sys, digit0
				Get_constant sys, digitsG
				or sys, common
				out PortD, sys
				mov temp, digit0
				Get_constant temp, digits
				out PortB, temp      
				rcall Delay_1ms

				ldi common, 0b00100000		
				;out PortD, common	
				mov sys, digit1
				Get_constant sys, digitsG
				or sys, common
				out PortD, sys
				mov temp, digit1
				Get_constant temp, digits
				out PortB, temp
				rcall Delay_1ms

				ret
;****************************************************************
DisplayMenu:
				eor digit0, digit0
				eor digit1, digit1
				GradeNumber LeftButton, digit0, digit1 

				/*ldi common, 0b10000000		
				out PortD, common	
				mov sys, digit0
				Get_constant sys, digitsG
				or sys, common
				out PortD, sys
				mov temp, digit0
				Get_constant temp, digits
				out PortB, temp
				rcall Delay_1ms*/

				ldi common, 0b01000000		
				;out PortD, common
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
				GradeNumber CurrentRightButton, digit0, digit1 

				/*ldi common, 0b00100000		
				out PortD, common	
				mov sys, digit0
				Get_constant sys, digitsG
				or sys, common
				out PortD, sys
				mov temp, digit0
				Get_constant temp, digits
				out PortB, temp
				rcall Delay_1ms*/				
			      
				ldi common, 0b00010000		
				;out PortD, common
				mov sys, digit1
				Get_constant sys, digitsG
				or sys, common
				out PortD, sys
				mov temp, digit1
				Get_constant temp, digits
				out PortB, temp      
				rcall Delay_1ms
ret

Display:		
				;============================================================
				lds temp, DisplayType 
				cpi temp, 0
				breq showHours

				rjmp showNext
				showHours:
				; Hours
				eor digit0, digit0
				eor digit1, digit1
				GradeNumber Hours, digit0, digit1

				ldi common, 0b10000000		
				;out PortD, common	
				mov sys, digit0
				Get_constant sys, digitsG
				or sys, common
				out PortD, sys
				mov temp, digit0
				Get_constant temp, digits
				out PortB, temp
				rcall Delay_1ms				
			      
				ldi common, 0b01000000		
				;out PortD, common
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
				GradeNumber Minutes, digit0, digit1  
			    
				ldi common, 0b00100000		
				;out PortD, common	
				mov sys, digit0
				Get_constant sys, digitsG
				or sys, common
				out PortD, sys
				mov temp, digit0
				Get_constant temp, digits
				out PortB, temp
				rcall Delay_1ms				
			      
				ldi common, 0b00010000		
				;out PortD, common
				mov sys, digit1
				Get_constant sys, digitsG
				or sys, common
				out PortD, sys
				mov temp, digit1
				Get_constant temp, digits
				out PortB, temp      
				rcall Delay_1ms   

				rjmp endDisplayDigits

				; Minutes
				showNext:
				lds temp, DisplayType 
				cpi temp, 1
				breq showMinutes

				rjmp endDisplayDigits

				showMinutes:
           
				eor digit0, digit0
				eor digit1, digit1
				GradeNumber Minutes, digit0, digit1 

				ldi common, 0b10000000		
				;out PortD, common	
				mov sys, digit0
				Get_constant sys, digitsG
				or sys, common
				out PortD, sys
				mov temp, digit0
				Get_constant temp, digits
				out PortB, temp
				rcall Delay_1ms				
			      
				ldi common, 0b01000000		
				;out PortD, common
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
				;out PortD, common	
				mov sys, digit0
				Get_constant sys, digitsG
				or sys, common
				out PortD, sys
				mov temp, digit0
				Get_constant temp, digits
				out PortB, temp
				rcall Delay_1ms				
			      
				ldi common, 0b00010000		
				;out PortD, common
				mov sys, digit1
				Get_constant sys, digitsG
				or sys, common
				out PortD, sys
				mov temp, digit1
				Get_constant temp, digits
				out PortB, temp      
				rcall Delay_1ms   

				endDisplayDigits:

				ret


;*********************************************************
