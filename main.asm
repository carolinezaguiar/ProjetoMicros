list P = 16F877 ;Target processor = 16F877
STATUS  EQU 0x03
PORTA   EQU 0x05
PORTB   EQU 0x06
TRISA   EQU 0x85
TRISB   EQU 0x86
PORTD   EQU 0x08
TRISD   EQU 0x88
E       EQU 0x00
RW      EQU 0x01
RS      EQU 0x02
LED     EQU 0x00

;Area RAM
    CBLOCK 0x20             ;endereço inicial do bloco de registradores de proposito geral 20H
    char1
    char2
    char3
    char4
    char5
    Kount100us
    Kount1ms
    Kount10ms
    Kount100ms
    Kount1s
    ENDC
;=========================================================
    org 0x0000
    goto START
;======================================================
    org 0x05
START
    banksel TRISB
    movlw 0x00
    movwf TRISA
    movwf TRISB
    movwf TRISD
    banksel PORTB
    movwf PORTD
    call delay10ms
    call delay10ms      ;delay de 20ms
    movlw 0x38          ;set function
    call instw
    movlw 0x0E          ;entry mode
    call instw
    movlw 0x06          ;display on, cursor on, blinking
    call instw
    movlw 0x01          ;clear display
    call instw
again
    movlw 0x50
    call dataw
    bcf PORTA, LED
    call delay1s
    bsf PORTA, LED
    call delay1s
	goto again

;SUBROTINAS
;============== instw ==============
;instruction write no LCD
;instrucao a ser escrita armazenada no W antes da chamada
instw 
    movwf PORTB
    bcf PORTD, RS
    bsf PORTD, E
    bcf PORTD, E
    call delay10ms
    return
;============== dataw ==============
;dado a ser escrito armazenado no W antes da chamada
dataw 
    movwf PORTB
    bsf PORTD, RS
    bsf PORTD, E
    bcf PORTD, E ;Transitional E signal
    call delay10ms
    return
;============== Delay100us ==============
;Precisa 500 ciclos de instrucao, pois uma instrucao -> 0.2 us
;A formula para 500 ciclos e:
; 500 =3*165 + 5
delay100us 
    movlw 0xA5          ;165 em decimal
    movwf Kount100us
R100us 
    decfsz Kount100us
    goto R100us
    return
;============== Delay1ms ==============
;Chama delay100us 10 vezes
delay1ms 
    movlw 0x0A          ;10 em decimal
    movwf Kount1ms
R1ms 
    call delay100us
    decfsz Kount1ms
    goto R1ms
    return
;============== Delay10ms ==============
;Chama delay1ms 10 vezes
delay10ms 
    movlw 0x0A          ;10 em decimal
    movwf Kount10ms
R10ms 
    call delay1ms
    decfsz Kount10ms
    goto R10ms
    return
;============== Delay100ms ==============
;Chama delay10ms 10 vezes
delay100ms 
    movlw 0x0A          ;10 em decimal
    movwf Kount100ms
R100ms 
    call delay10ms
    decfsz Kount100ms
    goto R100ms
    return
;============== Delay1s ==============
;Chama delay100ms 10 vezes
delay1s 
    movlw 0x0A          ;10 em decimal
    movwf Kount1s
R1s 
    call delay100ms
    decfsz Kount1s
    goto R1s
    return
;================= FIM =================
    END         ;Fim do codigo