;----------------------------------------------------------;
; BOS kernel                Christoffer Bubach, 2004-2005. ;
;----------------------------------------------------------;
;                                                          ;
;     Internal PCspeaker functions.                        ;
;                                                          ;
;----------------------------------------------------------;

;-----------------------;
;  turn on PC speaker   ;
;    bx = frequency     ;
;-----------------------;
speaker_on:
	  mov	  dx, 0x12
	  mov	  ax, 0x34DC
	  div	  bx
	  mov	  bl, al
	  mov	  al, 0xB6
	  out	  0x43, al
	  mov	  al, bl
	  out	  0x42, al
	  mov	  al, ah
	  out	  0x42, al
	  in	  al, 0x61
	  or	  al, 3
	  out	  0x61, al
	  ret


;----------------------;
;  turn speaker off    ;
;----------------------;
speaker_off:
	  push	  ax
	  in	  al, 0x61
	  and	  al, 0xFC			      ; some do 0xFD, some 0xFC... :/
	  out	  0x61, al
	  pop	  ax
	  ret


;----------------------------------;
; PC-speaker; beep                 ;
;----------------------------------;
beep:
	  push	  eax
	  push	  ecx
	  in	  al, 0x61			      ; turn the speaker on.
	  or	  al, 3
	  out	  0x61, al
	  mov	  ecx, 50
	  call	  delay 			      ; timer.inc
	  call	  speaker_off
	  pop	  ecx
	  pop	  eax
	  ret