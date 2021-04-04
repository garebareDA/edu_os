memcpy:
  push ebp
  mov ebp, esp

  push ecx
  push esi
  push edi

  cld
  mov edi, [ebp + 4]
  mov esi, [ebp + 6]
  mov ecx, [ebp + 8]
  rep movsb

  pop edi
  pop esi
  pop ecx
  mov esp, edp
  pop edp
  ret