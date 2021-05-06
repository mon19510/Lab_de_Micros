/*
 * File:   Lab10.c
 * Author: MxMon
 *
 * Created on May 4, 2021, 5:04 PM
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
#define _XTAL_FREQ 8000000 //definiendo frecuencia del oscilador

//------------------------------ Variables -------------------------------------

const char var = 45;
//------------------------- Prototipo de Funcion -------------------------------

void setup(void);

//---------------------------- Interrupciones ----------------------------------

void __interrupt() isr(void)
{
    //Interrupcion RX y TX
    if(PIR1bits.RCIF == 1)
    {
        PORTB = RCREG;
    }
    if(PIR1bits.TXIF == 1)
    {
        TXREG = var;
    }
    __delay_us(100);
}
//---------------------------------- main --------------------------------------

void main(void) {
    
    setup();
    
    while(1)
    {
        
    }
    
}

void setup(void)
{
//Configurando puertos digitales
    ANSEL = 0;
    ANSELH = 0;
    
// Configurando bits de salida y entrada
    TRISA = 0x0;
    TRISB = 0x0;
    
// Limpiando puertos
    PORTA = 0x00;
    PORTB = 0x00;
    
// Configurando oscilador interno
    OSCCONbits.IRCF = 0b0111; //8Mhz
    OSCCONbits.SCS = 1;
    
// Configurando Interrupciones
    INTCONbits.GIE = 1;
    INTCONbits.PEIE = 1; //periferical interrupt
    PIE1bits.RCIE = 1; // rx interrupt
    PIE1bits.TXIE = 1; //tx interrupt
    
// RECETA TX y RX
    TXSTAbits.SYNC = 0;
    TXSTAbits.BRGH = 1;
    BAUDCTLbits.BRG16 = 1;
    
    SPBRG = 207;
    SPBRGH = 0;
    
    RCSTAbits.SPEN = 1;
    RCSTAbits.RX9 = 0; 
    RCSTAbits.CREN = 1;
    
    TXSTAbits.TXEN = 1;
    
    PIR1bits.RCIF = 0;
    PIR1bits.TXIF = 0;
    
    
}
