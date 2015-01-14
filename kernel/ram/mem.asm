;----------------------------------------------------------;
; BOS kernel                Christoffer Bubach, 2003-2005. ;
;----------------------------------------------------------;
;                                                          ;
;           functions to allocate/free mem.                ;
;                                                          ;
;----------------------------------------------------------;

;----------------;
;   variables    ;
;----------------;
    first_free     dd   0
    prev_pointer   dd   0
    size           dd   0
    next_pointer   dd   0


;------------------------------------------------------;
;   init mem                                           ;
;                   in: ebx = first free memory        ;
;                       ecx = total memory size        ;
;------------------------------------------------------;
init_mem:
        push   ecx

        mov    [first_free], ebx
        sub    ecx, ebx
        mov    [size], ecx
        mov    [prev_pointer], 0
        mov    [next_pointer], 0
        mov    ecx, [prev_pointer]
        mov    [ebx], ecx
        mov    ecx, [size]
        mov    [ebx+4], ecx
        mov    ecx, [next_pointer]
        mov    [ebx+8], ecx

        pop    ecx
        ret



;------------------------------------------------------;
;   allocate memory                                    ;
;                    in:  ebx = wanted size in bytes   ;
;                    out: eax = 0 if failed            ;
;                         ebx = pointer to memory      ;
;------------------------------------------------------;
allocate_mem:
        push   ecx
        push   edx

        mov    eax, [first_free]

    .loop:
        mov    ecx, [eax]
        mov    [prev_pointer], ecx

        mov    ecx, [eax+4]
        mov    [size], ecx

        mov    ecx, [eax+8]
        mov    [next_pointer], ecx

        cmp    [size], ebx
        jae    .found
        cmp    [next_pointer], 0
        je     .error
        mov    eax, [next_pointer]
        jmp    .loop

    .error:
        xor    eax, eax
        jmp    .end

    .found:
        mov    ecx, [size]
        sub    ecx, ebx
        jz     .equal

        cmp    [next_pointer], 0
        jne    .next_exists
        cmp    [prev_pointer], 0
        jne    .prev_but_no_next


    ;----------------------------------------------;
    ; no other block exists; add new free block    ;
    ; with the reminding space as free, and move   ;
    ; "first free" to that block..                 ;
    ;----------------------------------------------;
        mov    ecx, eax                               ; move address to ecx and
        add    ecx, ebx                               ; add size. ecx=end requested
        mov    dword [ecx], 0                         ; set new header's prev to 0
        mov    edx, [size]
        sub    edx, ebx                               ; remaining space in edx
        mov    [ecx+4], edx                           ; save it to new header
        mov    dword [ecx+8], 0                       ; no next pointer..

        mov    [first_free], ecx
        mov    ebx, eax                               ; eax is unchanged from loop
        jmp    .end

    ;----------------------------------------------;
    ; no next block exists, make a new header at   ;
    ; the end of the requested size with the       ;
    ; reminder of the free space, and update the   ;
    ; prev header's next pointer..                 ;
    ;----------------------------------------------;
    .prev_but_no_next:
        mov    ecx, eax                               ; move address to ecx and
        add    ecx, ebx                               ; add size. ecx=end requested
        mov    edx, [prev_pointer]                    ; set prev for new header
        mov    [ecx], edx                             ; set new header's prev to 0
        mov    edx, [size]
        sub    edx, ebx                               ; remaining space in edx
        mov    [ecx+4], edx                           ; save it to new header
        mov    dword [ecx+8], 0                       ; no next pointer..

        mov    [prev_pointer+8], ecx
        mov    ebx, eax                               ; eax is unchanged from loop
        jmp    .end


    ;----------------------------------------------;
    ; both next and previous blocks exists, make a ;
    ; new header at the end of the requested size  ;
    ; with the reminder of the free space, move    ;
    ; data from next block to the new one but add  ;
    ; size so it gets right, then update all prev/ ;
    ; next pointers for total 3 blocks.. puh..     ;
    ;----------------------------------------------;
    .next_exists:
        cmp    [prev_pointer], 0
        je     .next_but_no_prev

        mov    ecx, eax                               ; move address to ecx and
        add    ecx, ebx                               ; add size. ecx=end requested
        mov    edx, [prev_pointer]                    ; set prev for new header
        mov    [ecx], edx                             ; set new header's prev
        mov    edx, [size]
        sub    edx, ebx
        mov    ebx, [next_pointer+4]
        add    edx, ebx                               ; remaining space in edx
        mov    [ecx+4], edx                           ; save it to new header
        mov    edx, [next_pointer]                    ; address to next block
        cmp    dword [edx], 0
        je     .no_next_next
        mov    dword [edx], ecx                       ; update next-next's prev..
        mov    dword [ecx+8], edx                     ; address to next pointer.

        mov    [prev_pointer+8], ecx
        mov    ebx, eax                               ; eax is unchanged from loop
        jmp    .end
    .no_next_next:
        mov    dword [edx], 0
        mov    dword [ecx+8], 0
        mov    [prev_pointer+8], ecx
        mov    ebx, eax                               ; eax is unchanged from loop
        jmp    .end


    ;----------------------------------------------;
    ; we allocated the first free block, do the    ;
    ; same as above, except ignore the prev block  ;
    ; part, and move the "first free".             ;
    ;----------------------------------------------;
    .next_but_no_prev:
        mov    ecx, eax                               ; move address to ecx and
        add    ecx, ebx                               ; add size. ecx=end requested
        mov    dword [ecx], 0                         ; set new header's prev to 0
        mov    edx, [size]
        sub    edx, ebx
        mov    ebx, [next_pointer+4]
        add    edx, ebx                               ; remaining space in edx
        mov    [ecx+4], edx                           ; save it to new header
        mov    edx, [next_pointer]                    ; address to next block
        cmp    dword [edx], 0
        je     .no_next_next2
        mov    dword [edx], ecx                       ; update next-next's prev..
        mov    dword [ecx+8], edx                     ; address to next pointer.

        mov    [first_free], ecx                      ; zero and update first free.
        mov    ebx, eax                               ; eax is unchanged from loop
        jmp    .end
    .no_next_next2:
        mov    dword [edx], 0
        mov    ecx, [ecx+8]
        mov    dword [ecx], 0
        mov    [prev_pointer+8], ecx
        mov    ebx, eax                               ; eax is unchanged from loop
        jmp    .end


    ;-----------------------------------------;
    ;   requested == size                     ;
    ;   I prefered coding this one.. ;)       ;
    ;-----------------------------------------;
    .equal:
        cmp    [next_pointer], 0
        jne    .next_exists2
        cmp    [prev_pointer], 0
        jne    .prev_but_no_next2
        mov    [first_free], 0
        mov    ebx, eax                               ; eax is unchanged from loop
        jmp    .end

    .prev_but_no_next2:
        mov    dword [prev_pointer+8], 0
        mov    ebx, eax                               ; eax is unchanged from loop
        jmp    .end

    .next_exists2:
        cmp    [prev_pointer], 0
        je     .next_but_no_prev2
        mov    ecx, [prev_pointer]                    ; update prev and next's
        mov    edx, [next_pointer]                    ; headers to bypass this
        mov    [ecx+8], edx                           ; chunk.
        mov    [edx], ecx
        mov    ebx, eax                               ; eax is unchanged from loop
        jmp    .end

    .next_but_no_prev2:
        mov    ecx, [eax+8]                           ; get address of next header
        mov    dword [ecx], 0                         ; set prev in next header to
        mov    [first_free], ecx                      ; zero and update first free.
        mov    ebx, eax                               ; eax is unchanged from loop

    .end:
        pop    edx
        pop    ecx
        ret




;------------------------------------------------------;
;    free memory                                       ;
;                  in:  ebx = pointer to mem           ;
;                       ecx = size in bytes            ;
;------------------------------------------------------;
free_mem:
        push   eax
        push   ebx
        push   ecx
        push   edx

        cmp    ebx, [first_free]
        jb     .new_first_free
        cmp    [first_free], 0
        je     .new_first_free

    ;-----------------------------------------------------------;
    ; the block we want to free is somewhere in between         ;
    ; two other free blocks or after the last free block.       ;
    ; search for the "ebx"-address, so we know where the new    ;
    ; prev/next pointers are, and then can check if we should   ;
    ; merge blocks..                                            ;
    ;-----------------------------------------------------------;
        mov    eax, [first_free]                      ; "current" free block
        mov    edx, [eax+8]                           ; next free block

    .find_pos_loop:
        cmp    edx, 0                                 ; check if the "next"
        je     .found_end_of_ram                      ; free exists..

        cmp    ebx, edx                               ; is ebx "below" edx?
        jb     .found_between                         ; found ebx in between

        mov    eax, edx                               ; update pointers for
        mov    edx, [eax+8]                           ; another loop.
        jmp    .find_pos_loop

    ;------------------------------------------;
    ;  the block is between two other blocks   ;
    ;------------------------------------------;
    .found_between:
        mov    [ebx], eax                             ; create header
        mov    [ebx+4], ecx
        mov    [ebx+8], edx

        mov    [eax+8], ebx                           ; update prev header
        mov    [edx], ebx                             ; update next header

        ; now check if we can merge blocks....
        add    ecx, ebx
        cmp    edx, ecx
        jne    .merge_only_first
        push   eax
        add    eax, [eax+4]
        cmp    ebx, eax
        pop    eax
        jne    .merge_only_last

        ; we can merge with both prev & next
        mov    ecx, [ebx+4]                           ; get size from "current"
        add    [eax+4], ecx                           ; and add it to "prev".
        mov    ecx, [edx+4]                           ; get size from "next"
        add    [eax+4], ecx                           ; and add it to "prev".
        mov    ecx, [edx+8]                           ; get the new next
        mov    [eax+8], ecx                           ; pointer, and store it.
        cmp    ecx, 0
        je     .end
        mov    [ecx], eax
        jmp    .end

    .merge_only_first:
        cmp    ebx, eax
        jne    .end
        mov    ecx, [ebx+4]                           ; get size from "current"
        add    [eax+4], ecx                           ; and add it to "prev".
        mov    [edx], eax                             ; update prev and next
        mov    [eax+8], edx                           ; pointers for the two..
        jmp    .end

    .merge_only_last:
        cmp    edx, ecx
        jne    .end
        mov    ecx, [edx+4]
        add    [ebx+4], ecx
        mov    ecx, [edx+8]
        mov    [ebx+8], ecx
        cmp    ecx, 0
        je     .end
        mov    [ecx], ebx
        jmp    .end

    ;----------------------------------------------;
    ;  the block is after all existing free ones   ;
    ;----------------------------------------------;
    .found_end_of_ram:
        mov    [ebx], eax                             ; create header
        mov    [ebx+4], ecx
        mov    [ebx+8], edx

        mov    [eax+8], ebx                           ; update prev header

        ; now check if we can merge the blocks....
        mov    ecx, eax
        add    ecx, [eax+4]
        cmp    ebx, ecx
        jne    .end
        mov    ecx, [ebx+4]
        add    [eax+4], ecx
        mov    ecx, [ebx+8]
        mov    [eax+8], ecx
        jmp    .end

    ;--------------------------------------------;
    ;  the block is before any other free ones   ;
    ;--------------------------------------------;
    .new_first_free:
        mov    dword [ebx], 0
        mov    [ebx+4], ecx                           ; create the
        mov    edx, [first_free]                      ; new header
        mov    [ebx+8], edx

        mov    edx, ebx                               ; check if the
        add    edx, [ebx+4]                           ; first_free matches
        cmp    edx, [first_free]                      ; current pos + size?
        je     .merge_first_free                      ; if so, merge the two

        cmp    [first_free], 0                        ; else check if
        je     .cont1                                 ; first_free exists
        mov    edx, [ebx+8]                           ; if it does, update
        mov    [edx], ebx                             ; it's prev pointer.
    .cont1:
        mov    [first_free], ebx                      ; else/and set new
        jmp    .end                                   ; first free and quit

    .merge_first_free:                                ; merge the two first
        mov    edx, [ebx+8]                           ; add the size of the
        mov    ecx, [edx+4]                           ; second block to the
        add    [ebx+4], ecx                           ; new one.
        mov    ecx, [edx+8]                           ; get the next pointer
        mov    [ebx+8], ecx                           ; from the old block,
        cmp    ecx, 0
        je     .cont2
        mov    [ecx], ebx                             ; update this + next..
    .cont2:
        mov    [first_free], ebx                      ; update first_free

    .end:
        pop    edx
        pop    ecx
        pop    ebx
        pop    eax
        ret