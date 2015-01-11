;----------------------------------------------------------;
; BOS kernel                Christoffer Bubach, 2003-2015. ;
;----------------------------------------------------------;
;                                                          ;
;   Set/modify IDT entries                                 ;
;                                                          ;
;----------------------------------------------------------;

;-----------------------------------------------------;
;                                                     ;
; IDT entry structure                                 ;
;                                                     ;
;   16bit - entry offset bits 0..15                   ;
;   16bit - code segment selector in GDT or LDT       ;
;   8bit  - unused, set to 0                          ;
;   8bit  - type and attributes                       ;
;              -  0xE = 32bit intterrupt              ;
;              -  0x8 = Present bit = 1               ;
;   16bit - entry offset bits 16..31                  ;
;                                                     ;
;   middle section for code segment 08 = 0x8E000008   ;
;-----------------------------------------------------;


;--------------------------------------------------;
;     set up IDT                                   ;
; in:  esi = pointer to "unhandled int"-function.  ;
;--------------------------------------------------;
init_idt:
        push   eax
        push   ecx
        push   edi

        xor    edi, edi
        xor    ecx, ecx
        add    edi, [idtr.address]
    .l1:                                              ; loop full IDT table
        mov    eax, esi
        mov    word [edi], ax                         ; set handler lower offset
        add    edi, 2

        mov    dword [edi], 0x8E000008                ; set IDT segment and attributes
        add    edi, 4

        mov    eax, esi
        shr    eax, 16
        mov    word [edi], ax                         ; set handler high offset
        add    edi, 2

        add    cx, 8                                  ; 8byte *
        cmp    cx, word [idtr.size]                   ; 256 ints
        jb     .l1                                    ; = done?

        pop    edi
        pop    ecx
        pop    eax
        ret



;--------------------------------------;
;  modify IDT, set any int             ;
;     in: cl  = int number             ;
;      edi = int function pointer      ;
;--------------------------------------;
set_int:
        push   eax
        push   ecx

        mov    al, 8                                  ; 8 bytes for each int
        mul    cl                                     ; cl * al = ax
        movzx  ecx, ax                                ; ecx = IDT offset
        shr    ecx, 1                                 ; 1/2 for dword list
        mov    dword [(idt_list+ecx)], edi            ; add to dword int list
        movzx  ecx, ax                                ; ecx = IDT offset

        mov    eax, edi
        mov    [(0x6c00+ecx)], ax
        add    ecx, 2

        mov    dword [(0x6c00+ecx)], 0x8E000008
        add    ecx, 4

        mov    eax, edi
        shr    eax, 16
        mov    [(0x6c00+ecx)], ax

        pop    ecx
        pop    eax
        ret



;------------------------------------------------;
;   get int address                              ;
;      in:  cl    = int number                   ;
;      out: esi = address or 0 if none present   ;
;------------------------------------------------;
get_int:
        push   eax

        mov    eax, 4                                 ; 4 bytes for each address
        mul    cl                                     ; cl * al = ax
        mov    esi, idt_list
        add    esi, eax

        pop    eax
        ret




;----------------------------------------;
;   sets ints from list                  ;
;      in:  esi = pointer to int list    ;
;----------------------------------------;
set_idt_list:
        push   eax
        push   edi

        xor    ecx, ecx
    .l1:
        lodsd
        or     eax, eax
        jz     .next
        mov    edi, eax
        call   set_int
    .next:
        inc    ecx
        cmp    ecx, 0x100
        jb     .l1

        pop    edi
        pop    eax
        ret



;------------------------------;
;   list of idt entries.       ;
;        0 = not handled       ;
;------------------------------;
idt_list:   dd   isr00
            dd   isr01
            dd   isr02
            dd   isr03
            dd   isr04
            dd   isr05
            dd   isr06
            dd   isr07
            dd   isr08
            dd   isr09
            dd   isr0A
            dd   isr0B
            dd   isr0C
            dd   isr0D
            dd   isr0E
            dd   0
            dd   isr10
            dd   isr11
            dd   isr12
            dd   isr13
   times 12 dd   0                                    ; 12 unused ints
            dd   isr20
            dd   isr21
   times 16 dd   0                                    ; 16 unused ints
            dd   isr32                                ; First free and BOS system interrupt.
  times 205 dd   0                                    ; 205 unused ints