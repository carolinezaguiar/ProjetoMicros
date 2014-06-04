list P = 16F877             ;Target = 16F877
STATUS  EQU 0x03
INTCON  EQU 0x0B
GIE     EQU 0x07
T0IE    EQU 0x05
T0IF    EQU 0x02
OPTREG  EQU 0x81
TMR0    EQU 0x01
STATUS  EQU 0x03
ZFLAG   EQU 0x02
PORTA   EQU 0x05
PORTB   EQU 0x06
PORTC   EQU 0x07
PORTD   EQU 0x08
TRISA   EQU 0x85
TRISB   EQU 0x86
TRISC   EQU 0x87
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
    countT0
    Kount100us
    Kount1ms
    Kount10ms
    Kount100ms
    Kount1s
    ledligado
    ENDC
;=======================================================
    org 0x0000
    goto START
;======================================================
;==========Interrupt Handler 0x04========
    org 0x04
    incf countT0
    movlw 0x13          ;76 (4CH) overflows para 1s, 13H para 1/4s
    xorwf countT0, 0
    btfsc STATUS, ZFLAG
    call piscaled
    bcf INTCON, T0IF
    retfie
    
START
    ;setar interrupcao
    banksel INTCON
    bsf INTCON, GIE
    bsf INTCON, T0IE
    clrf TMR0
    banksel OPTREG
    movlw 0xC7          ;pre-scaler em 256
    movwf OPTREG
    ;configura entradas saidas
    banksel TRISB
    movlw 0x00
    movwf TRISA
    movwf TRISB
    movwf TRISC
    movwf TRISD
    banksel PORTA
    movwf PORTD
    movwf ledligado
    call delay10ms
    call delay10ms      ;delay de 20ms para setar LCD
    ;configura LCD
    movlw 0x38          ;set function
    call instw
    movlw 0x0E          ;entry mode
    call instw
    movlw 0x06          ;display on, cursor on, no blinking
    call instw
    movlw 0x01          ;clear display
    call instw
    ;escreve no lcd
    movlw 0x49          ;I
    call dataw
    movlw 0x6E          ;n
    call dataw
    movlw 0x73          ;s
    call dataw
    movlw 0x69          ;i
    call dataw
    movlw 0x72          ;r
    call dataw
    movlw 0x61          ;a
    call dataw
    movlw 0x20          ;espaco
    call dataw
    movlw 0x73          ;s
    call dataw
    movlw 0x75          ;u
    call dataw
    movlw 0x61          ;a
    call dataw
    movlw 0x20          ;espaco
    call dataw
    movlw 0x73          ;s
    call dataw
    movlw 0x65          ;e
    call dataw
    movlw 0x6E          ;n
    call dataw
    movlw 0x68          ;h
    call dataw
    movlw 0x61          ;a
    call dataw
fim
    goto fim

;SUBROTINAS
;============== piscaled ==============
piscaled
    movlw 0x00
    xorwf ledligado, 0
    btfsc STATUS, ZFLAG
    goto ligaled
    goto desligaled
zeratimer
    clrf countT0
    return
desligaled
    movlw 0x00
    movwf ledligado
    bcf PORTA, LED
    goto zeratimer
ligaled
    movlw 0x01
    movwf ledligado
    bsf PORTA, LED
    goto zeratimer
;============== instw ==============
;instruction write no LCD
;instrucao a ser escrita armazenada no W antes da chamada
instw 
    movwf PORTC
    bcf PORTD, RS
    bsf PORTD, E
    bcf PORTD, E
    call delay10ms
    return
;============== dataw ==============
;dado a ser escrito armazenado no W antes da chamada
dataw 
    movwf PORTC
    bsf PORTD, RS
    bsf PORTD, E
    bcf PORTD, E
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