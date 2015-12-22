;----------------------------------------------------------;
; BOS 0.05                  Christoffer Bubach, 2004-2015. ;
;----------------------------------------------------------;
;                                                          ;
;     English strings used in BOS.                         ;
;                                                          ;
;----------------------------------------------------------;


;---------------;
;   strings     ;
;---------------;

    pmode_load      db   'Setting up protected mode...', 0
    pmode_load_ok   db   '[ 32-bits OK   ]', 0

    kernel_load     db   'Loading kernel...', 0
    kernel_load_ok  db   '[ OK           ]', 0

    pic_irq         db   'Fixing PIC and IRQs...', 0
    pic_irq_ok      db   '[ Done         ]', 0

    idt_mess        db   'Setting up IDT...', 0
    idt_ok          db   '[ IDT OK       ]', 0

    kbd_load        db   'Enables IRQ1...', 0
    kbd_ok          db   '[ Keyboard OK  ]', 0

    bos_shell       db   'BOS shell. Type "help" for more info.', 13, 10, 0
