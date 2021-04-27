DATA1 EQU 39H Data buffer
DATA2 EQU 40H
DATA3 EQU 41H
SEC EQU 42H ;second save address
MIN EQU 43H ;minute save address
HOUR EQU 44H ;hour save address
SDA BIT P1.0 ;Serial data input \ output
SCL BIT P1.1 ;Serial clock input
ORG 0000H
MOV 30H,#0
MOV 31H,#0
MOV 32H,#10
MOV 33H,#0
MOV 34H,#0
MOV 35H,#10
MOV 36H,#0
MOV 37H,#0
CLR P1.7
MOV R3,#00H ;Initialize the PIC
MOV R4,#00H
MOV DPTR,#TAB
CALL WDATA ;send data to PIC
CALL RDATA ;read data from PIC
; CALL CHUSHI ;Time initialization
;************Timezone***********************
SHIJIAN: CALL READ ;get the time from PIC
Q1: CALL ZH
CALL DISP
JNB P3.0,ANJIAN0 ;minute adjust
JNB P3.1,ANJIAN1 ;hour adjust
JMP SHIJIAN
;***********key dealing code*****************
;***********week setting code*****************
Data segment
Table dw t1,t2.t3,t4,t5,t6,t7;set the address format
T1 db 'MON$';this is Monday on the screen
T2 db 'TUE$';this is Tuesday on the screen
T3 db 'WENN$';this is Wednesday on the screen
T4 db 'THU$';this is Thursday on the screen
T5 db 'FRI$';this is Friday on the screen
T6 db 'SAT$';this is Saturday on the screen
T7 db 'SUN$';this is Sunday on the screen
Data ends
Code segment
assume ds:data,cs:code
Start:
         mov ax,data
         mov ds,ax
         mov ah,08h;Interrupt input numbers 1-7
         int 21h
         sub al.30h; change ascii to number
         dec al; subtract 1, if the input is 1, it means the first position
         shl al,1; multiple with 2, to set the address
         xor ah,ah; empty ah
         mov bx,,ax
         mov dx,[bx];Pass the first address of the output string to dx
         mov ah,09h
         Int 21h
         mov ah,01h
         Int 21h
         mov ah,01h
         Int 21h
         mov ax,4c00h
         Int 21h;code ends
;************minute dealing code*****************
ANJIAN0: CALL DELAY1
JB P3.0,Q1 ;Press the key 1 to call the display
W2: JB P3.0,W1 ;Press the key 2 to add one
CALL DISP ;
JMP W2 ;return to main menu double check
W1: MOV A,MIN
ADD A,#1 ;Press the key 2 to add one in minute
DA A ;Decimal adjustment
CJNE A,#60H,W3
MOV A,#0
W3: MOV R3,#03H ;send the setted time to PIC
MOV R4,A
CALL WDATA
JMP SHIJIAN
;************Time button dealing code***************
ANJIAN1: CALL DELAY1
JB P3.1£¬Q1
W4: JB P3.1,W5
CALL DISP
JMP W4
W5: MOV A,HOUR
ADD A,#1
DA A
CJNE A,#24H,W6
MOV A,#0
W6: MOV R3,#04H
MOV R4,A
CALL WDATA
JMP SHIJIAN
;************send the code to the PIC*******************
;R3=the address the information sent to,R4=the number to be sent
WDATA: CALL RWXT
MOV DATA2,R4
CALL XSZ
CALL STOP
RET
;************read message from PIC*****************
RDATA: CALL RWXT
CALL START
MOV DATA2,#0A1H
CALL XSZ
CALL DSZ
CALL STOP
RET
;************send the information from the equipment address*******************
RWXT: MOV DATA3,R3
CALL START
MOV DATA2,#0A0H
CALL XSZ
MOV DATA2,DATA3
CALL XSZ
RET
;************send the initialized time to PIC*******
/*CHUSHI: MOV DPTR,#TDATA
MOV R5,#3
MOV R0,#00H
CHUSHI1: MOV A,R0
MOVC A,@A+DPTR
MOV R3,A
INC R0
MOV A,R0
MOVC A,@A+DPTR
MOV R4,A
INC R0
CALL WDATA
DJNZ R5,CHUSHI1
RET
TDATA: DB 02H,43H,03H,15H,04H,55H */
;************the screen read the hour minute and second information code**************
READ: MOV R3,#02H
CALL RDATA
MOV SEC,A ;read second
MOV R3,#03H
CALL RDATA
MOV MIN,A ;read minute
MOV R3,#04H
CALL RDATA
MOV HOUR,A
ANL HOUR,#3FH ;read hour

;************write a byte to PIC*********
XSZ: MOV R2,#08H
MOV A,DATA2
XSZ0: RLC A
JNC XSZ1
SETB SDA
JMP XSZ2
XSZ1: CLR SDA
XSZ2: CALL CLOCK_LHL
DJNZ R2,XSZ0
CALL CLOCK_LHL
RET
;************read a byte from PIC*********
DSZ: MOV R2,#08H
DSZ0: SETB SDA
JB SDA,DSZ1
CLR C
SJMP DSZ2
DSZ1: SETB C
DSZ2: RLC A
CALL CLOCK_LHL; the clock function 
DJNZ R2,DSZ0
MOV DATA1,A
CALL CLOCK_LHL
RET
;************start *********************
START: SETB SDA
SETB SCL
NOP
NOP
CLR SDA
NOP
NOP
CLR SCL
RET
;************stio*********************
STOP: CLR SDA
SETB SCL
NOP
SETB SDA
NOP
CLR SCL
RET
;************Shift pulse*********************
CLOCK_LHL: CLR SCL
NOP
SETB SCL
NOP
CLR SCL
NOP
RET
;************Convert hexadecimal to decimal and send it to the display area****
ZH: MOV A,SEC ;Take seconds to store the value
MOV B,#10H ;Convert hexadecimal to decimal
DIV AB
MOV 31H,A ;seconds storage  for  (compressed bcd code)
MOV 30H,B ;seconds storage  
MOV A,MIN
MOV B,#10H
DIV AB
MOV 34H,A
MOV 33H,B
MOV A,HOUR
MOV B,#10H
DIV AB
MOV 37H,A
MOV 38H,B
RET

*******************date display*************
START: MOV AX,0001H          ;Set the display mode to 40*25 color text mode            
       INT 10H
       MOV AX,DATA
       MOV DS,AX
       MOV ES,AX
       MOV BP,OFFSET SPACE       
       MOV DX,0B00H
       MOV CX,1000
       MOV BX,0040H
       MOV AX,1300H
       INT 10H
       MOV BP,OFFSET PATTERN ;Show rectangular bar     
       MOV DX,0B00H
       MOV CX,120
       MOV BX,004EH
       MOV AX,1301H
       INT 10H
       LEA DX,STR            ;
       MOV AH,9
       INT 21H
       MOV AH,1              ;Enter a single character from the keyboard
       INT 21H
       CMP AL,44H            ;AL='D'£¿
       JNE A
       CALL DATE             ;show the date
A:     CMP AL,54H            ;AL='T'£¿
       JNE B                 
       CALL TIME             ;show the time             
B:     CMP AL,51H            ;AL='Q'£¿            
       JNE START
       MOV AH,4CH            ;back to doc condition
       INT 21H
DATE   PROC NEAR             ;Display date subroutine
DISPLAY:MOV AH,2AH           ;show the date
       INT 21H
       MOV SI,0
       MOV AX,CX
       MOV BX,100
       DIV BL
       MOV BL,AH
       CALL BCDASC1         ;The date value is converted into the corresponding ASCII code characte
       MOV AL,BL
       CALL BCDASC1
       INC SI
       MOV AL,DH
       CALL BCDASC1
       INC SI
       MOV AL,DL
       CALL BCDASC1
       MOV BP,OFFSET DBUFFER1
       MOV DX,0C0DH
       MOV CX,20
       MOV BX,004EH
       MOV AX,1301H
       INT 10H
       MOV AH,02H          ;Set cursor position
       MOV DX,0300H
       MOV BH,0
       INT 10H
       MOV BX,0018H
REPEA: MOV CX,0FFFFH       ;time delay
REPEAT:LOOP REPEAT
       DEC BX
       JNZ REPEA
       MOV AH,01H          ;Read keyboard buffer characters to AL register
       INT 16H
       JE  DISPLAY
       JMP START
       MOV AX,4C00H
       INT 21H
       RET
DATE  ENDP
TIME   PROC NEAR        ;Display time subroutine
DISPLAY1:MOV SI,0
       MOV BX,100
       DIV BL
       MOV AH,2CH       ;get the time information
       INT 21H
       MOV AL,CH
       CALL BCDASC      ;
       INC SI
       MOV AL,CL
       CALL BCDASC
       INC SI
       MOV AL,DH
       CALL BCDASC
       MOV BP,OFFSET DBUFFER
       MOV DX,0C0DH
       MOV CX,20
       MOV BX,004EH
       MOV AX,1301H
       INT 10H
       MOV AH,02H
       MOV DX,0300H
       MOV BH,0
       INT 10H
       MOV BX,0018H
RE:    MOV CX,0FFFFH
REA:   LOOP REA
       DEC BX
       JNZ RE
       MOV AH,01H
       INT 16H
       JE  DISPLAY1
       JMP START
       MOV AX,4C00H
       INT 21H
       RET
TIME  ENDP
BCDASC PROC NEAR                ;
       PUSH BX
       CBW
       MOV BL,10; change the date information to decimal expression
       DIV BL
       ADD AL,'0'
       MOV DBUFFER[SI],AL
       INC SI
       ADD AH,'0'
       MOV DBUFFER[SI],AH
       INC SI
       POP BX
       RET
BCDASC ENDP
BCDASC1 PROC NEAR              ;Subroutine for converting date value into ASCII code character
       PUSH BX
       CBW
       MOV BL,10
       DIV BL
       ADD AL,'0'
       MOV DBUFFER1[SI],AL
       INC SI
       ADD AH,'0'
       MOV DBUFFER1[SI],AH
       INC SI
       POP BX
       RET
BCDASC1 ENDP
CODE   ENDS
       END START


;************time display***************************
DISP: MOV DPTR,#TAB
MOV R0,#30H
MOV R1,#0FEH
MOV R2,#08 ;run for 8 times
LOOP: MOV P2,#0FFH ;
MOV A,@R0
MOVC A,@A+DPTR
MOV P0,A
MOV A,R1
RR A
MOV P2,A
MOV R1,A
INC R0
CALL DELAY
DJNZ R2,LOOP
RET
;************time delay program***********
DELAY: MOV 20H,#50
D1: MOV 21H,#20
DJNZ 21H,$
DJNZ 20H,D1
RET
DELAY1: MOV 20H,#250
D2: MOV 21H,#200
DJNZ 21H,$
DJNZ 20H,D2
RET
TAB: DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH,40H
