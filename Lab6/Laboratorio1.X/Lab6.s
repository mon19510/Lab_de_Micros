;Archivo: Lab6.S
; Dispositivo: PIC16F887
; Autora: Ximena Monzon
; Compilador: pic-as (v2.30), MPLABX V5.40
;
;Programa: Temporizadores
;Hardware: LEDs, display 7-seg, resistencias
;
;Creado: 23 Marzo, 2021
;Ultima modificacion: 28 Marzo, 2021

PROCESSOR 16F887
#include <xc.inc>

;configuration word 1
    CONFIG FOSC=INTRC_NOCLKOUT //Oscilador Interno sin salida
    CONFIG WDTE=OFF //WDT disabled (reinicio repetitivo del pic)
    CONFIG PWRTE=OFF //PWRT enabled (espera de 72ms al iniciar) antes de ejecutar cualquier cosa
    CONFIG MCLRE=OFF // El pin de MCRL se utiliza como I/O (masterclear) (pin RE3 en micro) (si esta on poner resistencia)
    CONFIG CP=OFF // Sin proteccion de codigo (por si vendemos)
    CONFIG CPD=OFF // Sin proteccion de datos
    
    CONFIG BOREN=OFF // Sin reinicio cuando el voltaje de alimentacion baja de 4V (reset por si baja el voltaje) (detecta problemas)
    CONFIG IESO=OFF // Reinicio sin cambio de reloj de interno a externo (abajo)
    CONFIG FCMEN=OFF // Cambio de relo externo a interno en caso de fallo (necesita resist. si esta prendido)
    CONFIG LVP=ON // programacion en bajo voltaje permitida
    
;configuration word 2
    CONFIG WRT=OFF // proteccion de autoescritura por el programa desactivada
    CONFIG BOR4V=BOR40V // Reinicio abajo de 4v, (BOR21V=2.1V)

    ;---------------------variables-------------------;

reset2 macro
;macro para reiniciar tmr2
    BANKSEL PR2
    movlw 100
    movwf PR2
    
    endm
    
PSECT udata_shr ;Common memory
    
    WT:	    ; Variable para que se guarde w
	DS 1
    ST:    ; Variable para que guarde status
	DS 1
    nibble:
	DS  2
    count:
	DS 1
    disp:
	DS  2
    flags:
	DS  1

PSECT udata_bank0 
    var:
	DS  1
    count1:
	DS  1
	
    blinka:
	DS  1
	
;--------------vector reset ---------------------;
PSECT resVect, class=code,abs, delta=2
    ORG 00h
    resetVec:
    PAGESEL setup
    goto setup
    
;---------------interrupt vector----------------;
PSECT code, abs, delta=2
ORG 04h
push: ;mueve las variables temp a w
    movwf WT
    swapf STATUS, W
    movwf ST
    
isr: ;interrupcion
    BANKSEL PORTB
    btfsc TMR1IF ;revision de overflow
    call intmr1 ;subrutina tmr1
    btfsc T0IF ;verificando overflow tmr0
    call intmr0 ;llamando subrutina tmr0
    
    BANKSEL PIR1
    btfsc TMR2IF ;verificando overflow tmr2
    call intmr2 ;interrupcion tmr2
    BANKSEL TMR2
    bcf TMR2IF ;limpiando bandera tmr2
    

pop: ;regreso de w a STATUS
    swapf ST, W
    movwf STATUS
    swapf WT, F
    swapf WT, W
    retfie
    
;--------------sub interrupt-----------------;
intmr2:
    
    btfsc blinka, 0 ;verificando bandera
    goto off
    
    on:
    
    bsf blinka, 0 ;activando bandera
    return
    
    off:
    
    bcf blinka, 0 ;desactivando bandera
    return

intmr1:
    ;modificando valor de los registros
    BANKSEL TMR1H
    movlw 0xE1
    movwf TMR1H
    
    BANKSEL TMR1L
    movlw 0x7C
    movwf TMR1L
    
    ;incrementando variable del contador
    incf count1
    bcf TMR1IF
    return

intmr0:
    call    reset0	;reseteando  TMR0
    bcf	    PORTD, 1	;limpiando puertos que van a los transistores
    bcf	    PORTD, 2
    btfsc   flags, 0
    goto    DISP2    

;rutinas internas para activar display
DISP1:
    movf disp, w
    movwf PORTC
    bsf PORTD, 2
    goto NDISP1
    
DISP2:
    movf disp+1, w
    movwf PORTC
    bsf PORTD, 1
    
NDISP1:
    movlw 1
    xorwf flags, f
    return
    
;------------------config--------------------;
PSECT code, delta=2, abs
 ORG 100h
 tablita:
    clrf PCLATH
    bsf PCLATH, 0
    andlw   0x0F    ; Se pone como limite d.16 
    addwf   PCL
    retlw   00111111B    ; 0
    retlw   00000110B    ; 1
    retlw   01011011B    ; 2
    retlw   01001111B    ; 3
    retlw   01100110B    ; 4
    retlw   01101101B    ; 5
    retlw   01111101B    ; 6
    retlw   00000111B    ; 7
    retlw   01111111B    ; 8
    retlw   01101111B    ; 9
    retlw   01110111B    ; A
    retlw   01111100B    ; b
    retlw   00111001B    ; C
    retlw   01011110B    ; d
    retlw   01111001B    ; E
    retlw   01110001B    ; F
    
ORG 118h 
setup:

;llamando configuraciones
    call config_io
    call config_clock
    
;------ configuracion interrupciones ----------------;
    BANKSEL INTCON
    ;interrucpiones global y tmr0
    bsf GIE
    bsf T0IE
    bcf T0IF

    BANKSEL PIE1
    bsf TMR2IE ;habilitando tmr2 para pr2
    bsf TMR1IE ;tmr1 interrupcion por overflow
    
    BANKSEL PIR1
    ;limpiando banderas
    bcf TMR2IF
    bcf TMR1IF
    
    call config_tmr0
    call config_tmr1
    call config_tmr2
   
    BANKSEL PORTA
    clrf PORTA
    clrf PORTB
    clrf PORTC
    clrf PORTD
    clrf PORTE

;-------------------- loop ---------------------------;
    
    loop:
    
    banksel PORTA
    call DNIB ;division de nibble
    
    btfss blinka, 0
    call PNIB ;mandando nibble a display
    
    btfsc blinka, 0
    call BLINK ;llamando parpadeo
    
    goto loop
    
;----------------- subrutinas ------------------------;
    DNIB:
    movf count1, w
    andlw 00001111B
    movwf nibble
    swapf count1, w
    andlw 00001111B
    movwf nibble+1
    return
    
    PNIB:
    movf nibble, w
    call tablita
    movwf disp
    movf nibble+1, w
    call tablita
    movwf disp+1
    return
    
    BLINK:
    movlw 0
    movwf disp
    movwf disp+1
    bcf PORTD, 0
    return
    
    reset0:
    banksel PORTA
    movlw 253
    movwf TMR0
    bcf T0IF
    return
    
;-----------------call - configuraciones--------------;

config_tmr0:
    banksel OPTION_REG
    bcf T0CS
    bcf PSA
    bsf PS0 ;prescaler 1:256
    bsf PS1
    bsf PS2
    return
    
config_tmr1:
    ;configuracion timer 1
    BANKSEL T1CON
    bsf T1CKPS0 ;prescaler 1:8
    bsf T1CKPS1
    bcf TMR1CS
    bsf TMR1ON ;habilitando tmr1
    return
    
config_tmr2:
    BANKSEL T2CON
    movlw 1001110B ;1001 postscalerm 1 tmr 2 on, 10 prescaler 16
    movwf T2CON
    return 
   
config_clock:
    ;configuracion de oscilador interno
    BANKSEL OSCCON
    bcf IRCF2 ;se utiliza 010
    bsf IRCF1
    bcf IRCF0 ;250 KHz
    bsf SCS ;activacion de oscilador interno
    return
    
config_io:
    ;deshabilitando puertos analogicos
    BANKSEL ANSEL
    clrf ANSEL
    clrf ANSELH
    
    ;definiendo puerto C como salida
    BANKSEL TRISC
    bcf TRISC, 0
    bcf TRISC, 1 
    bcf TRISC, 2
    bcf TRISC, 3
    bcf TRISC, 4
    bcf TRISC, 5
    bcf TRISC, 6
    bcf TRISC, 7
    clrf TRISC
    
    ;definiendo puerto D como salida
    BANKSEL TRISD
    bcf TRISD, 0
    bcf TRISD, 1
    bcf TRISD, 2
    clrf TRISD

    
    return 
    END