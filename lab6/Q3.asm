LIST p=18f4520
#include<p18f4520.inc>

    CONFIG OSC = INTIO67 ; Set internal oscillator to 1 MHz
    CONFIG WDT = OFF     ; Disable Watchdog Timer
    CONFIG LVP = OFF     ; Disable Low Voltage Programming

    L1 EQU 0x14         ; Define L1 memory location
    L2 EQU 0x15         ; Define L2 memory location
    org 0x00            ; Set program start address to 0x00
    MOVLW 0x00
    MOVWF 0x00
; instruction frequency = 1 MHz / 4 = 0.25 MHz
; instruction time = 1/0.25 = 4 ?s
; Total_cycles = 2 + (2 + 8 * num1 + 3) * num2 cycles
; num1 = 111, num2 = 70, Total_cycles = 62512 cycles
; Total_delay ~= Total_cycles * instruction time = 0.25 s
DELAY macro num1, num2
    local LOOP1         ; Inner loop
    local LOOP2         ; Outer loop
    
    ; 2 cycles
    MOVLW num2          ; Load num2 into WREG
    MOVWF L2            ; Store WREG value into L2
    
    ; Total_cycles for LOOP2 = 2 cycles
    LOOP2:
    MOVLW num1          
    MOVWF L1  
    
    ; Total_cycles for LOOP1 = 8 cycles
    LOOP1:
    NOP                 ; busy waiting
    NOP
    NOP
    NOP
    NOP
    DECFSZ L1, 1        
    BRA LOOP1           ; BRA instruction spends 2 cycles
    
    ; 3 cycles
    DECFSZ L2, 1        ; Decrement L2, skip if zero
    BRA LOOP2           
endm
    initial:
    
    ; let pin can receive digital signal 
    MOVLW 0x0f
    ;set digital IO
    MOVWF ADCON1      
    ;set RB0 as input TRISB = 0000 0001
    CLRF PORTB
    BSF TRISB, 0
    ;set RA0 as output TRISA = 0000 0000
    CLRF LATA
    ;BSF LATA,3
    BCF TRISA, 0
    BCF TRISA, 1
    BCF TRISA, 2


    check_press_0:          
	BTFSC PORTB, 0
	GOTO  state0
	DELAY d'111', d'70' ; Call delay macro to delay for about 0.25 seconds
	GOTO state1
    
    check_press_1: 
	
	BTFSC PORTB, 0
	GOTO  state1
	DELAY d'111', d'70' ; Call delay macro to delay for about 0.25 seconds
	GOTO state2
    check_press_2:          
	BTFSC PORTB, 0
	GOTO  state2
	DELAY d'111', d'70' ; Call delay macro to delay for about 0.25 seconds
	GOTO state0
    state0:
	MOVFF 0x00,LATA
	GOTO check_press_0
    state1:
	MOVFF 0x00,LATA
	BSF LATA ,0
	RCALL check_click_1
	RCALL check_click_1
	RLNCF LATA
	RCALL check_click_1
	RCALL check_click_1
	RLNCF LATA
	RCALL check_click_1
	RCALL check_click_1
	CLRF LATA
	GOTO  check_press_1
    state2:
	MOVFF 0x00,LATA
	BSF LATA ,0
	RCALL check_click_2
	RCALL check_click_2
	RCALL check_click_2
	RCALL check_click_2
	BSF LATA ,1
	RCALL check_click_2
	RCALL check_click_2
	RCALL check_click_2
	RCALL check_click_2
	CLRF LATA
	;2_3
	BSF LATA ,2
	RCALL check_click_2
	RCALL check_click_2
	BCF LATA ,2
	RCALL check_click_2
	RCALL check_click_2
	BSF LATA ,2
	RCALL check_click_2
	RCALL check_click_2
	BCF LATA ,2
	RCALL check_click_2
	RCALL check_click_2
	BSF LATA ,2
	RCALL check_click_2
	RCALL check_click_2
	MOVFF 0x00,LATA
	GOTO check_press_2
	
    check_click_1:
    DELAY d'111', d'70' ; Call delay macro to delay for about 0.25 seconds
    BTFSC PORTB, 0
    RETURN ;NO click
    DELAY d'111', d'70' ;avoid bouncing problem
    GOTO  state2;click
    
    
    check_click_2:
    DELAY d'111', d'70' ; Call delay macro to delay for about 0.25 seconds
    BTFSC PORTB, 0
    RETURN ;NO click
    DELAY d'111', d'70' ;avoid bouncing problem
    GOTO  state0;click
	
	
    end





