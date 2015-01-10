;----------------------------------------------------------;
; BOS 0.04                  Christoffer Bubach, 2004-2005. ;
;----------------------------------------------------------;
;                                                          ;
;     Keyboard functions. IRQ, INT's and more.             ;
;                                                          ;
;----------------------------------------------------------;


;--------------;
;  Variabels   ;
;--------------;

     ;--------------------------------------------------------------------------------;
     ;   _______________________      Keyboard buffer system                          ;
     ;   | | | | | | | | | | | |                                                      ;
     ;   +---------------------+                                                      ;
     ;      |         +----------> kbd_head, here is where we put new scan-codes.     ;
     ;      +--------------------> kbd_tail, where we last read a key. this means     ;
     ;                     that we have 4 new scan-codes to read before we catch up.  ;
     ;--------------------------------------------------------------------------------;
	  kbd_buffer	  db   '           A 64-byte            '
			  db   '        keyboard buffer         '
	  kbd_head	  db   1		      ; head must be +1 from tail
	  kbd_tail	  db   0

     ;-------------------------------------------------------------------------;
     ; _________________        Flag byte:                                     ;
     ; |1|1|0|0|0|1|1|1|                                                       ;
     ; +---------------+                     1 = True   0 = False              ;
     ;  | | | | | | | +--->  shift key                                         ;
     ;  | | | | | | +----->  ctrl key                                          ;
     ;  | | | | | +------->  alt key                                           ;
     ;  | | | | +--------->  reserved bit                                      ;
     ;  | | | +----------->  reserved bit                                      ;
     ;  | | +------------->  reserved bit                                      ;
     ;  | +--------------->  ctrl + alt + del                                  ;
     ;  +----------------->  key released                                      ;
     ;-------------------------------------------------------------------------;
	  kbd_flags	  db   0		      ; flag byte

     ;-------------------------------------------------------------------------;
     ; _________________        LED status byte:                               ;
     ; |0|0|0|0|0|1|1|1|                                                       ;
     ; +---------------+                     1 = True   0 = False              ;
     ;            | | +--->  scroll lock                                       ;
     ;            | +----->  num lock                                          ;
     ;            +------->  caps lock                                         ;
     ;-------------------------------------------------------------------------;
	  kbd_status	  db   0		      ; LED statusbyte


;----------------------;
;   Keyboard IRQ       ;
;----------------------;
keyboard_isr:
	  push	  eax

     ;-------------------------;
     ;   get the scancode      ;
     ;-------------------------;
	  xor	  eax, eax
	  in	  al, 0x60

     ;------------------------------;
     ;  check if key was released   ;
     ;------------------------------;
	  test	  al, 0x80
	  jz	  .key_down
	  and	  byte [kbd_flags], 01111111b	      ; key up..

	  cmp	  al, 42+128			      ; left shift up?
	  je	  .shift_up
	  cmp	  al, 54+128			      ; right shift up?
	  je	  .shift_up

	  cmp	  al, 29+128			      ; ctrl up?
	  je	  .ctrl_up

	  cmp	  al, 83+128			      ; del up?
	  je	  .del_up

	  cmp	  al, 56+128			      ; alt up?
	  je	  .alt_up
	  jmp	  .end

     ;--------------------;
     ;  it was released   ;
     ;--------------------;
     .shift_up:
	  and	  byte [kbd_flags], 11111110b
	  jmp	  .end

     .del_up:
	  jmp	  .CAD_off

     .ctrl_up:
	  and	  byte [kbd_flags], 11111101b	   ; ctrl off.
	  jmp	  .CAD_off

     .alt_up:
	  and	  byte [kbd_flags], 11111011b	   ; alt off.
	  jmp	  .CAD_off

     .CAD_off:
	  test	  byte [kbd_flags], 01000000b
	  jz	  .CAD_is_off
	  and	  byte [kbd_flags], 10111111b	   ; ctrl+alt+del bit off.
     .CAD_is_off:
	  jmp	  .end

     ;----------------------------------------------;
     ;  a key was pressed, check for special keys   ;
     ;----------------------------------------------;
     .key_down:
	  or	  byte [kbd_flags], 10000000b

     .shift:
	  cmp	  al, 42
	  jnz	  .check_rshift
	  or	  byte [kbd_flags], 00000001b
	  jmp	  .end

     .check_rshift:
	  cmp	  al, 54
	  jnz	  .check_ctrl
	  or	  byte [kbd_flags], 00000001b
	  jmp	  .end

     .check_ctrl:
	  cmp	  al, 29
	  jnz	  .check_alt
	  or	  byte [kbd_flags], 00000010b
	  jmp	  .end

     .check_alt:
	  cmp	  al, 56
	  jnz	  .ctrl_alt_del
	  or	  byte [kbd_flags], 00000100b
	  jmp	  .end

     .ctrl_alt_del:
	  test	  byte [kbd_flags], 00000110b	      ; check for ctrl+alt
	  jz	  .check_caps
	  cmp	  al, 83			      ; check for delete
	  jne	  .check_caps
	  or	  byte [kbd_flags], 01000000b	      ; ctrl+alt+del bit on.

     ;-------------------------------------;
     ;  toggle caps, num and scroll lock   ;
     ;-------------------------------------;
     .check_caps:
	  cmp	  al, 58
	  jnz	  .check_num
	  xor	  byte [kbd_status], 4
	  call	  update_leds
	  jmp	  .end

     .check_num:
	  cmp	  al, 69
	  jnz	  .check_scroll
	  xor	  byte [kbd_status], 2
	  call	  update_leds
	  jmp	  .end

     .check_scroll:
	  cmp	  al, 70
	  jnz	  .end
	  xor	  byte [kbd_status], 1
	  call	  update_leds
	  jmp	  .end

     ;-----------------------------------;
     ;  put the scancode in the buffer   ;
     ;-----------------------------------;
     .end:
	  push	  eax
	  mov	  edi, kbd_buffer
	  xor	  eax, eax
	  mov	  al, [kbd_head]
	  add	  edi, eax
	  pop	  eax
	  stosb
	  cmp	  [kbd_head], 63		      ; if we reach the buffer
	  jne	  .cont1			      ; end, go back to 0.
	  cmp	  [kbd_tail], 0
	  je	  .error
	  mov	  [kbd_head], 0
	  jmp	  .quit
     .cont1:
	  mov	  ah, [kbd_tail]
	  mov	  al, [kbd_head]
	  add	  al, 1
	  cmp	  ah, al
	  je	  .error
	  inc	  [kbd_head]
	  jmp	  .quit
     .error:
	  call	  beep				      ; pc_speaker.inc
	  mov	  [kbd_head], 1 		      ; fix it as good
	  mov	  [kbd_tail], 0 		      ; as possible.. :S
     .quit:
	  mov	  al, 0x20
	  out	  0x20, al
	  pop	  eax
	  ret



;------------------------------;
;  Update the keyboard LED's   ;
;------------------------------;
update_leds:
	  push	  ax

	  call	  kbd_wait
	  mov	  al, 0xED
	  out	  0x60, al
	  call	  kbd_wait
	  mov	  al, [kbd_status]
	  out	  0x60, al
	  call	  kbd_wait

	  pop	  ax
	  ret



;------------------;
;  keyboard wait   ;
;------------------;
kbd_wait:
	  jmp	  $+2
	  in	  al, 0x64
	  test	  al, 1
	  jz	  .ok
	  jmp	  $+2
	  in	  al, 0x60
	  jmp	  kbd_wait
     .ok:
	  test	  al, 2
	  jnz	  kbd_wait
	  ret



;-------------------------------------------------------;
;  BOS INT to get a char.                               ;
;          out: ah = scan code,      al = ascii         ;
;               bh = flag-byte,      bl = led-byte      ;
;-------------------------------------------------------;
getc:
	  push	  esi

     .no_new:
	  mov	  al, [kbd_head]
	  mov	  ah, [kbd_tail]
	  cmp	  ah, 63
	  jne	  .check2
	  cmp	  al, 0
	  je	  .no_new
	  mov	  [kbd_tail], 0
	  jmp	  .done_check
     .check2:
	  mov	  bl, ah
	  inc	  bl
	  cmp	  bl, al
	  je	  .no_new
	  inc	  [kbd_tail]
     .done_check:

	  mov	  esi, kbd_buffer
	  movzx   eax, [kbd_tail]
	  add	  esi, eax
	  mov	  ah, byte [esi]		      ; ah = scancode
	  movzx   esi, byte [esi]		      ; esi = scancode

     ;------------------;
     ;  some checks..   ;
     ;------------------;
	  cmp	  ah, 0xFA
	  je	  .no_new
	  cmp	  ah, 0xE0
	  je	  .no_new
	  cmp	  ah, 0xE1
	  je	  .no_new
	  test	  ah, 0x80
	  jnz	  .no_new

     ;--------------------------------;
     ;  check for caps, shift & alt   ;
     ;--------------------------------;
	  test	  [kbd_status], 00000100b
	  jnz	  .caps
	  test	  [kbd_flags], 00000001b
	  jnz	  .shift

     ;------------------;
     ;  normal keymap   ;
     ;------------------;
	  mov	  al, [esi+keymap]		      ; scancode + keymap = ascii
	  jmp	  .end

     ;--------------------;
     ;  capslock keymap   ;
     ;--------------------;
     .caps:
	  test	  [kbd_flags], 00000001b
	  jnz	  .caps_and_shift

	  mov	  al, [esi+keymap_caps]
	  jmp	  .end

     ;--------------------------;
     ;  caps and shift keymap   ;
     ;--------------------------;
     .caps_and_shift:
	  mov	  al, [esi+keymap_caps_shift]
	  jmp	  .end

     ;-----------------;
     ;  shift keymap   ;
     ;-----------------;
     .shift:
	  mov	  al, [esi+keymap_shift]
	  jmp	  .end

     ;---------------------------;
     ;  set registers and exit   ;
     ;---------------------------;
     .end:
	  mov	  bl, [kbd_status]
	  mov	  bh, [kbd_flags]

	  pop	  esi
	  ret


;------------------------------;
;  "press any key to..."       ;
;------------------------------;
wait_key:
	  push	  eax
	  push	  ebx
	  push	  esi

     .no_new:
	  mov	  al, [kbd_head]
	  mov	  ah, [kbd_tail]
	  cmp	  ah, 63
	  jne	  .check2
	  cmp	  al, 0
	  je	  .no_new
	  mov	  [kbd_tail], 0
	  jmp	  .done_check
     .check2:
	  mov	  bl, ah
	  inc	  bl
	  cmp	  bl, al
	  je	  .no_new
	  inc	  [kbd_tail]
     .done_check:

	  mov	  esi, kbd_buffer
	  movzx   eax, [kbd_tail]
	  add	  esi, eax
	  mov	  ah, byte [esi]		      ; ah = scancode
	  cmp	  ah, 0xFA			      ; check for some stuff..
	  je	  .no_new
	  cmp	  ah, 0xE0
	  je	  .no_new
	  cmp	  ah, 0xE1
	  je	  .no_new
	  test	  ah, 0x80
	  jnz	  .no_new

	  pop	  esi
	  pop	  ebx
	  pop	  eax
	  ret