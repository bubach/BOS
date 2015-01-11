;----------------------------------------------------------;
; BOS kernel                Christoffer Bubach, 2003-2005. ;
;----------------------------------------------------------;
;                                                          ;
;     Initiation function for BOS                          ;
;                                                          ;
;----------------------------------------------------------;


bos_init:

    ;----------------------;
    ;  we are in pmode..   ;
    ;----------------------;
        mov    bx, 0x0193
        call   setcursor
        mov    esi, pmode_load
        mov    bl, 0x07
        call   print

        mov    bx, 0x01C5
        call   setcursor
        mov    esi, pmode_load_ok
        mov    bl, 0x02
        call   print

    ;----------------------;
    ;   kernel loaded..    ;
    ;----------------------;
        mov    bx, 0x01E3
        call   setcursor
        mov    esi, kernel_load
        mov    bl, 0x07
        call   print

        mov    bx, 0x0215
        call   setcursor
        mov    esi, kernel_load_ok
        mov    bl, 0x02
        call   print

    ;----------------;
    ;  remap PICs    ;
    ;----------------;
        mov    cl, 0x20                               ; PIC 1, irq0-irq7 -> int 0x20-27.
        mov    ch, 0x28                               ; PIC 2, irq8-irq15 -> int 0x28-30.
        call   remap_pics
        call   disable_irqs

        mov    bx, 0x0233
        call   setcursor
        mov    esi, pic_irq
        mov    bl, 0x07
        call   print

        mov    bx, 0x0265
        call   setcursor
        mov    esi, pic_irq_ok
        mov    bl, 0x02
        call   print

    ;--------------;
    ;  setup IDT   ;
    ;--------------;
        mov    edi, u_isr                             ; isr.inc
        call   init_idt                               ; idt.inc
        mov    esi, idt_list                          ; idt.inc
        call   set_idt_list                           ; idt.inc

        sti                                           ; Interrupts back.

        mov    bx, 0x0283
        call   setcursor
        mov    esi, idt_mess
        mov    bl, 0x07
        call   print

        mov    bx, 0x02B5
        call   setcursor
        mov    esi, idt_ok
        mov    bl, 0x02
        call   print


    ;---------------------------------------------;
    ;  enable IRQs (one after one as i code it)   ;
    ;---------------------------------------------;
        mov    cl, 1
        call   enable_irq                             ; Enable IRQ 1.

        mov    bx, 0x02D3
        call   setcursor
        mov    esi, kbd_load
        mov    bl, 0x07
        call   print

        mov    bx, 0x0305
        call   setcursor
        mov    esi, kbd_ok
        mov    bl, 0x02
        call   print

    ;------------------------------------;
    ;  get CMOS data, set PIT to 100Hz   ;
    ;                 and start timer.   ;
    ;------------------------------------;
        call   get_cmos_data                          ; cmos.inc
        call   set_pit_freq                           ; timer.inc
        mov    cl, 0
        call   enable_irq                             ; Enable IRQ 0.

    ;-------------------;
    ;  init simple MM   ;
    ;-------------------;
        mov    ebx, 0x100000                          ; address of first free
        mov    ecx, [ram_amount]                      ; RAM. everything before
        call   init_mem                               ; that is reserved.

    ;--------------------;
    ;  init fdc driver   ;
    ;--------------------;
        call   fdc_init                               ; fdc.inc


    ;-------------------------;
    ;  return to kernel.asm   ;
    ;-------------------------;
        ret