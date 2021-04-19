/*
 * File:   Lab7.c
 * Author: MxMon
 *
 * Created on April 13, 2021, 6:23 PM
 */

// CONFIG1
#pragma config FOSC = INTRC_NOCLKOUT// Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = OFF      // RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = OFF      // Brown Out Reset Selection bits (BOR disabled)
#pragma config IESO = OFF       // Internal External Switchover bit (Internal/External Switchover mode is disabled)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
#pragma config LVP = OFF        // Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits (Write protection off)

//Importando librerias
#include <xc.h>
#include <stdint.h>
//------------------------------ Variables -------------------------------------
//matriz de traduccion
char tablita[10] = {0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110,
0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01101111};
int multiplex; //variable del multiplexado
// variables para divisiones
char centena;
char decena;
char unidad;
char residuo;
char counter; //variable del valor en el puerto
//------------------------- Prototipo de Funcion -------------------------------

void setup(void);
char division(void);

//------------------------- Interrupciones -------------------------------------

void __interrupt() isr(void)
{
    if(T0IF == 1) //verificando bandera tmr0
    {
        PORTAbits.RA2 = 0; //apagando transistor 2
        PORTAbits.RA0 = 1; //prendiendo transistor 0
        PORTD = (tablita[centena]); //ingreso de centenas
        multiplex = 0b00000001; //prendiendo bandera
    
        if(multiplex == 0b00000001) //revisando que bandera este prendida
        {
            PORTAbits.RA0 = 0; //prendo transistor y apago otro
            PORTAbits.RA1 = 1;
            PORTD = (tablita[decena]); //desplegando decenas
            multiplex = 0b00000010; //cambio de lugar la bandera
        }
        if (multiplex == 0b00000010) //revisando que bandera este prendida
        {
            PORTAbits.RA1 = 0; //prendiendo transistor y apagando otro
            PORTAbits.RA2 = 1;
            PORTD = (tablita[unidad]); //moviendo unidades a display
            multiplex = 0b00000000; //apagando banderas
        }
        INTCONbits.T0IF = 0; //limpiando interrupcion tmr
        TMR0 = 255; //valor de reinicio del tmr 0
    }
    if (RBIF == 1) //verificando bandera de interrupcion en puerto b
    {
        if(PORTBbits.RB0 == 0) //oprimiendo boton 1
        {
            PORTC = PORTC + 1; //suma 1 a puerto
        }
        if(PORTBbits.RB1 == 0) // oprimiendo boton 2
        {
            PORTC = PORTC - 1; //resta 1 a puerto
        }
        INTCONbits.RBIF = 0; //limpiando bandera de interrupcion
    }
}
void main(void) {
    
    setup(); //llamando configuracion
    
    while(1) //loop
    {
        division(); //llamando division
    }
    
}

//------------------------ Configuraciones ------------------------------------

void setup(void)
{
    //Desactivando puertos analogicos
    ANSEL = 0x00;
    ANSELH = 0x00;
    
    //Configurando bits de entrada o salida
    TRISAbits.TRISA0 = 0;
    TRISAbits.TRISA1 = 0;
    TRISAbits.TRISA2 = 0;
    TRISBbits.TRISB0 = 1;
    TRISBbits.TRISB1 = 1;
    TRISC = 0x00;
    TRISD = 0x00;
    
    //limpiando puertos
    PORTA = 0x00;
    PORTB = 0x00;
    PORTC = 0x00;
    PORTD = 0x00;
    
    //configurando oscilador interno a 250 kHz
    OSCCONbits.IRCF2 = 0;
    OSCCONbits.IRCF1 = 1;
    OSCCONbits.IRCF0 = 0;
    OSCCONbits.SCS = 1;
    
    //configurando tmr0
    OPTION_REGbits.T0CS = 0;
    OPTION_REGbits.PSA = 0;
    OPTION_REGbits.PS2 = 1;
    OPTION_REGbits.PS1 = 1;
    OPTION_REGbits.PS0 = 1;
    
    //configurando pullup interno
    OPTION_REGbits.nRBPU = 0;
    WPUB = 0b00000011;
    IOCBbits.IOCB0 = 1;
    IOCBbits.IOCB1 = 1;
    
    //configurando interrupciones
    INTCONbits.GIE = 1;
    INTCONbits.RBIF = 1;
    INTCONbits.RBIE = 1;
    INTCONbits.T0IE = 1;
    INTCONbits.T0IF = 0;
     
}

char division(void)
{
    counter = PORTC; //contador igual a puerto c
    centena = counter/100; //dividiendo enteros
    residuo = counter%100; // residuo de division
    decena = residuo/10; //dividiendo en 10 residuo
    unidad = residuo%10; // moviendo residuo a unidades
}
