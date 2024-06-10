.global TIMERCONTROLLER
TIMERCONTROLLER:  
  movia r15, 0x10000020
  ldwio r11, (r14)
  movia r12, INPUT_BUFFER  # INPUT_BUFFER
  ldwio r13, 4(r12)        # r13 = INPUT_BUFFER[1]
  subi r13,r13,0x30
  bne r13, r0, END_CRONO
  movia r9, 0x1
  movia r10, statusCrono  
  stwio r9, (r10)          # statusAnimation = 1
  

  br END

  END_CRONO:
  movia r15, 0x10000020  
  stbio r0, (r15)          #Turn off Display[0]
  movia r15, 0x10000021
  stbio r0, (r15)          #Turn off Display[1] 
  movia r15, 0x10000022
  stbio r0, (r15)          #Turn off Display[2] 
  movia r15, 0x10000023
  stbio r0, (r15)          #Turn off Display[3] 
  call RESET_CRONO
  movia r10, statusCrono  
  stwio r0, (r10)          # statusAnimation = 0


  END:
ret

.global statusCrono
statusCrono: 
.word 0




