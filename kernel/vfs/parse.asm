;--------------------------------------------------------------;
;   parse_path  -  parse path to get info on each part         ;
;--------------------------------------------------------------;
;                                                              ;
;             in:  esi = pointer to full ASCIIZ path           ;
;                  cl  = part no. to extract or 0 for none     ;
;                                                              ;
;             out: bl  = drive no. (VFS assigned) or zero      ;
;                  bh  = number of elements or zero for none   ;
;                  edi = pointer to ASCIIZ part of path in     ;
;                        cl, or 0 on error or no input         ;
;--------------------------------------------------------------;
parse_path:
          push    eax
          push    ecx
          push    edx
          push    esi

          cmp     byte [esi], 0
          je      .error
          cmp     byte [esi+1], 0                     ; minimum 3 chars drive
          je      .error
          cmp     byte [esi+2], 0
          je      .error

          and     byte [esi], 11011111b               ; (0xDF) to uppercase
          and     byte [esi+1], 11011111b             ; (0xDF) to uppercase

          mov     bl, 0x00                            ; fd base is 0x00
          cmp     word [esi], 'FD'                    ; fd check
          je      .drive_found
          mov     bl, 0x10                            ; hd base is 0x10
          cmp     word [esi], 'HD'                    ; hd check
          je      .drive_found
          mov     bl, 0x60                            ; cd base is 0x60
          cmp     word [esi], 'CD'                    ; cd check
          je      .drive_found
          mov     bl, 0x80                            ; vd base is 0x80
          cmp     word [esi], 'VD'                    ; vd (virtual ram drive) check
          je      .drive_found
          mov     bl, 0x90                            ; rd base is 0x90
          cmp     word [esi], 'RD'                    ; rd (removable/usb)
          je      .drive_found
          mov     bl, 0xB0                            ; nd base is 0xB0
          cmp     word [esi], 'ND'                    ; nd (net) check
          je      .drive_found

          jmp     .error                              ; no valid drive found

     ;-----------------------;
     ;   get drive number    ;
     ;-----------------------;
     .drive_found:
          xor     edx, edx                            ; esi offest for first /
          cmp     byte [esi+3], 0                     ; end of path
          je      .one_number
          cmp     byte [esi+3], '/'                   ; one number
          je      .one_number

          mov     edx, 4                              ; first / after numbers
          xor     eax, eax
          mov     ax, word [esi+2]                    ; get 2 bytes number
          jmp     .convert_cont
     .one_number:
          mov     edx, 3                              ; first / after numbers
          xor     eax, eax
          mov     al, byte [esi+2]                    ; 1 byte ASCII number
     .convert_cont:
          push    ecx
          xor     ecx, ecx
          cmp     ah, 0
          jne     .cont_convert
          pop     ecx
          sub     al, 0x30                            ; only one ASCII char.
          jmp     .number_found                       ; done.
     .cont_convert:
          mov     cl, ah
          sub     cx, 0x30                            ; take care of first
          push    ecx                                 ; save it for later..
          mov     cl, al
          sub     cx, 0x30
          shl     cx, 1                               ; multiply with 10 using
          mov     eax, ecx                            ; x*8 + x*2 =
          shl     cx, 2
          add     ax, cx                              ; x*10
          pop     ecx
          add     ax, cx                              ; add first number
          pop     ecx

     .number_found:
          add     bl, al                              ; add number to base

     ;------------------------;
     ;  parse parts of path   ;
     ;------------------------;
          mov     bh, 0                               ; start at zero
          add     esi, edx                            ; add start offset

          cmp     byte [esi], '/'
          jne     .end                                ; root, no parts
          xor     eax, eax                            ; counter
     .parts_loop:                                     ; loop for path parts
          inc     esi
          cmp     byte [esi], 0                       ; end of path?
          je      .end                                ; no inc in parts
          cmp     byte [esi], '/'                     ; end of part?
          je      .new_part
          cmp     eax, 0
          jne     .cont_parts
          inc     bh                                  ; inc no. of parts
     .cont_parts:
          inc     eax                                 ; char count inc

          cmp     cl, bh                              ; check for part to
          jne     .parts_loop                         ; save, if match:
          mov     edi, .filename_buffer               ; get buffer
          dec     edi                                 ; offset starts at 1,
          add     edi, eax                            ; not 0 - so fixed now
          push    eax
          mov     al, byte [esi]
          mov     byte [edi], al                      ; put the byte
          mov     byte [edi+1], 0                     ; make ASCIIZ
          pop     eax

          jmp     .parts_loop
     .new_part:
          xor     eax, eax                            ; reset char count
          jmp     .parts_loop                         ; loop again

     ;------------------------;
     ;   cleanup and return   ;
     ;------------------------;
     .end:
          mov     edi, .filename_buffer
          pop     esi
          pop     edx
          pop     ecx
          pop     eax
          ret
     .error:
          pop     esi
          pop     edx
          pop     ecx
          pop     eax
          mov     edi, 0                              ; not a valid part
          mov     bl, 0                               ; not a valid drive
          mov     bh, 0                               ; not a valid path
          ret

     .filename_buffer: times 256 db 0