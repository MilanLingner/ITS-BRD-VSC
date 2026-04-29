   
    Im Ausgangspunkt ist 48879 im Speicher dargestellt als: 0xefbe und 4660 als 0x1234
        ldr     R0,=VariableA   
    Anw01 lädt die Adresse (und nicht die variable selbst) von VariableA nach R0.
        ldrb    R2,[R0]          
    Anw02 lädt ein Byte der Adresse die bei R0 hinterlegt ist, nach R2. da 0xefbe ein Halbwort ist (16bit/2Byte) wird nur der erste    Teil der bei der Adresse hinterlegten Variable geladen. da nach little Endian gegangen wird, wird der lsb an der ersten Adresse zu finden sein in unserem Fall 0xef
        ldrb    R3,[R0,#1]       
    Anw03 lädt das Byte an der Adresse + 1 von VariableA in R3 da wir gesehen haben, das an erster stelle lsb 0cef stand wird nun 0xbe, der zweite bestandtteil unseres Ausgangs(halb)worts geladen.
        lsl     R2, #8          ; 
    Anw04 schiebt das Byte in R2 um 8 Positionen nach links wo vorher 0000 0000 1110 1111 im Register stand, steht jetzt 1110 1111 0000 0000
        orr     R2, R3          ; 
    Anw05 1110 1111 0000 0000 or 0000 0000 1011 1110 ergibt 1110 1111 1011 1110 (0xefbe) und speichert es in R2
        strh    R2,[R0]         ; 
    Anw06 speichert den Inhalt von R2 (0xefbe) als Halbwort (16 Bit) an der Adresse von VariableA, überschreibt also den ursprünglichen Wert von VariableA mit 0xefbe. 
                            