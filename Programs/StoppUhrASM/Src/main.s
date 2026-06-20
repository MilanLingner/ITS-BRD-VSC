;******************** (C) COPYRIGHT HAW-Hamburg ********************************
;* File Name          : main.s
;* Author             : Franz Korf	
;* Version            : V1.0
;* Date               : 11.05.2022
;* Description        : Rahmen zur Loesung von GTP Woche 7-9 (Stoppuhr).
;
;*******************************************************************************

; Define address of selected GPIO and Timer registers
PERIPH_BASE     	equ	0x40000000                 ;Peripheral base address
AHB1PERIPH_BASE 	equ	(PERIPH_BASE + 0x00020000)
APB1PERIPH_BASE     equ PERIPH_BASE

GPIOD_BASE			equ	(AHB1PERIPH_BASE + 0x0C00)
GPIOF_BASE			equ	(AHB1PERIPH_BASE + 0x1400)
TIM2_BASE           equ (APB1PERIPH_BASE + 0x0000)
	
GPIO_F_PIN        	equ	(GPIOF_BASE + 0x10)

GPIO_D_PIN			equ	(GPIOD_BASE + 0x10)
GPIO_D_SET			equ (GPIOD_BASE + 0x18)
GPIO_D_CLR			equ	(GPIOD_BASE + 0x1A)
	
TIMER				equ (TIM2_BASE + 0x24)   ; CNT : current time stamp (32 bit),  resolution
TIM2_PSC			equ (TIM2_BASE + 0x28)   ; Prescaler  resolution
TIM2_ERG			equ (TIM2_BASE + 0x14)   ; 16 Bit register, Bit 0 : 1 Restart Timer
	


    EXTERN initITSboard
    EXTERN GUI_init
	EXTERN TP_Init
	EXTERN initTimer
	EXTERN lcdSetFont
	EXTERN lcdGotoXY      		; TFT goto x y function
	EXTERN lcdPrintS			; TFT output function	
    EXTERN lcdPrintC            ; TFT output one character		
	EXTERN Delay				; Delay (ms) function


;********************************************
; Data section, aligned on 4-byte boundery
;********************************************
	AREA MyData, DATA, align = 2

DEFAULT_BRIGHTNESS	DCW     800
MY_TEXT				DCB		"00:00.00", 0
TimeDiv				DCD		60000000,6000000,1000000,100000,10000,1000,0
Zustand				DCB		0
TIMER_OLD		    DCB 	"11/11/11", 0
TIMER_AT		    DCB 	"00:00.00", 0
;********************************************
; Code section, aligned on 8-byte boundery
;********************************************
	AREA |.text|, CODE, READONLY, ALIGN = 3


;--------------------------------------------
; main subroutine
;--------------------------------------------
	EXPORT main [CODE]
	
main	PROC

		; Initialisierung der HW
		BL		initITSboard
		ldr   	r0, =DEFAULT_BRIGHTNESS
		ldrh 	r0, [r0]
		bl   	GUI_init
		bl  	initTimer
		ldr 	r0,=TIM2_PSC   	; Set pre scaler such that 1 timer tick represents 10 us
		mov 	r1,#(90*10-1) 	
		strh	r1,[r0]
		ldr 	r0,=TIM2_ERG   			; Restart timer	
		mov		r1,#0x01
		strh	r1,[r0]					; Set UG Bit
		MOV 	r0, #24
		bl  	lcdSetFont

superloop
	;load_Zustand
		ldr 	r4,=Zustand
		ldrb	r4,[r4]
	;check buttons
		ldr		r1,=GPIO_F_PIN
		ldrh	r1,[r1]
		and		r1,#0xFF
		eor		r1,r1,#0xFF
	;do Zustand
if_init
		cmp		r4,#0
		bne		if_init_end
then_init	
		bl		init
if_init_end

if_running
		cmp		r4,#1
		bne		if_running_end
then_running
		bl		running
if_running_end
		;hold?
if_hold
		cmp		r4,#2
		bne		if_hold_end
then_hold
		bl		hold
if_hold_end
		BAL		superloop				; End of superloop


;----------------------init----------------------

init
	push	{lr}
if_i
	and		r4,r1,#0x80
	cmp		r4,#0x80
	bne		if_i_end
then_i
	mov		R0,#1
	ldr		R6,=Zustand
	strb	R0,[R6]					; Zustand = 1 (running)
	mov		r0, #1
	ldr		r6,=TIM2_ERG			
	strb	R0,[R6]	
if_i_end
	; Print zeit
	ldr 	r0,=MY_TEXT
	bl 		print
	pop		{lr}
	BX		lr

;----------------------running----------------------

running
	push	{lr}
if_r_hold
	and		r4,r1,#0x40
	cmp		r4,#0x40
	bne		elif_r_init
then_r_hold
	mov		R0,#2
	ldr		R6,=Zustand
	strb	R0,[R6]				; Zustand = 2 (hold)
	b 		if_r_end
elif_r_init
	and		r4,r1,#0x20
	cmp		r4,#0x20
	bne		if_r_end
then_r_init
	mov		R0,#0
	ldr		R6,=Zustand
	strb	R0,[R6]				; Zustand = 0 (init)
if_r_end
	; Print zeit
	bl calTime
	bl print
	pop		{lr}
	BX		lr

;----------------------hold----------------------

hold
	push	{lr}
if_h_running
	and		r4,r1,#0x80
	cmp		r4,#0x80
	bne		elif_h_init
then_h_running
	mov		R0,#1
	ldr		R6,=Zustand
	strb	R0,[R6]				; Zustand = 1 (running)
	bl	if_h_end
elif_h_init
	and		r4,r1,#0x20
	cmp		r4,#0x20
	bne		if_h_end
then_h_init
	mov		R5,#0
	ldr		R6,=Zustand
	strb	R5,[R6]				; Zustand = 0 (init)
if_h_end
	pop		{lr}
	BX		lr
	
;----------------------calTime----------------------

calTime
	push	{lr}
	ldr		r4,=TIMER
	ldr		r4,[r4]				; Aktueller Timerstand in r4
	ldr		r7,=TimeDiv			; Array mit den Timerständen
	ldr 	r3,=TIMER_AT		
	mov 	r5, #0
for_calTime
	ldr		r1,[r7],#4			; Lade nächsten Divisor in r1 und inkrementiere die Adresse um 4
	cmp		r1, #0
	beq		endfor_calTime
do_calTime
	mov 	r0, r4
	bl 		div					; r0 = r4 / r1
	mov		r4, r0
	mov 	r0,#0x30			; ASCII '0'
	add 	r0, r0, r1			; Konvertiere die Ziffer in ASCII
	add		r6, r3, r5			; Berechne die Adresse für die aktuelle Ziffer
	strb	r0,[r6]				; Speichere die ASCII-Ziffer in TIMER_AT und inkrementiere die Adresse um 1
	add		r5, #1
if_calTime_2
	cmp		r5, #2				; Nach 2 Ziffern (Minuten) soll ein ':' ausgegeben werden
	bne		elif_calTime_5
then_calTime
	add		r5, #1
elif_calTime_5
	cmp		r5, #5				; Nach 5 Ziffern (Sekunden) soll ein '.' ausgegeben werden
	bne		if_calTime_end
then_calTime_5
	add		r5, #1
if_calTime_end
	bl 		for_calTime
endfor_calTime
	ldr		r0,=TIMER_AT
	pop		{lr}
	BX		lr

;-----------------------div----------------------

div
	push {lr}
	mov r2, #0
for_div
	cmp r0, r1
	blt endfor_div
do_div
	sub r0, r0, r1
	add r2, #1
	b for_div
endfor_div
	mov r1, r2
	pop {lr}
	BX lr

;----------------------print----------------------

print
	push	{lr}
	mov		r4, r0
	ldr 	r5,=TIMER_OLD
	mov 	r6, #1
	mov 	r7, #1
	mov 	r0,r6
	mov 	r1,r7
	bl 		lcdGotoXY
while_print
	ldrb 	r0, [r4],#1			; Lade aktuelle Ziffer in r0
	cmp 	r0, #0				; Vergleich auf Ende String
	beq 	end_while_print
do_while_print
	ldrb 	r3, [r5]			; Lade alte Ziffer in r3
if_print
	cmp 	r0, r3
	beq 	endif_print
then_print
	strb	r0, [r5]	
	bl lcdPrintC			; Ausgabe der Ziffer
endif_print
	add	r5,#1
	add r6,#1
	mov r0,r6
	mov r1,r7
	bl lcdGotoXY
	b while_print
end_while_print
	pop {lr}
	bx	lr
	


	



		; switch LEDs off (button s<i> not pressed : LED D<î+8> switched off (for 0 <= i <= 7)
		LDR		r4,=GPIO_D_CLR
		str		r4,[r4]
		
		; switch LEDs on (button s<i>      pressed : LED D<î+8> switched on  (for 0 <= i <= 7)
		eor		r4,r4,#0xFF       ; toogle bit 0 to 7 of r4
		LDR		r4,=GPIO_D_SET
		str		r4,[r4]	
	
		ENDP

		ALIGN
		END
