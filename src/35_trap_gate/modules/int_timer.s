int_timer:
  pusha
  push ds
  push es

  mov ax, 0x0010
  mov ds, ax
  mov es, ax

  inc dword [TIMER_COUNT]
  outp 0x20, 0x20

  str ax
  cmp ax, SS_TASK_0
  je .11L

  jmp SS_TASK_0:0
  jmp .10E
.11L:
  jmp SS_TASK_1:0
  jmp .10E
.10E:

  pop es
  pop ds
  popad

  iret

ALIGN 4, db 0
TIMER_COUNT: dd 0