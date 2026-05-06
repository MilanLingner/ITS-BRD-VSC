;************************************************
;* Beginn der globalen Daten *
;************************************************
                   AREA MyData, DATA, align = 2
Base
VariableA          DCW 0x1234	;legt halbwort mit label VariableA an.
VariableB          DCW 0x4711	;legt halbwort mit label VariableB an.

VariableC          DCD  0		;legt wort mit label VariableC an. (32 nullen)

MeinHalbwortFeld   DCW 0x22 , 0x3e , -52, 78 , 0x27 , 0x45	;legt ein 6stelliges Array mit halbworten an. 
															;dabei nur 1,2,5,6 in hex die anderen dez

MeinWortFeld       DCD 0x12345678 , 0x9dca5986				;legt ein 6stelliges Array mit Worten an
                   DCD -872415232 , 1308622848              ;diese sind dezimal
                   DCD 0x27000000
                   DCD 0x45000000

MeinTextFeld       DCB "ABab0123",0                         ;legt ein bytearray mit einem String und einem nullbyte an. 
                                                            ;(denke es sollte aber micht komplett funktionieren, da die Zeichen
                                                            ;größer als 1 byte sind?)

                   EXPORT VariableA                         ;Export der Variablen, Frage ist wo die landen.
                   EXPORT VariableB
                   EXPORT VariableC
                   EXPORT MeinHalbwortFeld
                   EXPORT MeinWortFeld
                   EXPORT MeinTextFeld

;***********************************************
;* Beginn des Programms *
;************************************************
    AREA |.text|, CODE, READONLY, ALIGN = 3
; ----- S t a r t des Hauptprogramms -----
                EXPORT main
                EXTERN initITSboard
main            PROC
                bl    initITSboard                 ; HW Initialisieren

; Laden von Konstanten in Register
                ldr   r0,=MeinTextFeld              ; Anw-00    ;belegt r0 mit der Adresse von MeinTextFeld um diese zu ermitteln.
                mov   r0,#0x12                      ; Anw-01    ;belegt r0 mit 0x12 (18 in dezimal)
                mov   r1,#-128                      ; Anw-02    ;belegt r1 mit -128 (dezimal) da negativ (signed) wird er als 32-Bit-Wert interpretiert, der unterläuft und somit nur die niederwertigen 32 Bit des Ergebnisses enthält, also 0xffffff80 in hex.
                ldr   r2,=0x12345678                ; Anw-03    ;belegt r2 mit 0x12345678, da die Zahl größer als 255 ist, muss sie mit ldr geladen werden, da mov nur Werte bis 255 direkt laden kann.

; Zugriff auf Variable
                ldr   r0,=VariableA                 ; Anw-04    ;belegt r0 mit der Adresse beim Label VariableA
                ldrh  r1,[r0]                       ; Anw-05    ;belegt r1 mit dem Inhalt der Adresse von VariableA, also 0x1234.
                ldr   r2,[r0]                       ; Anw-06    ;belegt r2 mit dem Inhalt der Adresse von VariableA, also 0x1234, 
                                                                ;da ldr ein Wort lädt, wird auch das nächste Halbwort (0x4711) mitgeladen.
                str   r2,[r0,#VariableC-VariableA]  ; Anw-07    ;???

; Zugriff auf Felder (Speicherzellen)
                ldr   r0,=MeinHalbwortFeld          ; Anw-08    ;belegt r0 mit der Adresse mit dem LabelMeinHalbwortFeld
                ldrh  r1,[r0]                       ; Anw-09    ;belegt r1 mit dem Inhalt der ersten Adresse von MeinHalbwortFeld, also 0x22.
                ldrh  r2,[r0,#2]                    ; Anw-10    ;belegt r2 mit dem Inhalt der zweiten Adresse von MeinHalbwortFeld, also 0x3e.
                mov   r3,#10                        ; Anw-11    ;belegt r3 mit 10, damit wir die Adresse von MeinHalbwortFeld[5] berechnen können, da jedes Halbwort 2 Byte hat, müssen wir 5*2=10 rechnen.
                ldrh  r4,[r0,r3]                    ; Anw-12    ;belegt r4 mit dem Inhalt der sechsten Adresse von MeinHalbwortFeld, also 0x45. Da r3 mit 10 belegt ist, wird die Adresse von MeinHalbwortFeld[5] berechnet, indem 10 zu der Basisadresse von MeinHalbwortFeld addiert wird.

                ldrh  r5,[r0,#2]!                   ; Anw-13    ;belegt r5 mit dem Inhalt der dritten (+2)Adresse von MeinHalbwortFeld
                ldrh  r6,[r0,#2]!                   ; Anw-14    ;belegt r6 mit dem Inhalt der dritten (+2)Adresse von MeinHalbwortFeld,
                
                
; Addition und Subtraktion von unsigned / signed Integer-Werten
                ldr  r0,=MeinWortFeld               ; Anw-16    ;belegt r0 mit der Adresse von MeinWortFeld
                ldr  r1,[r0]                        ; Anw-17    ;belegt r1 mit dem Inhalt der ersten Adresse neben dem label MeinWortFeld, also 0x12345678.
                ldr  r2,[r0,#4]                     ; Anw-18    ;belegt r2 mit dem Inhalt der vierten Adresse neben dem label MeinWortFeld, also 0x9dca5986.
                adds r3,r1,r2                       ; Anw-19    ;belegt r3 mit der Summe von r1 und r2, also 0x12345678 + 0x9dca5986 = 0xaffeaffe  (mit flags)

                ldr  r4,[r0,#8]                     ; Anw-20    ;belegt r4 mit dem Inhalt der achten Adresse neben dem label MeinWortFeld, also -872415232 (0xcc000000 in hex). 
                ldr  r5,[r0,#12]                    ; Anw-21    ;belegt r5 mit dem Inhalt der zwölften Adresse vneben dem label MeinWortFeld, also 1308622848 (0x4e000000 in hex). 
                subs r6,r4,r5                       ; Anw-22    ;belegt r6 mit der Differenz von r4 und r5.

                ldr  r7,[r0,#16]                    ; Anw-23    ;belegt r7 mit dem Inhalt der sechzehnten Adresse neben dem label MeinWortFeld, also 0x27000000. 
                ldr  r8,[r0,#20]                    ; Anw-24    ;belegt r8 mit dem Inhalt der zwanzigsten Adresse neben dem label MeinWortFeld, also 0x45000000. 
                subs r9,r7,r8                       ; Anw-25    ;belegt r9 mit der Differenz von r7 und r8, also 0x27000000 - 0x45000000 = -483183872 (0xe3000000 in hex). 
                ENDP
                END