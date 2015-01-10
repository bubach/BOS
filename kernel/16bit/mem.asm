;----------------------------------------------------------;
; BOS kernel                Christoffer Bubach, 2003-2005. ;
;----------------------------------------------------------;
;                                                          ;
;      Get memory size, only using E801 right now.         ;
;                                                          ;
;----------------------------------------------------------;

;-----------------------------------------;
;  get mem                                ;
;   in:  nothing                          ;
;   out: eax = mem in bytes, 0 = error    ;
;-----------------------------------------;
getmem:
	  push	  dx
	  push	  cx
	  push	  ebx

	  xor	  eax, eax
	  xor	  ebx, ebx
	  mov	  ax, 0xE801
	  xor	  dx, dx
	  xor	  cx, cx
	  int	  0x15
	  jnc	  .cont1
	  xor	  eax, eax
	  jmp	  .end				      ; failed! :'(

     .cont1:
	  mov	  si, ax
	  or	  si, bx
	  jne	  .cont
	  mov	  ax, cx
	  mov	  bx, dx

     .cont:
	  cmp	  ax, 0x3C00
	  jb	  .below_16
	  movzx   eax, bx
	  add	  eax, 0x100
	  shl	  eax, 16			      ; eax = eax * 65536
	  jmp	  .end

     .below_16:
	  shl	  eax, 10			      ; eax = eax * 1024

     .end:
	  pop	  ebx
	  pop	  cx
	  pop	  dx
	  ret