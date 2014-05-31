;--------------
;MICROCONTROLER
;--------------
	LIST P=16F877A
	INCLUDE "P16F877A.INC"

	__CONFIG  _XT_OSC & _WDT_OFF & _LVP_OFF & _CP_OFF & _PWRTE_ON

;-------
;DEVICES
;-------
;	LCD: PORTB
;	KEYPAD: PORTC


PC	EQU H'02'

;------------------
;BLOCK OF VARIABLES
;------------------
	CBLOCK H'20'
	DELAY1
	DELAY2
	BUTTON
	ENDC

;----------------
;LCD CONTROL PINS
;----------------
LCDRW EQU H'02'				; RB2 = LCD RW pin
LCDRS EQU H'04'				; RB4 = LCD RW pin
LCDE  EQU H'05'				; RB5 = LCD E pin  


;----------
;CODE BEGIN
;----------
	ORG H'0000'

	BCF STATUS, RP0			; Bank0
	BCF STATUS, RP1

	CLRF PORTA
	CLRF PORTB
	CLRF PORTC
	CLRF PORTD

	BSF STATUS, RP0			; Bank1
	BCF STATUS, RP1
	
	CLRF TRISA
	CLRF TRISB				; SET PORTB AS OUTPUT (LCD)
	MOVLW B'11111111'
	MOVWF TRISC				; SET PORTC AS INPUT (KEYPAD)
	CLRF TRISD

;-------------------------
;SET ALL INPUTS AS DIGITAL
;-------------------------	
	MOVLW H'06'				; All inputs digital = 0x06
	MOVWF ADCON1
	
	BCF STATUS, RP0

	GOTO SETUP				;

;----------------------------------
;DIGITS THAT WILL APPEAR IN THE LCD
;----------------------------------
LCD_DATA				
	
	MOVF BUTTON, W			; Button holds the number typed in the Keypad
	ADDWF PC, W				; Add the PC to check which number should be displayed

	RETLW B'11000000'		; 0
	RETLW B'11110011'		; 1
	RETLW B'10100100'		; 2
	RETLW B'10100001'		; 3
	RETLW B'10010011'		; 4
	RETLW B'10001001'		; 5
	RETLW B'10001000'		; 6
	RETLW B'11100011'		; 7
	RETLW B'10000000'		; 8
	RETLW B'10000001'		; 9
	RETLW B'11010010'		; *
	RETLW B'10101101'		; #

	RETURN

;---------
;INITILIZE
;---------
SETUP

	CALL LCDINIT			; Initialize the LCD
					
	CLRF BUTTON				; Erase BUTTON value
	CLRF PORTC				; Erase the PORTC


BEGIN
	
	CALL CHECK_KEYPAD		; Call the routine that checks the keypad
	CALL DISPLAY_LCD		; Call the routine that updates the LCD
	GOTO BEGIN				; Starts all over again

;--------------
;LCD INITIALIZE
;--------------
LCDINIT

	




;--------------
;KEYPAD CONTROL
;--------------

CHECK_KEYPAD

	CLRF BUTTON
	
	BSF PORTC, 3			; Scan the 1st column
	BTFSC PORTC, 2			; Key 1?
	MOVLW D'01'				; Copy decimal 01 into W
	BTFSC PORTC, 7			; Key 4?
	MOVLW D'04'				; Copy decimal 04 into W
	BTFSC PORTC, 6			; Key 7?
	MOVLW D'07'				; Copy decimal 07 into W
	BTFSC PORTC, 4			; Key *?
	MOVLW D'10'				; Copy decimal 10 into W
	BCF PORTC, 3

	BSF PORTC, 1			; Scan the 2nd column
	BTFSC PORTC, 2			; Key 2?
	MOVLW D'02'				; Copy decimal 02 into W
	BTFSC PORTC, 7			; Key 5?
	MOVLW D'05'				; Copy decimal 05 into W
	BTFSC PORTC, 6			; Key 8?
	MOVLW D'08'				; Copy decimal 08 into W
	BTFSC PORTC, 4			; Key 0?
	MOVLW D'00'				; Copy decimal 00 into W
	BCF PORTC, 1

	BSF PORTC, 5			; Scan the 3rd column
	BTFSC PORTC, 2			; Key 3?
	MOVLW D'03'				; Copy decimal 03 into W
	BTFSC PORTC, 7			; Key 6?
	MOVLW D'06'				; Copy decimal 06 into W
	BTFSC PORTC, 6			; Key 9?
	MOVLW D'09'				; Copy decimal 09 into W
	BTFSC PORTC, 4			; Key #?
	MOVLW D'11'				; Copy decimal 11 into W
	BCF PORTC, 5

	MOVWF BUTTON
	
	RETURN


DISPLAY_LCD
	
	CALL LCD_DATA			; Check which bits should be filled
	MOVWF PORTB
	
	RETURN
	


	END
