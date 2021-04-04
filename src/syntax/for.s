Test:
  mov cx, 0
.L:
  cmp cx, 5
  jge .E
  inc cx
  jmp .L
.E: