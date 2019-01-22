/*
 * Menu.inc
 *
 *  Created: 20.01.2019 11:58:43
 *   Author: Vit
 */ 

 ;========================
MenuL:
lds sys, LeftButton

cpi sys, 0
brne menu1
; 0 display h:m, m:s, temperature, turn off display
lds common, DisplayType
inc common
cpi common, 4
brne exitMenu0
eor common, common
exitMenu0:
sts DisplayType, common
sts CurrentRightButton, common
rjmp exitMenu

menu1:
cpi sys, 1
brne menu2
; 1 stop/start waytch
lds common, TicTac
inc common
cpi common, 2
brne exitMenu1
eor common, common
exitMenu1:
sts TicTac, common
sts CurrentRightButton, common
rjmp exitMenu

menu2:
cpi sys, 2
brne menu3

exitMenu2:
eor common, common
sts CurrentRightButton, common
lds common, Hours
inc common
sts Hours, common
rjmp exitMenu

menu3:
cpi sys, 3
brne menu4

exitMenu3:
eor common, common
sts CurrentRightButton, common
lds common, Minutes
inc common
sts Minutes, common
rjmp exitMenu

menu4:
cpi sys, 4
brne menu5

exitMenu4:
eor common, common
sts CurrentRightButton, common
; start
				OneWireReset
				lds temp, DS
				cpi temp, 1
				breq yesDS0
				rjmp NoDS0
				yesDS0:
				rcall GetTemperature0
				rcall GetTemperature1
				
				NoDS0:
				ClearOneWire
/*lds digit0, Temperature
lds digit1, Temperature + 1
ComposeTemperature digit0, digit1
sts Temperature, digit0
sts Temperature + 1, digit1*/
rjmp exitMenu

menu5:
exitMenu:
ret

;========================
