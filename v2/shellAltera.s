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
/* r11  - Mask                                                            */
/* r12  - INPUT_BUFFER #                                                  */
/* r13  - INPUT_BUFFER[i]                                                 */
/* r14  - i                                                               */            
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
  movia r10, statusAnimation  
  ldw r10, (r10) 
  beq r10,r0,EndFrame
    movia r14, 0x10000040
    ldwio r13, (r14) 
    movia r15, 0x10000000
    ldwio r16, (r15)
    movia r9, 0x1
    and r13, r13, r9          # Formata switchs   
    bne r13, r9, DIR       # If(Switch[0] != 0)
    movia r9, 0xF
    beq r16,r9, ROLMaior
    movia r9, 0x1 
    rol	r16, r16, r9
    stwio r16, (r15)
    br EndFrame
    ROLMaior:
    movia r16, 0x1
    stwio r16, (r15)
    br EndFrame
    
    DIR:
    beq r16,r9, RORMaior
    ror	r16,r16,r9
    stwio r16, (r15)
    br EndFrame
    RORMaior:
    roli  r16,r16,20
    stwio r16, (r15)
  EndFrame:
  stwio r0,(r18)          # timer = 0
ret


.global _start
 _start:


  movia r18, 0x10002000   
  movia r10, 10000000     # Separa valor no timer 200ms
  andi r11,r10,0xffff
  stwio r11, 8(r18)      #parte baixa
  srli r11, r10, 16
  stwio r11, 12(r18)     #parte alta

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

  WaitLoop:
    
    ldwio r10, (r8)         # Get Register Data
    andi  r11, r10, 0x8000  # Mask RValid
    beq r11, r0, WaitLoop   # if(RValid != 0)  
    andi r10, r10, 0xFF     # Mask Data 0 to 7
    stwio r10, (r8)         # Store

    movia r12, INPUT_BUFFER  # INPUT_BUFFER
    add r13, r12, r14        # INPUT_BUFFER[i]
    movia r9, 0x8
    beq r10, r9, Backspace
    stwio r10, (r13)         # INPUT_BUFFER[i] = Input
    addi r14,r14,4           # i++
    movia r9, 0xa            # r9 = ASCII ENTER
    bne r10, r9, WaitLoop    # if(Enter)
    

    movia r9, 0x30           # r9 = ASCII '0'
    ldwio r13, (r12)         # r13 = INPUT_BUFFER[0]
    bne r13, r9, ELSEIF      # if(r12 == 0)
    call LEDCONTROLLER
    movi r14, 0
    br WaitLoop
    ELSEIF:
    movia r9, 0x31           # r9 = ASCII '1'
    bne r13, r9, ELSE        # elseif(r12 == 1)
    call ANICONTROLLER
    movi r14, 0
    br WaitLoop
    ELSE:
    movia r9, 0x32           # r9 = ASCII '2'
    bne r13, r9, WaitLoop    # elseif(r12 == 2)
    #call TIMERCONTROLLER

    Backspace:
        subi r14,r14,4           # i++
    br WaitLoop                   

END:
 br		END              /* Espera aqui quando o programa terminar  */

.org 0x500
.global INPUT_BUFFER
INPUT_BUFFER:
    .skip 32
    

   

.end

