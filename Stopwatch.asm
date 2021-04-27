S_SEG SEGMENT STACK
DB 256 DUP(?)
S_SEG ENDS
D_SEG SEGMENT
COUNT DB 0 ;Timing unit, the initial value is 0
TENM DB ' 0' ;10 minutes timing unit, initial value is 0
MINUTE DB '0:' ;Time division unit, initial value is 0
TENS DB '0' ;10 second timing unit, initial value is 0
SECOND DB '0.' ;second timing unit, initial value is 0
HAOM DB '0'; 10 millisecond timing unit, the initial value is 0
HAO DB '8','$'; millisecond timing unit, the initial value is 8
D_SEG ENDS
C_SEG SEGMENT
ASSUME CS:C_SEG ,SS:S_SEG
START: MOV AX,D_SEG
MOV DS,AX
CLI; turn off the interrupt first to get INT1CH
MOV AX, 351CH; call 35H system function
INT 21H; return ES: BX = interrupt vector (segment: offset)
PUSH BX; save the original INT1CH interrupt vector in the stack
PUSH ES
STI; open interrupt to make the keyboard work
MOV AH,1; wait for button to be pressed
INT 16H
CLI; turn off interrupt
MOV DX, SEG TIMER; set new interrupt vector
MOV DS,DX
MOV DX,OFFSET TIMER; DS: DX = new interrupt vector (segment: offset)
MOV AX,251CH
INT 21H
STI; Open the interrupt again to make the keyboard and INT1CH work
CHECK: MOV AH ,1; check whether there is a key code
INT 16H
JZ DISPLAY1; if there is no code to read, jump to display (DISPLAY system reserved)]
MOV AH, 0; read it without code
INT 16H
CMP AL, 51H; is it "Q"
JE OVER; Yes, return to DOS
DISPLAY1: MOV AX, D_SEG; No, just display
MOV DS, AX
ASSUME DS: D_SEG
LEA DX, TENM; DS: DX=display string address
MOV AH, 9; display mm: ss.msms
INT 21H
JMP CHECK; return to CHECK, the loop continues
OVER: CLI
POP DS; retrieve the INT1CH original vector from the stack
POP DX
MOV AX, 251CH; set INT1CH, restore the original vector
INT 21H
STI; open interrupt
MOV AX, 4C00H; return to DOS
INT 21H
; The following is the interrupt service subroutine using INT 1CH
TIMER PROC FAR
PUSH AX
MOV AX, D_SEG
MOV DS, AX
ASSUME DS :D_SEG
INC COUNT; Increase the timing unit by 1
CMP COUNT, '2'; No to 110 milliseconds
JL EXIT; If not, return
MOV COUNT, '0'; when it arrives, the timing unit is cleared to 0
INC HAOM; 10 millisecond timing unit increases by 1
CMP HAOM ,'9' ;to 1 second no
JLE EXIT; If not, return
INC SECOND; When it arrives, the second timing unit will increase by 1
MOV HAOM, '0'; 10 millisecond timing unit is cleared to 0
CMP SECOND, '9'; to 10 seconds no
JLE EXIT; If not, return
MOV SECOND, '0'; when it arrives, the second timing unit is cleared to 0
INC TENS; 10 seconds timing unit increases by 1
CMP TENS, '6'; to 60 seconds no
JL EXIT; If not, return
MOV TENS, '0'; to, the 10 second timing unit is cleared to 0
INC MINUTE; cleared to 0 by the time unit
CMP MINUTE, '9'; to 10 points no
JLE EXIT; If not, return
MOV MINUTE, '0'; when it arrives, the sub-timing unit is clear
INC TENM; 10 minutes time unit increases by 1
CMP TENM, '6'; to 60 points no
JL EXIT; If not, return
MOV TENM, '0'; when it arrives, the 10 minute timing unit is cleared to 0, and the timing is restarted
EXIT: POP AX
IRET
TIMER ENDP
C_SEG ENDS
END START



