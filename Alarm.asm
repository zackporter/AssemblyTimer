ORG 0000H
                  LJMP MAIN
                  ORG 000BH
                  LJMP TIME

          ;¡Á¡Á¡Á¡Á¡Á main program part: ¡Á¡Á¡Á¡Á¡Á
                  ORG 0100H
                  MAIN:MOV SP,#50H
                  MOV 21H,#00H ;Minute¡¡BIN
                  MOV 22H,#00H ;Hour¡¡BIN
                  MOV 23H,#01H
                  MOV 24H,#01H
                  MOV 25H,#00H
                  MOV 30H,#00H
                  MOV 31H,#00H
                  MOV 32H,#00H
                  MOV 33H,#00H
                  MOV 34H,#00H
                  MOV 35H,#00H
                  MOV 36H,#01H
                  MOV 37H,#00H
                  MOV 38H,#01H
                  MOV 39H,#00H
                  MOV TMOD, #01H; 16-bit counter
                  MOV TH0, #03CH; Assign initial value of count
                  MOV TL0,#0B0H
                  MOV IE,#10000111B
                  SETB TR0; T0 starts counting
              MOV R2,#14H
              MOV P2,#0FFH
            LOOP: LCALL TIMEPRO
                  LCALL DISPLAY1
                  JB P1.1,M1
                  LCALL SETTIME; call set time program
                  LJMP LOOP
            M1: JB P1.2, M2
                  LCALL SETATIME; call set time program
                  LJMP LOOP
               M2: JB P1.4, M4
                  LCALL LOOKATIME; call to set the alarm time program
           M4: LJMP LOOP
            DELAY:MOV R4,#030H ;delay time
            DL00:MOV R5,#0FFH
            DL11:MOV R6,#9H
            DL12: DJNZ R6, DL12
                 DJNZ R5,DL11
                 DJNZ R4,DL00
                      RET
       ;¡Á¡Á¡Á¡Á¡ÁSet time program:¡Á¡Á¡Á¡Á¡Á
SETTIME:
L0: LCALL DISPLAY1; call time allows the program
        MM1: JB P1.2,L1
                MOV C,P1.2
                JC MM1
                LCALL DELAY1; call delay
                JC MM1
     MSTOP1: MOV C,P1.2
                JNC MSTOP1; Judge whether P1.2 is released? Release to continue
                LCALL DELAY1; call delay
                MOV C,P1.2
                JNC MSTOP1
                 INC 22H; hour increase by 1
                  MOV A,22H
                  CJNE A, #18H, GO12; Determine whether the hour is up to 24 o'clock? Not to continue loop
                  MOV 22H, #00H; hour reset
                  MOV 34H,#00H
                  MOV 35H,#00H
                  LJMP L0
               L1: JB P1.3, L2
                  MOV C,P1.3
                  JC L1
                  LCALL DELAY1; delay
                  JC L1
        MSTOP2: MOV C,P1.3
                  JNC MSTOP2; Judge whether P1.3 is released? Release to continue
                  LCALL DELAY1; call delay
                  MOV C,P1.3
                  JNC MSTOP2
                  INC 21H; Increase by one minute
                  MOV A,21H
                  CJNE A,#3CH,GO11
                  MOV 21H,#00H ;Minute reset
                  MOV 32H,#00H
                  MOV 33H,#00H
                  LJMP L0
            GO11:MOV B,#0AH; Divide the content in A into high and low parts
                 DIV AB
                 MOV 32H,B
                 MOV 33H,A
                 LJMP L0

            GO12: MOV B,#0AH
                 DIV AB
                 MOV 34H,B
                 MOV 35H,A
                 LJMP L0
              L2: JB P1.4, L0
                 MOV C,P1.4
                 JC L2
                 LCALL DELAY1; call delay
                 MOV C,P1.4
                 JC L2
        STOP1: MOV C, P1.4; Determine whether the button P1.4 is released?
                 JNC STOP1
                 LCALL DELAY1; call delay
                 MOV C,P1.4
                 JNC STOP1
                 LJMP LOOP

        ;¡Á¡Á¡Á¡Á¡ÁSet the alarm time¡Á¡Á¡Á¡Á¡Á

         SETATIME:LCALL DISPLAY2; run at call time
               N0:LCALL DISPLAY2
         MM2: JB P1.3, N1; Judge whether P1.3 is pressed?

                  MOV C,P1.3
                  JC MM2
                  LCALL DELAY1
                  JC MM2
        MSTOP3: MOV C, P1.3; Determine whether P1.3 is released?
                  JNC MSTOP3
                  LCALL DELAY1
                  MOV C,P1.3
                  JNC MSTOP3
                  INC 24H; set hour increase by 1
                  MOV A,24H
                  CJNE A,#24,GO22
                  MOV 24H, #00H; clock reset
                  MOV 38H,#00H
                  MOV 39H,#00H
                  LJMP N0
               N1: JB P1.1, N2; Judge whether P1.1 is pressed?

                  MOV C,P1.1
                  JC N1
                  LCALL DELAY1
                  JC N1
        MSTOP4: MOV C, P1.1; Determine whether P1.1 is released?
                  JNC MSTOP4
                  LCALL DELAY1
                  MOV C,P1.1
                  JNC MSTOP4
                  INC 23H; Set the alarm minute to increase by 1
                  MOV A,23H
                  CJNE A, #60, GO21; Determine whether A reaches 60 points?
                  MOV 23H,#00H ;Minute reset
                  MOV 36H,#00H
MOV 37H,#00H
                  LJMP N0
            GO21:MOV B,#0AH; Divide the content in A into high and low parts
                 DIV AB
                 MOV 36H,B
                 MOV 37H,A
                 LJMP N0

            GO22: MOV B,#0AH
                 DIV AB
                 MOV 38H,B
                 MOV 39H,A
                 LJMP N0
              N2: JB P1.4, N0; Judge whether P1.4 is pressed?
                 MOV C,P1.4
                 JC N2
                 LCALL DELAY1
                 MOV C,P1.4
                 JC N2
        STOP2: MOV C, P1.4; Determine whether P1.4 is released?
                 JNC STOP2
                 LCALL DELAY1
                 MOV C,P1.4
                 JNC STOP2
                 LJMP LOOP

         TIMEPRO:MOV A,21H
                    MOV B,23H
                    CJNE A, B, BK; Judge whether the minute runs to the minute of the set alarm?
                    MOV A,22H
                    MOV B,24H
                    CJNE A, B, BK; Determine whether the clock is running to the set alarm clock?
                    SETB 25H.0
                    MOV C,25H.0
                    JC XX
                 XX: LCALL TIMEOUT; call the time alarm response program
              BK:RET
           TIMEOUT:

                 X1: LCALL BZ; call the speaker response program
                    LCALL DISPLAY2
                    CLR 25H.0
                    JB P1.4, X1; Judge whether P1.4 is pressed?
                   LCALL DELAY
                   CLR 25H.0
                   LJMP DISPLAY1
              BZ: CLR P3.7; speaker response program
                  MOV R7, #250; Response delay time
               T2: MOV R6,#124
               T3: DJNZ R6, T3

                    DJNZ R7, T2
                    SETB P3.7
                    RET
            LOOKATIME:LCALL DISPLAY2; call time to run the program
         MM: JB P1.4, LOOKATIME; Judge whether the button P1.4 is pressed
                 MOV C,P1.4
                 JC MM
                 LCALL DELAY1
                 MOV C,P1.4
                 JC MM
        STOP3: MOV C,P1.4
                 JNC STOP3
                 LCALL DELAY1
                 MOV C,P1.4
                 JNC STOP3
                 LJMP LOOP
DELAY1: MOV R4,#14H; time delay
        DL001: MOV R5,#0FFH
        DL111: DJNZ R5,DL111
                 DJNZ R4,DL001
                 RET
        ;¡Á¡Á¡Á¡Á¡Átime running program¡Á¡Á¡Á¡Á¡Á
        TIME: PUSH ACC; On-site protection
                PUSH PSW
            MOV TH0,#03CH; Assign initial value
                 MOV TL0,#0B0H
                DJNZ R2,RET0
                MOV R2,#14H
                MOV A,20H
                CLR C
            MOV 30H,#0
            MOV 31H,#0
                MOV A,21H
                INC A; Minutes add 1
                  CJNE A, #3CH, GO2; Determine whether the minute reaches 60 minutes?
            MOV 21H, #0H; reset to 60 minutes
            MOV 32H,#0
            MOV 33H,#0
                MOV A,22H
                INC A; clock increments by 1
                CJNE A, #18H, GO3; Determine whether the clock reaches 24 o'clock?
                MOV 22H, #00H; reset at 24
            MOV 34H,#0
            MOV 35H,#0
                AJMP RET0
        GO1: MOV 20H,A
                MOV B,#0AH
                DIV AB
                MOV 31H,A
MOV 30H,B
                 AJMP RET0
        GO2: MOV 21H,A
                MOV B,#0AH
                DIV AB
                MOV 33H,A
                MOV 32H,B
                AJMP RET0
        GO3: MOV 22H,A
                MOV B,#0AH
                DIV AB
                MOV 35H,A
                MOV 34H,B
                       AJMP RET0
        RET0: POP PSW; restore scene
                POP ACC
                RETI
           ;¡Á¡Á¡Á¡Á¡Á running part¡Á¡Á¡Á¡Á¡Á
        DISPLAY1: MOV R0,#30H
                    MOV R3,#0FEH
                    MOV A, R3
        PLAY1: MOV P2,A
               MOV A,@R0
               MOV DPTR,#DSEG1; The first address of the table is sent to DPTR
               MOVC A,@A+DPTR
               MOV P0,A
               LCALL DL1
               MOV P2, #0FFH; Send high level to P2
               MOV A, R3
               RL A;
               JNB ACC.6, LD1
               INC R0
               MOV R3,A
               LJMP PLAY1; call the lookup table program
        LD1: RET
        DISPLAY2: PUSH ACC; field protection
            PUSH PSW
        MOV R0,#36H
                    MOV R3,#0FBH
                    MOV A, R3
        PLAY2: MOV P2,A
               MOV A,@R0
               MOV DPTR,#DSEG1; The first address of the table is sent to DPTR
               MOVC A,@A+DPTR ;Check ASCII special code
               MOV P0, a
               LCALL DL1
               MOV P2, #0FFH; Send high level to P2
               MOV A, R3
               RL A
               JNB ACC.6, LD2
               INC R0
               MOV R3,A
               LJMP PLAY2
        LD2: POP PSW; restore the scene
           POP ACC
         RET
          ;¡Á¡Á¡Á¡Á¡Ádelay time¡Á¡Á¡Á¡Á¡Á
        DL1: MOV R7,#02H; Delay time
        DL: MOV R6,#020H
        DL6: DJNZ R6,$
                    DJNZ R7,DL
                    RET
        DSEG1: DB 3FH,06H,5BH,4FH,66H
              DB 6DH,7DH,07H,7FH,6FH
        END
