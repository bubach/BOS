;----------------------------------------------------------;
; BOS 0.04                  Christoffer Bubach, 2004-2005. ;
;----------------------------------------------------------;
;                                                          ;
;     Basic shell.                                         ;
;                                                          ;
;----------------------------------------------------------;


;--------------;
;  Variabels   ;
;--------------;

    prompt                  db   'BOS kernel>', 0
    cmd_buffer: times 255   db   0                    ; 255 char command buffer



;----------------------------------------------;
;  print the prompt for the first time.. :-)   ;
;----------------------------------------------;
init_cmd:
        mov    byte [kbd_status], 0                   ; reset LEDs to 0..
        call   update_leds

        mov    esi, prompt
        mov    bl, 0x0E
        call   print

        mov    edi, cmd_buffer
        ret



;-------------------------------;
;  Main shell function & loop   ;
;-------------------------------;
shell:
        mov    cx, 0                                  ; max 254 chars in command
    .loop:                                            ; no. 255 is always a 0

        push   cx                                     ; better be sure it´s safe..
        push   edi

        call   getc                                   ; keyboard.inc

        pop    edi
        pop    cx

        cmp    ah, 28                                 ; enter
        je     .enter

        cmp    ah, 14                                 ; backspace
        je     .backspace

        cmp    al, 0                                  ; no normal key
        je     .loop                                  ; exceptions above..

        cmp    cx, 254
        jae    .loop

        stosb                                         ; store char in buffer
        inc    cx

        mov    bl, al                                 ; print it..
        mov    bh, 0x07
        call   print_char

        jmp    .loop

     .enter:
        mov    al, 0                                  ; the command buffer is
        stosb                                         ; in ASCIIZ format..
        jmp    chk_cmd

     .backspace:
        cmp    cx, 0                                  ; can´t delete the prompt.. ;-)
        je     .loop
        dec    edi                                    ; "remove" one char from buffer
        call   backspace                              ; do backspace on screen
        dec    cx                                     ; decrease buffer counter
        jmp    .loop
        jmp    $
        ret



;---------------------------------;
;    check for valid cmd          ;
;---------------------------------;
chk_cmd:

        mov    esi, commands
        mov    edi, cmd_buffer
        mov    ebp, 0                                 ; command-table counter

    ;------------------------------------------;
    ;   big loop, for each command in table    ;
    ;------------------------------------------;
    .l1:
        mov    ecx, 0                                 ; char counter

        cmp    byte [esi], 0xFF
        je     .no_valid_cmd

    ;------------------------------------------;
    ;  smaller loop for each char in command   ;
    ;------------------------------------------;
    .l2:
        cmp    byte [edi], ' '                        ; space or zero
        je     .l_chk                                 ; both indicate
        cmp    byte [edi], 0                          ; "end of command"
        je     .l_chk
        jmp    .l_cont

     .l_chk:
        cmp    byte [esi], 0                          ; commands are equal, but
        jne    .new_cmd                               ; do not match in size..
        jmp    .done

     .l_cont:
        cmp    byte [esi], 0                          ; commands are equal, but
        je     .new_cmd                               ; do not match in size..

        mov    al, [esi]
        cmp    al, [edi]
        jne    .new_cmd

        inc    esi
        inc    edi
        inc    ecx                                    ; inc char counter
        jmp    .l2
    ;----------------------;
    ;  end of small loop   ;
    ;----------------------;

    .new_cmd:
        inc    ebp                                    ; inc command counter
        mov    edi, cmd_buffer                        ; remember to point to the right place.. ;-)
    .l3:
        inc    esi
        cmp    byte [esi], 0                          ; loop until end of command
        jne    .l3

        inc    esi
        jmp    .l1
    ;----------------------;
    ;   end of big loop    ;
    ;----------------------;



    ;--------------------------;
    ;   done. command found    ;
    ;--------------------------;
    .done:
        cmp    ecx, 0                                 ; make sure it´s more
        je     .d_quit                                ; then 0 chars..

        shl    ebp, 2
        call   dword [ebp+call_table]

    .d_quit:
        jmp    .cont                                  ; then go back to the shell


    ;--------------------------;
    ;   command not found      ;
    ;--------------------------;
    .no_valid_cmd:

        ; call search_current_directory_for_file.... :-)

        call   no_such_cmd                            ; print error..
        jmp    .cont                                  ; then go back to the shell

    ;---------------------------------;
    ;  make the prompt appear again   ;
    ;---------------------------------;
    .cont:
        call   new_line
        call   new_line
        mov    esi, prompt
        mov    bl, 0x0E
        call   print
        mov    edi, cmd_buffer
        jmp    shell

        ret
