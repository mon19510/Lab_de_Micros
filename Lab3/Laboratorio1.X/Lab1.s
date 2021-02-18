
;Archivo: main.S
; Dispositivo: PIC16F887
; Autora: Ximena Monzon
; Compilador: pic-as (v2.30), MPLABX V5.40
;
;Programa: Contador en el puerto A
;Hardware: LEDs en el puerto A
;
;Creado: 2 feb, 2021
;Ultima modificacion: 2 Feb, 2021

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

PSECT udata_bank0 ;common memory
    cont_small: DS 1; 1 byte
    cont_big: DS 1
    
PSECT resVect, class=CODE, abs, delta=2
    ;---------vector reset-----------
ORG 00h ;posicion 0000h para el reset
resetVec:
    PAGESEL main
    goto main

PSECT code, delta=2, abs
 ORG 100h ;posicion para el codigo
 ;------------configuracion------------
 main:
    bsf STATUS, 5 ; banco 1
    bsf STATUS, 6 ;
    clrf ANSEL ;pines digitales
    clrf ANSELH 
    
    bsf STATUS, 5; banco 01
    bcf STATUS, 6
    clrf TRISA ; port A como salida
    
    bcf STATUS, 5; banco 00
    bcf STATUS, 6
    
loop:
    incf PORTA, 1
    call delay_big
    goto loop ;loop forever
    
;-----------sub rutinas--------------
    
delay_big:
    movlw 200 ; valor inicial del contador
    movwf cont_big
    call delay_small ;rutina de delay
    decfsz cont_big, 1 ;decrementar el contador
    goto $-2 ;ejecutar dos lineas atras
    return
    
delay_small:
    movlw 249 ;valor inicial del contador
    movwf cont_small
    decfsz cont_small, 1 ;decrementar el contador
    goto $-1 ;ejecutar linea anterior
    return

    END
   