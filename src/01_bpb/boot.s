entry:
  jmp ipl
  times 90 -($ - $$) db 0x90
ipl:
  jmp $
  times 510 - ($ - $$) db
  db 0x55, 0xAA