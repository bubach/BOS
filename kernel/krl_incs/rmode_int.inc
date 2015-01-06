;----------------------------------------------------------;
; BOS kernel                Christoffer Bubach, 2003-2005. ;
;----------------------------------------------------------;
;                                                          ;
;        Goes back to realmode to do an INT.               ;
;                                                          ;
;----------------------------------------------------------;


rmode_int:
	  pushad
	  push	  eax
	  shr	  eax, 16			      ; move high bits to ax
	  mov	  word [realmode_ax], ax	      ; save new ax value
	  pop	  eax				      ; restore

	  push	  ebx
	  shr	  ebx, 16			      ; move high bits to bx
	  mov	  byte [int_number], bl 	      ; save int number to call
	  pop	  ebx

	  mov	  byte [realmode_error], 0	      ; all variables is in the
	  mov	  word [realmode_bx], bx	      ; realmode/variables.inc file
	  mov	  word [realmode_cx], cx
	  mov	  word [realmode_dx], dx
	  call	  disable_irqs
	  jmp	  pword 0x18:do_16pmode-0x10000       ; must substract 0x10000 from
						      ; data addresses becasue of
						      ; fasm strict "org" behavior
use16
do_16pmode:
	  mov	  ax, 0x20
	  mov	  ds, ax
	  mov	  es, ax
	  mov	  fs, ax
	  mov	  gs, ax
	  mov	  ss, ax

	  cli
	  mov	  eax, cr0
	  and	  al, 0xFE
	  mov	  cr0, eax

	  jmp	  0x1000:(do_realm-0x10000)

do_realm:
	  mov	  ax, cs
	  mov	  ds, ax

	  xor	  ax, ax
	  mov	  es, ax
	  mov	  fs, ax
	  mov	  gs, ax
	  mov	  ss, ax

	  lidt	  [ridtr - 0x10000]		      ; realmode/variables.inc
	  sti

	  mov	  ax, word [realmode_ax - 0x10000]
	  mov	  bx, word [realmode_bx - 0x10000]
	  mov	  cx, word [realmode_cx - 0x10000]
	  mov	  dx, word [realmode_dx - 0x10000]

	  push	  ax				      ; this is some cool shit.. ;)
	  mov	  al, [int_number - 0x10000]	      ; interrupt to preform
	  mov	  [$+5 - 0x10000], al		      ; move it to right pos.
	  pop	  ax
	  db	  0xCD				      ; opcode for int.
	  db	  0x00				      ; move int_number here

	  jnc	  .no_error
	  mov	  byte [realmode_error - 0x10000], 1

     .no_error:
	  mov	  word [realmode_ax - 0x10000], ax
	  mov	  word [realmode_bx - 0x10000], bx
	  mov	  word [realmode_cx - 0x10000], cx
	  mov	  word [realmode_dx - 0x10000], dx

	  cli

	  lgdt	  [gdtr - 0x10000]
	  lidt	  [idtr - 0x10000]
	  mov	  eax, cr0
	  or	  al, 1
	  mov	  cr0, eax

	  jmp	  pword 0x08:gobackto_pm


use32
gobackto_pm:
	  mov	  ax, 0x10			      ; refresh all segment registers
	  mov	  ds, ax
	  mov	  es, ax
	  mov	  fs, ax
	  mov	  gs, ax
	  mov	  ss, ax
	  call	  enable_irqs
	  sti
	  popad
	  clc					      ; clear carry.
	  cmp	  [realmode_error], 1		      ; if error, then
	  jne	  .end
	  stc					      ; set carry.
     .end:
	  ret