;******************** (C) COPYRIGHT HAW-Hamburg ********************************
;* File Name          : main.s
;* Author             : Martin Becke    
;* Version            : V1.0
;* Date               : 01.06.2021
;* Description        : This is a simple main to demonstrate data transfer
;                     : and manipulation.
;                     : 
;
;*******************************************************************************
    EXTERN initITSboard ; Helper to organize the setup of the board

    EXPORT main         ; we need this for the linker - In this context it set the entry point,too

ConstByteA  EQU 0xaffe ; hier wird ConstByteA als Variable mit dem Wert 0xaffe definiert. (10*16**3 + 15*16**2 + 15*16**1 + 14*16**0 = 45054 || 1010 1111 1111 1110)
    
;* We need some data to work on
    AREA DATA, DATA, align=2    
VariableA   DCW 0xbeef ; diese Variablen werden auch im Speicher abgelegt, da sie mit DCW definiert wurden. (11*16**3 + 14*16**2 + 14*16**1 + 15*16**0 = 48879 || 1011 1110 1110 1111)
VariableB   DCW 0x1234 ; (1*16**3 + 2*16**2 + 3*16**1 + 4*16**0 = 4660 || 0001 0010 0011 0100)
VariableC   DCW 0xaffe ; (10*16**3 + 15*16**2 + 15*16**1 + 14*16**0 = 45054 || 1010 1111 1111 1110)
VariableD   DCW 0x0000 ; (0*16**3 + 0*16**2 + 0*16**1 + 0*16**0 = 0 = 0 || 0000 0000 0000 0000)

;* We need minimal memory setup of InRootSection placed in Code Section 
    AREA  |.text|, CODE, READONLY, ALIGN = 3    ; Ka. was das heißt
    ALIGN   
main
    BL initITSboard             ; needed by the board to setup
;* swap memory - Is there another, at least optimized approach?
    ldr     R0,=VariableA   ; Anw01 lädt die ADRESSE von VariableA into R0
    ldrb    R2,[R0]         ; Anw02 load byte at address in R0 into R2 (0xef) - da ldrb nur 1 Byte lädt, wird nur das niederwertigste Byte von VariableA geladen (ef nicht be)
    ldrb    R3,[R0,#1]      ; Anw03 lädt das nächste Byte an der Adresse von VariableA in R3 (0xbe) 
    lsl     R2, #8          ; Anw04 schiebt das Byte in R2 um 8 Positionen nach links vorher 1110 1111 danach 1110 1111 0000 0000
    orr     R2, R3          ; Anw05 1110 1111 0000 0000 or 0000 0000 1011 1110 ergibt 1110 1111 1011 1110 (0xefbe) und speichert es in R2
    strh    R2,[R0]         ; Anw06 speichert den Inhalt von R2 (0xefbe) als Halbwort (16 Bit) an der Adresse von VariableA, überschreibt also den ursprünglichen Wert von VariableA mit 0xbeef. 
                            ; 
;* const in var
    ;mov     R5,#ConstByteA  ; Anw07 lädt den Wert von ConstByteA (0xaffe) in R5. Da ConstByteA als Konstante definiert ist, wird der Wert direkt in den Register geladen, ohne dass er aus dem Speicher gelesen werden muss.
    ;strh    R5,[R0]         ; Anw08 speichert den Inhalt von R5 (0xaffe) als Halbwort (16 Bit) an der Adresse von VariableA, überschreibt also den ursprünglichen Wert von VariableA mit 0xaffe. Da VariableA zuvor 0xefbe war, wird der Wert jetzt auf 0xaffe geändert.
;Lösungsweg 1: mit ldrb und lsl:
    ldr      R5,=VariableC   ; AnwM01 lädt die ADRESSE von VariableC in R5
    ldrb     R6,[R5]         ; AnwM02 lädt das Byte an der Adresse von VariableD in R6, also den Wert 0x00. R6 enthält jetzt 0x00.
    lsl      R6, #8          ; AnwM03 schiebt das Byte in R6 um 8 Positionen nach links, vorher 0000 0000 danach 0000 0000 0000 0000
    ldrb     R7,[R5,#1]      ; AnwM04 lädt das nächste Byte an der Adresse von VariableD in R7, also den Wert 0x00. R7 enthält jetzt 0x00.
    orr      R6, R7          ; AnwM05 
    strh     R6,[R5]         ; AnwM06 speichert den Inhalt von R6 (0x0000) als Halbwort (16 Bit) an der Adresse von VariableA, überschreibt also den ursprünglichen Wert von VariableA mit 0x0000. Da VariableA zuvor 0xaffe war, wird der Wert jetzt auf 0x0000 geändert.
;lösungsweg 2: mit mov und add:
    ldr     R8,=VariableD   ; AnwM07 lädt die ADRESSE von VariableD in R8 (wäre das strh am ende auch möglich ohne eine konkrete Adresse zu nennen?)
    mov     R9,#ConstByteA  ; AnwM08 lädt den Wert von ConstByteA (0xaffe) in R9. Da ConstByteA als Konstante definiert ist, wird der Wert direkt in den Register geladen, ohne dass er aus dem Speicher gelesen werden muss.
    mov     R10,#0x4eb1     ; AnwM09 lädt den Wert 0x4eb1 in R10. 
    add     R9, R9, R10     ; AnwMA addiert den Wert in R10 zu dem Wert in R9 und speichert das Ergebnis in R9. 0xaffe + 0x4eb1
    strh    R9,[R8]         ; AnwMB speichert den Inhalt von R9 (0x4eb1 + 0xaffe = 0x5f2b) als Halbwort (16 Bit) an der Adresse von VariableD, überschreibt also den ursprünglichen Wert von VariableD mit 0x5f2b. Da VariableD zuvor 0x0000 war, wird der Wert jetzt auf 0x5f2b geändert.


;* Change value from x1234 to x4321
    ldr     R1,=VariableB    ;Anw09 lädt die ADRESSE von VariableB in R1
    ldrh    R6,[R1]          ;Anw0A lädt das Halbwort (16 Bit) an der Adresse von VariableB in R6, also den Wert 0x1234. R6 enthält jetzt 0x1234.
    mov     R7, #0x30ED      ;Anw0B lädt den Wert 0x30ED in R7. 
    add     R6, R6, R7       ;Anw0C addiert den Wert in R7 (0x30ED) zu dem Wert in R6 (0x1234) und speichert das Ergebnis in R6. D+4 = 17, (gesch. als 0x11) 3+E = 17 (gesch. als 0x110), 2+0 = 2 (gesch. als 0x200), 1+3 = 4 ergibt 0x4 (gesch als 0x4000) also 0x4321
; vom bisherigen wissensstand die einfachste lösung (plus sehr viel mit Copy und Paste machbar):
    ldr     R1,=VariableB   ; AnwMC lädt die ADRESSE von VariableB in R1
    ldrh    R6,[R1]         ; AnwMD lädt das Halbwort (16 Bit) an der Adresse von VariableB in R6, also den Wert 0x1234. R6 enthält jetzt 0x1234.
    mov     R7, #0x21de     ; AnwME lädt den Wert 0x21de in R7. 
    add     R6, R6, R7      ; AnwMF addiert den Wert in R7 (0x21de) zu dem Wert in R6 (0x1234) und speichert das Ergebnis in R6. 
    strh    R6,[R1]         ; AnwM10 speichert den Inhalt von R6 (0x21de + 0x1234 = 0x3412) als Halbwort (16 Bit) an der Adresse von VariableB, überschreibt also den ursprünglichen Wert von VariableB mit 0x4321. Da VariableB zuvor 0x1234 war, wird der Wert jetzt auf 0x4321 geändert.

    b .                     ; Anw0E endlosschleife, damit das Programm nicht weiterläuft und möglicherweise unerwünschte Effekte hat.
    
    ALIGN
    END