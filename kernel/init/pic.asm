;----------------------------------------------------------;
; BOS 0.04                       Christoffer Bubach, 2004. ;
;----------------------------------------------------------;
;                                                          ;
;     PIC/IRQ handling.                                    ;
;                                                          ;
;----------------------------------------------------------;


;-------------------------------------------;
;  remap PICs to:  cl = pic1  ch = pic2     ;
;-------------------------------------------;
remap_pics:
	  push	  ax
	  push	  dx

	  mov	  al, 0x11			      ; IWC1
	  out	  0x20, al
	  out	  0xA0, al

	  mov	  al, cl			      ; IWC2
	  out	  0x21, al
	  mov	  al, ch
	  out	  0xA1, al

	  mov	  al, 0x04			      ; IWC3
	  out	  0x21, al
	  mov	  al, 0x02
	  out	  0xA1, al

	  mov	  al, 0x01			      ; IWC4
	  out	  0x21, al
	  out	  0xA1, al

	  pop	  dx
	  pop	  ax
	  ret


;----------------------;
;  disable all IRQs.   ;
;----------------------;
disable_irqs:
	  push	  ax

	  mov	  al, 0xFF
	  out	  0x21, al
	  out	  0xA1, al

	  pop	  ax
	  ret


;---------------------;
;  enable all IRQs.   ;
;---------------------;
enable_irqs:
	  push	  ax

	  mov	  al, 0x00
	  out	  0x21, al
	  out	  0xA1, al

	  pop	  ax
	  ret


;-----------------------------;
;  enable an IRQ.  cl = irq   ;
;-----------------------------;
enable_irq:
	  push	  ax
	  push	  cx

	  cmp	  cl, 8
	  jb	  .master

	  sub	  cl, 8
	  mov	  ah, 1
	  shl	  ah, cl
	  xor	  ah, 0xFF

	  in	  al, 0xA1
	  and	  al, ah
	  out	  0xA1, al

	  pop	  cx
	  pop	  ax
	  ret
  .master:
	  mov	  ah, 1
	  shl	  ah, cl
	  xor	  ah, 0xFF

	  in	  al, 0x21
	  and	  al, ah
	  out	  0x21, al

	  pop	  cx
	  pop	  ax
	  ret


;------------------------------;
;  disable an IRQ.  cl = irq   ;
;------------------------------;
disable_irq:
	  push	  ax
	  push	  cx

	  cmp	  cl, 8
	  jb	  .master

	  sub	  cl, 8
	  mov	  ah, 1
	  shl	  ah, cl

	  in	  al, 0xA1
	  or	  al, ah
	  out	  0xA1, al

	  pop	  cx
	  pop	  ax
	  ret
  .master:
	  mov	  ah, 1
	  shl	  ah, cl

	  in	  al, 0x21
	  or	  al, ah
	  out	  0x21, al

	  pop	  cx
	  pop	  ax
	  ret