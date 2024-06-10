/**************************************************************************/
/* Main Program                                                           */
/*   Show Acc into GreenLeds and average into RedLeds                     */
/*                                                                        */
/* r8   - Switchs                                                         */
/* r9   - Mask                                                            */ 
/* r10  - GreenLeds                                                       */
/* r11  - Acc                                                             */
/* r12  - PushButton                                                      */
/* r13  - Input_buffer                                                    */
/* r14  - Switchs                                                         */ 
/* r15  - RedLeds                                                         */   
/* r16  - backup r15                                                      */ 
/* r18  - timer                                                           */     
/**************************************************************************/




.global ANICONTROLLER
ANICONTROLLER:


  movia r15, 0x10000000
  
  ldwio r11, (r14)
  
  movia r12, INPUT_BUFFER  # INPUT_BUFFER
  ldwio r13, 4(r12)        # r13 = INPUT_BUFFER[1]

  subi r13,r13,0x30
  bne r13, r0, PAUSE
  movia r9, 0x1
  movia r10, statusAnimation  
  stwio r9, (r10)         
  stwio r9, (r15)           # Apagando leds para iniciar animação
  

  br END

  PAUSE:
  movia r10, statusAnimation  
  stwio r0, (r10) 

  stwio r16, (r15)



  END:

ret

.global statusAnimation
statusAnimation: 
.word 0
