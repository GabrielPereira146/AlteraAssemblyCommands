
/*
global int input;
int main() {
        input
        scanf("%d %d", &comando, &posicao);
        // Verifica se a posição do LED está dentro do intervalo válido
        if (posicao < 0 || posicao >= 100) {
            printf("Posição inválida. Digite um número entre 0 e 99.\n");
            continue;
        }

        // Verifica o comando digitado e realiza a operação correspondente
        if (comando == 0) {
            leds[posicao] = 1; // Acende o LED na posição especificada
            printf("Acendeu o LED na posição %d\n", posicao);
        } else if (comando == 1) {
            leds[posicao] = 0; // Apaga o LED na posição especificada
            printf("Apagou o LED na posição %d\n", posicao);
        } else {
            printf("Comando inválido. Digite 0 para acender ou 1 para apagar.\n");
        }

    return 0;
}
*/

/**************************************************************************/
/* Main Program                                                           */
/*   Show Acc into GreenLeds and average into RedLeds                     */
/*                                                                        */
/* r8   - Switchs                                                         */
/* r9   - Mask                                                            */ 
/* r10  - GreenLeds                                                       */
/* r11  - Acc                                                             */
/* r12  - PushButton                                                      */
/* r13  - RedLeds                                                         */
/* r14  - RegLast4Acc                                                     */ 
/* r15  - Average4Acc                                                     */   
/* r16  - Temp                                                            */             
/**************************************************************************/



.global LEDCONTROLLER
LEDCONTROLLER:
  movia r15, 0x10000000
  ldwio r17, (r15)
  movia r12, INPUT_BUFFER  # INPUT_BUFFER
  ldwio r13, 8(r12)        # r13 = INPUT_BUFFER[2]
  subi r13, r13, 0x30
  beq r13, r0, SKIPSOMA
  addi r13, r13, 9
  SKIPSOMA: 
  ldwio r14, 12(r12)       # r14 = INPUT_BUFFER[3]
  subi r14, r14, 0x30
  add r14, r13, r14
  ldwio r13, 4(r12)        # r13 = INPUT_BUFFER[1]
  movia r9, 0x30           # r9 = ASCII '0'
  bne r13, r9, ELSEIF
  movia r16, 0x1
  sll r14, r16, r14 
  or r14, r14, r17
  stwio r14, (r15)       # Print RED_LED
  ELSEIF:
  movia r9, 0x31           # r9 = ASCII '1'
  bne r13, r9, ENDLED
  #movia r16, 0xfffffffe
  addi r16, r0, -2
  rol r14, r16, r14
  and r14, r14, r17
  stwio r14, (r15)       # Print RED_LED
ENDLED:



ret
