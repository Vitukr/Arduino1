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
lds common, RightButton + 0
inc common
sts RightButton + 0, common
sts CurrentRightButton, common
cpi common, 3
brne exitMenu0
eor common, common
sts RightButton + 0, common
sts CurrentRightButton, common

exitMenu0:
rjmp exitMenu

menu1:
cpi sys, 1
brne menu2
; 1 stop/start waytch
lds common, RightButton + 1
inc common
sts RightButton + 1, common
sts CurrentRightButton, common
cpi common, 2
brne exitMenu1
eor common, common
sts RightButton + 1, common
sts CurrentRightButton, common

exitMenu1:
cpi common, 0
brne turnOnClock
; stop clock
ldi temp, 0
sts TicTac, temp
rjmp exitMenu
turnOnClock: ; continue clock
ldi temp, 1
sts TicTac, temp
rjmp exitMenu

menu2:
cpi sys, 2
brne menu3
; 2 assign hours
ldi common, 0
sts CurrentRightButton, common
sts RightButton + 2, common
lds common, Hours
inc common
sts Hours, common
cpi common, 24
brne exitMenu2
eor common, common

exitMenu2:
sts Hours, common
rjmp exitMenu

menu3:
cpi sys, 3
brne menu4
; 3 assign minutes
ldi common, 0
sts CurrentRightButton, common
sts RightButton + 3, common
lds common, Minutes
inc common
cpi common, 60
brne exitMenu3
eor common, common

exitMenu3:
sts Minutes, common
rjmp exitMenu

menu4:
exitMenu:
ret

;========================
