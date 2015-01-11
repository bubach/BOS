;----------------------------------------------------------;
; BOS kernel                     Christoffer Bubach, 2005. ;
;----------------------------------------------------------;
;                                                          ;
;      Variabels for/from realmode.                        ;
;                                                          ;
;----------------------------------------------------------;

;---------------------------------------;
;  needed to get back to 16-bit mode    ;
;---------------------------------------;
    realmode_cs     dw   0
    ridtr:	     dw   0x3FF
                    dd   0

;----------------;
;  other stuff   ;
;----------------;
    int_number      db   0
    realmode_error  db   0
    realmode_ax     dw   0
    realmode_bx     dw   0
    realmode_cx     dw   0
    realmode_dx     dw   0

;-------------------;
;    saved info     ;
;-------------------;
    ram_amount      dd   0