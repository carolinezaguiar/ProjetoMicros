	list P = 16F877             ;Target = 16F877

STATUS      EQU 0x03
INTCON      EQU 0x0B
INTF        EQU 0x01
GIE         EQU 0x07
PEIE        EQU 0x06
INTE        EQU 0x04
T0IE        EQU 0x05
T0IF        EQU 0x02
OPTREG      EQU 0x81
NOT_RBPU    EQU 0x07
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
INTCON2		EQU 0x10B
EEDATA		EQU 0x10C
EEADR		EQU 0x10D
EEDATH		EQU 0x10E
EEADRH		EQU 0x10F
INTCON3		EQU 0x18B
EECON1		EQU 0x10C
EECON2		EQU 0x10D
RD			EQU 0x00
WR			EQU 0x01
WREN		EQU 0x02
EEPGD		EQU 0x07
W			EQU 0
F			EQU 0x01
E           EQU 0x00
RW          EQU 0x01
RS          EQU 0x02
RP0         EQU 0x05
RP1         EQU 0x06
LED         EQU 0x00
FECHADURA   EQU 0x01
COL0        EQU 0x05
COL1        EQU 0x07
COL2        EQU 0x03
LIN0        EQU 0x06
LIN1        EQU 0x01
LIN2        EQU 0x02
LIN3        EQU 0x04
;flags
KEYPRESSED  EQU 0x00
LEDON       EQU 0x01
SENHAERRADA	EQU 0x02
ABREON      EQU 0x03
ENDCONFIG   EQU 0x04
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
ASCPOINT    EQU 0x2E    ;.
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
	Kount500ms
    Kount1s
    Kount5s
    flags
    nrochars
    nrocharsaux
    abreportaaux
    input
    ENDC
	CBLOCK 0x120
	dataeeaddr
	ENDC
;=======================================================
    org 0x0000
    goto START
;======================================================
;============Interrupt Handler 0x04========
    org 0x04
    btfsc INTCON, T0IF
    goto interrupcaotimer
    btfsc INTCON, INTF
    goto interrupcaorb0
    retfie  ;nao deveria acontecer
interrupcaorb0
    bcf INTCON, INTF
    btfss flags, ENDCONFIG
    retfie
    movwf abreportaaux
    call abreporta
    movf abreportaaux, 0
    retfie
interrupcaotimer
    decfsz countT0, 1
    goto naoestouro
    call piscaled
naoestouro
    bcf INTCON, T0IF
    retfie
    
START
    ;setar interrupcao
    banksel INTCON
    bsf INTCON, GIE
    bsf INTCON, PEIE
    bsf INTCON, INTE
    bsf INTCON, T0IE
    clrf TMR0
    banksel OPTREG
    movlw 0xC7          ;pre-scaler em 256
    movwf OPTREG
    bcf OPTREG, NOT_RBPU
    ;configura entradas saidas
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
    movwf nrochars
    bcf flags, ENDCONFIG
    ;inicializacao timer0
    movlw 0x26          ;76 (4CH) overflows para 1s, 26H para 1/2s
    movwf countT0
    call delay10ms
    call delay10ms      ;delay de 20ms para setar LCD
    ;configura LCD
    movlw 0x38          ;set function
    call instw
    movlw 0x0C          ;display on, cursor on, no blinking
    call instw
    movlw 0x06          ;entry mode
    call instw
    call readpass
    movlw 0xFF
    xorwf nrochars, 0
    ;btfsc STATUS, ZFLAG
    call configurasenha
    bsf flags, ENDCONFIG
cleardisplay
    ;escreve no lcd: INSIRA SUA SENHA
	call msg_insirasuasenha
    call msg_brackets
    bcf flags, SENHAERRADA
    movlw 0x00
    movwf nrocharsaux
    incf nrochars, 1
lesenha1
    decfsz nrochars, 1
    goto lesenha2
    goto lesenha3
lesenha2
	call checkkeypad
    movwf input
    movlw 0x00
    xorwf input, 0
    btfsc STATUS, ZFLAG
    goto lesenha2
    movf input, 0
    movlw ASCSTAR
    call dataw
	call verificachar
    call delay500ms
    goto lesenha1
lesenha3
    call completacompontos
    btfsc flags, SENHAERRADA
    goto incorreta
    goto correta
incorreta
	call msg_senhaincorreta
    call delay500ms
    call delay500ms
    call delay500ms
    call delay500ms
    goto cleardisplay
correta
    call msg_portaaberta
    call abreporta
	goto cleardisplay
	 
;SUBROTINAS
;============== configurasenha ==============
;Escolher uma nova senha para a fechadura
;Usuario escolhe de quantos digitos sera a
;nova senha e fornece os novos valores
;============================================ 
configurasenha
	call msg_setarnovasenha
	call msg_chars1to9
peganrochars
	call checkkeypad
    movwf input
    movlw 0x00
    xorwf input, 0
    btfsc STATUS, ZFLAG
    goto peganrochars
    movf input, 0       ;w <- input
    movwf nrochars
    ;imprime o numero selecionado e faz piscar 3 vezes
    movwf nrocharsaux
    call dataw
    movlw 0xCE          ;linha 2 penultima pos
    call instw
    call delay500ms
    movlw ASCESP
    call dataw
    movlw 0xCE          ;linha 2 penultima pos
    call instw
    call delay500ms
    movf nrochars, 0
    call dataw
    movlw 0xCE          ;linha 2 penultima pos
    call instw
    call delay500ms
    movlw ASCESP
    call dataw
    movlw 0xCE          ;linha 2 penultima pos
    call instw
    call delay500ms
    movf nrochars, 0
    call dataw
    movlw 0xCE          ;linha 2 penultima pos
    call instw
    call delay500ms
    ;fim imprime o numero selecionado e faz piscar 3 vezes
    
    ;verifica se eh nro cacacteres entre 1 a 9
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
    goto continuaconfiguracao
    
;valor invalido para nro de char
nrocharinvalido
	call msg_numeroinvalido
    call delay500ms
    call delay500ms
    call delay500ms
    call delay500ms
    goto configurasenha

;usuario escolhe a nova senha
continuaconfiguracao
	call msg_setarnovasenha
    call msg_brackets
    movlw 0x00
    movwf nrocharsaux
	movlw 0x30
	subwf nrochars, 1   ;subtrai 30 pois esta em ASCII
    incf nrochars, 1
setasenha1
    decfsz nrochars, 1
    goto setasenha2
    goto setasenha3
;le char do keypad
setasenha2
	call checkkeypad
    movwf input
    movlw 0x00
    xorwf input, 0
    btfsc STATUS, ZFLAG
    goto setasenha2
    movf input, 0
    movlw ASCSTAR
    call dataw
	call descobrechar
    call delay500ms
    goto setasenha1
;nova senha foi inserida
;armazena na eeprom
setasenha3
    call completacompontos
    call msg_senhasetada
    call delay500ms
    call delay500ms
    ;call writepass
    return
;============== completacompontos ==============
;apos a senha ter sido inserida, completa com 
;pontos ate o final da segunda linha, ao final 
;nrochars contera o numero inicial de caracteres 
;da senha
;===============================================
completacompontos
    movf nrocharsaux, 0
    movwf nrochars
    movlw 0x0E			;14 em decimal
    movwf nrocharsaux
    movf nrochars, 0
    subwf nrocharsaux, 1
    incf nrocharsaux, 1
completacompontos1
    decfsz nrocharsaux, 1
    goto completacompontos2
    goto completacompontos3
completacompontos2
    movlw ASCPOINT
    call dataw
    call delay100ms
    goto completacompontos1
completacompontos3
    return
    
;================= descobrechar ================
;descobre qual char esta sendo inserido de acordo
;com as variaveis nrocharsaux, inicialmente em 0
;antes de chamar essa rotina pela primeira vez
;o numero de vezes que essa rotina e chamada deve
;ser controlado externamente de acordo com o numero
;de caracteres que a senha deve possuir
;===============================================	
descobrechar
    incf nrocharsaux, 1
    movlw 0x01
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto primeirochard
    movlw 0x02
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto segundochard
    movlw 0x03
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto terceirochard
    movlw 0x04
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto quartochard
    movlw 0x05
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto quintochard
    movlw 0x06
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto sextochard
    movlw 0x07
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto setimochard
    movlw 0x08
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto oitavochard
    movlw 0x09
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto nonochard
    goto descobrechar ;nao deveria acontecer
primeirochard
    movf input, 0
    movwf char1
    return
segundochard
    movf input, 0
    movwf char2
    return
terceirochard
    movf input, 0
    movwf char3
    return
quartochard
    movf input, 0
    movwf char4
    return
quintochard
    movf input, 0
    movwf char5
    return
sextochard
    movf input, 0
    movwf char6
    return
setimochard
    movf input, 0
    movwf char7
    return
oitavochard
    movf input, 0
    movwf char8
    return
nonochard
    movf input, 0
    movwf char9
    return
;================= verificachar ================
;semelhante a rotina descobrechar, porem agora 
;os caracteres de entrada sao checados conforme
;sao lidos e se algum nao condiz com as variaveis
;char[n] onde a senha correta foi armazenada a flag
;SENHAERRADA e setada
;===============================================
verificachar
    incf nrocharsaux, 1
    movlw 0x01
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto primeirocharv
    movlw 0x02
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto segundocharv
    movlw 0x03
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto terceirocharv
    movlw 0x04
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto quartocharv
    movlw 0x05
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto quintocharv
    movlw 0x06
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto sextocharv
    movlw 0x07
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto setimocharv
    movlw 0x08
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto oitavocharv
    movlw 0x09
    xorwf nrocharsaux, 0
    btfsc STATUS, ZFLAG
    goto nonocharv
    goto verificachar ;nao deveria acontecer
primeirocharv
    movf input, 0
    xorwf char1, 0
    btfss STATUS, ZFLAG
    goto senhaerrada
    return
segundocharv
    movf input, 0
    xorwf char2, 0
    btfss STATUS, ZFLAG
    goto senhaerrada
    return
terceirocharv
    movf input, 0
    xorwf char3, 0
    btfss STATUS, ZFLAG
    goto senhaerrada
    return
quartocharv
    movf input, 0
    xorwf char4, 0
    btfss STATUS, ZFLAG
    goto senhaerrada
    return
quintocharv
    movf input, 0
    xorwf char5, 0
    btfss STATUS, ZFLAG
    goto senhaerrada
    return
sextocharv
    movf input, 0
    xorwf char6, 0
    btfss STATUS, ZFLAG
    goto senhaerrada
    return
setimocharv
    movf input, 0
    xorwf char7, 0
    btfss STATUS, ZFLAG
    goto senhaerrada
    return
oitavocharv
    movf input, 0
    xorwf char8, 0
    btfss STATUS, ZFLAG
    goto senhaerrada
    return
nonocharv
    movf input, 0
    xorwf char9, 0
    btfss STATUS, ZFLAG
    goto senhaerrada
    return
senhaerrada
    bsf flags, SENHAERRADA 
    return
;================== abre porta =================
;Mantém o LED aceso por 3s para indicar
;que a porta está aberta
;===============================================
abreporta
    bsf flags, ABREON
    bsf PORTA, FECHADURA
    call delay500ms
    call delay500ms
    call delay500ms
    call delay500ms
    call delay500ms
    call delay500ms
    call delay500ms
    call delay500ms
    call delay500ms
    call delay500ms
    bcf PORTA, FECHADURA
    bcf flags, ABREON
    return
;================== piscaled ===================
;rotina para piscar o LED periodicamente
;garantindo que o microcontrolador esta
;funcionando corretamente
;===============================================
piscaled
    btfsc flags, LEDON
    goto desligaled
    goto ligaled
resetatimer
    movlw 0x26          ;76 (4CH) overflows para 1s, 26H para 1/2s
    movwf countT0
    return
desligaled
    btfsc flags, ABREON
    goto abreonledoff
    bcf flags, LEDON
    bcf PORTA, LED
    goto resetatimer
abreonledoff
    movlw 0x02
    movwf PORTA
    bcf flags, LEDON
    goto resetatimer
ligaled
    btfsc flags, ABREON
    goto abreonledon
    bsf flags, LEDON
    bsf PORTA, LED
    goto resetatimer
abreonledon
    movlw 0x03
    movwf PORTA
    bsf flags, LEDON
    goto resetatimer
;=================== instw =====================
;instruction write no LCD instrucao a ser 
;escrita armazenada no W antes da chamada
;===============================================
instw 
    movwf PORTC
    bcf PORTD, RS
    bsf PORTD, E
    bcf PORTD, E
    call delay10ms
    return
;==================== dataw ====================
;data write no LCD dado a ser escrito 
;armazenado no W antes da chamada
;===============================================
dataw 
    movwf PORTC
    bsf PORTD, RS
    bsf PORTD, E
    bcf PORTD, E
    call delay10ms
    return
;=========== readpassword =============
;Lê a senha armazenada na eeprom 
;======================================
readpass
	bsf STATUS, RP1
    bcf STATUS, RP0     ; Bank2
    movlw 0x00
    movwf dataeeaddr
	call readeeprom
	movwf char1
	call readeeprom
	movwf char2
	call readeeprom
	movwf char3
	call readeeprom
	movwf char4
	call readeeprom
	movwf char5
	call readeeprom
	movwf char6
	call readeeprom
	movwf char7
	call readeeprom
	movwf char8
	call readeeprom
	movwf char9
	call readeeprom
	movwf nrochars
    return
;============== readeeprom ===============
readeeprom
	bsf STATUS, RP1
    bcf STATUS, RP0     ; Bank2
	movf dataeeaddr, W
	movwf EEADR
    bsf STATUS, RP0     ; Bank3
	bcf EECON1, EEPGD
	bsf EECON1, RD
    bcf STATUS, RP0     ; Bank2
	movf EEDATA, W
	incf dataeeaddr, 1
    banksel PORTA
	return
;=========== writepassword ============
;Armazena a nova senha na eeprom e o
;numero de chars da senha
;======================================
writepass
	bsf STATUS, RP1
    bcf STATUS, RP0     ; Bank2
    movlw 0x0
    movwf dataeeaddr
	bsf STATUS, RP0     ; Bank3
	;char1
waitwrite1
	btfsc EECON1, WR
	goto waitwrite1
    bcf STATUS, RP0     ; Bank2
	movf dataeeaddr, W
	movwf EEADR
	banksel PORTA
	movf char1, W
	bsf STATUS, RP1
    bcf STATUS, RP0     ; Bank2
	call writeeeprom
	;char2
waitwrite2
	btfsc EECON1, WR
	goto waitwrite1
    bcf STATUS, RP0     ; Bank2
	movf dataeeaddr, W
	movwf EEADR
	banksel PORTA
	movf char2, W
	bsf STATUS, RP1
    bcf STATUS, RP0     ; Bank2
	call writeeeprom
	;char3
waitwrite3
	btfsc EECON1, WR
	goto waitwrite1
    bcf STATUS, RP0     ; Bank2
	movf dataeeaddr, W
	movwf EEADR
	banksel PORTA
	movf char3, W
	bsf STATUS, RP1
    bcf STATUS, RP0     ; Bank2
	call writeeeprom
	;char
waitwrite4
	btfsc EECON1, WR
	goto waitwrite1
    bcf STATUS, RP0     ; Bank2
	movf dataeeaddr, W
	movwf EEADR
	banksel PORTA
	movf char4, W
	bsf STATUS, RP1
    bcf STATUS, RP0     ; Bank2
	call writeeeprom
	;char5
waitwrite5
	btfsc EECON1, WR
	goto waitwrite1
    bcf STATUS, RP0     ; Bank2
	movf dataeeaddr, W
	movwf EEADR
	banksel PORTA
	movf char5, W
	bsf STATUS, RP1
    bcf STATUS, RP0     ; Bank2
	call writeeeprom
    ;char6
waitwrite6
	btfsc EECON1, WR
	goto waitwrite1
    bcf STATUS, RP0     ; Bank2
	movf dataeeaddr, W
	movwf EEADR
	banksel PORTA
	movf char6, W
	bsf STATUS, RP1
    bcf STATUS, RP0     ; Bank2
	call writeeeprom
    ;char7
waitwrite7
	btfsc EECON1, WR
	goto waitwrite1
    bcf STATUS, RP0     ; Bank2
	movf dataeeaddr, W
	movwf EEADR
	banksel PORTA
	movf char7, W
	bsf STATUS, RP1
    bcf STATUS, RP0     ; Bank2
	call writeeeprom
    ;char8
waitwrite8
	btfsc EECON1, WR
	goto waitwrite1
    bcf STATUS, RP0     ; Bank2
	movf dataeeaddr, W
	movwf EEADR
	banksel PORTA
	movf char8, W
	bsf STATUS, RP1
    bcf STATUS, RP0     ; Bank2
	call writeeeprom
    ;char9
waitwrite9
	btfsc EECON1, WR
	goto waitwrite1
    bcf STATUS, RP0     ; Bank2
	movf dataeeaddr, W
	movwf EEADR
	banksel PORTA
	movf char9, W
	bsf STATUS, RP1
    bcf STATUS, RP0     ; Bank2
	call writeeeprom
    ;nrochars
waitwritenro
	btfsc EECON1, WR
	goto waitwrite1
    bcf STATUS, RP0     ; Bank2
	movf dataeeaddr, W
	movwf EEADR
	banksel PORTA
	movf nrochars, W
	bsf STATUS, RP1
    bcf STATUS, RP0     ; Bank2
	call writeeeprom
    banksel PORTA
    return
;============== writeeprom ==============
writeeeprom
	movwf EEDATA
    bsf STATUS, RP0     ; Bank3
	bcf EECON1, EEPGD
	bsf EECON1, WREN
	bcf	INTCON3, GIE
	movlw 0x55
	movwf EECON2
	movlw 0xAA
	movwf EECON2
	bsf EECON1,WR
	bsf INTCON3, GIE
	bcf EECON1, WREN
    bcf STATUS, RP0     ; Bank2
	incf dataeeaddr, 1
	bsf STATUS, RP0     ; Bank3
	return
;================= checkkeypad =================
;seta cada coluna uma por vez e verifica as 
;linhas para descobrir se ha uma tecla apertada. 
;O codigo ASC da tecla apertada se encontrara em 
;WREG. Se nenhuma tecla estiver apertada WREG 
;contera o valor 0x00
;===============================================
checkkeypad
	movlw 0x00
	; scan the 1st column
	bcf PORTB, COL0
    movwf input
    call delay10ms
    movf input, 0
	btfss PORTB, LIN0		;1?
	movlw ASC1	
	btfss PORTB, LIN1		;4?
	movlw ASC4	
	btfss PORTB, LIN2		;7?
	movlw ASC7
	btfss PORTB, LIN3		;*?
	movlw ASCSTAR
	bsf PORTB, COL0
	; scan the 2nd column
	bcf PORTB, COL1 
    movwf input
    call delay10ms
    movf input, 0
	btfss PORTB, LIN0		;2?
	movlw ASC2
	btfss PORTB, LIN1		;5?
	movlw ASC5	
	btfss PORTB, LIN2		;8?
	movlw ASC8
	btfss PORTB, LIN3		;0?
	movlw ASC0
	bsf PORTB, COL1
	; scan the 3rd column
	bcf PORTB, COL2
    movwf input
    call delay10ms
    movf input, 0    
	btfss PORTB, LIN0		;3?
	movlw ASC3		
	btfss PORTB, LIN1		;6?
	movlw ASC6		
	btfss PORTB, LIN2		;9?
	movlw ASC9		
	btfss PORTB, LIN3		;#?
	movlw ASCCARD		
	bsf PORTB, COL2
    return
	
;****************************************
;**************** DELAYS ****************
;****************************************
;================== delay100us =================
;Precisa 500 ciclos de instrucao, pois uma instrucao 
;leva 0.2 us A formula para 500 ciclos e:
;500 =3*165 + 5
;===============================================
delay100us 
    movlw 0xA5          ;165 em decimal
    movwf Kount100us
R100us 
    decfsz Kount100us, 1
    goto R100us
    return
;================== delay1ms ===================
;Chama delay100us 10 vezes
;===============================================
delay1ms 
    movlw 0x0A          ;10 em decimal
    movwf Kount1ms
R1ms 
    call delay100us
    decfsz Kount1ms, 1
    goto R1ms
    return
;================== delay10ms ==================
;Chama delay100s 100 vezes
;===============================================
delay10ms 
    movlw 0x64          ;100 em decimal
    movwf Kount10ms
R10ms 
    call delay100us
    decfsz Kount10ms, 1
    goto R10ms
    return
;================= delay100ms ==================
;Chama delay1ms 100 vezes
;===============================================
delay100ms 
    movlw 0x64          ;100 em decimal
    movwf Kount100ms
R100ms 
    call delay1ms
    decfsz Kount100ms, 1
    goto R100ms
    return
;================= delay500ms ==================
;Chama delay10ms 50 vezes
;===============================================
delay500ms 
    movlw 0x32          ;50 em decimal
    movwf Kount500ms
R500ms 
    call delay10ms
    decfsz Kount500ms, 1
    goto R500ms
    return
;****************************************
;**************** MENSAGENS *************
;****************************************
;============ brackets na linha 2 ==========
msg_brackets
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
	return
;============ Setar nova senha ==========
msg_setarnovasenha
    movlw 0x01          ;limpar display
    call instw
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
	return
;============ Senha setada! ==========
msg_senhasetada
    movlw 0x01          ;limpar display
    call instw
    movlw ASCS
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
    movlw ASCS
    call dataw
    movlw ASCe
    call dataw
    movlw ASCt
    call dataw
    movlw ASCa
    call dataw
    movlw ASCd
    call dataw
    movlw ASCa
    call dataw
    movlw ASCEXC
    call dataw
	return
;============ Insira sua senha ==========
msg_insirasuasenha
    movlw 0x01          ;clear display
    call instw
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
	return
;========== Numero Invalido! =========
msg_numeroinvalido
    movlw 0x01          ;limpar display
    call instw
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
	return
;========== #Chars(1-9) =========	
msg_chars1to9
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
	return
;========== SENHA INCORRETA =========	
msg_senhaincorreta
    movlw 0x01          ;limpar display
    call instw
    movlw ASCS
    call dataw
    movlw ASCE
    call dataw
    movlw ASCN
    call dataw
    movlw ASCH
    call dataw
    movlw ASCA
    call dataw
    movlw ASCESP
    call dataw
    movlw ASCI
    call dataw
    movlw ASCN
    call dataw
    movlw ASCC
    call dataw
    movlw ASCO
    call dataw
    movlw ASCR
    call dataw
    movlw ASCR
    call dataw
    movlw ASCE
    call dataw
    movlw ASCT
    call dataw
    movlw ASCA
    call dataw
    movlw ASCEXC
    call dataw
	return
;========== PORTA ABERTA =========	
msg_portaaberta
    movlw 0x01          ;limpar display
    call instw
    movlw ASCP
    call dataw
    movlw ASCO
    call dataw
    movlw ASCR
    call dataw
    movlw ASCT
    call dataw
    movlw ASCA
    call dataw
    movlw ASCESP
    call dataw
    movlw ASCA
    call dataw
    movlw ASCB
    call dataw
    movlw ASCE
    call dataw
    movlw ASCR
    call dataw
    movlw ASCT
    call dataw
    movlw ASCA
    call dataw
	return
	
;================= FIM =================
    END         ;Fim do codigo
