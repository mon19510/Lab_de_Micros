/*
 * File:   Lab9.c
 * Author: MxMon
 *
 * Created on April 27, 2021, 2:59 PM
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

//------------------------- Prototipo de Funcion -------------------------------

void setup(void);

//----------------------------- Interrupcion -----------------------------------

void __interrupt() isr(void)
{
    //interrupcion del ADC

    if(PIR1bits.ADIF == 1)
    {
    
    if(ADCON0bits.CHS == 0)
    {
        CCPR1L = (ADRESH>>1) + 124;
    }
    else
    {
        CCPR2L = (ADRESH>>1)+124;
    }
    PIR1bits.ADIF = 0;
    }
}
void main(void) {
    
    setup();
    //ADCON0bits.GO = 1;
    while(1)
    {
        if(ADCON0bits.GO == 0)
        {
            if (ADCON0bits.CHS == 1)
            {
                ADCON0bits.CHS = 0;
            }
            
            else 
            {
                ADCON0bits.CHS = 1;
            }
            __delay_us(100);
            ADCON0bits.GO = 1;
        }
    }
        
}

void setup(void)
{
    //configuracion entradas y salidas
    ANSEL = 0b00000011;
    ANSELH = 0;
    
    TRISAbits.TRISA0 = 1;
    TRISAbits.TRISA1 = 1;
    
    //limpiando puertos
    PORTA = 0x00;
    PORTC = 0x00;
    
    //configuracion del oscilador
    OSCCONbits.IRCF = 0b0111; //8Mhz
    OSCCONbits.SCS = 1;
    
    //configuracion del ADC
    ADCON1bits.ADFM = 0; //justificacion a la izquierda
    ADCON1bits.VCFG0 = 0; //voltaje ref en VSS y VDD
    ADCON1bits.VCFG1 = 0;
    
    //ADCON0bits.ADCS = 0b10;// clock selection - FOSc/32/
    ADCON0bits.ADCS0 = 1;
    ADCON0bits.ADCS1 = 0;
    ADCON0bits.CHS = 0; //canal 0 prendiendo ADC
    ADCON0bits.ADON = 1;
    __delay_us(50);
    
    //----------------------------Receta del PWM-------------------------------
    
    //configuracion PWM
    TRISCbits.TRISC2 = 1; // desconectado  RC2/CCP1 como entrada
    TRISCbits.TRISC1 = 1;
    
    //senal capaz de controlar los servos
    PR2 = 250; //config del periodo
    CCP1CONbits.P1M = 0; //configurando el modo pwm
    CCP1CONbits.CCP1M = 0b1100;
    CCP2CONbits.CCP2M = 0b1100;
    CCP2CONbits.DC2B0 = 0;
    CCP2CONbits.DC2B1 = 0;

    CCPR1L = 0x0f; //periodo inicial
    CCP1CONbits.DC1B = 0; //bits menos significativos
    CCPR2L = 0x0f;
    
    //inicio del TMR2
    PIR1bits.TMR2IF = 0; //apagando bandera
    T2CONbits.T2CKPS = 0b11; // prescaler 1:16
    T2CONbits.TMR2ON = 1;
    
    while(PIR1bits.TMR2IF == 0); //esperando 1 ciclo trm2
    PIR1bits.TMR2IF = 0;
    
    
    //configuracion de las interrupciones
    PIR1bits.ADIF = 0;
    PIE1bits.ADIE = 1;
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;
    
    //SALIDAS PWM
    TRISCbits.TRISC1 = 0;
    TRISCbits.TRISC2 = 0;

}