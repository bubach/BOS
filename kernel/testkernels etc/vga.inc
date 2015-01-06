;----------------------------------------------------------;
; BOS 0.04                  Christoffer Bubach, 2004-2005. ;
;----------------------------------------------------------;
;                                                          ;
;     VGA functions. Change video mode etc.                ;
;                                                          ;
;----------------------------------------------------------;


     ;-------------------;
     ;   VGA palettes    ;
     ;-------------------;

	  palette256	  db   00, 00, 00, 00, 10, 41, 12, 28, 18, 02, 43, 22, 35
			  db   19, 09, 58, 00, 00, 57, 35, 12, 43, 43, 47, 24, 24
			  db   28, 20, 24, 60, 10, 60, 15, 31, 47, 63, 62, 56, 20
			  db   60, 56, 22, 63, 61, 36, 63, 63, 63, 00, 00, 00, 05
			  db   05, 05, 08, 08, 08, 11, 11, 11, 14, 14, 14, 17, 17
			  db   17, 20, 20, 20, 24, 24, 24, 28, 28, 28, 32, 32, 32
			  db   36, 36, 36, 40, 40, 40, 45, 45, 45, 50, 50, 50, 56
			  db   56, 56, 63, 63, 63, 13, 12, 15, 15, 16, 22, 17, 20
			  db   29, 19, 24, 36, 21, 28, 43, 23, 31, 50, 25, 34, 57
			  db   26, 42, 63, 00, 15, 02, 01, 22, 04, 02, 29, 06, 03
			  db   36, 08, 04, 43, 10, 05, 50, 12, 06, 57, 14, 20, 63
			  db   40, 18, 06, 07, 25, 12, 11, 33, 17, 14, 40, 23, 18
			  db   48, 28, 21, 55, 34, 25, 62, 39, 27, 63, 48, 36, 15
			  db   03, 02, 22, 06, 04, 29, 09, 06, 36, 12, 08, 43, 15
			  db   10, 50, 18, 12, 57, 21, 14, 63, 28, 20, 15, 00, 00
			  db   22, 07, 00, 29, 15, 00, 36, 23, 00, 43, 31, 00, 50
			  db   39, 00, 57, 47, 00, 63, 55, 00, 15, 05, 03, 22, 11
			  db   07, 29, 17, 11, 36, 23, 15, 43, 29, 19, 50, 35, 23
			  db   57, 41, 27, 63, 53, 34, 28, 14, 12, 33, 20, 14, 38
			  db   26, 16, 43, 32, 18, 48, 38, 20, 53, 44, 22, 58, 50
			  db   24, 63, 56, 30, 05, 05, 06, 10, 10, 13, 15, 15, 20
			  db   20, 20, 27, 25, 25, 34, 30, 30, 41, 35, 35, 48, 44
			  db   44, 63, 03, 06, 05, 05, 11, 09, 07, 16, 13, 09, 21
			  db   17, 11, 26, 21, 13, 31, 25, 15, 36, 29, 20, 48, 38
			  db   06, 06, 07, 13, 13, 15, 20, 20, 23, 27, 27, 31, 34
			  db   34, 39, 41, 41, 47, 48, 48, 55, 57, 57, 63, 06, 15
			  db   04, 12, 22, 08, 18, 29, 12, 24, 36, 16, 30, 43, 20
			  db   36, 50, 24, 42, 57, 28, 54, 63, 35, 15, 10, 10, 22
			  db   16, 16, 29, 21, 21, 36, 27, 27, 43, 32, 32, 50, 38
			  db   38, 57, 43, 43, 63, 54, 54, 15, 15, 06, 22, 22, 12
			  db   29, 29, 18, 36, 36, 24, 43, 43, 30, 50, 50, 36, 57
			  db   57, 42, 63, 63, 54, 02, 04, 14, 06, 12, 21, 10, 20
			  db   28, 14, 28, 35, 18, 36, 42, 22, 44, 49, 26, 52, 56
			  db   36, 63, 63, 18, 04, 14, 24, 08, 21, 31, 12, 28, 37
			  db   16, 35, 44, 20, 42, 50, 24, 49, 57, 28, 56, 63, 38
			  db   63, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
			  db   00, 00, 00, 00, 00, 00, 00, 00, 00, 53, 44, 22, 09
			  db   08, 12, 16, 14, 16, 22, 21, 20, 29, 27, 24, 35, 34
			  db   28, 42, 40, 32, 48, 47, 36, 57, 56, 43, 08, 12, 16
			  db   14, 16, 22, 21, 20, 29, 27, 24, 35, 34, 28, 42, 40
			  db   32, 48, 47, 36, 57, 56, 43, 63, 13, 09, 11, 21, 16
			  db   15, 27, 22, 18, 36, 29, 22, 42, 35, 25, 51, 42, 29
			  db   57, 48, 32, 63, 56, 39, 06, 14, 09, 12, 21, 14, 18
			  db   27, 22, 24, 33, 28, 30, 39, 36, 36, 46, 42, 42, 52
			  db   47, 50, 59, 53, 00, 00, 00, 00, 00, 00, 00, 00, 00
			  db   00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
			  db   00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
			  db   00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
			  db   00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
			  db   00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
			  db   00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
			  db   00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
			  db   00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
			  db   00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
			  db   00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
			  db   00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
			  db   00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
			  db   00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
			  db   00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
			  db   00

	  palette16	  db   00, 00, 00, 00, 00, 42, 00, 42, 00, 00, 42, 42, 42
			  db   00, 00, 42, 00, 42, 42, 21, 00, 42, 42, 42, 21, 21
			  db   21, 21, 21, 63, 21, 63, 21, 21, 63, 63, 63, 21, 21
			  db   63, 21, 63, 63, 63, 21, 63, 63, 63

     ;---------------------;
     ;  VGA mode values.   ;
     ;---------------------;
	  mode0x03	  db   0x67, 0x00, 0x03, 0x00, 0x03, 0x00, 0x02, 0x5F, 0x4F
			  db   0x50, 0x82, 0x55, 0x81, 0xBF, 0x1F, 0x00, 0x4F, 0x0E
			  db   0x0F, 0x00, 0x00, 0x00, 0x00, 0x9C, 0x0E, 0x8F, 0x28
			  db   0x01, 0x96, 0xB9, 0xA3, 0xFF, 0x00, 0x00, 0x00, 0x00
			  db   0x00, 0x10, 0x0E, 0x00, 0xFF, 0x00, 0x01, 0x02, 0x03
			  db   0x04, 0x05, 0x14, 0x07, 0x38, 0x39, 0x3A, 0x3B, 0x3C
			  db   0x3D, 0x3E, 0x3F, 0x0C, 0x00, 0x0F, 0x08, 0x00

	  mode0x13	  db   0x63, 0x00, 0x03, 0x01, 0x0F, 0x00, 0x0E, 0x5F, 0x4F
			  db   0x50, 0x82, 0x54, 0x80, 0xBF, 0x1F, 0x00, 0x41, 0x00
			  db   0x00, 0x00, 0x00, 0x00, 0x00, 0x9C, 0x0E, 0x8F, 0x28
			  db   0x40, 0x96, 0xB9, 0xA3, 0xFF, 0x00, 0x00, 0x00, 0x00
			  db   0x00, 0x40, 0x05, 0x0F, 0xFF, 0x00, 0x01, 0x02, 0x03
			  db   0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C
			  db   0x0D, 0x0E, 0x0F, 0x41, 0x00, 0x0F, 0x00, 0x00


	  vga_buff	  dd   0

;---------------------------------;
;  sets the screen to mode 0x03   ;
;---------------------------------;
set_mode_0x03:
	  pushad
	  push	  ax

	  mov	  esi, mode0x03
	  call	  set_regs

	  call	  load_font			      ; IT WORKS!! FINALLY!

	  mov	  esi, palette16
	  call	  set_palette16

	  pop	  ax
	  cmp	  ax, 1
	  jne	  .cont
	  call	  cls				      ; in text.inc
     .cont:

	  popad
	  ret



;---------------------------------;
;  sets the screen to mode 0x13   ;
;---------------------------------;
set_mode_0x13:
	  pushad
	  push	  ax

	  mov	  esi, mode0x13
	  call	  set_regs

	  mov	  esi, palette256
	  call	  set_palette256

	  pop	  ax
	  cmp	  ax, 1
	  jne	  .cont
	  mov	  edi, 0xa0000			      ; write directly to mem
	  mov	  ax, 0x0000			      ; clear all 256kb with color 0
	  mov	  ecx, 0x20000			      ; 256kb, 0x20000 = (256*1024)/2
	  rep	  stosw 			      ; by wordwrites
     .cont:

	  popad
	  ret



;----------------------------;
;  loads the standard font   ;
;----------------------------;
load_font:
	  cld
	  mov	  edi, vga_buff

	  mov	  dx, 0x03ce			      ; graphics
	  mov	  al, 5 			      ; write mode reg
	  out	  dx, al
	  inc	  dx
	  in	  al, dx
	  stosb
	  and	  al, 0xfc
	  xchg	  al, ah
	  mov	  al, 5
	  dec	  dx
	  out	  dx, ax

	  mov	  al, 6 			      ; misc reg
	  out	  dx, al
	  inc	  dx
	  in	  al, dx
	  stosb
	  and	  al, 0xf1
	  or	  al, 4
	  xchg	  al, ah
	  mov	  al, 6
	  dec	  dx
	  out	  dx, ax

	  mov	  dx, 0x03c4			      ; sequencer port
	  mov	  al, 2 			      ; map mask reg
	  out	  dx, al
	  inc	  dx
	  in	  al, dx
	  stosb

	  dec	  dx
	  mov	  ax, 0x0402
	  out	  dx, ax

	  mov	  al, 4 			      ; memory selector reg
	  out	  dx, al
	  inc	  dx
	  in	  al, dx
	  stosb
	  or	  al, 4
	  xchg	  al, ah
	  mov	  al, 4
	  dec	  dx
	  out	  dx, ax

	  mov	  esi, font_8x16		      ; font pointer
	  mov	  edi, 0xa0000

	  xor	  ecx, ecx
	  mov	  ebx, ecx

     .l1:
	  mov	  cl, 16			      ; font bytes (16 is standard)
	  rep	  movsb

	  mov	  cl, 32
	  sub	  cl, 16			      ; font bytes
	  xor	  eax, eax
	  rep	  stosb

	  dec	  bl				      ; 256 chars
	  jnz	  .l1

	  mov	  esi, vga_buff

	  mov	  dx, 0x03ce
	  lodsb
	  xchg	  al, ah
	  mov	  al, 5
	  out	  dx, ax

	  lodsb
	  xchg	  al, ah
	  mov	  al, 6
	  out	  dx, ax

	  mov	  dx, 0x03c4
	  lodsb
	  xchg	  al, ah
	  mov	  al, 2
	  out	  dx, ax

	  lodsb
	  xchg	  al, ah
	  mov	  al, 4
	  out	  dx, ax

	  ret



;------------------------------------;
;  put a pixel at x, y with color    ;
;           used only in mode 0x13   ;
;                                    ;
; input:   bx = x                    ;
;          cx = y                    ;
;          al = color                ;
;                                    ;
; output:  none.                     ;
;------------------------------------;
put_0x13_pixel:
	  push	  ax
	  push	  bx
	  push	  cx
	  push	  edi

	  mov	  edi, 0xa0000			      ; directly to mem
	  add	  di, bx
	  mov	  bx, cx
	  shl	  cx, 8
	  shl	  bx, 6
	  add	  cx, bx
	  add	  di, cx
	  stosb

	  pop	  edi
	  pop	  cx
	  pop	  bx
	  pop	  ax
	  ret


;-----------------------------------------------------;
;  put a sprite at x, y.  only for mode 0x13          ;
;                                                     ;
; input:   ax  = x, bx = y, cx = width, dx = height   ;
;          esi = pointer to sprite                    ;
;                                                     ;
; output:  none.                                      ;
;-----------------------------------------------------;
put_0x13_sprite:
	  pushad				      ; this was a
     .row_loop: 				      ; nightmare to write.
	  dec	  dx				      ; guess how many times
	  push	  cx				      ; i got lost in the push
	  push	  ax				      ; and pops here.. ;)
     .col_loop: 				      ; not to mention what
	  dec	  cx				      ; time it was when i wrote
	  push	  ax				      ; it.. :P
	  push	  bx
	  push	  cx
	  mov	  cx, bx
	  mov	  bx, ax
	  lodsb
	  call	  put_0x13_pixel
	  pop	  cx
	  pop	  bx
	  pop	  ax
	  inc	  ax
	  cmp	  cx, 0
	  jne	  .col_loop
	  pop	  ax
	  pop	  cx
	  inc	  bx
	  cmp	  dx, 0
	  jne	  .row_loop
	  popad
	  ret


;---------------------------------------------;
;  sets the palette (256 colors)              ;
;                                             ;
; input:  esi = palette.                      ;
; output: none.                               ;
;---------------------------------------------;
set_palette256:
	  push	  ax
	  push	  cx
	  push	  dx

	  xor	  cx, cx
     .l1:
	  mov	  dx, 0x03C8
	  mov	  al, cl			      ; color no. = loop no.
	  out	  dx, al
	  inc	  dx				      ; port 0x3C9
	  mov	  al, byte [esi]		      ; red
	  out	  dx, al
	  inc	  esi
	  mov	  al, byte [esi]		      ; green
	  out	  dx, al
	  inc	  esi
	  mov	  al, byte [esi]		      ; blue
	  out	  dx, al
	  inc	  esi

	  inc	  cx
	  cmp	  cx, 256
	  jl	  .l1

	  pop	  dx
	  pop	  cx
	  pop	  ax
	  ret


;---------------------------------------------;
;  sets the palette (16 colors)               ;
;                                             ;
; input:  esi = pointer to palette.           ;
; output: none.                               ;
;---------------------------------------------;
set_palette16:
	  push	  ax
	  push	  cx
	  push	  dx

	  xor	  cx, cx
     .l1:
	  mov	  dx, 0x3DA
	  in	  al, dx
	  mov	  al, cl			      ; color no.
	  mov	  dx, 0x3C0
	  out	  dx, al
	  inc	  dx				      ; port 0x3C1
	  in	  al, dx
	  mov	  dx, 0x3C8
	  out	  dx, al

	  inc	  dx				      ; port 0x3C9
	  mov	  al, byte [esi]		      ; red
	  out	  dx, al
	  inc	  esi
	  mov	  al, byte [esi]		      ; green
	  out	  dx, al
	  inc	  esi
	  mov	  al, byte [esi]		      ; blue
	  out	  dx, al
	  inc	  esi

	  inc	  cx
	  cmp	  cx, 16
	  jl	  .l1

	  mov	  dx, 0x3DA
	  in	  al, dx
	  mov	  al, 0x20
	  mov	  dx, 0x3C0
	  out	  dx, al

	  pop	  dx
	  pop	  cx
	  pop	  ax
	  ret



;---------------------------------;
;  Set VGA regs to choosen mode   ;
;           internal use.         ;
;---------------------------------;
set_regs:
	  cli
	  mov	  dx, 0x3C2
	  lodsb
	  out	  dx, al

	  mov	  dx, 0x3DA
	  lodsb
	  out	  dx, al

	  xor	  ecx, ecx
	  mov	  dx, 0x3C4
     .l1:
	  lodsb
	  xchg	  al, ah
	  mov	  al, cl
	  out	  dx, ax
	  inc	  ecx
	  cmp	  cl, 4
	  jbe	  .l1

	  mov	  dx, 0x3D4
	  mov	  ax, 0x0E11
	  out	  dx, ax

	  xor	  ecx, ecx
	  mov	  dx, 0x3D4
     .l2:
	  lodsb
	  xchg	  al, ah
	  mov	  al, cl
	  out	  dx, ax
	  inc	  ecx
	  cmp	  cl, 0x18
	  jbe	  .l2

	  xor	  ecx, ecx
	  mov	  dx, 0x3CE
     .l3:
	  lodsb
	  xchg	  al, ah
	  mov	  al, cl
	  out	  dx, ax
	  inc	  ecx
	  cmp	  cl, 8
	  jbe	  .l3

	  mov	  dx, 0x3DA
	  in	  al, dx

	  xor	  ecx, ecx
	  mov	  dx, 0x3C0
     .l4:
	  in	  ax, dx
	  mov	  al, cl
	  out	  dx, al
	  lodsb
	  out	  dx, al
	  inc	  ecx
	  cmp	  cl, 0x14
	  jbe	  .l4

	  mov	  al, 0x20
	  out	  dx, al

	  sti
	  ret