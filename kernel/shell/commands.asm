;----------------------------------------------------------;
; BOS kernel                Christoffer Bubach, 2003-2005. ;
;----------------------------------------------------------;
;                                                          ;
;  Command table and some commands for the shell.          ;
;                                                          ;
;----------------------------------------------------------;

; I should really do something about this file, divide it into
; smaller ones or something. I'm just too lazy. Next version..


    commands:
        db   'ver', 0
        db   'help', 0
        db   '?', 0
        db   'about', 0
        db   'cls', 0
        db   'clrscr', 0
        db   'reboot', 0
        db   'regdump', 0
        db   'time', 0
        db   'date', 0
        db   'delay', 0
        db   'vgatest', 0
        db   'memtest', 0
        db   'fddtest', 0
        db   0xFF                                     ; end of command table


    call_table:
        dd   show_ver                                 ; commands.inc
        dd   show_help                                ; commands.inc
        dd   show_help                                ; commands.inc
        dd   show_about                               ; commands.inc
        dd   clrscr                                   ; commands.inc
        dd   clrscr                                   ; comamnds.inc
        dd   reboot                                   ; commands.inc
        dd   dump_regs                                ; debug.inc
        dd   print_time                               ; time_date.inc
        dd   print_date                               ; time_date.inc
        dd   delay_test                               ; commands.inc
        dd   vga_test                                 ; commands.inc
        dd   mem_test                                 ; commands.inc
        dd   fdd_test                                 ; commands.inc



    ;--------------------------;
    ;   not a valid command    ;
    ;--------------------------;
    not_a_valid_cmd  db   13,10,'No such command or program exists.', 0

    no_such_cmd:
        push   esi
        push   bx

        mov    esi, not_a_valid_cmd
        mov    bl, 0x04
        call   print

        pop    bx
        pop    esi
        ret


    ;-------------------;
    ;   show version    ;
    ;-------------------;
    bos_ver_str  db   13,10,'BOS version 0.05 by Christoffer Bubach, 2003-2005.', 0
    show_ver:
        push   esi
        push   bx

        mov    esi, bos_ver_str
        mov    bl, 0x07
        call   print

        pop    bx
        pop    esi
        ret


    ;--------------------;
    ;   show BOS help    ;
    ;--------------------;
    bos_help_str  db   13,10,13,10,' BOS 0.04 by Christoffer Bubach, 2003-2005.',13,10,\
                                '--------------------------------------------',13,10,\
                                'Type a command and press ENTER to execute it.',13,10,13,10,\
                                '"help" or "?"       - Displays this text.',13,10,\
                                '"ver"               - Shows version information.',13,10,\
                                '"about"             - Shows information about the OS.',13,10,\
                                '"cls" or "clrscr"   - Clears the screen.',13,10,\
                                '"memtest"           - Shows memory info (and allocates/frees some, to test).',13,10,\
                                '"vgatest"           - Test some VGA stuff.',13,10,\
                                '"fddtest"           - Read and print bootsector from A:',13,10,\
                                '"delay"             - Tests the delay function for 5 s.',13,10,\
                                '"time"              - Prints current time.',13,10,\
                                '"date"              - Prints current date.',13,10,\
                                '"regdump"           - Dump some standard registers.',13,10,\
                                '"reboot"            - Restarts the computer.',0
    show_help:
        push   esi
        push   bx

        mov    esi, bos_help_str
        mov    bl, 0x07
        call   print

        pop    bx
        pop    esi
        ret


    ;-----------------;
    ;   show about    ;
    ;-----------------;
    bos_about_str   db   13,10,'About BOS',13,10,\
                    'Hmm.. I started with OS-dev in late 2003.. Anyway..',13,10,13,10,\
                    'Thanks for helping me get this far goes to:',13,10,\
                    'all people at mega-tokyo.com, osdever.net and flatassembler.net',13,10,\
                    'Robert ',153,'stling for Primula, http://ostling.no-ip.com/',13,10,\
                    'J.Thim for EelOS, http://www.ludd.luth.se/~ivileel/',13,10,\
                    'Tomasz Grysztar for fasm and fasmw, http://flatassembler.net/',13,10,\
                    'ASHLEY4, Candy, John S. Fine and Petroff Heroj.',0
     show_about:
        push   esi
        push   bx

        mov    esi, bos_about_str
        mov    bl, 0x07
        call   print

        pop    bx
        pop    esi
        ret


    ;-----------------------;
    ;   clear the screen    ;
    ;-----------------------;
    clrscr:
        call   cls                                    ; text.inc
        mov    esi, prompt
        mov    bl, 0x0E
        call   print
        mov    edi, cmd_buffer
        jmp    shell                                  ; no normal return, as it gives an extra line feed



    ;-------------;
    ;   reboot    ;
    ;-------------;
    reboot:
        call   kbd_wait
        mov    al, 0xFE
        out    0x64, al
        jmp    $
        ret


    ;-----------------;
    ;   delay test    ;
    ;-----------------;
    bos_delay_str   db   13,10,'~1 second has passed.', 0
    delay_test:
        mov    ecx, 5
     .loop:
        push   ecx
        mov    ecx, 100
        call   delay
        pop    ecx
        mov    esi, bos_delay_str
        mov    bl, 0x07
        call   print
        loop   .loop
        ret


    ;----------------;
    ;   VGA test     ;
    ;----------------;
    bos_vga_str        db   13,10,'It works..! :-D', 0
    vga_test:

        mov    ax, 1                                  ; clear the screen
        call   set_mode_0x13                          ; set mode 0x13

        mov    cx, 256                                ; loop out some pixels
    .l1:
        mov    bx, cx                                 ; x value
        mov    al, cl
        push   cx
        mov    cx, 50                                 ; y value
        call   put_0x13_pixel
        pop    cx
        loop   .l1

    ;  draw mario and some ground
        mov    esi, mario
        mov    ax, 260                                ; x
        mov    bx, 168                                ; y
        mov    cx, 20                                 ; height
        mov    dx, 18                                 ; width
        call   put_0x13_sprite                        ; in vga.inc
        mov    esi, grass_l
        mov    ax, 250
        mov    bx, 186
        mov    cx, 20
        mov    dx, 14
        call   put_0x13_sprite
        mov    esi, grass_f
        mov    ax, 265
        mov    bx, 186
        mov    cx, 20
        mov    dx, 14
        call   put_0x13_sprite
        mov    esi, grass_ul
        mov    ax, 280
        mov    bx, 186
        mov    cx, 20
        mov    dx, 14
        call   put_0x13_sprite
        mov    esi, g_lefts
        mov    ax, 280
        mov    bx, 172
        mov    cx, 20
        mov    dx, 14
        call   put_0x13_sprite
        mov    esi, grass_l
        mov    ax, 280
        mov    bx, 158
        mov    cx, 20
        mov    dx, 14
        call   put_0x13_sprite
        mov    esi, g_earth
        mov    ax, 300
        mov    bx, 186
        mov    cx, 20
        mov    dx, 14
        call   put_0x13_sprite
        mov    esi, g_earth
        mov    ax, 300
        mov    bx, 172
        mov    cx, 20
        mov    dx, 14
        call   put_0x13_sprite
        mov    esi, grass_f
        mov    ax, 300
        mov    bx, 158
        mov    cx, 20
        mov    dx, 14
        call   put_0x13_sprite

        call   wait_key

        mov    ax, 1                                  ; clear the screen
        call   set_mode_0x03                          ; set mode 0x03

        mov    esi, bos_vga_str                       ; print that it worked!
        mov    bl, 1
        call   print
        ret




    ;--------------------------;
    ;      fdd test            ;
    ;--------------------------;
    fdd_test:
        mov    bl, 13
        mov    bh, 7                                  ; make newline
        call   print_char

        mov    ecx, 512
        mov    edi, 0x80000
    .loop511:
        mov    dword [edi], 'shit'                    ; set DMA buffer to shit, as a test
        add    edi, 4
        sub    ecx, 4
        cmp    ecx, 0
        jne    .loop511

        mov    dh, 0x00                               ; side
        mov    dl, 0x00                               ; drive
        mov    ch, 0x00                               ; track
        mov    cl, 0x01                               ; sector
        mov    bl, 0x00                               ; 1 = write
        call   fdd_read_write
        jc     .error

        mov    esi, 0x80000                           ; dma buffer
        mov    ecx, 512
    .print:
        lodsb
        mov    bl, al
        mov    bh, 7
        call   print_char                             ; print it. is it still
        dec    ecx                                    ; "shit" ?
        cmp    ecx, 0
        jne    .print
        jmp    .end

    .error:
        mov    bl, 13
        call   print_char
        mov    bl, 10
        call   print_char
        mov    bh, 0x40
        mov    bl, 'E'                                ; error sign... :'(
        call   print_char

        call   fdd_reset
        mov    al, 1
        call   fdd_recal_seek                         ; do somthing about the error.. :P

    .end:
        ret





    ;------------------------------;
    ;      memory test             ;
    ;------------------------------;

    bos_mem_str1    db   13,10,'Performing memory test. (debugging allocs assume 32mb RAM)', 0
    bos_mem_str2    db   13,10,'Total installed memory (in bytes): ',0
    bos_mem_str3    db   13,10,13,10,'Memory chunks:',0
    bos_mem_str4    db   13,10,'Address    Size       Type       Previous   Next',0
    bos_mem_str5    db   13,10,'-------------------------------------------------------',0
    bos_mem_str6    db   '0x',0
    bos_mem_str7    db   'Free       ',0
    bos_mem_str8    db   'Used       ',0
    bos_mem_str9    db   'None       ',0
    bos_mem_str0    db   ' ',0
    bos_mem_crlf    db   13,10,0
    current_mem_pos dd   0
    next_free       dd   0

    ;---------DEBUG---------
    test1_or_2      db   1
    test_address    dd   0
    test_size       dd   0
    test_address2   dd   0
    test_size2      dd   0
    ;---------END DEBUG---------

    mem_test:
        push   eax
        push   ebx
        push   ecx
        push   edx

    ;---------DEBUG---------
        cmp    [test1_or_2],0
        je     .free_the_test_block

        mov    ebx, 0x1000000                         ;first test
        mov    [test_size2], ebx
        call   allocate_mem
        mov    [test_address2], ebx

        mov    ebx, 0xE00000                          ; second test
        mov    ecx, ebx
        call   allocate_mem
        push   ebx
        push   ecx

        mov    ebx, 0x10000                           ; third test
        mov    [test_size], ebx
        call   allocate_mem
        mov    [test_address], ebx                    ; test allocation

        pop    ecx
        pop    ebx
        call   free_mem

        mov    [test1_or_2], 0
        jmp    .end_test
    .free_the_test_block:
        mov    ebx, [test_address]
        mov    ecx, [test_size]                       ; and freeing
        call   free_mem
        mov    ebx, [test_address2]
        mov    ecx, [test_size2]                      ; and freeing
        call   free_mem
        mov    [test1_or_2], 1
    .end_test:
    ;---------END DEBUG---------

        mov    esi, bos_mem_str1
        mov    bl, 0x07
        call   print
        mov    esi, bos_mem_str2
        mov    bl, 0x07
        call   print
        mov    esi, bos_mem_str6
        mov    bl, 0x04
        call   print
        mov    ebx, [ram_amount]
        mov    cl, 0x04
        call   print_hex32

        mov    esi, bos_mem_str3
        mov    bl, 0x07
        call   print
        mov    esi, bos_mem_str4
        mov    bl, 0x07
        call   print
        mov    esi, bos_mem_str5
        mov    bl, 0x07
        call   print

        mov    [current_mem_pos], 0
        mov    eax, [first_free]
        mov    [next_free], eax

    ;-------------------------;
    ;  this is a used block   ;
    ;-------------------------;
    .used:
        mov    eax, [current_mem_pos]
        mov    ebx, [next_free]
        cmp    eax, [ram_amount]                      ; .free will always let us
        jae    .end                                   ; decide if we are to quit or not.

        cmp    [next_free], 0
        jne    .more_blocks
        mov    ebx, [ram_amount]                      ; no next block, use ram size
        sub    ebx, eax                               ; get size in ebx
        mov    edi, 1
        call   .print_mem_info
        jmp    .end

    .more_blocks:
        sub    ebx, eax
        mov    edi, 1
        call   .print_mem_info

        mov    eax, [next_free]
        cmp    eax, 0
        je    .end
        mov    ebx, [eax+8]
        mov    [current_mem_pos], eax
        mov    [next_free], ebx

    ;-------------------------;
    ;  this is a free block   ;
    ;-------------------------;
    .free:
        mov    eax, [current_mem_pos]                 ; current pos. in eax
        mov    ebx, [eax+4]                           ; current size in ebx
        mov    ecx, [eax]                             ; prev pointer in ecx
        mov    edx, [eax+8]                           ; next pointer in edx
        xor    edi, edi
        call   .print_mem_info

        add    eax, ebx
        mov    [current_mem_pos], eax
        jmp    .used

    .end:
        pop    eax
        pop    ebx
        pop    ecx
        pop    edx
        ret

    ;-------------------------;
    ;  print mem block info   ;
    ;-------------------------;
    .print_mem_info:
        push   eax                                    ; current pos
        push   ebx                                    ; current size
        push   ecx                                    ; prev pointer
        push   edx                                    ; next pointer
        push   edi                                    ; 1 = used

        push   ebx                                    ; push size
        mov    esi, bos_mem_crlf
        mov    bl, 0x07
        call   print
        mov    esi, bos_mem_str6
        mov    bl, 0x04
        call   print

        push   ecx                                    ; push prev
        mov    ebx, eax
        mov    cl, 0x04
        call   print_hex32

        mov    esi, bos_mem_str0
        mov    bl, 0x07
        call   print
        mov    esi, bos_mem_str6
        mov    bl, 0x04
        call   print

        pop    ecx                                    ; pop prev
        pop    ebx                                    ; pop size
        push   ecx                                    ; push prev
        mov    cl, 0x04
        call   print_hex32
        mov    esi, bos_mem_str0
        mov    bl, 0x07
        call   print

        cmp    edi, 1
        jne    .print_free
        pop    ecx                                    ; pop prev

        mov    esi, bos_mem_str8                      ; it's used
        mov    bl, 0x07
        call   print
        mov    esi, bos_mem_str9
        mov    bl, 0x07
        call   print
        mov    esi, bos_mem_str9
        mov    bl, 0x07
        call   print
        jmp    .print_end

    .print_free:
        mov    esi, bos_mem_str7                      ; it's free
        mov    bl, 0x07
        call   print
        mov    esi, bos_mem_str6
        mov    bl, 0x04
        call   print

        pop    ebx                                    ; pop the pushed ecx
        mov    cl, 0x04                               ; into ebx instead.. ;)
        call   print_hex32
        mov    esi, bos_mem_str0
        mov    bl, 0x07
        call   print
        mov    esi, bos_mem_str6
        mov    bl, 0x04
        call   print
        mov    ebx, edx
        mov    cl, 0x04
        call   print_hex32

    .print_end:
        pop    edi
        pop    edx
        pop    ecx
        pop    ebx
        pop    eax
        ret