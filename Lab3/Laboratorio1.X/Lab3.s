
;Archivo: Lab3.S
; Dispositivo: PIC16F887
; Autora: Ximena Monzon
; Compilador: pic-as (v2.30), MPLABX V5.40
;
;Programa: Contador 4 bits en un display de 7 segmentos
;Hardware: LEDs, pushbutton, display 7-seg, resistencias
;
;Creado: 16 feb, 2021
;Ultima modificacion: 16 Feb, 2021

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

;PSECT udata_bank0 
    counter: DS 1; 1 byte
 
 
 PSECT resVect, class=CODE, abs, delta=2
    ;---------vector reset-----------
ORG 00h ;posicion 0000h para el reset
resetVec:
    PAGESEL setup
    goto setup
    
PSECT code, delta=2, abs
 ORG 100h ;posicion para el codigo
 ;------------configuracion------------;

 ;d
tablita:
    clrf PCLATH
    bsf PCLATH, 0
    andlw   0x0F    ; Se pone como limite 16 , en hex F
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

setup:
   
   call config_io
   call config_clock
   call config_timer0
   banksel PORTA
   
loop:
   btfss T0IF
   goto $-1
   call reiniciar_timer0
   incf PORTB, f
 
   btfss PORTA, 2
   call counter1
 
   btfss PORTA, 3
   call discount1
 
   clrf PORTD
   call comparador
 
   goto loop
 

;---------- subrutinas ---------------;
comparador:
    movf PORTB, w
    subwf counter, w
    btfsc STATUS, 2
    call alarma
    return

alarma:
    bsf PORTD, 0
    clrf PORTB
    return
    
counter1: ;
    btfss PORTA, 2
    goto $-1
    incf counter
    movf counter, W ;moviendo variable a tablita
    call tablita
    movwf PORTC
    return

discount1:
    btfss PORTA, 3
    goto $-1
    decf counter
    movf counter, W
    call tablita
    movwf PORTC
    return
    
config_timer0:
    banksel OPTION_REG
    bcf T0CS ;reloj interno
    bcf PSA ;prescaler
    bsf PS2
    bsf PS1
    bcf PS0 ; PS =110
    
    banksel PORTB
    call reiniciar_timer0
    
    return

reiniciar_timer0:
    movlw 12 ;tiempo de instruccion
    movwf TMR0
    bcf T0IF
    
    return
    
    
config_clock:
    banksel OSCCON
    bcf IRCF2 ; IRCF = 011 500kHz
    bsf IRCF1
    bsf IRCF0
    bsf SCS ; reloj interno
    
    return
    
config_io:
    
    banksel ANSEL
    banksel ANSELH
    clrf ANSEL
    clrf ANSELH
    
    ;configurar port A como entrada
    banksel TRISA
    bsf TRISA, 2 ;R0
    bsf TRISA, 3 ;R1
    
    banksel TRISB
    bcf TRISB, 0
    bcf TRISB, 1
    bcf TRISB, 2
    bcf TRISB, 3; configurar port B como salida
    
    ;configurar port C como salida
    banksel TRISC
    bcf TRISC, 0
    bcf TRISC, 1
    bcf TRISC, 2
    bcf TRISC, 3
    bcf TRISC, 4
    bcf TRISC, 5
    bcf TRISC, 6
    bcf TRISC, 7
    
    
    banksel TRISD
    bcf TRISD, 0; configurar port D como salida
    
    banksel PORTA
    clrf PORTA
    clrf PORTB
    clrf PORTC
    clrf PORTD
    return

END
 