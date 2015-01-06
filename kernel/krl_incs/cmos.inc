;----------------------------------------------------------;
; BOS kernel                     Christoffer Bubach, 2005. ;
;----------------------------------------------------------;
;                                                          ;
;     To get stuff ( time & date ) from CMOS memory.       ;
;                                                          ;
;----------------------------------------------------------;


;-----------------------------------;
;  variables containing CMOS data   ;
;-----------------------------------;
	  century	  db   0		      ; latest century,
	  year		  db   0		      ; year,
	  month 	  db   0		      ; month,
	  day		  db   0		      ; day (1 = sunday),
	  hour		  db   0		      ; hour,
	  minute	  db   0		      ; minute and
	  second	  db   0		      ; second read in from CMOS.


;-------------------------;
;  save info from CMOS    ;
;-------------------------;
get_cmos_data:
	  push	  ax

	  mov	  al, 0x00			      ; get the "second" byte
	  out	  0x70, al
	  in	  al, 0x71
	  mov	  [second], al			      ; save it.

	  mov	  al, 0x02			      ; get the "minute" byte
	  out	  0x70, al
	  in	  al, 0x71
	  mov	  [minute], al

	  mov	  al, 0x04			      ; get the "hour" byte
	  out	  0x70, al
	  in	  al, 0x71
	  mov	  [hour], al

	  mov	  al, 0x07			      ; get the "day" byte
	  out	  0x70, al
	  in	  al, 0x71
	  mov	  [day], al

	  mov	  al, 0x08			      ; get the "month" byte
	  out	  0x70, al
	  in	  al, 0x71
	  mov	  [month], al

	  mov	  al, 0x09			      ; get the "year" byte
	  out	  0x70, al
	  in	  al, 0x71
	  mov	  [year], al

	  mov	  al, 0x32			      ; get the "century" byte
	  out	  0x70, al
	  in	  al, 0x71
	  mov	  [century], al

	  pop	  ax
	  ret

;------------------------------------------------;
;   calculate binary from BCD                    ;
;                              in:  al = BCD     ;
;                              out: al = bin     ;
;------------------------------------------------;
BCD2bin:
	  push	  ebx
	  mov	  bl, al			      ; bl = al mod 16
	  and	  bl, 0x0F
	  shr	  al, 4 			      ; al = al / 16
	  mov	  bh, 10
	  mul	  bh				      ; multiply by 10
	  add	  al, bl			      ; add in low nib
	  pop	  ebx
	  ret


;------------------------------------------------;
;    calculate ASCII from BCD                    ;
;                              in:  al = BCD     ;
;                              out: ax = ASCII   ;
;------------------------------------------------;
BCD2ascii:
	  push	  ecx
	  mov	  ah, al
	  and	  ax, 0xF00F			      ; mask bits
	  shr	  ah, 4 			      ; right shift ah to get unpacked BCD
	  or	  ax, 0x3030			      ; combine with 30 to get ASCII
	  xchg	  ah, al			      ; swap for ASCII storage convention
	  pop	  ecx
	  ret