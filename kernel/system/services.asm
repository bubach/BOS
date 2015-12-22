;----------------------------------------------------------;
; BOS 0.05                  Christoffer Bubach, 2004-2015. ;
;----------------------------------------------------------;
;                                                          ;
;   Service handler for components such as VFS & STDIO.    ;
;                                                          ;
;----------------------------------------------------------;

  ;----------------------------------------------------;
  ; TODO:   A lot, when user programs can be runned..  ;
  ;----------------------------------------------------;

;--------------------------;
;  System interrupt 0x32   ;
;--------------------------;

        isr32_str_1    db  "ษอออออออออออออออออออออออออป", 0
        isr32_str_2    db  "บ     INT 32 CALLED!!    บ", 0
        isr32_str_3    db  "บ                       บ", 0
        isr32_str_4    db  "ศอออออออออออออออออออออออออผ", 0

        isr32_str_5    db  "CTRL+ALT+DEL was pressed!", 0

interrupt_32:

    ;-----------------;
    ;   get char      ;
    ;-----------------;
        cmp    ax, 0x0001                             ; get character int..
        jne    .cade

        call   getc

        jmp    .end

    ;-----------------------------;
    ;  ctrl+alt+delete function   ;
    ;-----------------------------;
    .cade:
        cmp    ax, 0xCADE		            ; CTRL+ALT+DEL was pressed
        jne    .ordinary

        push   bx
        push   cx
        push   dx

        call   getcursor
        mov    cx, bx

        mov    dl, 0x0C
        mov    dh, 0x1B
        call   setcursorxy

        mov    esi, isr32_str_5
        mov    al, 0x40
        call   print

        mov    bx, cx
        call   setcursor

        pop    dx
        pop    cx
        pop    bx

        jmp    .end

    ;-----------------------------;
    ;   no selected function..    ;
    ;-----------------------------;
    .ordinary:                                        ; print that int 0x32 was called...
        push   bx
        push   cx
        push   dx

        mov    dl, 0x0B
        mov    dh, 0x1A
        call   setcursorxy

        mov    esi, isr32_str_1
        mov    bl, 0x40
        call   print

        mov    dl, 0x0C
        mov    dh, 0x1A
        call   setcursorxy

        mov    esi, isr32_str_2
        mov    bl, 0x40
        call   print

        mov    dl, 0x0D
        mov    dh, 0x1A
        call   setcursorxy

        mov    esi, isr32_str_3
        mov    bl, 0x40
        call   print

        mov    dl, 0x0E
        mov    dh, 0x1A
        call   setcursorxy

        mov    esi, isr32_str_4
        mov    bl, 0x40
        call   print

        pop    dx
        pop    cx
        pop    bx

    .end:
        ret
