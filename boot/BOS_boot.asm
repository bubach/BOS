;------------------------------------------------------------;
;                 BOS - FAT12 bootsector                     ;
;------------------------------------------------------------;
;  - FAT12 compatible.                                       ;
;  - Loads a binary file from the floppy.                    ;
;                                                            ;
;     16-bit mem map  (seg:off)                              ;
;------------------------------------------------------------;
;  0x0000:0x0000 -> 0x0000:0x0500  BIOS stuff                ;
;  0x0000:0x0500 -> 0x0000:0x2100  FAT12 rootdir             ;
;  0x0000:0x2100 -> 0x0000:0x3300  FAT for FAT12             ;
;  0x0000:0x3300 -> 0x0000:0x6c00  14,25kb free space        ;
;  0x0000:0x6c00 -> 0x0000:0x7400  IDT, 256 descriptors      ;
;  0x0000:0x7400 -> 0x0000:0x7c00  GDT, 256 descriptors      ;
;  0x0000:0x7c00 -> 0x0000:0x7e00  bootsector                ;
;  0x0000:0x7e00 <- 0x0000:0x8000  512b stack for boot       ;
;  0x0000:0x8000 -> 0x9000:0xffff  608kb kernel/free space   ;
;  0xA000:0x0000 -> .............  VGA mem etc.              ;
;------------------------------------------------------------;

use16
org 0x7C00

boot:
        jmp    short start
        nop

;------------------------------------------;
;  Standard BIOS Parameter Block, "BPB".   ;
;------------------------------------------;
    bpbOEM          db  'BOS 0.04'
    bpbSectSize     dw  512
    bpbClustSize    db  1
    bpbReservedSec  dw  1
    bpbFats         db  2
    bpbRootSize     dw  224
    bpbTotalSect    dw  2880
    bpbMedia        db  240
    bpbFatSize      dw  9
    bpbTrackSect    dw  18
    bpbHeads        dw  2
    bpbHiddenSect   dd  0
    bpbLargeSect    dd  0
    ;---------------------------------;
    ;  extended BPB for FAT12/FAT16   ;
    ;---------------------------------;
    bpbDriveNo      db  0
    bpbReserved     db  0
    bpbSignature    db  41                            ; 0 = end. 41 = three more.
    bpbID           dd  1
    bpbVolumeLabel  db  'BOOT FLOPPY'
    bpbFileSystem   db  'FAT12   '


;----------------------------------------;
;   starting point of bootsector code    ;
;----------------------------------------;
start:
        cli

        xor    ax, ax                                 ; initialize all the necessary
        mov    ds, ax                                 ; registers.
        mov    es, ax
        mov    ss, ax
        mov    sp, 0x8000                             ; Stack..

        mov    [bpbDriveNo], dl

        sti


    ;----------------------------------;
    ;   clear screen and print some    ;
    ;----------------------------------;
        mov    ax, 3                                  ; Set mode 0x03
        int    0x10

        mov    bp, loading                            ; Print loading message.
        mov    ax, 0x1301
        mov    bx, 7
        mov    cx, 12
        mov    dx, 0x0102
        int    0x10

        mov    bl, 2                                  ; Set cursor.
        mov    ah, 2
        mov    dx, 0x0201
        int    0x10

        mov    ah, 9                                  ; Print 14 green dots.
        mov    al, '.'
        mov    cx, 14
        int    0x10


    ;---------------------------;
    ;    load FAT and root      ;
    ;---------------------------;
        mov    di, 0x0050                             ; Load the root to
        mov    ax, 19                                 ; 0x0000:0x0500 (0x500/0x10)
        mov    cx, 14
        call   read_sectors

        mov    di, 0x0210                             ; Load the fat to
        mov    ax, 1                                  ; 0x0000:0x2100
        mov    cx, 9
        call   read_sectors


    ;------------------------;
    ;  search for the file   ;
    ;------------------------;
        mov    dx, [bpbRootSize]
        mov    bx, 0x0500
    .filesearch:
        cld
        mov    si, filename
        mov    cx, 11
        mov    di, bx
        repe   cmpsb
        je     found
        add    bx, 32
        dec    dx
        jz     error
        jmp    .filesearch


;-----------------------------------;
;      variables & functions        ;
;-----------------------------------;
    loading    db  'Starting BOS'
    filename   db  'KERNEL  SYS'
    failure    db  'Read error!'


;-----------------------------------------------;
;   read a number of sectors (one at a time)    ;
;-----------------------------------------------;
;  in:                                          ;
;    di = segment to save at                    ;
;    ax = sector to read                        ;
;    cx = number of sectors                     ;
;  out:                                         ;
;    di = updated (added for next read)         ;
;    ax = updated (added for next read)         ;
;-----------------------------------------------;
read_sectors:
        pusha
        mov    bl, byte [bpbTrackSect]                ; bl = number of sectors per track
        div    bl                                     ; al = ax / bl
        mov    cl, ah                                 ; cl = real sector number
        add    cl, 1

        xor    ah, ah                                 ; del the rest of the div before
        mov    bl, byte [bpbHeads]                    ; bl = number of heads
        div    bl                                     ; ah = rest of ( ax / bx ), al = ax / bx
        mov    ch, al                                 ; ch = number of track
        mov    dh, ah                                 ; dh = the head number

        mov    ax, cx                                 ; save cx in ax
        mov    cx, 6                                  ; try it 6 times
    .next_try:
        push   es
        push   cx
        mov    cx, ax                                 ; restore cx
        push   cx

        xor    ax, ax
        mov    dl, [bpbDriveNo]                       ; reset drive
        push   dx
        int    0x13
        jc     .failed

        pop    dx
        pop    cx
        xor    bx, bx
        mov    es, di
        mov    ax, 0x0201                             ; function 2, 1 sector
        int    0x13
        jnc    .ok                                    ; if it was ok, check next..

    .failed:
        pop    dx
        pop    ax

        pop    cx
        pop    es
        loop   .next_try                              ; else try once again if there is an error
        jmp    error                                  ; if cx = 0 and the read operation failed, halt
    .ok:
        pop    cx                                     ; from the next_try loop
        pop    es
        popa
        add    di, 32                                 ; add 32 (512/16) to segment
        inc    ax                                     ; add sector counter
        loop   read_sectors
        ret


;----------------------------------------------------;
;  show a message and wait for a key before reboot   ;
;----------------------------------------------------;
error:
        mov    bp, failure
        mov    ax, 0x1301
        mov    bx, 4
        mov    cx, 11
        mov    dx, 0x0401
        int    0x10

        mov    ah, 0
        int    0x16
        int    0x19


;-----------------------------------;
;   the file is found, load it.     ;
;-----------------------------------;
found:
        mov    bp, [bx+26]                            ; bp = cluster from dir entry
        mov    di, 0x0800                             ; 800 (segment)

    .next_block:
        xor    cx, cx
        mov    cl, [bpbClustSize]                     ; reset sector count to 1 cluster
        mov    si, bp                                 ; si = next should-be cluster for
                                                      ; contiguous reads
    .next_contiguous:
        mov    ax, 3
        mul    si                                     ; multiply cluster number by 3
        shr    ax, 1                                  ; divide by two
        mov    bx, ax
        mov    ax, word [(0x2100+bx)]                 ; ax = FAT element with junk
        jc     .odd_cluster                           ; jump if the value was odd
        and    ax, 0x0FFF                             ; leave only lower 12 bits
        jmp    .got_cluster                           ; got it
    .odd_cluster:
        shr    ax, 4                                  ; (leave only bits 4-15)

    .got_cluster:
        inc    si                                     ; si = current cluster+1
        cmp    ax, si                                 ; next cluster = current cluster+1?
        jne    .force_read                            ; is it still contiguous?

        add    cl, [bpbClustSize]                     ; increase sector count by 1 cluster
        adc    ch, 0                                  ; add cf + 0 to ch
        jmp    .next_contiguous

    .force_read:
        xchg   bp, ax                                 ; ax = bp (base cluster), bp = new cluster
        dec    ax                                     ; decrease by 2 to get the actual...
        dec    ax                                     ; ...cluster number

        movzx  dx, byte [bpbClustSize]
        mul    dx                                     ; multiply by sectors per cluster
        add    ax, 33                                 ; add data-area location (33)
        call   read_sectors

        cmp    bp, 0x0FF8                             ; is the new cluster EOF (FF8-FFF)?
        jb     .next_block                            ; if not, read next block

;-----------------------;
;  the file is loaded   ;
;-----------------------;
quit:
        jmp    0x0000:0x8000                          ; jump to loaded file (64kb in mem)


;-------------------------------------;
; set the BOOT-signature at byte 510. ;
;-------------------------------------;
        rb boot+512-2-$
        dw 0xAA55