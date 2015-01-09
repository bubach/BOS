;-------------------------------------------------------;
;		      BOS kernel			;
;-------------------------------------------------------;
;    BOS 32-bit kernel, expects to be loaded at 64kb	;
;    in mem.   Small amount of 16-bit code included.	;
;							;
;      For any comments on this code, mail me.		;
;   http://bos.asmhackers.net/	 asmhacker@gmail.com	;
;							;
;	      by: Christoffer Bubach, 2003-2005 	;
;-------------------------------------------------------;
use16
org 0x8000

;---------------------------;
;  jump to starting point   ;
;---------------------------;
	  jmp 	  start

;----------------------------------------;
;     16-bit include files		 ;
;----------------------------------------;
	  include  'realmode/a20.inc'		      ; Function to set the a20-gate.
	  include  'realmode/gdt.inc'		      ; Global Description Table.
	  include  'realmode/idt.inc'		      ; The Interrupt Description Table.
	  include  'realmode/mem.inc'		      ; Get memory size.
	  include  'realmode/variables.inc'	      ; For/from realmode.
	  include  'realmode/do_all_16bit.inc'	      ; Save "go back to 16-bit"-info.



;--------------------------;
;   16-bit entry point	   ;
;--------------------------;
start:
	  cli
	  mov	  ax, cs
	  mov	  ds, ax
						      ; fasm is more strict about
	  xor	  eax, eax			      ; "org 0x10000" then nasm, so
	  mov	  es, ax			      ; i have to do -0x10000 from
	  mov	  fs, ax			      ; all variable addresses while
	  mov	  gs, ax			      ; in realmode.
	  sti

	  call	  enable_a20
	  call	  do_all_16bit			      ; ...  :P

	  cli
	  mov	  ax, cs			      ; save cs
	  mov	  [realmode_cs], ax	      ; in variables.inc

	  lgdt	  [gdtr]		      ; Load the GDT descriptor
	  lidt	  [idtr]		      ; Load the IDT descriptor

	  mov	  eax, cr0
	  or	  al, 1
	  mov	  cr0, eax

	  jmp	  pword 0x08:flush		      ; dword in nasm



;--------------------------;
;   32-bit entry point	   ;
;--------------------------;
use32
flush:
	  mov	  ax, 0x10			      ; refresh all segment registers
	  mov	  ds, ax
	  mov	  es, ax
	  mov	  fs, ax
	  mov	  gs, ax
	  mov	  ss, ax
	  mov	  esp, 0xFFFC

	  call	  bos_init			      ; fix everything

	  mov	  bx, 0x04B1			      ; start the shell
	  call	  setcursor
	  mov	  esi, bos_shell
	  mov	  bl, 0x07
	  call	  print
	  call	  init_cmd
	  jmp	  shell

	  ;int	   0x32

     .hang:
	  cli
	  hlt
	  jmp	  .hang 			      ; hang, just in case..


;----------------------------------------;
;     32-bit include files		 ;
;----------------------------------------;
	  include  'krl_incs/idt.inc'		      ; The Interrupt Description Table.
	  include  'krl_incs/text.inc'		      ; The default textmode functions.
	  include  'krl_incs/bos_init.inc'	      ; Function that starts up BOS
	  include  'krl_incs/en_mess.inc'	      ; All strings in english (soon).
	  include  'krl_incs/rmode_int.inc'	      ; Get back to realmode and do an INT.
	  include  'krl_incs/pic.inc'		      ; PIC rutines.
	  include  'krl_incs/sys_ints.inc'	      ; System specific interrupts.
	  include  'krl_incs/keyboard.inc'	      ; Keyboard ISR.
	  include  'krl_incs/keymap.inc'	      ; Keymap(s).
	  include  'krl_incs/shell.inc' 	      ; File with shell/kernel monitor functions.
	  include  'krl_incs/commands.inc'	      ; Command table, for valid shell commands.
	  include  'krl_incs/isr.inc'		      ; Interrupt Service Rutines.
	  include  'krl_incs/debug.inc' 	      ; Print contents of all regs and hang.
	  include  'krl_incs/cmos.inc'		      ; To get CMOS data.
	  include  'krl_incs/time_date.inc'	      ; Print time and date.
	  include  'krl_incs/timer.inc' 	      ; Timer IRQ.
	  include  'krl_incs/vga.inc'		      ; VGA functions.
	;  include  'krl_incs/font8x16.inc'	       ; Standard font.
	  include  'krl_incs/dma.inc'		      ; DMA code.
	  include  'krl_incs/fdc.inc'		      ; Floppy code.
	  include  'krl_incs/mario.inc' 	      ; Mario sprite.
	  include  'krl_incs/pc_speaker.inc'	      ; PC speaker.
	  include  'krl_incs/mem.inc'		      ; Memory allocation and freeing.