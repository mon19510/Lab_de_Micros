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
void putch(char data);
void text(void);

//--------------------------------- Main ---------------------------------------
void main(void) {
    
    setup();
    
    while(1)
    {
        text();
    }
    
}

void putch(char data)
{
    while(TXIF == 0);
    TXREG = data;
    return;
}

void text(void)
{
    __delay_ms(250);
    printf("\r Elija una opcion: \r");
    
    __delay_ms(250);
    printf(" 1. Desplegar cadena de caracteres \r");
    
    __delay_ms(250);
    printf(" 2. Desplegar PORTA \r ");
    
    __delay_ms(250);
    printf(" 3. Desplegar PORTB \r");
    
    while(RCIF == 0);
    
    if (RCREG == '1')
    {
        __delay_ms(500);
        printf("\r Cadena de caracteres cargando... \r");
       
    }
    if (RCREG == '2')
    {
        printf("\r Insertar caracter para desplegar en PORTA: \r");
        while (RCIF == 0);
        PORTB = RCREG;
    }
    else 
    {
        NULL;
    }
    
    return;
}

void setup (void)
{
    ANSEL = 0;
    ANSELH = 0;
    
    TRISA = 0x0;
    TRISB = 0x0;
    
    PORTA = 0x00;
    PORTB = 0x00;
    
    OSCCONbits.IRCF = 0b0111; //8Mhz
    OSCCONbits.SCS = 1;
    
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
    
    PIR1bits.RCIF = 0;
    PIR1bits.TXIF = 0;
}
