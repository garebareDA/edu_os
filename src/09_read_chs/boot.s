%include "../include/define.s"
%include "../include/macro.s"

  ORG BOOT_LOAD

entry:
  jmp ipl
  times 90 -($ - $$) db 0x90
ipl:
  cli
  mov ax, 0x0000
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, BOOT_LOAD

  sti
  mov [BOOT + drive.no], dl

  cdecl puts, .s0

  mov bx, BOOT_SECT - 1
  mov cx, BOOT_LOAD + SECT_SIZE

  cdecl read_chs, BOOT, bx, cx

  cmp ax, bx
.10Q:
  jz .10E
.10T:
  call reboot
.10E:
  cdecl puts, .s0
  jmp stage_2

.s0 db "booting...", 0x0A, 0x0D, 0
.e0 db "Error:Sector: read", 0
ALIGN 2, db 0
BOOT:
  istruc	drive
    at drive.no, dw 0
    at drive.cyln, dw 0
    at drive.head, dw 0
    at drive.sect, dw 2
  iend

%include "../modules/real/puts.s"
%include "../modules/real/reboot.s"
%include "../modules/real/read_chs.s"

  times 510 - ($ - $$) db 0x00
  db 0x55, 0xAA

stage_2:
  cdecl puts, .s0
  jmp $
.s0 db "2nd stage..."
  times BOOT_SIZE - ($ - $$) db 0