;------------------------------------------------------------;
;                     BOS - test kernel                      ;
;------------------------------------------------------------;
;                                                            ;
;          by: Christoffer Bubach, 2003-2005                 ;
;   http://bos.asmhackers.net/      asmhacker@gmail.com      ;
;                                                            ;
;------------------------------------------------------------;

;     16-bit mem map  (seg:off)
;  0x0000:0x0000 -> 0x0000:0x0500  BIOS stuff
;  0x0000:0x0500 -> 0x0000:0x2100  root
;  0x0000:0x2100 -> 0x0000:0x3300  fat
;  0x0000:0x3300 -> 0x0000:0x6c00  14,25kb free space
;  0x0000:0x6c00 -> 0x0000:0x7c00  IDT and GDT (256 desc. eatch)
;  0x0000:0x7c00 -> 0x0000:0x7e00  bootsector
;  0x0000:0x7e00 <- 0x0000:0xffff  ~32,5kb stack for boot
;  0x1000:0x0000 -> 0x9000:0xffff  576kb free space
;  0xa000:0x0000 -> .............  VGA mem etc.

use16
org 0x0000
	  jmp	  start

	   include 'realmode/a20.inc'
	   include 'realmode/variables.inc'
     ;----------------------------------------------------;
     ;  show a message and wait for a key before reboot   ;
     ;----------------------------------------------------;
     first:
	  mov	  bp, first16
	  mov	  ax, 0x1301
	  mov	  bx, 4
	  mov	  cx, 19
	  mov	  dx, 0x0401
	  int	  0x10

	  mov	  ah, 0
	  int	  0x16
	  ;int     0x19
	  ret

	  first16     db  'Now in 16 bit mode.'


;------------------------------------------;
;   starting point of second stage code    ;
;------------------------------------------;
start:
	  cli
	  mov	  ax, 0x1000
	  mov	  ds, ax			      ; registers.
	  mov	  es, ax
	  mov	  ss, ax
	  mov	  sp, 0xFFFF			      ; Stack..
	  sti


;----------------------;
;   enable a20 gate    ;
;----------------------;
a20:						      ; Enable A20
	  in	  al, 0x64
	  test	  al, 2
	  jnz	  a20
	  mov	  al, 0xD1
	  out	  0x64, al
     .d6:
	  in	  al, 0x64
	  and	  ax, 2
	  jnz	  .d6
	  mov	  al, 0xDF
	  out	  0x60, al


;-----------------;
; display message ;
;-----------------;
	  call	  first


;------------------------;
;   enter 32-bit mode    ;
;------------------------;
pmode:
    ;      xor     ebx, ebx
    ;      mov     bx, ds
    ;      shl     ebx, 4
    ;      mov     [BaseAddOn], ebx
    ;      mov     eax, ebx

    ;      mov     [gdt.BOS_code + 2], ax
    ;      mov     [gdt.BOS_data + 2], ax
    ;      mov     [gdt.BOS_16code + 2], ax
    ;      mov     [gdt.BOS_16data + 2], ax

    ;      shr     eax, 16

    ;      mov     [gdt.BOS_code + 4], al
    ;      mov     [gdt.BOS_data + 4], al
    ;      mov     [gdt.BOS_16code + 4], al
    ;      mov     [gdt.BOS_16data + 4], al

    ;      mov     [gdt.BOS_code + 7], ah
    ;      mov     [gdt.BOS_data + 7], ah
    ;      mov     [gdt.BOS_16code + 7], ah
    ;      mov     [gdt.BOS_16data + 7], ah

    ;      add     ebx, gdt

    ;      mov     [gdtr + 2], ebx
    ;      add     ebx, idt_start - gdt
    ;      mov     [idtr + 2], ebx

	xor   ebx,ebx
	mov   bx,ds			       ; BX=segment
	shl   ebx,4			       ; BX="linear" address of segment base
	mov   eax,ebx
	mov   [sys_code_1 + 2],ax	       ; set base address of 32-bit segments
	mov   [sys_data_1 + 2],ax
	mov   [Real_code_1 + 2],ax	       ; set base address of 16-bit segments
	mov   [Real_data_1 + 2],ax
	shr   eax,16
	mov   [sys_code_1 + 4],al
	mov   [sys_data_1 + 4],al
	mov   [Real_code_1 + 4],al
	mov   [Real_data_1 + 4],al

	mov   [sys_code_1 + 7],ah
	mov   [sys_data_1 + 7],ah
	mov   [Real_code_1 + 7],ah
	mov   [Real_data_1 + 7],ah

	add   ebx,gdt			       ; EBX=linear address of gdt
	mov   [gdtr + 2],ebx

	cli				       ; Disable interrupts,
	mov   ax,cs
	mov   [RealModeCS],ax
	lgdt  [gdtr]			       ; Load the GDT descriptor

	mov   eax, cr0			       ; Copy the contents of CR0 into EAX
	or    eax, 1			       ; Set bit 0
	mov   cr0, eax			       ; Copy the contents of EAX into CR0

	;jmp   10h:clear_pipe                   ; Jump to code segment, offset clear_pipe

	;  cli                                         ; set protected mode (32-bit)
	;  lgdt    [gdtr]
	;  mov     eax, cr0
	;  or      eax, 1
	;  mov     cr0, eax

	  jmp	  0x08:flush

;----------------------------------------;
; start of 32-bit area.                  ;
;     flush segments and jump to kernel  ;
;----------------------------------------;
use32
flush:
	  mov	  eax, 0x10			      ; refresh all segment registers
	  mov	  ds, eax
	  mov	  es, eax
	  mov	  fs, eax
	  mov	  gs, eax
	  mov	  ss, eax
	  mov	  esp, 0xfffc

	  mov	  byte [ds:0B8502h], 'P'
	  mov	  byte [ds:0B8503h], 0x07	      ; Assign a color code

	  jmp	  $ ;hang



;--------------------------------;
;  global descriptor table (gdt) ;
;--------------------------------;
gdt:
    .null:	     dw   0x0000, 0x0000, 0x0000, 0x0000
    .codesel:	     dw   0xFFFF, 0x0000, 0x9800, 0x00CF
    .datasel:	     dw   0xFFFF, 0x0000, 0x9200, 0x00CF
gdt_end:

gdtr:
     .size:	     dw   gdt_end - gdt - 1
     .address	     dd   gdt ;+ 0x10000               ; 0x10000 is where we are in mem