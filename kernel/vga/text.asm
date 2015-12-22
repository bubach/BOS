;----------------------------------------------------------;
; BOS kernel                Christoffer Bubach, 2003-2005. ;
;----------------------------------------------------------;
;                                                          ;
;    Textmode screen functions.                            ;
;                                                          ;
;----------------------------------------------------------;

;-----------------;
;   variables     ;
;-----------------;
    screen_rows     db   25                           ; all comments assume
    screen_cols     db   80                           ; that this is 25 & 80
    cursor_pos      dw   0


;--------------------------------------;
;  change cursor attribs               ;
;            in: bx = cursor attribs   ;
;--------------------------------------;
changecursor:
        push   ax
        push   dx

        mov    dx, 0x3D4
        mov    al, 0x0A
        mov    ah, bh
        out    dx, ax
        inc    ax
        mov    ah, bl
        out    dx, ax

        pop    dx
        pop    ax
        ret


;----------------------;
;  clear the screen    ;
;----------------------;
cls:
        push   bx
        push   cx

        movzx  cx, [screen_rows]
     .loop:
        call   _scroll_up
        loop   .loop

        mov    bx, 0
        call   setcursor

        pop    cx
        pop    bx
        ret


;-----------------------------------;
;  get the cursor pos               ;
;            out: bh = x   bl = y   ;
;-----------------------------------;
getcursorxy:
        push   ax

        call   getcursor
        mov    ax, bx
        mov    bl, [screen_cols]
        div    bl
        mov    bl, al
        mov    bh, ah

        pop    ax
        ret


;-------------------------------;
;  get the cursor pos           ;
;            out: bx = offset   ;
;-------------------------------;
getcursor:
        push   ax
        push   dx

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

        pop    dx
        pop    ax
        ret


;------------------------------;
;  set the cursor to:          ;
;            bh = x   bl = y   ;
;------------------------------;
setcursorxy:
        push   ax
        push   bx

        xor    ax, ax
        mov    al, [screen_cols]
        mul    bl                                     ; bl * al = ax
        movzx  bx, bh
        add    bx, ax
        call   setcursor

        pop    bx
        pop    ax
        ret


;--------------------------;
;  set the cursor to:      ;
;            bx = offset   ;
;--------------------------;
setcursor:
        push   ax
        push   bx
        push   dx

        mov    al, 0x0E
        mov    ah, bh
        mov    dx, 0x3D4
        out    dx, ax
        inc    ax
        mov    ah, bl
        out    dx, ax

        pop    dx
        pop    bx
        pop    ax
        ret


;-----------------------;
;  cursor position +1   ;
;-----------------------;
inccursor:
        push   ax
        push   bx

        mov    al, [screen_cols]
        mov    bl, [screen_rows]
        mul    bl
        dec    ax

        call   getcursor
        cmp    bx, ax                                 ; 0x7CF = (80*25)-1
        jne    .cont
        call   scroll_up
        jmp    .end

    .cont:
        inc    bx
        call   setcursor

    .end:
        pop    bx
        pop    ax
        ret


;-----------------------;
;  cursor position -1   ;
;-----------------------;
deccursor:
        push   bx

        call   getcursor
        cmp    bx, 0
        je     .end

        dec    bx
        call   setcursor

    .end:
        pop    bx
        ret



;---------------------------------------;
;  backspace - delete last typed char   ;
;---------------------------------------;
backspace:
        push   bx

        call   getcursor
        cmp    bx, 0
        je     .end

        call   deccursor

        mov    bh, 0x07
        mov    bl, 0
        call   print_char

        call   deccursor

    .end:
        pop    bx
        ret



;-----------------------------------------;
;  print char                             ;
;            in: bl = char, bh = attrib   ;
;-----------------------------------------;
print_char:
        push   eax
        push   bx

        cmp    bl, 13
        jne    .cont
        call   new_line
        jmp    .done

    .cont:
        cmp    bl, 10                                 ; ignore
        je     .done

        push   bx
        call   getcursor
        movzx  eax, bx
        pop    bx

        mov    [es:(eax*2 + 0xB8000)], bx

        call   inccursor
    .done:
        pop    bx
        pop    eax
        ret



;------------------------------------------;
;  print 32-bit hex value                  ;
;            in: ebx = value, cl = color   ;
;------------------------------------------;
print_hex32:
        push   eax
        push   ebx
        push   ecx
        push   edx

        mov    eax, ebx                               ; quick & dirty fix so
        mov    bh, cl                                 ; input reg != eax
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
        call   print_char
        loop   .print_it

        pop    edx
        pop    ecx
        pop    ebx
        pop    eax
        ret



;-------------------------------------------------;
;  display a asciiz message on the screen         ;
;            in: esi = message, bl = color        ;
;-------------------------------------------------;
print:
        push   eax
        push   bx

        mov    ah, bl
        call   getcursor
        mov    [cursor_pos], bx

    .displaychar:
        lodsb
        or     al, al
        jz     .done

        cmp    al, 13
        jne    .cont
        mov    bx, [cursor_pos]
        call   setcursor
        call   new_line
        call   getcursor
        mov    [cursor_pos], bx
        jmp    .displaychar

    .cont:
        cmp    al, 10                                 ; ignore
        je     .displaychar
        movzx  ebx, [cursor_pos]
        mov    [es:(ebx*2 + 0xB8000)], ax
        inc    [cursor_pos]
        jmp    .displaychar

    .done:
        mov    bx, [cursor_pos]
        call   setcursor                              ; update cursor on screen

        pop    bx
        pop    eax
        ret



;-----------------------------;
;  make a new line (CR, LF)   ;
;-----------------------------;
new_line:
        push   bx

        call   getcursorxy
        mov    bh, [screen_rows]
        dec    bh
        cmp    bl, bh                                 ; 24
        jb     .newline

        call   scroll_up
        jmp    .done

    .newline:
        call   getcursorxy
        mov    bh, 0
        inc    bl
        call   setcursorxy

    .done:
        pop        bx
        ret



;----------------;
;  scrolling..   ;
;----------------;
scroll_up:
        call   _scroll_up

    .mv_curs:
        push   ax
        push   bx

        xor    ax, ax
        mov    al, [screen_rows]                      ; mov bx, 80*24
        mov    bl, [screen_cols]
        dec    al
        mul    bl
        mov    bx, ax
        call   setcursor

        pop    bx
        pop    ax
        ret

    _scroll_up:
        push   eax
        push   ecx
        push   edi
        push   esi

        mov    edi, 0xB8000
        movzx  esi, [screen_cols]
        shl    esi, 1                                 ; 80*2 = 160
        mov    cl, [screen_rows]
        dec    cl
        mov    eax, esi
        mul    cl
        shr    ax, 2                                  ; ax  = (160*24)/4
        movzx  ecx, ax                                ; ecx =   - || -
        add    esi, 0xB8000                           ; esi = 0xB8000+160

        rep    movsd

        mov    cl, [screen_cols]
        shl    cl, 1                                  ; 80*2 = 160
        mov    al, [screen_rows]
        dec    al                                     ; al = 24
        mul    cl
        movzx  edi, ax
        add    edi, 0xB8000                           ; edi = 0xB8000+160*24
        movzx  ecx, [screen_cols]
        shr    ecx, 1                                 ; 80/2
        mov    eax, 0x07000700                        ; fill with zeros
        rep    stosd

        pop    esi
        pop    edi
        pop    ecx
        pop    eax
        ret