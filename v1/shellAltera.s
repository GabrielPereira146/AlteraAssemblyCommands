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
/* r8   - Register Data                                                   */
/* r9   - Consts                                                            */ 
/* r10  - Value Register Data                                             */
/* r11  - Mask                                                            */
/* r12  - INPUT_BUFFER                                                    */
/* r13  - INPUT_BUFFER[i]                                                 */
/* r14  - i                                                               */ 
/* r15  -                                                      */   
/* r16  - Temp                                                            */             
/**************************************************************************/

.global _start
 _start:
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
    stwio r10, (r13)         # INPUT_BUFFER[i] = Input
    addi r14,r14,4           # i++
    movia r9, 0xa            # r9 = ASCII ENTER
    bne r10, r9, WaitLoop    # if(Enter)
    

    movia r9, 0x30           # r9 = ASCII '0'
    ldwio r13, (r12)         # r13 = INPUT_BUFFER[0]
    bne r13, r9, ELSEIF      # if(r12 == 0)
    call LEDCONTROLLER
    movi r14, 0
    ELSEIF:
    movia r9, 0x31           # r9 = ASCII '1'
    bne r13, r9, ELSE        # elseif(r12 == 1)
    #call ANICONTROLLER
    ELSE:
    movia r9, 0x32           # r9 = ASCII '2'
    bne r13, r9, WaitLoop    # elseif(r12 == 2)
    #call TIMERCONTROLLER

    
    br WaitLoop                   

END:
 br		END              /* Espera aqui quando o programa terminar  */

.org 0x500
.global INPUT_BUFFER
INPUT_BUFFER:
    .skip 32
    

   

.end

