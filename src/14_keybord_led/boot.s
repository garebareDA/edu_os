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
  cdecl puts, .e0
  call reboot
.10E:
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

  FONT:
  .seg: dw 0
  .off: dw 0
  ACPI_DATA:
  .adr: dd 0
  .len: dd 0

%include "../modules/real/itoa.s"
%include "../modules/real/get_drive_param.s"
%include "../modules/real/get_font_adr.s"
%include "../modules/real/get_mem_info.s"
%include "../modules/real/kbc.s"

stage_2:
  cdecl puts, .s0
  cdecl get_drive_param, BOOT
  cmp ax, 0
.10Q:
  jne .10E
.10T:
  cdecl puts, .e0
  call reboot
.10E:
	mov	ax, [BOOT + drive.no]
	cdecl	itoa, ax, .p1, 2, 16, 0b0100
	mov	ax, [BOOT + drive.cyln]
	cdecl	itoa, ax, .p2, 4, 16, 0b0100
	mov	ax, [BOOT + drive.head]
	cdecl	itoa, ax, .p3, 2, 16, 0b0100
	mov	ax, [BOOT + drive.sect]
	cdecl	itoa, ax, .p4, 2, 16, 0b0100
	cdecl	puts, .s1
  jmp stage_3
.s0		db	"2nd stage...", 0x0A, 0x0D, 0
.s1		db	" Drive:0x"
.p1		db	"  , C:0x"
.p2		db	"    , H:0x"
.p3		db	"  , S:0x"
.p4		db	"  ", 0x0A, 0x0D, 0

.e0		db	"Can't get drive parameter.", 0

stage_3:
  cdecl puts, .s0
  cdecl get_font_adr, FONT
  cdecl itoa, word [FONT.seg], .p1, 4, 16, 0b0100
  cdecl	itoa, word [FONT.off], .p2, 4, 16, 0b0100
	cdecl	puts, .s1

  cdecl get_mem_info

  mov eax, [ACPI_DATA.adr]
  cmp eax, 0
  je .10E

  cdecl itoa, ax, .p4, 4, 16, 0b0100
  shr eax, 16
  cdecl itoa, ax, .p3, 4, 16, 0b0100

  cdecl puts, .s2
.10E:
  jmp stage_4

.s0:	db	"3rd stage...", 0x0A, 0x0D, 0

.s1:	db	" Font Address="
.p1:	db	"ZZZZ:"
.p2:	db	"ZZZZ", 0x0A, 0x0D, 0
	db	0x0A, 0x0D, 0

.s2: db " ACPI data="
.p3: db "ZZZZ"
.p4: db "ZZZZ", 0x0A, 0x0D, 0

stage_4:
  cdecl puts, .s0
  cli
  cdecl KBC_Cmd_Write, 0x0AD

  cdecl KBC_Cmd_Write, 0xD0
  cdecl KBC_Data_Read, .key

  mov bl, [.key]
  or bl, 0x02

  cdecl KBC_Cmd_Write, 0xD1
  cdecl KBC_Data_Write, bx
  cdecl KBC_Cmd_Write, 0xAE
  sti

  cdecl puts, .s1

  cdecl puts, .s2
  mov bx, 0

.10L:
  mov ah, 0x00
  int 0x16

  cmp al, '1'
  jb .10E

  cmp al, '3'
  ja .10E

  mov cl, al
  dec cl
  and cl, 0x03
  mov ax, 0x001
  shl ax, cl
  xor bx, ax

  cli

  cdecl KBC_Cmd_Write, 0xAD
  cdecl KBC_Data_Write, 0xED
  cdecl KBC_Data_Read, .key

  cmp [.key], byte 0xFA
  jne .11F
  cdecl KBC_Data_Write, bx
  jmp .11E

.11F:
    cdecl itoa, word [.key], .e1, 2, 16, 0b0100
    cdecl puts, .e0
.11E:
  cdecl KBC_Cmd_Write, 0xAE
  sti
  jmp .10L
.10E:
  cdecl puts, .s3
  jmp $

.s0: db "4th stage...", 0x0A, 0x0D,0
.s1: db "A20 Gate Enabled.", 0x0A, 0x0D, 0
.s2: db "Keybord LED Test..."
.s3: db "(done)", 0x0A, 0x0D, 0
.e0: db "["
.e1: db "ZZ]", 0
.key: dw 0
  times BOOT_SIZE - ($ - $$) db 0