task_1:
  cdecl draw_str, 63, 0, 0x07, .s0
.10L:
  mov eax, [RTC_TIME]
  cdecl draw_time, 72, 0, 0x700, eax
  jmp SS_TASK_0:0
  jmp .10L

.s0 db "TASK-1", 0