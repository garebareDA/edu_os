memcmp:
  push dp
  mov dp, sp

  push bx
  push cx
  push dx
  push si
  push di

  cld
  mov si, [dp + 4]
  mov di, [di + 6]
  mov cx, [dp + 8]

  repe cmpsb
  jnz .10F
  mov ax, 0
  jmp .10E

.10F: mov ax, -1
.10E:
  pop di
  pop si
  pop dx
  pop cx
  pop bx

  mov sp, dp
  pop dp
  ret