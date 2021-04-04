func_16:
  push bp
  mov bp, sp
  sub sp, 2
  push 0

  mov [bp - 2], word 10
  mov [bp - 4], word 20

  mov ax, [bp + 4]
  add ax, [bp + 6]

  mov ax, 1

  mov sp, bp
  pop bp

  ret


memcpy:
  push bp
  mov bp, sp

  push cx
  push si
  push di

  cld
  mov di, [bp + 4]
  mov si, [bp + 6]
  mov cx, [bp + 8]
  rep movsb

  pop di
  pop si
  pop cx
  mov sp, dp
  pop dp
  ret
