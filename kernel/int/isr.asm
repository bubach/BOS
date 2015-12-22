;----------------------------------------------------------;
; BOS 0.04                       Christoffer Bubach, 2004. ;
;----------------------------------------------------------;
;                                                          ;
; ISR (Interrupt Service Rutines).                         ;
;                                                          ;
;----------------------------------------------------------;



;------------------------;
;  Unhandled Interrupt   ;
;------------------------;
u_isr:
        mov    [dbg_keypress], 0                      ; in debug.inc
        mov    [dbg_error], 'U'
        mov    [dbg_error+1], 'n'
        mov    [dbg_error+2], 'h'
        mov    [dbg_error+3], 'a'
        mov    [dbg_error+4], 'n'
        mov    [dbg_error+5], 'd'
        mov    [dbg_error+6], 'l'
        mov    [dbg_error+7], 'e'
        mov    [dbg_error+8], 'd'
        mov    [dbg_error+9], ' '
        mov    [dbg_error+10], 'I'
        mov    [dbg_error+11], 'n'
        mov    [dbg_error+12], 't'
        mov    [dbg_error+13], ' '
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 00   ;
;-------------------------------;
isr00:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'D'
        mov    [dbg_error+1], 'i'
        mov    [dbg_error+2], 'v'
        mov    [dbg_error+3], 'i'
        mov    [dbg_error+4], 'd'
        mov    [dbg_error+5], 'e'
        mov    [dbg_error+6], ' '
        mov    [dbg_error+7], 'e'
        mov    [dbg_error+8], 'r'
        mov    [dbg_error+9], 'r'
        mov    [dbg_error+10], 'o'
        mov    [dbg_error+11], 'r'
        mov    [dbg_error+12], ' '
        mov    [dbg_error+13], ' '
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 01   ;
;-------------------------------;
isr01:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'D'
        mov    [dbg_error+1], 'e'
        mov    [dbg_error+2], 'b'
        mov    [dbg_error+3], 'u'
        mov    [dbg_error+4], 'g'
        mov    [dbg_error+5], ' '
        mov    [dbg_error+6], 'f'
        mov    [dbg_error+7], 'a'
        mov    [dbg_error+8], 'u'
        mov    [dbg_error+9], 'l'
        mov    [dbg_error+10], 't'
        mov    [dbg_error+11], ' '
        mov    [dbg_error+12], ' '
        mov    [dbg_error+13], ' '
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 02   ;
;-------------------------------;
isr02:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'N'
        mov    [dbg_error+1], 'M'
        mov    [dbg_error+2], 'I'
        mov    [dbg_error+3], ' '
        mov    [dbg_error+4], 'i'
        mov    [dbg_error+5], 'n'
        mov    [dbg_error+6], 't'
        mov    [dbg_error+7], 'e'
        mov    [dbg_error+8], 'r'
        mov    [dbg_error+9], 'r'
        mov    [dbg_error+10], 'u'
        mov    [dbg_error+11], 'p'
        mov    [dbg_error+12], 't'
        mov    [dbg_error+13], ' '
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 03   ;
;-------------------------------;
isr03:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'B'
        mov    [dbg_error+1], 'r'
        mov    [dbg_error+2], 'e'
        mov    [dbg_error+3], 'a'
        mov    [dbg_error+4], 'k'
        mov    [dbg_error+5], 'p'
        mov    [dbg_error+6], 'o'
        mov    [dbg_error+7], 'i'
        mov    [dbg_error+8], 'n'
        mov    [dbg_error+9], 't'
        mov    [dbg_error+10], ' '
        mov    [dbg_error+11], ' '
        mov    [dbg_error+12], ' '
        mov    [dbg_error+13], ' '
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 04   ;
;-------------------------------;
isr04:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'O'
        mov    [dbg_error+1], 'v'
        mov    [dbg_error+2], 'e'
        mov    [dbg_error+3], 'r'
        mov    [dbg_error+4], 'f'
        mov    [dbg_error+5], 'l'
        mov    [dbg_error+6], 'o'
        mov    [dbg_error+7], 'w'
        mov    [dbg_error+8], ' '
        mov    [dbg_error+9], 'f'
        mov    [dbg_error+10], 'a'
        mov    [dbg_error+11], 'u'
        mov    [dbg_error+12], 'l'
        mov    [dbg_error+13], 't'
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 05   ;
;-------------------------------;
isr05:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'B'
        mov    [dbg_error+1], 'o'
        mov    [dbg_error+2], 'u'
        mov    [dbg_error+3], 'n'
        mov    [dbg_error+4], 'd'
        mov    [dbg_error+5], 's'
        mov    [dbg_error+6], ' '
        mov    [dbg_error+7], 'c'
        mov    [dbg_error+8], 'h'
        mov    [dbg_error+9], 'e'
        mov    [dbg_error+10], 'c'
        mov    [dbg_error+11], 'k'
        mov    [dbg_error+12], ' '
        mov    [dbg_error+13], ' '
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 06   ;
;-------------------------------;
isr06:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'I'
        mov    [dbg_error+1], 'n'
        mov    [dbg_error+2], 'v'
        mov    [dbg_error+3], 'a'
        mov    [dbg_error+4], 'l'
        mov    [dbg_error+5], 'i'
        mov    [dbg_error+6], 'd'
        mov    [dbg_error+7], ' '
        mov    [dbg_error+8], 'o'
        mov    [dbg_error+9], 'p'
        mov    [dbg_error+10], 'c'
        mov    [dbg_error+11], 'o'
        mov    [dbg_error+12], 'd'
        mov    [dbg_error+13], 'e'
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 07   ;
;-------------------------------;
isr07:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'N'
        mov    [dbg_error+1], 'o'
        mov    [dbg_error+2], ' '
        mov    [dbg_error+3], 'c'
        mov    [dbg_error+4], 'o'
        mov    [dbg_error+5], 'p'
        mov    [dbg_error+6], '.'
        mov    [dbg_error+7], ' '
        mov    [dbg_error+8], 'a'
        mov    [dbg_error+9], 'v'
        mov    [dbg_error+10], 'a'
        mov    [dbg_error+11], 'i'
        mov    [dbg_error+12], 'l'
        mov    [dbg_error+13], '.'
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 08   ;
;-------------------------------;
isr08:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'D'
        mov    [dbg_error+1], 'o'
        mov    [dbg_error+2], 'u'
        mov    [dbg_error+3], 'b'
        mov    [dbg_error+4], 'l'
        mov    [dbg_error+5], 'e'
        mov    [dbg_error+6], ' '
        mov    [dbg_error+7], 'f'
        mov    [dbg_error+8], 'a'
        mov    [dbg_error+9], 'u'
        mov    [dbg_error+10], 'l'
        mov    [dbg_error+11], 't'
        mov    [dbg_error+12], ' '
        mov    [dbg_error+13], ' '
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 09   ;
;-------------------------------;
isr09:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'C'
        mov    [dbg_error+1], 'o'
        mov    [dbg_error+2], 'p'
        mov    [dbg_error+3], 'r'
        mov    [dbg_error+4], 'o'
        mov    [dbg_error+5], '.'
        mov    [dbg_error+6], ' '
        mov    [dbg_error+7], 's'
        mov    [dbg_error+8], 'e'
        mov    [dbg_error+9], 'g'
        mov    [dbg_error+10], 'm'
        mov    [dbg_error+11], 'e'
        mov    [dbg_error+12], 'n'
        mov    [dbg_error+13], 't'
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 10   ;
;-------------------------------;
isr0A:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'I'
        mov    [dbg_error+1], 'n'
        mov    [dbg_error+2], 'v'
        mov    [dbg_error+3], 'a'
        mov    [dbg_error+4], 'l'
        mov    [dbg_error+5], 'i'
        mov    [dbg_error+6], 'd'
        mov    [dbg_error+7], ' '
        mov    [dbg_error+8], 'T'
        mov    [dbg_error+9], 'S'
        mov    [dbg_error+10], 'S'
        mov    [dbg_error+11], '!'
        mov    [dbg_error+12], ' '
        mov    [dbg_error+13], ' '
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 11   ;
;-------------------------------;
isr0B:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'N'
        mov    [dbg_error+1], 'o'
        mov    [dbg_error+2], ' '
        mov    [dbg_error+3], 's'
        mov    [dbg_error+4], 'e'
        mov    [dbg_error+5], 'g'
        mov    [dbg_error+6], 'm'
        mov    [dbg_error+7], 'e'
        mov    [dbg_error+8], 'n'
        mov    [dbg_error+9], 't'
        mov    [dbg_error+10], '!'
        mov    [dbg_error+11], ' '
        mov    [dbg_error+12], ' '
        mov    [dbg_error+13], ' '
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 12   ;
;-------------------------------;
isr0C:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'S'
        mov    [dbg_error+1], 't'
        mov    [dbg_error+2], 'a'
        mov    [dbg_error+3], 'c'
        mov    [dbg_error+4], 'k'
        mov    [dbg_error+5], ' '
        mov    [dbg_error+6], 'f'
        mov    [dbg_error+7], 'a'
        mov    [dbg_error+8], 'u'
        mov    [dbg_error+9], 'l'
        mov    [dbg_error+10], 't'
        mov    [dbg_error+11], '!'
        mov    [dbg_error+12], ' '
        mov    [dbg_error+13], ' '
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 13   ;
;-------------------------------;
isr0D:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'T'
        mov    [dbg_error+1], 'r'
        mov    [dbg_error+2], 'i'
        mov    [dbg_error+3], 'p'
        mov    [dbg_error+4], 'l'
        mov    [dbg_error+5], 'e'
        mov    [dbg_error+6], ' '
        mov    [dbg_error+7], 'f'
        mov    [dbg_error+8], 'a'
        mov    [dbg_error+9], 'u'
        mov    [dbg_error+10], 'l'
        mov    [dbg_error+11], 't'
        mov    [dbg_error+12], '!'
        mov    [dbg_error+13], ' '
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 14   ;
;-------------------------------;
isr0E:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'P'
        mov    [dbg_error+1], 'a'
        mov    [dbg_error+2], 'g'
        mov    [dbg_error+3], 'e'
        mov    [dbg_error+4], ' '
        mov    [dbg_error+5], 'f'
        mov    [dbg_error+6], 'a'
        mov    [dbg_error+7], 'u'
        mov    [dbg_error+8], 'l'
        mov    [dbg_error+9], 't'
        mov    [dbg_error+10], '!'
        mov    [dbg_error+11], ' '
        mov    [dbg_error+12], ' '
        mov    [dbg_error+13], ' '
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 16   ;
;-------------------------------;
isr10:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'C'
        mov    [dbg_error+1], 'o'
        mov    [dbg_error+2], 'p'
        mov    [dbg_error+3], 'r'
        mov    [dbg_error+4], 'o'
        mov    [dbg_error+5], 'c'
        mov    [dbg_error+6], 'e'
        mov    [dbg_error+7], 's'
        mov    [dbg_error+8], 's'
        mov    [dbg_error+9], 'o'
        mov    [dbg_error+10], 'r'
        mov    [dbg_error+11], '!'
        mov    [dbg_error+12], ' '
        mov    [dbg_error+13], ' '
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 17   ;
;-------------------------------;
isr11:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'A'
        mov    [dbg_error+1], 'l'
        mov    [dbg_error+2], 'i'
        mov    [dbg_error+3], 'g'
        mov    [dbg_error+4], 'n'
        mov    [dbg_error+5], 'm'
        mov    [dbg_error+6], 'e'
        mov    [dbg_error+7], 'n'
        mov    [dbg_error+8], 't'
        mov    [dbg_error+9], ' '
        mov    [dbg_error+10], 'c'
        mov    [dbg_error+11], 'h'
        mov    [dbg_error+12], 'k'
        mov    [dbg_error+13], '.'
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 18   ;
;-------------------------------;
isr12:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'M'
        mov    [dbg_error+1], 'a'
        mov    [dbg_error+2], 'c'
        mov    [dbg_error+3], 'h'
        mov    [dbg_error+4], 'i'
        mov    [dbg_error+5], 'n'
        mov    [dbg_error+6], 'e'
        mov    [dbg_error+7], ' '
        mov    [dbg_error+8], 'c'
        mov    [dbg_error+9], 'h'
        mov    [dbg_error+10], 'e'
        mov    [dbg_error+11], 'c'
        mov    [dbg_error+12], 'k'
        mov    [dbg_error+13], '!'
        mov    [dbg_error+14], 0
        call   dump_regs


;-------------------------------;
;  Exception Interrupt no. 19   ;
;-------------------------------;
isr13:
        mov    [dbg_keypress], 0
        mov    [dbg_error], 'S'
        mov    [dbg_error+1], 'I'
        mov    [dbg_error+2], 'M'
        mov    [dbg_error+3], 'D'
        mov    [dbg_error+4], ' '
        mov    [dbg_error+5], 'f'
        mov    [dbg_error+6], 'l'
        mov    [dbg_error+7], 'o'
        mov    [dbg_error+8], 'a'
        mov    [dbg_error+9], 't'
        mov    [dbg_error+10], '.'
        mov    [dbg_error+11], '-'
        mov    [dbg_error+12], 'p'
        mov    [dbg_error+13], '.'
        mov    [dbg_error+14], 0
        call   dump_regs



;--------------------------;
;   ISR 20. The timer.     ;
;--------------------------;
isr20:
        pusha
        push   gs
        push   fs
        push   ds
        push   es

        call   timer                                  ; in timer.inc

        pop   es
        pop   ds
        pop   fs
        pop   gs
        popa
        iret


;--------------------------;
;  Keyboard IRQ. ISR 21.   ;
;--------------------------;
isr21:
        pusha
        push   gs
        push   fs
        push   ds
        push   es
        push   esi

        call   keyboard_isr                           ; Located in keyboard.inc

        pop    esi
        pop    es
        pop    ds
        pop    fs
        pop    gs
        popa
        iret


;---------------------;
;  Interrupt no. 50   ;
;---------------------;
isr32:
        push   gs
        push   fs
        push   ds
        push   es

        call   interrupt_32                           ; Located in sys_ints.inc

        pop    es
        pop    ds
        pop    fs
        pop    gs
        iret