.global ANICONTROLLER
ANICONTROLLER:


  movia r15, 0x10000000
  
  ldwio r11, (r14)

  movia r12, INPUT_BUFFER   # INPUT_BUFFER
  ldwio r13, 4(r12)         # r13 = INPUT_BUFFER[1]

  subi r13,r13,0x30         # r13 = convert ASCIInumber to int
  bne r13, r0, PAUSE
  movia r9, 0x1             # r9 = Mask(1)
  movia r10, statusAnimation  
  stwio r9, (r10)           # statusAnimation = 1
  ldwio r16, (r15)          # r16 = on redLeds
  
  stwio r9, (r15)           # Reset leds to start the animation
  movia r15, BackupLeds     
  stwio r16, (r15)          # Store r16 into BackupLeds

  br END

  PAUSE:
  movia r10, statusAnimation  
  stwio r0, (r10)          # statusAnimation = 1
  movia r15, BackupLeds 
  ldwio r16, (r15)         # Load BackupLeds into r16
  movia r15, 0x10000000
  stwio r16, (r15)         # Store r16 into leds



  END:

ret

.global statusAnimation
statusAnimation: 
.word 0

.global BackupLeds
BackupLeds:
.word 0


