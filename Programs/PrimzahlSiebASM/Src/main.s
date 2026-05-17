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

VariableS FILL 1000, 1, 1	        ;legt ein Array mit 1000 Einträgen an, die alle mit 1 gefüllt sind.
	

;***********************************************
;* Beginn des Programms *
;************************************************
    AREA |.text|, CODE, READONLY, ALIGN = 3
; ----- S t a r t des Hauptprogramms -----
                EXPORT main
                EXTERN initITSboard
main            PROC
                bl    initITSboard      ; HW Initialisieren

;**************************************************************
;       *Algorithmus für das Sieb des Eratosthenes*
;***************************************************************

	        mov r0, #1		;Startwert für die Primzahlsuche -1 für die loop logik
                ldr r2, =VariableS	;Adresse des Siebmusters in r2 laden
while_1                                 ;while Bedingung: die Zahl ist kleiner als die Wurzel der Obergrenze sqrt(1000) = 31.62 also 32
                cmp r0, #32             ;Vergleich mit der Obergrenze
                bge endwhile_1          ;wenn r0 >= 32, dann Ende der Schleife
do_1
if_1                                    ;if Bedingung: wenn der Speicher an der Stelle VariableS[r0] keine Primzahl ist, dann zurück zum Anfang der Schleife.
                ldrb r3, [r2, r0]	;inhalt der aktuellen Adresse des Siebmusters in r3 laden
                cmp r3, #0		;Überprüfen, ob die Zahl als Primzahl markiert ist
then_1
                beq while_1             ;wenn r3 == 0, dann ist die Zahl keine Primzahl, zurück zum Anfang der Schleife
else_1                                  ;in den zweiten Loop:
                MUL r4, r0, r0          ;Berechnung des Quadrats der aktuellen Primzahl, um die inneren Schleifen zu starten

while_2                                 ;while Bedingung: das nächste Vielfache der aktuellen Primzahl ist kleiner als die Obergrenze (1000)
                cmp r4, #1000             ;Vergleich mit der Obergrenze
                bge endwhile_2              ;wenn r4 >= 1000, dann Ende der inneren Schleife und zurück zum Anfang der äußeren Schleife
do_2
                mov r6, #0                  ;r6 mit 0 belegen, damit wir die Zahl als Nicht-Primzahl markieren können
                strb r6, [r2, r4]           ;Markieren des Vielfachen als Nicht-Primzahl 
                add r4, r4, r0              ;Berechnung des nächsten Multiplikators der aktuellen Primzahl
                b while_2                   ;zurück zum Anfang der inneren Schleife
endwhile_2
            b while_1                   ;zurück zum Anfang der äußeren Schleife

endwhile_1

;*********************************************************************
;       * Ausgabe der Primzahlen *
;*********************************************************************

                mov r0, #0		;r0 mit 0 belegen, damit wir die Primzahlen von 0 bis 999 ausgeben können
                add r2, #1000         ;Adresse des Endes des Siebmusters in r2 laden, damit wir dort die konkreten Werte laden können.
                ldr r3, =VariableS	;Adresse des Siebmusters in r3 laden, damit wir dort die konkreten Werte laden können.
for_1
                cmp r0, #1000          ;Vergleich mit der Obergrenze
                bge endfor_1             ;wenn r0 >= 1000, dann Ende der Schleife
do_3
                ldrb r4, [r3, r0]	;inhalt der aktuellen Adresse des Siebmusters in r4 laden
if_2                                    ;if Bedingung: wenn der Speicher an der Stelle VariableS[r0] eine Primzahl ist, dann Ausgabe der Zahl.
                cmp r4, #1		;Überprüfen, ob die Zahl nicht als Primzahl markiert ist
                bne then_2              ;wenn r4 == 1, dann ist die Zahl eine Primzahl, Ausgabe der Zahl
                strh r0, [r2]           ;die aktuelle Primzahl in die Adresse von r2 (Ende des Siebmusters) speichern, damit wir sie später ausgeben können.
then_2
                b for_1                   ;zurück zum Anfang der Schleife
endfor_1

forever	b	forever		; nowhere to retun if main ends		
		ENDP
	
		ALIGN
       
		END