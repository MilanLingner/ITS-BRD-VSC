Struktur:
    Superloop:
        mit Zustandsabfragen für init, running, hold. diese sind als Unterprogramme zu schreiben
        init: 
            löscht alle leds
            sollte alle relevanten nicht im Setup bewerkstelligten Schritte für Runnig enthalten. Anschließend dauerloop mit abfrage ob S7 gedrückt wurde, bei true: running mode, zurück in den superloop
        running: 
            setzt d8.
            loop mit abfrage s6?, s5? jeweils entweder set mode hold / set mode init und beendigung des Programms in den superloop
            wenn beides falsch: Displywert um aktuellen prescaler wert erhöhen, rückkehr in den lokalenloop.
        hold: 
            löscht d8, setzt d9.
            loop mit abfrage s7? / s5? -> jeweils set mode running/init -> rückkehr superloop


Aufgaben(technisch):
    GUI mit stoppzahlen und interner logik initialisieren (1000 ms = 1s, 60 s = 1m) -> Unterprogramm?
    
