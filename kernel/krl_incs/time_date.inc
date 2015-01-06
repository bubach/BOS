;----------------------------------------------------------;
; BOS kernel                     Christoffer Bubach, 2005. ;
;----------------------------------------------------------;
;                                                          ;
;        functions to print date and time.                 ;
;                                                          ;
;----------------------------------------------------------;

;------------------;
;    variables     ;
;------------------;
     msg_time	     db   13,10,'   Time: ',0
     msg_date	     db   13,10,'   Date: ',0


;------------------------------------------------------;
;   date, prints current date and goes back to the     ;
;   prompt. swedish i.e. normal :) format              ;
;------------------------------------------------------;
print_date:
	  push	  eax
	  push	  ebx
	  push	  esi

	  mov	  esi, msg_date
	  mov	  bl, 0x07
	  call	  print 			      ; text.inc
	  call	  get_cmos_data 		      ; cmos.inc

	  mov	  al, [century] 		      ; cmos.inc
	  call	  BCD2ascii
	  push	  eax
	  mov	  bh, 0x07
	  mov	  bl, al
	  call	  print_char
	  pop	  eax
	  mov	  bl, ah
	  call	  print_char

	  mov	  al, [year]
	  call	  BCD2ascii
	  push	  eax
	  mov	  bl, al
	  call	  print_char
	  pop	  eax
	  mov	  bl, ah
	  call	  print_char

	  mov	  bl, ':'
	  call	  print_char

	  mov	  al, [month]
	  call	  BCD2ascii
	  push	  eax
	  mov	  bl, al
	  call	  print_char
	  pop	  eax
	  mov	  bl, ah
	  call	  print_char

	  mov	  bl, ':'
	  call	  print_char

	  mov	  al, [day]
	  call	  BCD2ascii
	  push	  eax
	  mov	  bl, al
	  call	  print_char
	  pop	  eax
	  mov	  bl, ah
	  call	  print_char

	  pop	  esi
	  pop	  ebx
	  pop	  eax
	  ret


;------------------------------------------------------;
;   time, prints current time and goes back to the     ;
;   prompt.                                            ;
;------------------------------------------------------;
print_time:
	  push	  eax
	  push	  ebx
	  push	  esi

	  mov	  esi, msg_time
	  mov	  bl, 0x07
	  call	  print 			      ; text.inc
	  call	  get_cmos_data 		      ; cmos.inc
	  mov	  al, [hour]			      ; cmos.inc
	  call	  BCD2ascii
	  push	  eax
	  mov	  bh, 0x07
	  mov	  bl, al
	  call	  print_char
	  pop	  eax
	  mov	  bl, ah
	  call	  print_char

	  mov	  bl, ':'
	  call	  print_char

	  mov	  al, [minute]
	  call	  BCD2ascii
	  push	  eax
	  mov	  bl, al
	  call	  print_char
	  pop	  eax
	  mov	  bl, ah
	  call	  print_char

	  mov	  bl, ':'
	  call	  print_char

	  mov	  al, [second]
	  call	  BCD2ascii
	  push	  eax
	  mov	  bl, al
	  call	  print_char
	  pop	  eax
	  mov	  bl, ah
	  call	  print_char

	  pop	  esi
	  pop	  ebx
	  pop	  eax
	  ret