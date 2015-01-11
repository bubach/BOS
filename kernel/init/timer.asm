;----------------------------------------------------------;
; BOS kernel                     Christoffer Bubach, 2005. ;
;----------------------------------------------------------;
;                                                          ;
;     Function to set up the timer IRQ.                    ;
;                                                          ;
;----------------------------------------------------------;

;-----------------;
;   variables     ;
;-----------------;
    timer_wait      dd   0                            ; time to wait
    timer_counter   dd   0, 0                         ; time since BOS started
    call_list       dd   0, 0, 0, 0, 0                ; functions to call


;---------------------------;
;      Timer IRQ(0)         ;
;---------------------------;
timer:
        add    dword [timer_counter], 1               ; it's just a 64-bit
        adc    dword [timer_counter+4], 0             ; counter since boot.

        cmp    [timer_wait], 0                        ; "delay" countdown.
        je     .test1
        dec    [timer_wait]

    .test1:                                           ; checks for calls to
        cmp    [call_list], dword 0                   ; do before we quit.
        je     .test2
        call   dword [call_list]
    .test2:
        cmp    [call_list+4], dword 0
        je     .test3
        call   dword [call_list+4]
    .test3:
        cmp    [call_list+8], dword 0
        je     .test4
        call   dword [call_list+8]
    .test4:
        cmp    [call_list+12], dword 0
        je     .test5
        call   dword [call_list+12]
    .test5:
        cmp    [call_list+16], dword 0
        je     .end
        call   dword [call_list+16]

    .end:
        mov    al, 0x20
        out    0x20, al
        ret



;------------------------------------------------;
;   add function for the timer to call           ;
;                  in:  ebx = function address   ;
;                  out: eax = 0 if OK            ;
;------------------------------------------------;
add_timercall:
        cmp    [call_list], 0
        jne    .test2
        mov    [call_list], ebx
        jmp    .end
    .error:
        mov    eax, 1
        ret
    .test2:
        cmp    [call_list+4], 0                       ; since i am so lazy
        jne    .test3                                 ; and a loop can be
        mov    [call_list+4], ebx                     ; rather complicated
        jmp    .end                                   ; for this stuff, i
    .test3:                                           ; check for each one..
        cmp    [call_list+8], 0                       ; after all, it's only 5.
        jne    .test4
        mov    [call_list+8], ebx
        jmp    .end
    .test4:
        cmp    [call_list+12], 0
        jne    .test5
        mov    [call_list+12], ebx
        jmp    .end
    .test5:
        cmp    [call_list+16], 0
        jne    .error
        mov    [call_list+16], ebx
    .end:
        xor    eax, eax
        ret



;-------------------------------------------------;
;   remove function from the call list            ;
;                  in:  ebx = function address    ;
;                  out: eax = 0 if OK             ;
;-------------------------------------------------;
remove_timercall:
        cmp    [call_list], ebx
        jne    .test2
        mov    [call_list], dword 0
        jmp    .end
    .error:
        mov    eax, 1
        ret
    .test2:
        cmp    [call_list+4], ebx
        jne    .test3
        mov    [call_list+4], dword 0
        jmp    .end
    .test3:
        cmp    [call_list+8], ebx
        jne    .test4
        mov    [call_list+8], dword 0
        jmp    .end
    .test4:
        cmp    [call_list+12], ebx
        jne    .test5
        mov    [call_list+12], dword 0
        jmp    .end
    .test5:
        cmp    [call_list+16], ebx
        jne    .error
        mov    [call_list+16], dword 0
    .end:
        xor    eax, eax
        ret



;--------------------------------------------;
;   delay function                           ;
;           in:  ecx = 100/second to wait    ;
;           out: nothing                     ;
;--------------------------------------------;
delay:
        mov    [timer_wait], ecx                      ; mov value to "timer"
    .loop:
        cmp    [timer_wait], 0
        jne    .loop
        ret



;--------------------------------------------;
;   "active" delay                           ;
;                                            ;
; gives the caller a pointer to the counter  ;
; so that it can check for timeouts etc,     ;
; itself.                                    ;
;           in:  ecx = 100/second to wait    ;
;           out: ecx = pointer to counter    ;
;--------------------------------------------;
active_delay:
        mov    [timer_wait], ecx                      ; mov value to "timer"
        mov    ecx, timer_wait                        ; let caller check value
        ret



;------------------------------;
;     set PIT to 100Hz         ;
;------------------------------;
set_pit_freq:
        push   eax
        mov    al, 0x34                               ; set to 100Hz, 0x34 = 00110100b
        out    0x43, al
        mov    al, 0x9B                               ; lsb    1193180 / 1193
        out    0x40, al
        mov    al, 0x2E                               ; msb
        out    0x40, al
        pop    eax
        ret