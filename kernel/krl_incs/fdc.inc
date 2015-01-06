;----------------------------------------------------------;
; BOS kernel                Christoffer Bubach, 2004-2005. ;
;----------------------------------------------------------;
;                                                          ;
;  floppy disk driver originally by Craig Bamford, Dex4u.  ;
;          adjustments and for BOS by bubach.              ;
;                                                          ;
;----------------------------------------------------------;

;  NOTE: I'm almost finished with a much improved version of
;        this code, that supports 2 drives of multiple types.
;        I'll wait with that until next version, so you won't
;        have to see a half finished mess here.

;---------------------------;
;  variables and contants   ;
;---------------------------;
     fdd_int_done    dw   0			      ; is the IRQ done?
     fdd_motor_on    db   0			      ; fdd motor on=1, off=0
     fdd_head	     db   0
     fdd_driveno     db   0
     fdd_track	     db   0
     fdd_sector      db   0

     fdd_errorcode   db   0			      ; this the error code 00 = no error
     fdd_tries	     db   0			      ; no. of times to try, before error.

     ResultST0	     db   0
     ResultST1	     db   0			      ; or pcn
     ResultST2	     db   0
     ResultST3	     db   0
     ResultC	     db   0
     ResultH	     db   0
     ResultR	     db   0
     ResultN	     db   0
     ResultExtra     db   0



;------------------------------------------------------;
;    initializes the floppy disk driver                ;
;                                                      ;
;------------------------------------------------------;
fdc_init:
	  push	  ecx
	  push	  edi

	  mov	  cl, 0x26			      ; hook interrupt 0x26 (IRQ6)
	  mov	  edi, floppy_irq
	  call	  set_int

	  mov	  cl, 6 			      ; enable IRQ6
	  call	  enable_irq

	  call	  fdd_reset			      ; reset FDC
	  call	  fdd_recalibrate

	  pop	  edi
	  pop	  ecx
	  ret



;------------------------------------------------------;
;         floppy IRQ                                   ;
;                                                      ;
;------------------------------------------------------;
floppy_irq:
	  pusha
	  push	  gs
	  push	  fs
	  push	  ds
	  push	  es
	  push	  esi

	  or	  [fdd_int_done], 1
	  mov	  al, 0x20
	  out	  0x20, al

	  pop	  esi
	  pop	  es
	  pop	  ds
	  pop	  fs
	  pop	  gs
	  popa
	  iret



;------------------------------------------------------;
;     wait for a floppy int                            ;
;                           out:  cf  = 1 if timeout   ;
;------------------------------------------------------;
wait_int:
	  push	  eax
	  push	  ecx

	  mov	  ecx, 150			      ; 150 = 1.5 seconds.
	  call	  active_delay			      ; timer.inc
     .l1:
	  cmp	  dword [ecx], 0		      ; timeup?
	  je	  .error
	  mov	  ax, [fdd_int_done]		      ; if not we check for int.
	  or	  ax, ax
	  jz	  .l1
	  pop	  ecx
	  pop	  eax
	  clc
	  ret
     .error:
	  pop	  ecx
	  pop	  eax
	  stc
	  ret



;------------------------------------------------------;
;     fdd motor off                                    ;
;                           out:  nothing              ;
;------------------------------------------------------;
fdd_off:
	  push	  eax
	  push	  edx

	  mov	  dx, 0x3F2
	  mov	  al, 0 			      ; all motors off..
	  out	  dx, al
	  mov	  [fdd_motor_on], 0

	  pop	  edx
	  pop	  eax
	  ret




;------------------------------------------------------;
;     fdd motor on                                     ;
;                           out: nothing               ;
;------------------------------------------------------;
fdd_on:
	  push	  eax
	  push	  edx

	  mov	  dx, 0x3F2			      ; motor 0 on..
	  mov	  al, 0x1C
	  out	  dx, al

	  mov	  ecx, 20			      ; 1/5 of a sec. to speed up
	  call	  delay 			      ; in timer.inc
	  mov	  [fdd_motor_on], 1

	  pop	  edx
	  pop	  eax
	  ret



;------------------------------------------------------;
;   send a data byte to the FDC                        ;
;                                                      ;
;                                in:  al  = data byte  ;
;------------------------------------------------------;
fdc_sendbyte:
	  push	  edx
	  push	  ecx
	  push	  eax

	  mov	  ecx, 150			      ; 150 = 1.5 seconds.
	  call	  active_delay			      ; timer.inc
     .l1:
	  cmp	  dword [ecx], 0		      ; timeup?
	  je	  .error
	  mov	  dx, 0x3f4			      ; check status reg
	  in	  al, dx
	  and	  al, 11000000b
	  cmp	  al, 10000000b 		      ; are we ok to write
	  jnz	  .l1

	  pop	  eax
	  pop	  ecx
	  mov	  dx, 0x3F5			      ; send byte
	  out	  dx, al
	  pop	  edx
	  clc
	  ret
     .error:
	  pop	  eax
	  pop	  ecx
	  pop	  edx
	  stc
	  ret


;------------------------------------------------------;
;   read a data byte from the FDC                      ;
;                                                      ;
;                             out: al  = data byte     ;
;------------------------------------------------------;
fdc_getbyte:
	  push	  edx
	  push	  ecx
	  push	  eax

	  mov	  ecx, 150			      ; 150 = 1.5 seconds.
	  call	  active_delay			      ; timer.inc
     .l1:
	  cmp	  dword [ecx], 0		      ; timeup?
	  je	  .error
	  mov	  dx, 0x3f4			      ; check status reg
	  in	  al, dx
	  and	  al, 11000000b
	  cmp	  al, 11000000b 		      ; are we ok to read
	  jnz	  .l1

	  pop	  eax
	  pop	  ecx
	  mov	  dx, 0x3F5			      ; get the byte
	  in	  al, dx
	  pop	  edx
	  clc
	  ret
     .error:
	  pop	  eax
	  pop	  ecx
	  pop	  edx
	  stc
	  ret




;------------------------------------------------------;
;    reset controller                                  ;
;                                                      ;
;------------------------------------------------------;
fdd_reset:
	  push	  eax
	  push	  ecx
	  push	  edx

	  mov	  dx, 0x3F2
	  mov	  al, 00001000b 		      ; no motors enabled, DMA Enabled, held FDC at reset
	  out	  dx, al			      ; drive A selected.

	  mov	  ecx, 5
	  call	  delay 			      ; in timer.inc

	  mov	  dx, 0x3F7
	  mov	  al, 00000000b 		      ; 500Kb/sec mode
	  out	  dx, al

	  mov	  dx, 0x3F2
	  or	  al, 00001100b 		      ; FDC completed reset, al =0x0c.
	  out	  dx, al

	  mov	  [fdd_int_done], 0		      ; we need to wait
	  call	  wait_int			      ; for floppy int.
	  jc	  .error			      ; jump to error exit, if timeout.

	  mov	  cx, 0x04			      ; after a reset, the interrupts must be
     .status:					      ; cleared by (four) dummy-reads.
	  mov	  al, 0x08			      ; sense interrupt status command
	  call	  fdc_sendbyte
	  call	  fdc_getbyte
	  call	  fdc_getbyte
	  loop	  .status

	  mov	  al, 0x03			      ; specify command (includes next two bytes sent)
	  call	  fdc_sendbyte
	  mov	  al, 0xDF			      ; SRT = 3ms, HUT = 240ms
	  call	  fdc_sendbyte
	  mov	  al, 0x02			      ; HLT = 16ms, ND = 0
	  call	  fdc_sendbyte
     .ok:
	  pop	  edx
	  pop	  ecx
	  pop	  eax
	  clc
	  ret
     .error:
	  pop	  edx
	  pop	  ecx
	  pop	  eax
	  stc
	  ret




;------------------------------------------------------;
;     fdd seek                                         ;
;                                                      ;
;------------------------------------------------------;
fdd_seek:
	  push	  eax

	  mov	  al, [ResultC] 		      ; put what track/cylinder we are at in al
	  cmp	  [fdd_track], al		      ; is it the same as we want
	  je	  .ok				      ; yes, then leave.

	  mov	  al, 0x0F			      ; seek command
	  call	  fdc_sendbyte
	  mov	  al, [fdd_driveno]		      ; drive # (00 = A)
	  call	  fdc_sendbyte
	  mov	  al, [fdd_track]		      ; cylinder #
	  call	  fdc_sendbyte

	  mov	  [fdd_int_done], 0
	  call	  wait_int
	  jc	  .error

	  mov	  al, 0x08			      ; sense interrupt status command
	  call	  fdc_sendbyte
	  call	  fdc_getbyte
	  mov	  ah, al			      ; save ST0 in ah
	  call	  fdc_getbyte			      ; should read PCN

	  test	  ah, 00100000b 		      ; test sr0 is 0x20
	  jz	  .error			      ; if not we have a error :-(.
	  test	  ah,10000000b			      ; test sr0 is 0x80
	  jnz	  .error			      ; if not we have a error :-(.
     .ok:					      ; succsess.. :-)
	  pop	  eax
	  clc
	  ret
     .error:
	  pop	  eax
	  stc
	  ret


;------------------------------------------------------;
;   fdd recalibrate                                    ;
;                                                      ;
;------------------------------------------------------;
fdd_recalibrate:
	  push	  eax

	  test	  [fdd_motor_on], 1
	  jnz	  .l1
	  call	  fdd_on
     .l1:
	  mov	  al, 0x07			      ; recalibrate command
	  call	  fdc_sendbyte
	  mov	  al, 0x00			      ; selects drive a:
	  call	  fdc_sendbyte

	  mov	  [fdd_int_done], 0
	  call	  wait_int
	  jc	  .error

	  mov	  al, 0x08			      ; sense interrupt status command
	  call	  fdc_sendbyte
	  call	  fdc_getbyte			      ; read STO
	  mov	  ah, al			      ; save ST0 in ah
	  call	  fdc_getbyte

	  test	  ah, 00100000b 		      ; test sr0 is 0x20
	  jz	  .error
	  test	  ah, 00010000b 		      ; test sr0 is 0x80
	  jnz	  .error
     .ok:
	  mov	  [ResultC], 0
	  pop	  eax
	  clc
	  ret
     .error:
	  pop	  eax
	  stc
	  ret



;------------------------------------------------------;
;  fdd read/write                                      ;
;   input:  bl  = 0 read, 1 write                      ;
;           ch  = track/cylinder                       ;
;           cl  = sector                               ;
;           dh  = head                                 ;
;           dl  = drive (only A: drive used, 00 )      ;
;   output: ah  = status                               ;
;           al  = sector number read                   ;
;           cf  = 0 if ok, 1 if error                  ;
;------------------------------------------------------;
fdd_read_write:
	  pushad
	  and	  dh, 00000001b 		      ; is it set to fdd_head 0 or 1?
	  mov	  [fdd_head], dh		      ; store it.
	  shl	  dh, 2 			      ; make the first 2 bits = 00 for A:.
	  mov	  [fdd_driveno], dh		      ; store it.

	  mov	  [fdd_errorcode], 0x04 	      ; put error code in ah, just incase
	  cmp	  ch, 0x51			      ; cmp if track number, is above 80 decimal (51 hex)?
	  jae	  .error			      ; if above jump error.
	  mov	  [fdd_track], ch		      ; if not above,store it.

	  cmp	  cl, 0x13			      ; cmp if fdd_sector number, is above 18 decimal (12 hex) ?.
	  jae	  .error			      ; if above jump error.
	  mov	  [fdd_sector], cl		      ; if not above,store it.

	  test	  [fdd_motor_on], 1
	  jnz	  .l1
	  call	  fdd_on
     .l1:
	  mov	  dx, 0x3F7
	  mov	  al, 00000000b 		      ; 500Kb/sec mode
	  out	  dx, al
	  mov	  [fdd_errorcode], 0x80 	      ; put basic error code, just in case.

	  xor	  ecx, ecx
	  mov	  cx, 3 			      ; we want to try seek 3 times
     .l2:
	  call	  fdd_seek			      ; we need to move to the right track.
	  jnc	  .l3				      ; we should be on the right track.
	  loop	  .l2
	  jmp	  .error			      ; timeout.
     .l3:
	  mov	  dx, 0x3f4			      ; check status reg (to see if DMA bit set)
	  in	  al, dx
	  test	  al, 00100000b 		      ; test sr0 is 0x80
	  jnz	  .error

	  cmp	  bl, 0
	  je	  .read_fdd

     .write_fdd:
	  mov	  bl, 2 			      ; channel 2
	  mov	  esi, 512			      ; bytes to write
	  mov	  ecx, 0x80000			      ; page & offset
	  mov	  bh, 1 			      ; write floppy, "read DMA"
	  call	  dma_transfer

	  mov	  al, 0xC5			      ; write fdd_sector command
	  call	  fdc_sendbyte
	  jmp	  .cont

     .read_fdd:
	  mov	  bl, 2 			      ; channel 2
	  mov	  esi, 512			      ; bytes to read
	  mov	  ecx, 0x80000			      ; page & offset
	  mov	  bh, 0 			      ; read floppy, "write DMA"
	  call	  dma_transfer

	  mov	  al, 0xE6			      ; read fdd_sector command
	  call	  fdc_sendbyte

     .cont:
	  mov	  al, [fdd_driveno]		      ; fdd_head no. 0, drive A:
	  call	  fdc_sendbyte
	  mov	  al, [fdd_track]		      ; cylinder
	  call	  fdc_sendbyte

	  mov	  al, [fdd_head]		      ; head/side 0 or 1
	  call	  fdc_sendbyte
	  mov	  al, [fdd_sector]		      ; sector number,starts at 1
	  call	  fdc_sendbyte
	  mov	  al, 0x02			      ; sector size - 512 bytes
	  call	  fdc_sendbyte

	  mov	  al, 0x12			      ; 18 decimal sectors to a track
	  call	  fdc_sendbyte
	  mov	  al, 0x1B			      ; 27 should be the gap length for a 3.5" 1.44Mb
	  call	  fdc_sendbyte
	  mov	  al, 0xFF			      ; not used data length, because sector size has been filled
	  call	  fdc_sendbyte

	  mov	  [fdd_int_done], 0
	  call	  wait_int
	  jc	  .error

	  call	  fdc_getbyte
	  mov	  [ResultST0], al		      ; save result of ST0 in var
	  call	  fdc_getbyte
	  mov	  [ResultST1], al		      ; save result of ST1 in var
	  call	  fdc_getbyte
	  mov	  [ResultST2], al		      ; save result of ST2 in var
	  call	  fdc_getbyte
	  mov	  [ResultC], al 		      ; save result of cylinder
	  call	  fdc_getbyte
	  mov	  [ResultH], al 		      ; save result of head
	  call	  fdc_getbyte
	  mov	  [ResultR], al 		      ; save result of sector number.
	  call	  fdc_getbyte
	  mov	  [ResultN], al 		      ; save result of sector size

	  test	  [ResultST0], 11000000b	      ; test sr0 is 0xC0
	  jnz	  .error
	  mov	  [fdd_errorcode], 0x00
     .ok:
	  popad
	  mov	  ah, [fdd_errorcode]		      ; move error status into ah
	  mov	  al, [ResultR]
	  clc
	  ret
     .error:
	  popad
	  mov	  ah, [fdd_errorcode]		      ; move error status into ah
	  stc
	  ret