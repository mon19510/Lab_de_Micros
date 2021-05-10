///*
// * File:   Lab10.c
// * Author: MxMon
// *
// * Created on May 4, 2021, 5:04 PM
// */
//
//#pragma config FOSC = INTRC_NOCLKOUT// Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
//#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
//#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
//#pragma config MCLRE = OFF      // RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
//#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
//#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
//#pragma config BOREN = OFF      // Brown Out Reset Selection bits (BOR disabled)
//#pragma config IESO = OFF       // Internal External Switchover bit (Internal/External Switchover mode is disabled)
//#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
//#pragma config LVP = OFF        // Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)
//
//// CONFIG2
//#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
//#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits (Write protection off)
//
////Importando librerias
//#include <xc.h>
//#include <stdint.h>
//#define _XTAL_FREQ 8000000 //definiendo frecuencia del oscilador
//
////------------------------------ Variables -------------------------------------
//
//const char var = 45;
////------------------------- Prototipo de Funcion -------------------------------
//
//void setup(void);
//
////---------------------------- Interrupciones ----------------------------------
//
//void __interrupt() isr(void)
//{
//    //Interrupcion RX y TX
//    if(PIR1bits.RCIF == 1)
//    {
//        PORTB = RCREG;
//    }
//    if(PIR1bits.TXIF == 1)
//    {
//        TXREG = var;
//    }
//    __delay_us(100);
//}
////---------------------------------- main --------------------------------------
//
//void main(void) {
//    
//    setup();
//    
//    while(1)
//    {
//        
//    }
//    
//}
//
//void setup(void)
//{
////Configurando puertos digitales
//    ANSEL = 0;
//    ANSELH = 0;
//    
//// Configurando bits de salida y entrada
//    TRISA = 0x0;
//    TRISB = 0x0;
//    
//// Limpiando puertos
//    PORTA = 0x00;
//    PORTB = 0x00;
//    
//// Configurando oscilador interno
//    OSCCONbits.IRCF = 0b0111; //8Mhz
//    OSCCONbits.SCS = 1;
//    
//// Configurando Interrupciones
//    INTCONbits.GIE = 1;
//    INTCONbits.PEIE = 1; //periferical interrupt
//    PIE1bits.RCIE = 1; // rx interrupt
//    PIE1bits.TXIE = 1; //tx interrupt
//    
//// RECETA TX y RX
//    TXSTAbits.SYNC = 0;
//    TXSTAbits.BRGH = 1;
//    BAUDCTLbits.BRG16 = 1;
//    
//    SPBRG = 207;
//    SPBRGH = 0;
//    
//    RCSTAbits.SPEN = 1;
//    RCSTAbits.RX9 = 0; 
//    RCSTAbits.CREN = 1;
//    
//    TXSTAbits.TXEN = 1;
//    
//    PIR1bits.RCIF = 0;
//    PIR1bits.TXIF = 0;
//    
//    
//}

/*
 * File:   Lab10_Parte2.c
 * Author: MxMon
 *
 * Created on May 8, 2021, 9:57 PM
 */

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
#include <stdio.h>
#define _XTAL_FREQ 8000000 //definiendo frecuencia del oscilador

//------------------------------ Variables -------------------------------------


//------------------------- Prototipo de Funcion -------------------------------

void setup(void);
void putch(char data); //funcion para recibir dato
void text(void); //funacion para texto

//--------------------------------- Main ---------------------------------------
void main(void) {
    
    setup(); //lamando configuracion
    
    while(1)
    {
        text(); //funcion de cadenas de caracteres
    }
    
}

void putch(char data)
{
    while(TXIF == 0);
    TXREG = data; //contenido de cadena
    return;
}

//funcion de definicion de cadenas de caracteres
void text(void)
{
    //delays para desplegar opciones
    __delay_ms(250);
    printf("\r Elija una opcion: \r");
    
    __delay_ms(250);
    printf(" 1. Desplegar cadena de caracteres \r");
    
    __delay_ms(250);
    printf(" 2. Desplegar PORTA \r ");
    
    __delay_ms(250);
    printf(" 3. Desplegar PORTB \r");
    
    while(RCIF == 0);
    
    //opciones del menu
    if (RCREG == '1')
    {
        __delay_ms(500);
        printf("\r Cadena de caracteres cargando... \r");
       
    }
    if (RCREG == '2')
    {
        printf("\r Insertar caracter para desplegar en PORTA: \r");
        while (RCIF == 0);
        PORTA = RCREG;
    }
    if (RCREG == '3')
    {
        printf("\r Insertar caracter para desplegar en PORTB: \r");
        while (RCIF == 0);
        PORTB = RCREG;
    }
    else 
    {
        NULL; //opcion si se introduce un caracter no valido
    }
    
    return;
}

void setup (void)
{
    //Confugraion de puertos digitales
    ANSEL = 0;
    ANSELH = 0;
    
    //Configuracion de entradas y salidas
    TRISA = 0x0;
    TRISB = 0x0;
    
    //limpiando puertos
    PORTA = 0x00;
    PORTB = 0x00;
    
    //configuracion oscilador interno 8Mhz
    OSCCONbits.IRCF2 = 1;
    OSCCONbits.IRCF1 = 1;
    OSCCONbits.IRCF0 = 1;
    OSCCONbits.SCS = 1;
    
    //configuracion de TX y RX
    INTCONbits.GIE = 1;
    INTCONbits.PEIE = 1;
    PIE1bits.RCIE = 1;
    PIE1bits.TXIE = 1;
    
    TXSTAbits.SYNC = 0;
    TXSTAbits.BRGH = 1;
    BAUDCTLbits.BRG16 = 1;
    
    SPBRG = 208;
    SPBRGH = 0;
    
    RCSTAbits.SPEN = 1;
    RCSTAbits.RX9 = 0;
    RCSTAbits.CREN = 1;
    
    TXSTAbits.TXEN = 1;
    
    PIR1bits.RCIF = 0; //bandera rx
    PIR1bits.TXIF = 0; //bandera tx
}
