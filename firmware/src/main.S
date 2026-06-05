#define __SFR_OFFSET 0
#include <avr/io.h>

// loading values
#define val r16        
// sensor values
#define sensors r17    

// bit0 bay, bit1 speed mod, bit2 lost
#define robotState r18 

#define timerL r24      
#define timerH r25      
#define lastMarkerL r2  
#define lastMarkerH r3  

// robot lost the line
#define lostTimerL r8   
#define lostTimerH r9   

#define leftBase r4   
#define rightBase r5  
#define turnFast r6    
#define turnSlow r7    

.global INT1_vect
INT1_vect:
BAY_ISR:
    sbr robotState, (1<<0)
    reti                   

.global main
main:
SETUP:
    ldi val, hi8(RAMEND)
    out SPH, val
    ldi val, lo8(RAMEND)
    out SPL, val

    clr robotState
    clr timerL
    clr timerH
    clr lastMarkerL
    clr lastMarkerH
    clr lostTimerL
    clr lostTimerH

    rcall LOAD_NORMAL_SPEEDS

    cbi DDRC, 0          
    cbi DDRC, 1          
    cbi DDRD, 3          

    sbi DDRB, 0          
    sbi DDRB, 1          
    sbi DDRB, 2          
    sbi DDRD, 7          
    sbi DDRD, 6          
    sbi DDRD, 5          

    ldi val, (1<<COM0B1) | (1<<WGM01) | (1<<WGM00)
    out TCCR0A, val
    ldi val, (1<<CS01) | (1<<CS00) 
    out TCCR0B, val

    ldi val, (1<<COM1B1) | (1<<WGM10)
    sts TCCR1A, val
    ldi val, (1<<WGM12) | (1<<CS11) | (1<<CS10) 
    sts TCCR1B, val

    lds val, EICRA
    ori val, (1<<ISC11) | (1<<ISC10) 
    sts EICRA, val
    in val, EIMSK
    ori val, (1<<INT1)    
    out EIMSK, val
    sei                  

MAIN:
    adiw timerL, 1      

    sbrc robotState, 0   
    rcall CHECK_PARK

    in sensors, PINC      
    andi sensors, 0x03   

    cpi sensors, 0x00    
    breq LOST_LOGIC

    cbr robotState, (1<<2)

    cpi sensors, 0x03    
    breq MARKER_DETECTED

    cpi sensors, 0x01    
    breq GO_LEFT

    cpi sensors, 0x02    
    breq GO_RIGHT

    rjmp MAIN_END

GO_LEFT:
    rcall TURN_LEFT
    rjmp MAIN_END

GO_RIGHT:
    rcall TURN_RIGHT
    rjmp MAIN_END

LOST_LOGIC:
    sbrc robotState, 1       
    rjmp CONTINUE_LOST       

    sbrc robotState, 2       
    rjmp CHECK_LOST_TIME     

    sbr robotState, (1<<2)   
    mov lostTimerL, timerL   
    mov lostTimerH, timerH
    rcall FWD                
    rjmp MAIN_END

CHECK_LOST_TIME:
    mov r20, timerL
    mov r21, timerH
    sub r20, lostTimerL      
    sbc r21, lostTimerH

    cpi r21, 11              
    brlo CONTINUE_LOST       
    brne STOP_DEAD           
    
    cpi r20, 184             
    brsh STOP_DEAD           

CONTINUE_LOST:
    rcall FWD                
    rjmp MAIN_END

STOP_DEAD:
    rcall STOP_MOTORS
FREEZE:
    rjmp FREEZE              

MARKER_DETECTED:
    mov r20, timerL
    mov r21, timerH
    sub r20, lastMarkerL
    sbc r21, lastMarkerH

    cpi r21, hi8(150)        
    brlo MAIN_END        

    mov lastMarkerL, timerL
    mov lastMarkerH, timerH

    cpi r21, hi8(600)        
    brsh SET_SLOW        

SET_NORMAL:
    cbr robotState, (1<<1)   
    rcall LOAD_NORMAL_SPEEDS
    rjmp EXECUTE_MARKER

SET_SLOW:
    sbr robotState, (1<<1)   
    rcall LOAD_SLOW_SPEEDS

EXECUTE_MARKER:
    rcall FWD
    rcall DELAY_150MS        
    rjmp MAIN_END

MAIN_END:
    rcall DELAY_1MS          
    rjmp MAIN

CHECK_PARK:
    cbr robotState, (1<<0)   
    sbrc robotState, 1       
    rcall PARK_SEQUENCE      
    ret                      

LOAD_NORMAL_SPEEDS:
    ldi val, 55
    mov leftBase, val
    ldi val, 52
    mov rightBase, val
    ldi val, 80
    mov turnFast, val
    ldi val, 35
    mov turnSlow, val
    ret

LOAD_SLOW_SPEEDS:
    ldi val, 30
    mov leftBase, val
    ldi val, 32
    mov rightBase, val
    ldi val, 60
    mov turnFast, val
    ldi val, 25
    mov turnSlow, val
    ret

FWD:
    sbi PORTB, 0
    cbi PORTB, 1
    sbi PORTD, 7
    cbi PORTD, 6
    sts OCR1BL, leftBase  
    out OCR0B, rightBase   
    ret

TURN_LEFT:
    sbi PORTB, 0
    cbi PORTB, 1
    sbi PORTD, 7
    cbi PORTD, 6
    sts OCR1BL, turnSlow  
    out OCR0B, turnFast   
    ret

TURN_RIGHT:
    sbi PORTB, 0
    cbi PORTB, 1
    sbi PORTD, 7
    cbi PORTD, 6
    sts OCR1BL, turnFast  
    out OCR0B, turnSlow   
    ret

STOP_MOTORS:
    ldi val, 0
    sts OCR1BL, val 
    out OCR0B, val  
    ret

PARK_SEQUENCE:
    rcall FWD
    ldi val, 50
    sts OCR1BL, val
    ldi val, 52
    out OCR0B, val
    rcall DELAY_500MS
    rcall STOP_MOTORS
    rcall DELAY_200MS

    cbi PORTB, 0         
    sbi PORTB, 1
    sbi PORTD, 7         
    cbi PORTD, 6
    ldi val, 70
    sts OCR1BL, val
    out OCR0B, val
    rcall DELAY_500MS    
    rcall STOP_MOTORS
    rcall DELAY_200MS

    cbi PORTB, 0         
    sbi PORTB, 1
    cbi PORTD, 7         
    sbi PORTD, 6
    ldi val, 41
    sts OCR1BL, val
    ldi val, 40
    out OCR0B, val
    
    rcall DELAY_500MS
    rcall DELAY_500MS
    rcall DELAY_500MS
    rcall DELAY_500MS
    rcall DELAY_500MS
    
    rcall STOP_MOTORS
FOREVER_STOP:
    rjmp FOREVER_STOP

DELAY_1MS:
    ldi r20, 16
Outer1:
    ldi r21, 250
Inner1:
    nop
    dec r21
    brne Inner1
    dec r20
    brne Outer1
    ret

DELAY_150MS:
    ldi r22, 150
D150_Loop:
    rcall DELAY_1MS
    dec r22
    brne D150_Loop
    ret

DELAY_200MS:
    ldi r22, 200
D200_Loop:
    rcall DELAY_1MS
    dec r22
    brne D200_Loop
    ret

DELAY_500MS:
    ldi r22, 250
D500_Loop1:
    rcall DELAY_1MS
    dec r22
    brne D500_Loop1
    ldi r22, 250
D500_Loop2:
    rcall DELAY_1MS
    dec r22
    brne D500_Loop2
    ret