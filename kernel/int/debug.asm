;----------------------------------------------------------;
; BOS kernel                Christoffer Bubach, 2004-2005. ;
;----------------------------------------------------------;
;                                                          ;
;   BOS mighty debugging service, dump some regs..         ;
;                                                          ;
;----------------------------------------------------------;

;----------------;
;   variables    ;
;----------------;
    dbg_head      db   'ษออออออออออออออออออออออออออออออออออป',0
    dbg_head2     db   'บ BOS 0.05 - ERROR: ',0
    dbg_head3     db   'บ                                  บ',0
    dbg_press     db   'บ  Press any key to continue...    บ',0
    dbg_restart   db   'บ Press a key to restart the PC... บ',0
    dbg_footer    db   'ศออออออออออออออออออออออออออออออออออผ',0
    dbg_close_row db   ' บ',0
    dbg_keypress  db   1                              ; 0 = restart,  1 = wait for key
    dbg_error     db   ' none.        ',0             ; error msg to show, max 14 chars

    ;--------------------------------------;
    ;  I'll start with the common regs..   ;
    ;--------------------------------------;
    debug_eax     db   'บ EAX: 0x', 0
    debug_ebx     db   '  EBX: 0x', 0
    debug_ecx     db   'บ ECX: 0x', 0
    debug_edx     db   '  EDX: 0x', 0
    debug_esp     db   'บ ESP: 0x', 0
    debug_ebp     db   '  EBP: 0x', 0
    debug_esi     db   'บ ESI: 0x', 0
    debug_edi     db   '  EDI: 0x', 0

    ;-------------------;
    ;  state to print   ;
    ;-------------------;
    state_eax     dd   0
    state_ebx     dd   0
    state_ecx     dd   0
    state_edx     dd   0
    state_esp     dd   0
    state_ebp     dd   0
    state_esi     dd   0
    state_edi     dd   0

    ;-----------------------------------;
    ;  "fake stack" to save regs on..   ;
    ;-----------------------------------;
    stack_eax     dd   0
    stack_eax2    dd   0
    stack_ebx     dd   0
    stack_edx     dd   0

    ;-------------------------------;
    ;  original cursor placment..   ;
    ;-------------------------------;
    state_cursor  dw   0

    ;-------------------------------------------------;
    ;  mostly in debug purpose, and in lack of MM..   ;
    ;-------------------------------------------------;
    scr_buffer: times 180 dd   0                      ; 720 = box buffer size (char+attrib)


;--------------------------------------------;
;   dump regs..  does not use the stack.     ;
;--------------------------------------------;
dump_regs:
        mov    [state_eax], eax
        mov    [state_ebx], ebx
        mov    [state_ecx], ecx
        mov    [state_edx], edx
        mov    [state_esp], esp
        mov    [state_ebp], ebp
        mov    [state_esi], esi
        mov    [state_edi], edi

        call   .get_cur
        mov    [state_cursor], bx

        mov    dx, 0                                  ; row counter
        mov    esi, (0xB8000+840)
        mov    edi, scr_buffer
    .big_loop:
        mov    cx, 0                                  ; col counter
    .small_loop:
        movsb                                         ; copy creen content
        inc    cx                                     ; increase counter
        cmp    cx, 72                                 ; have we copied 72 bytes?
        je     .end_small                             ; if we have, end small loop
        jmp    .small_loop                            ; if not continue with next byte
    .end_small:
        inc    dx                                     ; increase row count
        cmp    dx, 10                                 ; check if all ten is copied
        je     .end_big                               ; if it is, end.
        add    esi, 88                                ; else continue with next row
        jmp    .big_loop
     .end_big:

        mov    bx, 420                                ; row 5 char 20
        call   .set_cur
        mov    ebp, dbg_head
        call   .print
        mov    bx, 500                                ; row 6 char 20
        call   .set_cur
        mov    ebp, dbg_head2
        call   .print
        mov    ebp, dbg_error
        call   .print
        mov    ebp, dbg_close_row
        call   .print
        mov    bx, 580                                ; row 7 char 20
        call   .set_cur
        mov    ebp, dbg_head3
        call   .print


        mov    bx, 660                                ; row 8 char 20
        call   .set_cur
        mov    ebp, debug_eax
        call   .print
        mov    eax, [state_eax]                       ; eax
        call   .print_hex32
        mov    ebp, debug_ebx
        call   .print
        mov    eax, [state_ebx]                       ; ebx
        call   .print_hex32
        mov    ebp, dbg_close_row
        call   .print

        mov    bx, 740                                ; row 9 char 20
        call   .set_cur
        mov    ebp, debug_ecx
        call   .print
        mov    eax, [state_ecx]                       ; ecx
        call   .print_hex32
        mov    ebp, debug_edx
        call   .print
        mov    eax, [state_edx]                       ; edx
        call   .print_hex32
        mov    ebp, dbg_close_row
        call   .print

        mov    bx, 820                                ; row 10 char 20
        call   .set_cur
        mov    ebp, debug_esp
        call   .print
        mov    eax, [state_esp]                       ; esp
        call   .print_hex32
        mov    ebp, debug_ebp
        call   .print
        mov    eax, [state_ebp]                       ; ebp
        call   .print_hex32
        mov    ebp, dbg_close_row
        call   .print

        mov    bx, 900                                ; row 11 char 20
        call   .set_cur
        mov    ebp, debug_esi
        call   .print
        mov    eax, [state_esi]                       ; esi
        call   .print_hex32
        mov    ebp, debug_edi
        call   .print
        mov    eax, [state_edi]                       ; edi
        call   .print_hex32
        mov    ebp, dbg_close_row
        call   .print

        mov    bx, 980                                ; row 12 char 20
        call   .set_cur
        mov    ebp, dbg_head3
        call   .print
        mov    bx, 1140                               ; row 14 char 20
        call   .set_cur
        mov    ebp, dbg_footer
        call   .print
        mov    bx, 1060                               ; row 13 char 20
        call   .set_cur

        cmp    [dbg_keypress], 1
        je     .wait_key

     ;----------------------------------;
     ;  wait for scancode and restart   ;
     ;----------------------------------;
        mov    ebp, dbg_restart
        call   .print
        mov    bx, 1093                               ; row 13 char 46
        call   .set_cur

     .no_new1:
        mov    al, [kbd_head]
        mov    ah, [kbd_tail]
        cmp    ah, 63
        jne    .check1
        cmp    al, 0
        je     .no_new1
        mov    [kbd_tail], 0
        jmp    .done_check1
     .check1:
        mov    bl, ah
        inc    bl
        cmp    bl, al
        je     .no_new1
        inc    [kbd_tail]
     .done_check1:

        mov    esi, kbd_buffer
        movzx  eax, [kbd_tail]
        add    esi, eax
        mov    ah, byte [esi]                         ; ah = scancode
        cmp    ah, 0xFA                               ; check for some stuff..
        je     .no_new1
        cmp    ah, 0xE0
        je     .no_new1
        cmp    ah, 0xE1
        je     .no_new1
        test   ah, 0x80
        jnz    .no_new1

        call   reboot                                 ; in commands.inc

     ;--------------------------;
     ;  wait for key and quit   ;
     ;--------------------------;
     .wait_key:
        mov    ebp, dbg_press
        call   .print
        mov    bx, 1091                               ; row 13 char 51
        call   .set_cur

     .no_new2:
        mov    al, [kbd_head]
        mov    ah, [kbd_tail]
        cmp    ah, 63                                 ; if we are at the buffer end,
        jne    .check2                                ; we must check that head != 0
        cmp    al, 0
        je     .no_new2                               ; we don't have new keys to read
        mov    [kbd_tail], 0                          ; "increase" to 0 (loop buffer)
        jmp    .done_check2
     .check2:
        mov    bl, ah
        inc    bl                                     ; head should be +1 compared to tail
        cmp    bl, al
        je     .no_new2
        inc    [kbd_tail]                             ; increase
     .done_check2:
        mov    esi, kbd_buffer
        movzx  eax, [kbd_tail]
        add    esi, eax
        mov    ah, byte [esi]                         ; ah = scancode
        cmp    ah, 0xFA                               ; check for some stuff..
        je     .no_new2
        cmp    ah, 0xE0
        je     .no_new2
        cmp    ah, 0xE1
        je     .no_new2
        test   ah, 0x80
        jnz    .no_new2

        mov    dx, 0                                  ; restore screen as
        mov    edi, (0xB8000+840)                     ; it was before.
        mov    esi, scr_buffer                        ; same loops as above
     .big_loop2:                                      ; but exchanged esi and edi
        mov    cx, 0
     .small_loop2:
        movsb
        inc    cx
        cmp    cx, 72
        je     .end_small2
        jmp    .small_loop2
     .end_small2:
        inc    dx
        cmp    dx, 10
        je     .end_big2
        add    edi, 88
        jmp    .big_loop2
     .end_big2:

        mov    bx, [state_cursor]
        call   .set_cur
        mov    [dbg_keypress], 1
        mov    [dbg_error], ' '                       ; restore variables.
        mov    [dbg_error+1], 'n'                     ; ugly..
        mov    [dbg_error+2], 'o'
        mov    [dbg_error+3], 'n'
        mov    [dbg_error+4], 'e'
        mov    [dbg_error+5], '.'
        mov    [dbg_error+6], ' '
        mov    [dbg_error+7], ' '
        mov    [dbg_error+8], ' '
        mov    [dbg_error+9], ' '
        mov    [dbg_error+10], ' '
        mov    [dbg_error+11], ' '
        mov    [dbg_error+12], ' '
        mov    [dbg_error+13], ' '
        mov    [dbg_error+14], 0
        ret

     ;-------------------------------;
     ;  subfunctions to inc cursor   ;
     ;-------------------------------;
     .set_cur:
        mov    [stack_eax2], eax
        mov    [stack_edx], edx                       ; can it get any uglier?
        mov    al, 0x0E
        mov    ah, bh
        mov    dx, 0x3D4
        out    dx, ax
        inc    ax
        mov    ah, bl
        out    dx, ax
        mov    edx, [stack_edx]
        mov    eax, [stack_eax2]
        ret
     .get_cur:
        mov    [stack_eax2], eax
        mov    [stack_edx], edx
        mov    dx, 0x3D4
        mov    al, 0x0E
        out    dx, al
        inc    dx
        in     al, dx
        mov    bh, al
        mov    al, 0x0F
        dec    dx
        out    dx, al
        inc    dx
        in     al, dx
        mov    bl, al
        mov    edx, [stack_edx]
        mov    eax, [stack_eax2]
        ret
    ;--------------------------------;
    ;  subfunction to print a char   ;
    ;        bl = char, bh = attrib  ;
    ;--------------------------------;
    .print_char:
        mov    [stack_eax], eax
        mov    [stack_ebx], ebx
        call   .get_cur
        mov    eax, ebx
        mov    ebx, [stack_ebx]
        mov    [es:(eax*2 + 0xB8000)], bx
        mov    ebx, eax
        inc    bx
        call   .set_cur
        mov    ebx, [stack_ebx]
        mov    eax, [stack_eax]
        ret
     ;------------------------------------------;
     ;  subfunction to print 32-bit hex value   ;
     ;          IN: eax = value, bh = color.    ;
     ;------------------------------------------;
     .print_hex32:
        mov    ecx, 8
     .print_it:
        rol    eax, 4
        movzx  edx, al
        and    edx, 0x0F
        or     edx, 0x30
        cmp    edx, 0x39
        jna    .cont
        add    edx, 7
     .cont:
        mov    bl, dl
        call   .print_char
        loop   .print_it
        ret
    ;-----------------------------------------;
    ;  subfunction to display asciiz string   ;
    ;       Input: ebp = string               ;
    ;-----------------------------------------;
    .print:
        mov    al, byte [ebp]
        or     al, al
        jz     .done
        mov    bl, al
        mov    bh, 0x40                               ; standard color for this...
        call   .print_char
        inc    ebp
        jmp    .print
    .done:
        ret