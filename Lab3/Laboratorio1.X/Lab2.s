;Archivo: Lab2.S
; Dispositivo: PIC16F887
; Autora: Ximena Monzon
; Compilador: pic-as (v2.30), MPLABX V5.40
;
;Programa: Sumador de 4 bits
;Hardware: LEDs, Pushbuttons y Osciladores
;
;Creado: 9 feb, 2021
;Ultima modificacion:  Feb, 2021

PROCESSOR 16F887
#include <xc.inc>

;configuration word 1
    CONFIG FOSC=XT //Oscilador Externo
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
    count1: DS 1; 1 byte
    count2: DS 1
    dec1: DS 1
    dec2: DS 1
    add: DS 1
    
    
PSECT resVect, class=CODE, abs, delta=2
    ;---------vector reset-----------
ORG 00h ;posicion de origen 0000h para el reset
    resetVec:
    PAGESEL main
    goto main

PSECT code, delta=2, abs
 ORG 100h ;posicion para el codigo
 
 ;--------------------configuracion-----------------------:
 
 main:
    
   ;primero tengo que poner los puertos como digitales 
    
   banksel ANSEL ;seleccion banco 3
   clrf ANSEL ;clear para digital A
   clrf ANSELH ;clear digital B
    
   ;definir que puertos son input y output
   ;puerto A es de input (pushbuttons y oscilador) por lo tanto usamos bsf
    
   banksel TRISA
   bsf TRISA, 1  ;definiendo todo TRISA --> PORTA como input
    
   ;puerto B es de output, por lo tanto uso bcf
   ;definiendo puertos individuales
   
   banksel TRISB
   bcf TRISB, 0 ;RB0
   bcf TRISB, 1; RB1
   bcf TRISB, 2; RB2
   bcf TRISB, 3; RB3
   
   ;puerto C es de output tambien
   ;definiendo puerto completo
   banksel TRISC
   bcf TRISC, 0 ;definiendo TRISC --> PORTC como output
   
   ;puerto D es de overflow, output
   ;definiendo unico puerto
   banksel TRISD
   bcf TRISD, 0 ;definiendo TRISD --> PORTD como output
    
   ;limpiando puertos
    
    clrf PORTA
    clrf PORTB
    clrf PORTC
    clrf PORTD

    
loop:
    
    btfss PORTA, 0 ;puerto de botones
    call count1 ;llamamos a la primera subrutina de incremento
    
    btfss PORTA, 1 
    call dec1 ;llamamos a la primera subrutina de decremento
    
    btfss PORTA, 2
    call count2 ;llamamos a la segunda subrutina de incremento
    
    btfss PORTA, 3
    call dec2 ;llamamos a la segunta subrutina de decremento
    
    btfss PORTA, 4
    call add ;llamamos a la subrutina de la suma
    
    goto loop ;repite
    
    ;---------------subrutinas-----------;

count1: ;incremento con pushbutton 1
    

    
dec1: ;decremento con pushbutton 2
    
	

count2: ;incremento con pushbutton 3
    

    
dec2: ;decremento con pushbutton 4
    
  

add: ;sumatoria con pushbutton 5
   
    
    
    END
    

