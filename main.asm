	list P = 16F877             ;Target = 16F877

STATUS      EQU 0x03
INTCON      EQU 0x0B
GIE         EQU 0x07
T0IE        EQU 0x05
T0IF        EQU 0x02
OPTREG      EQU 0x81
TMR0        EQU 0x01
STATUS      EQU 0x03
ZFLAG       EQU 0x02
PORTA       EQU 0x05
PORTB       EQU 0x06
PORTC       EQU 0x07
PORTD       EQU 0x08
TRISA       EQU 0x85
TRISB       EQU 0x86
TRISC       EQU 0x87
TRISD       EQU 0x88
E           EQU 0x00
RW          EQU 0x01
RS          EQU 0x02
LED         EQU 0x00
COL0        EQU 0x03
COL1        EQU 0x01
COL2        EQU 0x05
LIN0        EQU 0x02
LIN1        EQU 0x07
LIN2        EQU 0x06
LIN3        EQU 0x04
;flags
KEYPRESSED  EQU 0x00
LEDON       EQU 0x01
;ASCII
ASCESP      EQU 0x20    ;espaco
ASCEXC      EQU 0x21    ;!
ASCCARD     EQU 0x23    ;#
ASCPAR1     EQU 0x28    ;(
ASCPAR2     EQU 0x29    ;)
ASCSTAR     EQU 0x2A    ;*
ASCBRA1     EQU 0x5B    ;[
ASCBRA2     EQU 0x5D    ;]
ASCTRA      EQU 0x2D    ;-
ASCCOL      EQU 0x3A    ;:
ASCBAR      EQU 0x2F    ;/
ASC0        EQU 0x30
ASC1        EQU 0x31
ASC2        EQU 0x32
ASC3        EQU 0x33
ASC4        EQU 0x34
ASC5        EQU 0x35
ASC6        EQU 0x36
ASC7        EQU 0x37
ASC8        EQU 0x38
ASC9        EQU 0x39
ASCA        EQU 0x41
ASCB        EQU 0x42
ASCC        EQU 0x43
ASCD        EQU 0x44
ASCE        EQU 0x45
ASCF        EQU 0x46
ASCG        EQU 0x47
ASCH        EQU 0x48
ASCI        EQU 0x49
ASCJ        EQU 0x4A
ASCK        EQU 0x4B
ASCL        EQU 0x4C
ASCM        EQU 0x4D
ASCN        EQU 0x4E
ASCO        EQU 0x4F
ASCP        EQU 0x50
ASCQ        EQU 0x51
ASCR        EQU 0x52
ASCS        EQU 0x53
ASCT        EQU 0x54
ASCU        EQU 0x55
ASCV        EQU 0x56
ASCW        EQU 0x57
ASCX        EQU 0x58
ASCY        EQU 0x59
ASCZ        EQU 0x5A
ASCa        EQU 0x61
ASCb        EQU 0x62
ASCc        EQU 0x63
ASCd        EQU 0x64
ASCe        EQU 0x65
ASCf        EQU 0x66
ASCg        EQU 0x67
ASCh        EQU 0x68
ASCi        EQU 0x69
ASCj        EQU 0x6A
ASCk        EQU 0x6B
ASCl        EQU 0x6C
ASCm        EQU 0x6D
ASCn        EQU 0x6E
ASCo        EQU 0x6F
ASCp        EQU 0x70
ASCq        EQU 0x71
ASCr        EQU 0x72
ASCs        EQU 0x73    
ASCt        EQU 0x74
ASCu        EQU 0x75
ASCv        EQU 0x76
ASCw        EQU 0x77
ASCx        EQU 0x78
ASCy        EQU 0x79
ASCz        EQU 0x7A

;Area RAM
    CBLOCK 0x20             ;endereço inicial do bloco de registradores de proposito geral 20H
    char1
    char2
    char3
    char4
    char5
    char6
    char7
    char8
    char9
    countT0
    Kount100us
    Kount1ms
    Kount10ms
    Kount100ms
    Kount1s
    flags
    nrochars
    nrocharsaux
    auxint
    input
    ENDC
;=======================================================
    org 0x0000
    goto START
;======================================================
;==========Interrupt Handler 0x04========
    org 0x04
    incf countT0
    movwf auxint 
    movlw 0x26          ;76 (4CH) overflows para 1s, 13H para 1/4s
    xorwf countT0, 0
    btfsc STATUS, ZFLAG
    call piscaled
    bcf INTCON, T0IF
    movf auxint, 0
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
    bsf TRISB, 0x00
    bcf TRISB, COL0
    bcf TRISB, COL1
    bcf TRISB, COL2
    bsf TRISB, LIN0
    bsf TRISB, LIN1
    bsf TRISB, LIN2
    bsf TRISB, LIN3
    movlw 0x00
    movwf TRISA
    movwf TRISC
    movwf TRISD
    banksel PORTA
    movwf PORTD
    movwf flags
    call delay10ms
    call delay10ms      ;delay de 20ms para setar LCD
    ;configura LCD
    movlw 0x38          ;set function
    call instw
    movlw 0x0C          ;display on, cursor on, no blinking
    call instw
    movlw 0x06          ;entry mode
    call instw
    call configurasenha
    movlw 0x01          ;clear display
    call instw
    ;escreve no lcd
    movlw ASCI
    call dataw
    movlw ASCn
    call dataw
    movlw ASCs
    call dataw
    movlw ASCi
    call dataw
    movlw ASCr
    call dataw
    movlw ASCa
    call dataw
    movlw ASCESP
    call dataw
    movlw ASCs
    call dataw
    movlw ASCu
    call dataw
    movlw ASCa
    call dataw
    movlw ASCESP
    call dataw
    movlw ASCs
    call dataw
    movlw ASCe
    call dataw
    movlw ASCn
    call dataw
    movlw ASCh
    call dataw
    movlw ASCa
    call dataw
	movlw 0xC0          ;linha 2 pos 40H (primeira)
    call instw
    movlw ASCBRA1
    call dataw
    movlw 0xCF          ;linha 2 ultima posicao
    call instw
    movlw ASCBRA2
    call dataw
    movlw 0xC1          ;linha 2 posicao 2
    call instw
polling
	call checkkeypad
    movwf input
    movlw 0x00
    xorwf input, 0
    btfss STATUS, ZFLAG
    goto imprimechar
    goto polling
imprimechar
    movf input, 0
    call dataw
    call delay100ms
    call delay100ms
    goto polling
    
;SUBROTINAS
;============== configura senha ==============
configurasenha
    movlw 0x01          ;limpar display
    call instw
    ;escreve no lcd
    movlw ASCS
    call dataw
    movlw ASCe
    call dataw
    movlw ASCt
    call dataw
    movlw ASCa
    call dataw
    movlw ASCr
    call dataw
    movlw ASCESP
    call dataw
    movlw ASCn
    call dataw
    movlw ASCo
    call dataw
    movlw ASCv
    call dataw
    movlw ASCa
    call dataw
    movlw ASCESP
    call dataw
    movlw ASCs
    call dataw
    movlw ASCe
    call dataw
    movlw ASCn
    call dataw
    movlw ASCh
    call dataw
    movlw ASCa
    call dataw
	movlw 0xC0          ;linha 2 pos 40H (primeira)
    call instw
    movlw ASCCARD
    call dataw
    movlw ASCc
    call dataw
    movlw ASCh
    call dataw
    movlw ASCa
    call dataw
    movlw ASCr
    call dataw
    movlw ASCs
    call dataw
    movlw ASCESP
    call dataw
    movlw ASCPAR1
    call dataw
    movlw ASC1
    call dataw
    movlw ASCTRA
    call dataw
    movlw ASC9
    call dataw
    movlw ASCPAR2
    call dataw
    movlw ASCCOL
    call dataw
    movlw ASCESP
    call dataw
peganrochars
	call checkkeypad
    movwf input
    movlw 0x00
    xorwf input, 0
    btfss STATUS, ZFLAG
    goto pegounrochars
    goto peganrochars
pegounrochars
    movf input, 0       ;w <- input
    movwf nrochars
    movwf nrocharsaux
    call dataw
    movlw 0xCE          ;linha 2 penultima pos
    call instw
    call delay100ms
    call delay100ms
    call delay100ms
    call delay100ms
    call delay100ms
    movlw ASCESP
    call dataw
    movlw 0xCE          ;linha 2 penultima pos
    call instw
    call delay100ms
    call delay100ms
    call delay100ms
    call delay100ms
    call delay100ms
    movf nrochars, 0
    call dataw
    movlw 0xCE          ;linha 2 penultima pos
    call instw
    call delay100ms
    call delay100ms
    call delay100ms
    call delay100ms
    call delay100ms
    movlw ASCESP
    call dataw
    movlw 0xCE          ;linha 2 penultima pos
    call instw
    call delay100ms
    call delay100ms
    call delay100ms
    call delay100ms
    call delay100ms
    movf nrochars, 0
    call dataw
    movlw 0xCE          ;linha 2 penultima pos
    call instw
    call delay100ms
    call delay100ms
    call delay100ms
    call delay100ms
    call delay100ms
    
    ;nro cacacteres entre 1 a 9
    movlw ASC0
    xorwf nrochars, 0
    btfsc STATUS, ZFLAG
    goto nrocharinvalido
    movlw ASCCARD
    xorwf nrochars, 0
    btfsc STATUS, ZFLAG
    goto nrocharinvalido
    movlw ASCSTAR
    xorwf nrochars, 0
    btfsc STATUS, ZFLAG
    goto nrocharinvalido

    goto continuaconfiguracao1
    
nrocharinvalido
    movlw 0x01          ;limpar display
    call instw
    ;escreve no lcd
    movlw ASCN
    call dataw
    movlw ASCu
    call dataw
    movlw ASCm
    call dataw
    movlw ASCe
    call dataw
    movlw ASCr
    call dataw
    movlw ASCo
    call dataw
    movlw ASCESP
    call dataw
    movlw ASCI
    call dataw
    movlw ASCn
    call dataw
    movlw ASCv
    call dataw
    movlw ASCa
    call dataw
    movlw ASCl
    call dataw
    movlw ASCi
    call dataw
    movlw ASCd
    call dataw
    movlw ASCo
    call dataw
    movlw ASCEXC
    call dataw
    call delay1s
    call delay1s
    goto configurasenha

continuaconfiguracao1
    movlw 0x01          ;limpar display
    call instw
    ;escreve no lcd
    movlw ASCN
    call dataw
    movlw ASCo
    call dataw
    movlw ASCv
    call dataw
    movlw ASCa
    call dataw
    movlw ASCESP
    call dataw
    movlw ASCs
    call dataw
    movlw ASCe
    call dataw
    movlw ASCn
    call dataw
    movlw ASCh
    call dataw
    movlw ASCa
    call dataw
    movlw ASCESP
    call dataw
    movlw ASCBRA1
    call dataw
    movlw ASC1
    call dataw
    movlw ASCBAR
    call dataw
    movlw ASC2
    call dataw
    movlw ASCBRA2
    call dataw
    movlw 0x00
    movwf nrocharsaux
    
setasenha1a
    decfsz nrochars
    goto setasenha1b
    goto setasenha2a
setasenha1b
	call checkkeypad
    movwf input
    movlw 0x00
    xorwf input, 0
    btfss STATUS, ZFLAG
    goto setasenha1c
    goto setasenha1a
setasenha1c
    movf input, 0
    movlw ASCSTAR
    call dataw
    call delay100ms
    call delay100ms
    goto setasenha1a
setasenha2a
    return
    
descobrechar
    incf nrocharsaux
    movlw 0x01
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto primeirochar
    movlw 0x02
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto segundochar
    movlw 0x03
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto terceirochar
    movlw 0x04
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto quartochar
    movlw 0x05
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto quintochar
    movlw 0x06
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto sextochar
    movlw 0x07
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto setimochar
    movlw 0x08
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto oitavochar
    movlw 0x09
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto nonochar
    
    goto descobrechar ;nao deveria acontecer

primeirochar
    movf input, 0
    movwf char1
    return
segundochar
    movf input, 0
    movwf char2
    return
terceirochar
    movf input, 0
    movwf char3
    return
quartochar
    movf input, 0
    movwf char4
    return
quintochar
    movf input, 0
    movwf char5
    return
sextochar
    movf input, 0
    movwf char6
    return
setimochar
    movf input, 0
    movwf char7
    return
oitavochar
    movf input, 0
    movwf char8
    return
nonochar
    movf input, 0
    movwf char9
    return
    
;============== piscaled ==============
piscaled
    btfsc flags, LEDON
    goto desligaled
    goto ligaled
zeratimer
    clrf countT0
    return
desligaled
    bcf flags, LEDON
    bcf PORTA, LED
    goto zeratimer
ligaled
    bsf flags, LEDON
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
;============== checkkeypad ==============
checkkeypad
	movlw 0x00
	; scan the 1st column
	bsf PORTB, COL0
	btfsc PORTB, LIN0		;1?
	movlw ASC1	
	btfsc PORTB, LIN1		;4?
	movlw ASC4	
	btfsc PORTB, LIN2		;7?
	movlw ASC7
	btfsc PORTB, LIN3		;*?
	movlw ASCSTAR
	bcf PORTB, COL0
	; scan the 2nd column
	bsf PORTB, COL1 
	btfsc PORTB, LIN0		;2?
	movlw ASC2
	btfsc PORTB, LIN1		;5?
	movlw ASC5	
	btfsc PORTB, LIN2		;8?
	movlw ASC8
	btfsc PORTB, LIN3		;0?
	movlw ASC0
	bcf PORTB, COL1
	; scan the 3rd column
	bsf PORTB, COL2   
	btfsc PORTB, LIN0		;3?
	movlw ASC3		
	btfsc PORTB, LIN1		;6?
	movlw ASC6		
	btfsc PORTB, LIN2		;9?
	movlw ASC9		
	btfsc PORTB, LIN3		;#?
	movlw ASCCARD		
	bcf PORTB, COL2
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