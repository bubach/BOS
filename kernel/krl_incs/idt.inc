;----------------------------------------------------------;
; BOS kernel                Christoffer Bubach, 2003-2005. ;
;----------------------------------------------------------;
;                                                          ;
;       set/modify IDT entries                             ;
;                                                          ;
;----------------------------------------------------------;



;--------------------------------------------------;
;     set up IDT                                   ;
; in:  edi = pointer to "unhandled int"-function.  ;
;--------------------------------------------------;
init_idt:
	  push	  eax
	  push	  ecx

	  mov	  ecx, 0
     .loop:					      ; loop
	  mov	  eax, edi			      ; and
	  mov	  [(0x6c00+ecx)], ax		      ; set whole IDT
	  add	  ecx, 2			      ; to one ISR

	  mov	  dword [(0x6c00+ecx)], 0x8E000008    ; 0x6c00 is where
	  add	  ecx, 4			      ; we put the IDT

	  mov	  eax, edi
	  shr	  eax, 16
	  mov	  [(0x6c00+ecx)], ax
	  add	  ecx, 2

	  cmp	  ecx, 0x800			      ; 256 ints
	  jb	  .loop 			      ; * 8 bytes each

	  pop	  ecx
	  pop	  eax
	  ret



;--------------------------------------;
;  modify IDT, set any int             ;
;     in: cl  = int number             ;
;         edi = int function pointer   ;
;--------------------------------------;
set_int:
	  push	  eax
	  push	  ecx

	  mov	  al, 8 			      ; 8 bytes for each int
	  mul	  cl				      ; cl * al = ax
	  movzx   ecx, ax			      ; ecx = offset in IDT (1/2 for dword list)
	  mov	  [(idt_list+ecx/2)], edi	      ; add new int to idt entry list

	  mov	  eax, edi
	  mov	  [(0x6c00+ecx)], ax
	  add	  ecx, 2

	  mov	  dword [(0x6c00+ecx)], 0x8E000008
	  add	  ecx, 4

	  mov	  eax, edi
	  shr	  eax, 16
	  mov	  [(0x6c00+ecx)], ax

	  pop	  ecx
	  pop	  eax
	  ret



;------------------------------------------------;
;   get int address                              ;
;      in:  cl  = int number                     ;
;      out: esi = address or 0 if none present   ;
;------------------------------------------------;
get_int:
	  push	  eax

	  mov	  eax, 4			      ; 4 bytes for each address
	  mul	  cl				      ; cl * al = ax
	  mov	  esi, idt_list
	  add	  esi, eax

	  pop	  eax
	  ret




;----------------------------------------;
;   sets ints from list                  ;
;      in:  esi = pointer to int list    ;
;----------------------------------------;
set_idt_list:
	  push	  eax
	  push	  edi

	  mov	  ecx, 0
     .loop:
	  lodsd
	  or	  eax, eax
	  jz	  .next
	  mov	  edi, eax
	  call	  set_int
     .next:
	  inc	  ecx
	  cmp	  ecx, 0x100
	  jb	  .loop

	  pop	  edi
	  pop	  eax
	  ret



;------------------------------;
;   list of idt entries.       ;
;           0 = not handled    ;
;------------------------------;
idt_list:	     dd   isr00
		     dd   isr01
		     dd   isr02
		     dd   isr03
		     dd   isr04
		     dd   isr05
		     dd   isr06
		     dd   isr07
		     dd   isr08
		     dd   isr09
		     dd   isr0A
		     dd   isr0B
		     dd   isr0C
		     dd   isr0D
		     dd   isr0E
		     dd   0
		     dd   isr10
		     dd   isr11
		     dd   isr12
		     dd   isr13
	    times 12 dd   0			      ; 12 unused ints
		     dd   isr20
		     dd   isr21
	    times 16 dd   0			      ; 16 unused ints
		     dd   isr32 		      ; First free and BOS system interrupt.
	   times 205 dd   0			      ; 205 unused ints