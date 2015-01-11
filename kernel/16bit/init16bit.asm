;----------------------------------------------------------;
; BOS kernel                     Christoffer Bubach, 2005. ;
;----------------------------------------------------------;
;                                                          ;
;     Do everything related to 16-bit here... :)           ;
;                                                          ;
;----------------------------------------------------------;

;---------------------;
;    save info        ;
;---------------------;
init16bit:
        call   getmem                                 ; realmode/mem.inc
        mov    [ram_amount], eax

        xor    eax, eax                               ; clear mem for IDT and GDT
        mov    edi, [idtr.address]                    ; IDT address
        mov    ecx, (0x800 + 0x800)/4
        rep    stosd

        mov    eax, cs
        shl    eax, 4
        mov    [gdt.BOS_16code + 2], ax               ; Prepare GDT by
        mov    [gdt.BOS_16data + 2], ax               ; setting 16-bit base.
        shr    eax, 16
        mov    [gdt.BOS_16code + 4], al
        mov    [gdt.BOS_16data + 4], al
        mov    [gdt.BOS_16code + 7], ah
        mov    [gdt.BOS_16data + 7], ah

        lea    esi, [gdt]
        mov    edi, 0x7400                            ; GDT address
        mov    ecx, (gdt_end - gdt)/4
        rep    movsd                                  ; Move it to final pos.

        push   dword 0                                ; clear NT bit
        popfd
        ret