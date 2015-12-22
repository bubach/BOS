;----------------------------------------------------------;
; BOS kernel                Christoffer Bubach, 2004-2005. ;
;----------------------------------------------------------;
;                                                          ;
;    DMA transfer code.                                    ;
;                                                          ;
;----------------------------------------------------------;


;------------------------------------------;
;  Lookup table for DMA controller ports   ;
;------------------------------------------;
     dma_mask_reg    dw   0x0A, 0x0A, 0x0A, 0x0A, 0xD4, 0xD4, 0xD4, 0xD4
     dma_mode_reg    dw   0x0B, 0x0B, 0x0B, 0x0B, 0xD6, 0xD6, 0xD6, 0xD6
     dma_clear_reg   dw   0x0C, 0x0C, 0x0C, 0x0C, 0xD8, 0xD8, 0xD8, 0xD8
     dma_page_port   dw   0x87, 0x83, 0x81, 0x82, 0x8F, 0x8B, 0x89, 0x8A
     dma_addr_port   dw   0x00, 0x02, 0x04, 0x06, 0xC0, 0xC4, 0xC8, 0xCC
     dma_count_port  dw   0x01, 0x03, 0x05, 0x07, 0xC2, 0xC6, 0xCA, 0xCE


;-----------------------------------;
;   dma transfer                    ;
;                                   ;
;  in:  ecx = page:offset           ;
;       bl  = channel               ;
;       bh  = 1=read, 0=write       ;
;       esi = count                 ;
;                                   ;
;  out: nothing.                    ;
;-----------------------------------;
dma_transfer:
        push   eax
        push   edx
        push   esi
        cli
        or     bh, bh
        jz     .dont_read

        mov    bh, bl
        add    bh, 0x48
        jmp    .read
    .dont_read:
        mov    bh, bl
        add    bh, 0x44
    .read:
        dec    esi

        movzx  eax, bl
        mov    dx, word [(eax*2)+dma_mask_reg]
        mov    al, bl
        or     al, 0x04
        out    dx, al                                 ; disable the channel

        movzx  eax, bl
        mov    dx, word [(eax*2)+dma_clear_reg]
        mov    al, 0
        out    dx, al                                 ; initialize flip-flop

        movzx  eax, bl
        mov    dx, word [(eax*2)+dma_mode_reg]
        mov    al, bh
        out    dx, al                                 ; set DMA mode

        movzx  eax, bl
        mov    dx, word [(eax*2)+dma_addr_port]
        mov    al, cl
        out    dx, al                                 ; write low offset part
        mov    al, ch
        out    dx, al                                 ; and high offset part

        movzx  eax, bl
        mov    dx, word [(eax*2)+dma_page_port]
        mov    eax, ecx
        shr    eax, 16
        out    dx, al                                 ; write page.

        movzx  eax, bl
        mov    dx, word [(eax*2)+dma_count_port]
        mov    eax, esi
        out    dx, al                                 ; low count
        mov    al, ah
        out    dx, al                                 ; high count

        movzx  eax, bl
        mov    dx, word [(eax*2)+dma_mask_reg]
        mov    al, bl
        out    dx, al                                 ; enable channel

        sti
        pop    esi
        pop    edx
        pop    eax
        ret