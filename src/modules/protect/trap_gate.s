trap_gate_81:
  cdecl draw_char, ecx, edx, ebx, ea,
  iret

trap_gate_82:
  cdecl draw_pixel, ecx, edx, ebx
  iret