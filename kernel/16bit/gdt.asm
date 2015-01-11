;----------------------------------------------------------;
; BOS kernel                Christoffer Bubach, 2004-2005. ;
;----------------------------------------------------------;
;                                                          ;
;     Global Descriptor Table (GDT).                       ;
;                                                          ;
;----------------------------------------------------------;

;-------------------;
;  pointer to GDT   ;
;-------------------;
gdtr:
    .size        dw   gdt_end - gdt - 1
    .address     dd   0x7400                          ; here we move the gdt

;-----------------------------------;
;  Global Descriptor Table (GDT).   ;
;-----------------------------------;
gdt:
    .null        dw   0x0000, 0x0000, 0x0000, 0x0000  ; null desc.
    .BOS_code:   dw   0xFFFF, 0x0000, 0x9A00, 0x00CF  ; 0x08 , was 9800 before.
    .BOS_data:   dw   0xFFFF, 0x0000, 0x9200, 0x00CF  ; 0x10
    .BOS_16code: dw   0xFFFF, 0x0000, 0x9A00, 0x0000  ; 0x18
    .BOS_16data: dw   0xFFFF, 0x0000, 0x9200, 0x0000  ; 0x20
gdt_end: