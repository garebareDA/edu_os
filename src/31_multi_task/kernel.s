%include "../include/define.s"
%include "../include/macro.s"

  ORG KERNEL_LOAD
[BITS 32]
kernel:
  mov esi, BOOT_LOAD + SECT_SIZE
  movzx eax, word  [esi + 0]
  movzx ebx, word [esi + 2]
  shl eax, 4
  add eax, ebx
  mov [FONT_ADR], eax

  set_desc GDT.tss_0, TSS_0
  set_desc GDT.tss_1, TSS_1
  set_desc GDT.ldt, LDT, word LDT_LIMIT
  lgdt [GDTR]
  mov esp, SP_TASK_0
  mov ax, SS_TASK_0
  ltr ax

  cdecl init_int
  cdecl	init_pic

  set_vect 0x00, int_zero_div
  set_vect 0x20, int_timer
  set_vect 0x21, int_keyboard
  set_vect 0x28, int_rtc

  cdecl rtc_int_en, 0x10
  cdecl	int_en_timer0

  outp 0x21, 0b1111_1000
  outp 0xA1, 0b1111_1110

  sti

  cdecl draw_font, 63, 13
  cdecl draw_color_bar, 63, 4

  cdecl draw_str, 25, 14, 0x010F, .s0

  call	SS_TASK_1:0

.10L:
  mov eax, [RTC_TIME]
  cdecl draw_time, 72, 0, 0x0700, eax

  cdecl	draw_rotation_bar

  cdecl ring_rd, _KEY_BUFF, .int_key
  cmp eax, 0
  je .10E

  cdecl draw_key, 2, 29, _KEY_BUFF
.10E:
  jmp .10L

.s0 db "Hello, kernel", 0

ALIGN 4, db 0
.int_key: db 0

ALIGN 4, db 0
FONT_ADR: dd 0
RTC_TIME: dd 0

%include	"../modules/protect/vga.s"
%include	"../modules/protect/draw_char.s"
%include	"../modules/protect/draw_font.s"
%include  "../modules/protect/draw_str.s"
%include "../modules/protect/draw_color_bar.s"
%include  "../modules/protect/draw_pixel.s"
%include  "../modules/protect/draw_line.s"
%include 	"../modules/protect/draw_rect.s"
%include  "../modules/protect/itoa.s"
%include "../modules/protect/rtc.s"
%include "../modules/protect/draw_time.s"
%include  "../modules/protect/interrupt.s"
%include  "../modules/protect/pic.s"
%include  "../modules/protect/int_rtc.s"
%include  "../modules/protect/ring_buff.s"
%include "../modules/protect/int_keyboard.s"
%include "modules/int_timer.s"
%include "../modules/protect/timer.s"
%include "../modules/protect/draw_rotation_bar.s"

%include	"descriptor.s"
%include	"tasks/task_1.s"

  times KERNEL_SIZE - ($ - $$) db 0x00