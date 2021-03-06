%macro cdecl 1-*.nolist
  %rep %0 - 1
    push %{-1:-1}
    %rotate -1
  %endrep
  %rotate -1
    call %1
  %if 1 < %0
    add sp, (__BITS__ >> 3) * (%0 - 1)
  %endif
%endmacro

struc drive
  .no resw 1
  .cyln resw 1
  .head resw 1
  .sect resw 1
  endstruc

%macro set_vect 1-*
  push eax
  push edi

  mov edi,VECT_BASE + (%1 * 8)
  mov eax, %2

  mov [edi + 0], ax
  shr eax, 16
  mov [edi + 6], ax

  pop edi
  pop eax
%endmacro

%macro outp 2
  mov al, %2
  out %1, al
%endmacro

struc ring_buff
  .rp resd 1
  .wp resd 1
  .item resd RING_ITEM_SIZE
  endstruc

%macro  set_desc 2-*
  push eax
  push edi

  mov edi, %1
  mov eax, %2

  %if 3 == %0
    mov [edi + 0], %3
  %endif

  mov [edi + 2], ax
  shr eax, 16
  mov [edi + 4], al
  mov [edi + 7], ah

  pop edi
  pop eax
%endmacro

%macro set_gate 2-*
  push eax
  push edi

  mov edi %1
  mov eax %2

  mov [edi + 0], ax
  shr eax, 16
  mov [edi + 6]

  pop edi
  pop eax
%endmacro
