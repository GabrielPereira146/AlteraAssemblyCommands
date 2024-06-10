/* "MAQUINA DE ESCREVER"

1. Esperar alguém colocar o foco no terminal e precionar o teclado;
2. O código ASCII do caractere é enviado para a UART da placa (disponivel no buffer leitura da UART);

"inicio em termos de código"
3. Ler o buffer leitura;
4. Escrever ó código ASCII no buffer de escrita;
*/

/**************************************************************************/
/* Main Program                                                           */
/*   Show Acc into GreenLeds and average into RedLeds                     */
/*                                                                        */
/* r8   - Register Data #                                                 */
/* r9   - Consts                                                          */ 
/* r10  - Value Register Data                                             */
/* r11  - Mask #                                                          */
/* r12  - INPUT_BUFFER #                                                  */
/* r13  - INPUT_BUFFER[i]                                                 */
/* r14  - i #*                                                            */            
/**************************************************************************/
.org 0x20
/*Exception handler*/
  rdctl et,ipending
  beq et, r0, OTHER_EXCEPTIONS
  subi ea, ea, 4

  andi r13, et, 1
  beq r13, r0, OTHER_INTERRUPTS

call EXT_IRQ0

OTHER_INTERRUPTS:
  
br END_HANDLER

OTHER_EXCEPTIONS:

END_HANDLER:
  
eret
  
EXT_IRQ0:
  addi sp, sp, -4
  stw  ra, 4(sp)

  movia r10, statusCrono  
  ldw r10, (r10)                # r10 = statusCrono
  beq r10,r0,NoSEGUNDOS         # If(statusCrono != true)
  movia r17, ControlCrono     
  ldw r10, (r17)                # r10 = Cont200ms
  addi r10, r10, 1              # r10++
  stw r10, (r17)                # Store R10 into Cont200ms
  movi r17, 0x5               
  bne r10, r17, NoSEGUNDOS      # If(r10 == 5)
  call SEGUNDOS_CONVERT
  movia r17, ControlCrono       
  stw r0, (r17)                 # Cont200ms = 0;
  NoSEGUNDOS:
  movia r10, statusAnimation     
  ldw r10, (r10)                # r10 = statusAnimation 
  beq r10,r0,EndFrame           # If(statusAnimation != true)
    movia r17, 0x10000040       
    ldwio r13, (r17)            # r13 = Switchs
    movia r15, 0x10000000
    ldwio r18, (r15)            # r15 = RedLeds
    movia r9, 0x1               # r9 = Mask (1)
    and r13, r13, r9            # Format Switchs   
    bne r13, r9, DIR            # If(Switch[0] == 0)
    movia r9, 0x20000           # LastLed Position 
    beq r18,r9, ROLMaior        # If(LedAceso != UltimoLed)
    movia r9, 0x1               # r9 = Mask (1)
    rol	r18, r18, r9            # move one position to left
    stwio r18, (r15)            # turn on next led
    br EndFrame
    ROLMaior:     
    movia r18, 0x1              
    stwio r18, (r15)            # Reset animation
    br EndFrame
    
    DIR:
    beq r18,r9, RORMaior        # If(LedAceso != PrimeiroLed)
    ror	r18,r18,r9              # move one position to right
    stwio r18, (r15)            # turn on next led
    br EndFrame
    RORMaior:
    roli  r18,r18,17          
    stwio r18, (r15)            # Reset animation
  EndFrame:
  movia r18, 0x10002000   
  stwio r0,(r18)                # timer = 0

 ldw  ra, 4(sp)
 addi sp, sp, 4

ret

SEGUNDOS_CONVERT:
  movia r17, USegundos     
  ldw r10, (r17)                # r10 = USegundos
  addi r10, r10, 1              # r10++
  movi r9, 10                   # r9 = Mask (10)   
  beq r10, r9, DEZENA           # if(r10 != 10)
  stw r10, (r17)                # Store r10 into USegundos
  br END_CONVERT_COUNT
  DEZENA:
  mov r10,r0                    # r10 = 0
  stw r10, (r17)                # Store r10 into USegundos (Reset USegundos)
  movia r17, DSegundos
  ldw r10, (r17)                # r10 = DSegundos
  addi r10, r10, 1              # r10++
  movi r9, 10                   # r9 = Mask (10)
  beq r10, r9, CENTENA          # if(r10 != 10)
  stw r10, (r17)                # Store r10 into DSegundos
  br END_CONVERT_COUNT
  CENTENA:
  mov r10,r0                    # r10 = 0
  stw r10, (r17)                # Store r10 into DSegundos (Reset DSegundos)
  movia r17, CSegundos
  ldw r10, (r17)                # r10 = CSegundos
  addi r10, r10, 1              # r10++
  movi r9, 10                   # r9 = Mask (10)
  beq r10, r9, MILHAR           # if(r10 != 10)
  stw r10, (r17)                # Store r10 into CSegundos
  br END_CONVERT_COUNT
  MILHAR:
  mov r10,r0                    # r10 = 0
  stw r10, (r17)                # Store r10 into CSegundos (Reset CSegundos)
  movia r17, MSegundos          
  ldw r10, (r17)                # r10 = MSegundos
  addi r10, r10, 1              # r10++
  movi r9, 10                   # r9 = Mask (10)
  beq r10, r9, ZERAR            # if(r10 != 10)
  stw r10, (r17)                # Store r10 into MSegundos
  br END_CONVERT_COUNT

 
  ZERAR:
    call RESET_CRONO


  END_CONVERT_COUNT:
  movia r15, 0x10000020
  movia r9, code7seg            # r9 = Mask (Convertion Array)
  movia r17, USegundos          
  ldb r17, (r17)                # r17 = USegundos
  add r9, r9, r17               # Array[r17]
  ldb r9, (r9)                  # r9 = Array[r17]
  stbio r9, (r15)               # Store r9 into Display[0]
  movia r15, 0x10000021
  movia r9, code7seg            # r9 = Mask (Convertion Array)
  movia r17, DSegundos
  ldb r17, (r17)                # r17 = DSegundos
  add r9, r9, r17               # Array[r17]
  ldb r9, (r9)                  # r9 = Array[r17]
  stbio r9, (r15)               # Store r9 into Display[1]
  movia r15, 0x10000022
  movia r9, code7seg            # r9 = Mask (Convertion Array)
  movia r17, CSegundos
  ldb r17, (r17)                # r17 = CSegundos
  add r9, r9, r17               # Array[r17]
  ldb r9, (r9)                  # r9 = Array[r17]
  stbio r9, (r15)               # Store r9 into Display[2]
  movia r15, 0x10000023
  movia r9, code7seg            # r9 = Mask (Convertion Array)
  movia r17, MSegundos
  ldb r17, (r17)                # r17 = MSegundos
  add r9, r9, r17               # Array[r17]
  ldb r9, (r9)                  # r9 = Array[r17]
  stbio r9, (r15)               # Store r9 into Display[3]
ret

 # Zera todas as Variáveis relacionadas ao cronometro{
.global RESET_CRONO
RESET_CRONO:
  mov r10,r0                    
  movia r17, USegundos
  stw r10, (r17)
  movia r17, DSegundos
  stw r10, (r17)
  movia r17, CSegundos
  stw r10, (r17)
  movia r17, MSegundos
  stw r10, (r17)
ret
# }

Prompt:
  movia r10, PrintPainel
  PrintLoop:
  ldb r11, (r10)
  stbio r11, (r8)
  addi r10, r10, 1
  bne r11, r0, PrintLoop
ret
.global _start
 _start:

  movia sp, 0x10000


  movia r18, 0x10002000   
  movia r10, 10000000           # Separa valor no timer 200ms
  andi r11,r10,0xffff
  stwio r11, 8(r18)             # parte baixa
  srli r11, r10, 16
  stwio r11, 12(r18)            # parte alta

  #Config interrupção timer
  movi r10,7
  stwio r10, 4(r18) 

  # PIE de processador
  movi r12, 1
  wrctl	ctl0, r12

  # Ienable
  wrctl ctl3, r12


  movia r8, 0x10001000
  movia r9, 0
  movi r14, 0
  call Prompt
  WaitLoop:
    
    ldwio r10, (r8)             # Get Register Data
    andi  r11, r10, 0x8000      # Mask RValid
    beq r11, r0, ELSE           # if(RValid != 0)  
    andi r10, r10, 0xFF         # Mask Data 0 to 7
    stwio r10, (r8)             # Store

    movia r12, INPUT_BUFFER     # INPUT_BUFFER
    add r13, r12, r14           # INPUT_BUFFER[i]
    movia r9, 0x8
    beq r10, r9, Backspace
    stwio r10, (r13)            # INPUT_BUFFER[i] = Input
    addi r14,r14,4              # i++
    movia r9, 0xa               # r9 = ASCII ENTER
    bne r10, r9, WaitLoop       # if(Enter)
    

    movia r9, 0x30              # r9 = ASCII '0'
    ldwio r13, (r12)            # r13 = INPUT_BUFFER[0]
    bne r13, r9, ELSEIF         # if(r12 == 0)
    call LEDCONTROLLER
    call Prompt
    movi r14, 0
    br WaitLoop
    ELSEIF:
    movia r9, 0x31              # r9 = ASCII '1'
    bne r13, r9, ELSEIF2        # elseif(r12 == 1)
    call ANICONTROLLER
    call Prompt
    movi r14, 0
    br WaitLoop
    ELSEIF2:
    movia r9, 0x32              # r9 = ASCII '2'
    bne r13, r9, WaitLoop       # elseif(r12 == 2)
    call TIMERCONTROLLER
    call Prompt
    movi r14, 0
    br WaitLoop
    ELSE:
      movia r16, 0x1000005C
      ldwio r16, (r16)          # Get PushButton
      andi  r16, r16, 0x2       # Mask button1
      beq r16, r0, WaitLoop     # if(Button1 != Pressed)

      movia r10, statusCrono  
      ldw r16, (r10)            # r16 = statusAnimation
      beq r16, r0, PLAY         # if(r16 != 0)
      stwio r0, (r10)           # statusAnimation = 0
      br ENDELSE
      PLAY:
      movia r16, 0x1            # r16 = Mask(1)
      stwio r16, (r10)          # statusAnimation = r16
      ENDELSE:
      movia r16, 0x1000005C
      stwio r0, (r16)           # Reset Button
    br WaitLoop
    Backspace:
        subi r14,r14,4          # i++
    br WaitLoop                   

END:
 br		END              /* Espera aqui quando o programa terminar  */



.org 0x500
.global INPUT_BUFFER
INPUT_BUFFER:
    .skip 32

.global ControlCrono
ControlCrono: 
.word 0

.global USegundos 
USegundos:
.word 0

.global DSegundos 
DSegundos:
.word 0

.global CSegundos 
CSegundos:
.word 0

.global MSegundos 
MSegundos:
.word 0

code7seg:
.byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
   
PrintPainel:
    .asciz "Entre com o comando: \n"
.end

