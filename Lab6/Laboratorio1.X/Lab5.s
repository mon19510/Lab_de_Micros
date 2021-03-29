;Archivo: Lab5.S
; Dispositivo: PIC16F887
; Autora: Ximena Monzon
; Compilador: pic-as (v2.30), MPLABX V5.40
;
;Programa: Displays Simultaneos
;Hardware: LEDs, pushbutton, display 7-seg, resistencias
;
;Creado: 1 Marzo, 2021
;Ultima modificacion:  Marzo, 2021

PROCESSOR 16F887
#include <xc.inc>

;configuration word 1
    CONFIG FOSC=INTRC_NOCLKOUT //Oscilador Interno sin salida
    CONFIG WDTE=OFF //WDT disabled (reinicio repetitivo del pic)
    CONFIG PWRTE=ON //PWRT enabled (espera de 72ms al iniciar) antes de ejecutar cualquier cosa
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
PSECT udata_bank0

residue: DS 1
cent: DS 1
dec: DS 1
unidad: DS 1

PSECT udata_shr    
WT: DS 1
ST: DS 1
var: DS 1
banderas: DS 1 ;variables temp para interrupciones
DISP: DS 2 ;variable del displey
nibble: DS 2
    
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
    banksel PORTB
    btfsc RBIF ;revision de interrupciones en puerto b
    call actv ;llamando subrutina de botones
    btfsc T0IF ;revision de overflow en timer0
    call intmr ;llamando a timer 0

pop: ;regreso de w a STATUS
    swapf ST, W
    movwf STATUS
    swapf WT, F
    swapf WT, W
    retfie

;--------------sub interrupt-----------------;
    
intmr:
    call reset0
    bcf PORTE, 0
    bcf PORTE, 1
    bcf PORTB, 5
    bcf PORTB, 6
    bcf PORTB, 7
    
    btfsc banderas, 0
    goto DISP2
    
    btfsc banderas, 1
    goto DIPS3
    
    btfsc banderas, 2
    goto DISP4
    
    btfsc banderas, 3
    goto DISP5

DISP1:
    movf DISP, w
    movwf PORTD
    bsf PORTE, 0
    goto DISPN

DISP2:
    movf DISP+1, w
    movwf PORTD
    bsf PORTE, 1
    goto DISPN1
    
DIPS3:
    
DISPN:
    movlw 1
    xorwf banderas, f
    
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
call config_pullup
call config_clock

;activando interrupciones
banksel IOCB
movlw 00000011B ;activando bits del banksel
movwf IOCB

;registro de configuracion de control de interrupcion
banksel INTCON
movf PORTB, 0
bcf RBIF

call config_tmr0
    
;seteando bits de interrupcion
bsf GIE ;global interrupt enable bit
bsf RBIE ;PORTB change interrupt enable bit
bsf T0IF ;timer0 overflow interrupt flag
bcf T0IF
    
banksel PORTA
    clrf PORTA
    clrf PORTB
    clrf PORTC
    clrf PORTD

banksel PORTA

;-------------------Loop--------------------;

loop:
    
    movf PORTA, w
    movwf var
    call DNIB
    call PNIB

goto loop
    
;----------------subrutinas----------------;
    
DNIB:
    movf var, w
    andlw 00001111B
    movwf NBL
    swapf var, w
    andlw 00001111B
    movwf NBL+1
    return
    
PNIB:
    movf NBL, w
    call tablita
    movwf DISP
    movf NBL+1, w
    call tablita
    movwf DISP+1
    return
    
reset0:
    movlw 253 ;tiempo de instruccion
    movwf TMR0
    bcf T0IF ;convertir a 0 el bit de overflow
    return 
    
/*timer0: ;incrementa el valor cada vez que haya un overflow
    btfss T0IF ;sumar cuando llegue al overflow de timer0
    goto $-1
    call reset0 ;regreso del overflow a 0
    incf DISP
    movf DISP, w
    call tablita
    movwf PORTD
    return */

actv:
    ;subrutina de incremento y decremento
    btfss PORTB, 0 ;revisa si se presiona el boton 1
    incf PORTA ;incrementa
    btfss PORTB, 1 ;revisa si se presiona el boton 2
    decf PORTA ;decrementa
    return

    
    
    
    
;-----------------call - configuraciones--------------;
    
config_clock:
    ;configuracion de oscilador interno
    banksel OSCCON
    bcf IRCF2 ;se utiliza 010
    bsf IRCF1
    bcf IRCF0 ;250 KHz
    bsf SCS ;activacion de oscilador interno
    return
    
config_pullup:
   
    banksel OPTION_REG
    bcf OPTION_REG, 7 ;limpiando para habilitacion de pullup interno
    
    banksel WPUB
    ;activando primeros dos (push)
    bsf WPUB, 0
    bsf WPUB, 1
    bcf WPUB, 2
    bcf WPUB, 3
    bcf WPUB, 4
    bcf WPUB, 5
    bcf WPUB, 6
    bcf WPUB, 7
    return
    
config_tmr0:
    banksel OPTION_REG
    bcf T0CS
    bcf PSA ;prescaler tmr0
    bsf PS0 ;valores de 1:256
    bsf PS1
    bsf PS2
    return
    
config_io:
 
    ;deshabilitando puertos analogicos
    banksel ANSEL
    banksel ANSELH
    clrf ANSEL
    clrf ANSELH

    ;configuracion puerto A
    banksel TRISA
    bcf TRISA, 0
    bcf TRISA, 1
    bcf TRISA, 2
    bcf TRISA, 3
    bcf TRISA, 4
    bcf TRISA, 5
    bcf TRISA, 6
    bcf TRISA, 7
    
    ;configuracion puerto b
    banksel TRISB
    bsf TRISB, 0
    bsf TRISB, 1
    bcf TRISB, 5
    bcf TRISB, 6
    bcf TRISB, 7
    
    ;configuracion puerto c
    banksel TRISC
    bcf TRISC, 0
    bcf TRISC, 1
    bcf TRISC, 2
    bcf TRISC, 3
    bcf TRISC, 4
    bcf TRISC, 5
    bcf TRISC, 6
    bcf TRISC, 7
    
    ;configuracion puerto d
    banksel TRISD
    bcf TRISD, 0
    bcf TRISD, 1
    bcf TRISD, 2
    bcf TRISD, 3
    bcf TRISD, 4
    bcf TRISD, 5
    bcf TRISD, 6
    bcf TRISD, 7
    
    ;configuracion puerto e
    banksel TRISE
    bcf TRISE, 0
    bcf TRISE, 1
   
    return

end
