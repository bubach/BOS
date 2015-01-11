;----------------------------------------------------------;
; BOS kernel                Christoffer Bubach, 2004-2012. ;
;----------------------------------------------------------;
;                                                          ;
;               floppy disk driver.                        ;
;                                                          ;
;----------------------------------------------------------;


;---------------------------;
;  variables and contants   ;
;---------------------------;
    fdd_int_done    dw   0                            ; is the IRQ done?
    fdd_motor_on    db   0                            ; fdd motor on=1, off=0
    fdd_drivehead   db   0                            ; ((head*4)|drive)
    fdd_head        db   0
    fdd_track       db   0
    fdd_sector      db   0
    fdd_error       db   0                            ; should we recalibrate
                                                      ; at next read/write?
    fdd_errorcode   db   0

    result_ST0      db   0
    result_ST1      db   0                            ; or pcn
    result_ST2      db   0
    result_ST3      db   0
    result_C        db   0
    result_H        db   0
    result_R        db   0
    result_N        db   0
    result_extra    db   0



;------------------------------------------------------;
;    initializes the floppy disk driver                ;
;                                                      ;
;------------------------------------------------------;
fdc_init:
        push   eax
        push   ebx
        push   ecx
        push   edi
        push   esi

        xor    eax, eax                               ; get configuration
        mov    al, 0x10                               ; from CMOS.
        out    0x70, al
        in     al, 0x71

        shr    al, 4
        cmp    al, 4                                  ; a 1.44mb?
        jnz    .no_floppy

        mov    cl, 0x26                               ; hook IRQ 6
        mov    dx, 0x8                                ; CS = 8
        mov    edi, floppy_irq
        call   set_int

        mov    cl, 6                                  ; enable IRQ6
        call   enable_irq

        call   fdd_reset                              ; reset FDC

    .no_floppy:
        pop    esi
        pop    edi
        pop    ecx
        pop    ebx
        pop    eax
        ret



;------------------------------------------------------;
;         floppy IRQ                                   ;
;                                                      ;
;------------------------------------------------------;
floppy_irq:
		push   ds
		push   eax
		push   ebx

		mov    ax, 0x10
		mov    ds, ax

		mov    [fdd_int_done], 1
		mov    al, 0x20
		out    0x20, al

		pop    ebx
		pop    eax
		pop    ds
		iret



;------------------------------------------------------;
;     wait for a floppy int                            ;
;                           out:  cf  = 1 if timeout   ;
;------------------------------------------------------;
wait_int:
        push   eax
        push   ecx

        mov    ecx, 150                               ; 50 = 0.5 seconds.
        call   active_delay                           ; timer.inc
    .l1:
        cmp    dword [ecx], 0                         ; timeup?
        je     .error
        mov    ax, [fdd_int_done]                     ; if not we check for int.
        or     ax, ax
        jz     .l1

        clc
        jmp    .end
    .error:
        stc
    .end:
        pop    ecx
        pop    eax
        ret



;------------------------------------------------------;
;     fdd motor off                                    ;
;                           out:  nothing              ;
;------------------------------------------------------;
fdd_off:
		cmp    [fdd_motor_on], 0
		je     .end
		push   eax
		push   edx

		mov    dx, 0x3F2
		mov    al, 0x0c                               ; motor off
		out    dx, al
		mov    [fdd_motor_on], 0

		pop    edx
		pop    eax
    .end:
         ret



;------------------------------------------------------;
;     fdd motor on                                     ;
;                           out: nothing               ;
;------------------------------------------------------;
fdd_on:
		cmp    [fdd_motor_on], 1
		je     .end
		push   eax
		push   edx

		mov    dx, 0x3F2                              ; motor 0 on..
		mov    al, 0x1C
		out    dx, al

		mov    ecx, 20                                ; 1/5 of a sec. to speed up
		call   delay                                  ; in timer.inc
		mov    [fdd_motor_on], 1

		pop    edx
		pop    eax
    .end:
        ret



;------------------------------------------------------;
;   send a data byte to the FDC                        ;
;                                                      ;
;                                in:  al  = data byte  ;
;------------------------------------------------------;
fdc_sendbyte:
		push   edx
		push   ecx
		push   eax

		mov    ecx, 50                             ; 50 = 0.5 seconds.
		call   active_delay                        ; timer.inc
    .l1:
		cmp    dword [ecx], 0                      ; timeup?
		je     .error
		mov    dx, 0x3f4                           ; check status reg
		in     al, dx
		and    al, 0xC0
		cmp    al, 0x80                            ; ok to write?
		jnz    .l1

		pop    eax
		pop    ecx
		mov    dx, 0x3F5                           ; send byte
		out    dx, al
		pop    edx
		clc
		ret
    .error:
		pop    eax
		pop    ecx
		pop    edx
		stc
		ret



;------------------------------------------------------;
;   read a data byte from the FDC                      ;
;                                                      ;
;                             out: al  = data byte     ;
;------------------------------------------------------;
fdc_getbyte:
		push   edx
		push   ecx
		push   eax

		mov    ecx, 50                                ; 50 = 0.5 seconds.
		call   active_delay                           ; timer.inc
    .l1:
		cmp    dword [ecx], 0                         ; timeup?
		je     .error
		mov    dx, 0x3f4                              ; check status reg
		in     al, dx
		and    al, 0xD0
		cmp    al, 0xD0                               ; ok to read?
		jnz    .l1

		pop    eax
		pop    ecx
		mov    dx, 0x3F5                              ; get the byte
		in     al, dx
		pop    edx
		clc
		ret
    .error:
		pop    eax
		pop    ecx
		pop    edx
		stc
		ret



;------------------------------------------------------;
;   sense interrupt status command                     ;
;                                                      ;
;------------------------------------------------------;
sensei:
		push   eax

		mov    al, 0x08                            ; fdc command
		call   fdc_sendbyte
		call   fdc_getbyte
		mov    ah, al                              ; save ST0 in ah
		call   fdc_getbyte                         ; read PCN
		clc
		test   ah, 0x80                            ; test for error:
		jz     .end                                ; "invalid command"
		stc
    .end:
		pop    eax
		ret



;------------------------------------------------------;
;    reset controller                                  ;
;                                                      ;
;------------------------------------------------------;
fdd_reset:
		push   eax
		push   ecx
		push   edx

		mov    byte [fdd_motor_on], 0

		mov    dx, 0x3f2
		mov    al, 8                                  ; off with all motors,
		out    dx, al                                 ; dma,irq etc..

		mov    ecx, 5
		call   delay                                  ; in timer.inc

		mov    dx, 0x3f7
		mov    al, 0
		out    dx, al                                 ; work at 500 kbit/s

		mov    dx, 0x3f2
		mov    al, 0x0c
		out    dx, al                                 ; reenable interrupts

		mov    [fdd_int_done], 0
		call   wait_int                               ; wait for floppy int.
		jc     .error                                 ; timeout?

		mov    cx, 0x04
    .status:                                          ; 4 dummy-reads.
		call   sensei
		loop   .status

		mov    al, 0x03                               ; specify command
		call   fdc_sendbyte
		mov    al, 0xDF                               ; SRT, HUT
		call   fdc_sendbyte
		mov    al, 0x02                               ; HLT, ND
		call   fdc_sendbyte

		mov    al, 1
		call   fdd_recal_seek
		jc     .error
		call   fdd_off
		clc
		jmp    .end
    .error:
		call   fdd_off
		stc
    .end:
		pop    edx
		pop    ecx
		pop    eax
		ret



;------------------------------------------------------;
;  fdd_recal_seek  -   fdd recalibrate/seek            ;
;------------------------------------------------------;
;                                                      ;
;   in:  al  = 0 on seek, 1 on recalibrate             ;
;        bl  = (at seek) track                         ;
;        bh  = (at seek) ((head*4)|drive)              ;
;                                                      ;
;------------------------------------------------------;
fdd_recal_seek:
		push   eax

		call   fdd_on                                 ; turn motor on
		cmp    al, 0
		jne    .recalibrate
		clc
		cmp    bl, [result_C]                         ; are we there yet? :D
		je     .ok
		mov    al, 0x0F                               ; seek command
		call   fdc_sendbyte
		mov    al, bh                                 ; ((head*4)|drive)
		call   fdc_sendbyte
		mov    al, bl                                 ; track
		call   fdc_sendbyte
		mov    [result_C], bl                         ; now on..?
		jmp    .get_int
    .recalibrate:
		mov    al, 0x07                               ; recalibrate command
		call   fdc_sendbyte
		mov    al, 0                                  ; drive number
		call   fdc_sendbyte
		mov    [result_C], 0                          ; now on track 0
    .get_int:
		mov    [fdd_int_done], 0
		call   wait_int
		jc     .error

		call   sensei                                 ; sense interrupt status
		jc     .error
     .ok:
		clc
		jmp    .end
    .error:
        stc
    .end:
        pop    eax
        ret



;------------------------------------------------------;
;  fdd_read_write   -  fdd read/write                  ;
;------------------------------------------------------;
;   input:  bl  = 0 read, 1 write                      ;
;           ch  = track/cylinder                       ;
;           cl  = sector                               ;
;           dh  = head                                 ;
;           edi = address to store or read the data    ;
;   output: al  = status                               ;
;           cf  = 0 if ok, 1 if error                  ;
;------------------------------------------------------;
fdd_read_write:
		pushad

		and    dh, 1                                  ; head 0 or 1?
		mov    [fdd_head], dh                         ; store it.
		shl    dh, 2
		or     dh, 0                                  ; drive 0, fd0
		mov    [fdd_drivehead], dh                    ; dh = ((head*4)|drive)
		mov    [fdd_errorcode], 0x04                  ; basic error code
		cmp    ch, 0x51                               ; check for allowed
		jae    .error                                 ; track number.
		mov    [fdd_track], ch
		cmp    cl, 0x13                               ; check for allowed
		jae    .error                                 ; sector number.
		mov    [fdd_sector], cl

		cmp    [fdd_error], 1
		jne    .no_previous_error
		mov    al, 1
		call   fdd_recal_seek
    .no_previous_error:
		call   fdd_on

		mov    dx, 0x3F7
		mov    al, 0                                  ; 500Kb/sec mode
		out    dx, al
		mov    [fdd_errorcode], 0x80                  ; error code

		xor    ecx, ecx
		mov    cx, 3                                  ; try seek 3 times
    .l2:
		mov    al, 0
		push   ebx
		mov    bl, [fdd_track]
		mov    bh, [fdd_drivehead]                    ; ((head*4)|drive)
		call   fdd_recal_seek
		pop    ebx
		jnc    .l3                                    ; ok, continue.
		loop   .l2
		jmp    .error                                 ; timeout.
    .l3:
		push   ebx
		cmp    bl, 0
		je     .read_fdd

    .write_fdd:
		push   edi
		mov    esi, edi
		mov    edi, 0x80000                           ; copy the stuff we will
		mov    ecx, 128                               ; write to the DMA buffer
		rep    movsd                                  ; 128*4=512
		pop    edi

		mov    bl, 2                                  ; channel 2
		mov    esi, 512                               ; bytes to write
		mov    ecx, 0x80000                           ; page & offset
		mov    bh, 1                                  ; write floppy, read DMA
		call   dma_transfer

		mov    al, 0xC5                               ; write sector command
		call   fdc_sendbyte
		jmp    .cont

    .read_fdd:
		mov    bl, 2                                  ; channel 2
		mov    esi, 512                               ; bytes to read
		mov    ecx, 0x80000                           ; page & offset
		mov    bh, 0                                  ; read floppy, write DMA
		call   dma_transfer

		mov    al, 0xE6                               ; read sector command
		call   fdc_sendbyte

    .cont:
		pop    ebx
		mov    al, [fdd_drivehead]                    ; ((head*4)|drive)
		call   fdc_sendbyte
		mov    al, [fdd_track]                        ; track/cylinder
		call   fdc_sendbyte

		mov    al, [fdd_head]                         ; head/side 0 or 1
		call   fdc_sendbyte
		mov    al, [fdd_sector]                       ; sector number
		call   fdc_sendbyte
		mov    al, 0x02                               ; sector size, 512 bytes
		call   fdc_sendbyte

		mov    al, 0x12                               ; sectors to a track
		call   fdc_sendbyte
		mov    al, 0x1B                               ; gap length
		call   fdc_sendbyte
		mov    al, 0xFF                               ; data length
		call   fdc_sendbyte

		mov    [fdd_int_done], 0
		call   wait_int
		jc     .error

		call   fdc_getbyte
		mov    [result_ST0], al                       ; ST0
		call   fdc_getbyte
		mov    [result_ST1], al                       ; ST1
		call   fdc_getbyte
		mov    [result_ST2], al                       ; ST2
		call   fdc_getbyte
		mov    [result_C], al                         ; cylinder
		call   fdc_getbyte
		mov    [result_H], al                         ; head
		call   fdc_getbyte
		mov    [result_R], al                         ; sector number.
		call   fdc_getbyte
		mov    [result_N], al                         ; sector size

		test   [result_ST0], 0xc0                     ; test if sr0 is 0xC0
		jnz    .error
		cmp    bl, 1                                  ; did we write the disk?
		je     .ok

		mov    ecx, 512                               ; sector size in bytes
		mov    esi, 0x80000                           ; copy to dest. in edi
		rep    movsb
    .ok:
		mov    [fdd_errorcode], 0                     ; no error.. :D
		mov    [fdd_error], 0                         ; no recal. next time
		clc
		jmp    .end
    .error:
		mov    [fdd_error], 1                         ; recalibrate next time
		stc
    .end:
		call   fdd_off                                ; floppy motor off
		popad
		mov    al, [fdd_errorcode]                    ; error status
		ret