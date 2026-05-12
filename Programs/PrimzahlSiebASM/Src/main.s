;******************** (C) COPYRIGHT HAW-Hamburg ********************************
;* File Name          : main.s
;* Author             : Silke Behn	
;* Version            : V1.0
;* Date               : 01.06.2021
;* Description        : This is the first try to implement the Sieve of Eratosthenes in ARM assembly.
;					  :
;					  : Replace this main with yours.
;
;*******************************************************************************
    EXTERN initITSboard
    EXTERN lcdPrintS            ;Display ausgabe
    EXTERN GUI_init
;	EXTERN TP_Init

;********************************************
; Data section, aligned on 4-byte boundery
;********************************************
	
	AREA MyData, DATA, align = 2
;hier muss eine Variable für das Siebmuster angelegt werden und mit 1 gefüllt werden.

VariableS FILL 1000, 1, 1		;legt ein Array mit 1000 Einträgen an, die alle mit 1 gefüllt sind.
	

;***********************************************
;* Beginn des Programms *
;************************************************
    AREA |.text|, CODE, READONLY, ALIGN = 3
; ----- S t a r t des Hauptprogramms -----
                EXPORT main
                EXTERN initITSboard
main            PROC
                bl    initITSboard                 ; HW Initialisieren

;Algorithmus für das Sieb des Eratosthenes
			mov r0, #1				;Startwert für die Primzahlsuche -1 für die loop logik
            ldr r2, =VariableS		;Adresse des Siebmusters in r2 laden
loop_outer
            add r0, #1			    ;Zähler erhöhen, damit wir die nächste Zahl prüfen können
            mov r1, #0              ;Zähler (zurück)setzen, damit wir die nächste Zahl prüfen können
    ;erste Bedingung: die Zahl ist kleiner als die Obergrenze (1000)
            cmp r0, #1000         ;Vergleich mit der Obergrenze
            bge loop_end_outer      ;wenn r0 >= 1000, dann Ende der Schleife
    ;zweite Bedingung: der Speicher an der Stelle VariableS[r0] ist eine Primzahl.
            ldrb r3, [r2, r0]		;inhalt der aktuellen Adresse des Siebmusters in r3 laden
            cmp r3, #0			    ;Überprüfen, ob die Zahl als Primzahl markiert ist
            beq loop_outer          ;wenn r3 == 0, dann ist die Zahl keine Primzahl, zurück zum Anfang der Schleife

;in den zweiten Loop:

loop_inner
            add r4, r0, r1          ;Berechnung des nächsten Multiplikators der aktuellen Primzahl
            mul r5, r0, r4          ;Berechnung des nächsten Vielfachen der aktuellen Primzahl
    ;Bedingung: das Vielfache ist kleiner als die Obergrenze (1000)
            cmp r5, #1000         ;Vergleich mit der Obergrenze
            bge loop_outer          ;wenn r5 >= 1000, dann Ende der inneren Schleife und zurück zum Anfang der äußeren Schleife
            mov r6, #0              ;r6 mit 0 belegen, damit wir die Zahl als Nicht-Primzahl markieren können
            strb r6, [r2, r5]       ;Markieren des Vielfachen als Nicht-Primzahl 
            add r1, #1              ;Zähler erhöhen, damit wir die nächste Zahl prüfen können
            b loop_inner          ;zurück zum Anfang der inneren Schleife

loop_end_outer

forever	b	forever		; nowhere to retun if main ends		
		ENDP
	
		ALIGN
       
		END
