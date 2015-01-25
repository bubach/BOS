;----------------------------------------------------------;
; BOS kernel                Christoffer Bubach, 2012-2015. ;
;----------------------------------------------------------;
;                                                          ;
;    FAT12 driver.                                         ;
;                                                          ;
;----------------------------------------------------------;

    ;---------------------------------------------;
    ;   FAT12 calltable and structure pointer     ;
    ;---------------------------------------------;
    FAT12:
        .data_pointer         dd  0                   ; internal driver data
        .FSname               db  'FAT12'             ; 5 char filesystem name
        .init                 dd  init_fat12          ; pointer to init
        .deinit               dd  0                   ; remove driver
        .format               dd  0                   ; format drive
        .mount                dd  0                   ; mount drive
        .unmount              dd  0                   ; unmount drive
        .find                 dd  0                   ; find file
        .findnext             dd  0                   ; get next match
        .open                 dd  0                   ; open file, get handle
        .close                dd  0                   ; close file from handle
        .attrib               dd  0                   ; get/set attrib. and time
        .read                 dd  0                   ; read file from handle
        .write                dd  0                   ; write file from handle
        .seek                 dd  0                   ; seek from handle
        .rename               dd  0                   ; rename file
        .remove               dd  0                   ; remove file/dir
        .create               dd  0                   ; create file/dir
        .ioctl                dd  0                   ; extra calls if exists

    ;---------------------------------------------;
    ;   FAT12 main info structure                 ;
    ;---------------------------------------------;
    struc fat12_data
    {
        .disk_number                     db  0        ; which VFS disk number
        .root_dir                        dw  0        ; position of rootdir
        .disk_size                       dd  0        ; total storage size
        .free_space                      dd  0        ; free space available
        .fat_1                           dd  0        ; position of fat1
        .fat_2                           dd  0        ; position of fat2
        .data_area                       dw  0        ; position of dataarea
        .boot: times sizeof.bootsector   db  0        ; copy of FAT12 bootsector
        .dir_entries:
            times 16 * sizeof.dir_entry  db  0        ; 512b dir entry buffer
        .fat_buffer:      times 512      db  0        ; 512b FAT cluster info buffer
        .foundfile:
            times 1 * sizeof.search      db  0        ; "DTA" like structure
        .filehandles:                                 ; "System File Table"
            times 32 * sizeof.filehandle db  0        ; for now, max opened files is 32
    }

    virtual at 0                                      ; could use "at esi" instead
        fat12_data fat12_data
        sizeof.fat12_data = $-$$     
    end virtual

    ;---------------------------------------------;
    ;   FAT12 bootsector structure                ;
    ;---------------------------------------------;
    struc bootsector                                  ; 512 bytes
    {
        .jumper            db  0,0,0
        .oem               db  0,0,0,0,0,0,0,0
        .sectorsize        dw  0
        .sect_per_clust    db  0  
        .reserved_sect     dw  0                      ; reserved sectors, 1 for bootsector.
        .fats_per_drive    db  0
        .root_entries      dw  0
        .small_sectors     dw  0                      ; total sectors on small disk
        .media_describtor  db  0                      ; 240 / 0xF0 = 1.44MB, 3.5"
        .sectors_per_fat   dw  0                      ; 9   on 1.44MB, 3,5"
        .sect_per_track    dw  0                      ; 18  on 1.44MB, 3,5"
        .heads             dw  0                      ; 2   on 1.44MB, 3,5"
        .hidden_sectors    dd  0                      ; sectors before bootsector
        .large_sectors     dd  0                      ; total sectors if large disk
        .drive_no          db  0
        .reserved_field    db  0
        .bpb_signature     db  0                      ; 41=3 more (win NT req.), 0=end.
        .disk_id           dd  0                      ; random ident number on format.
        .volume_label      db  0,0,0,0,0,0,0,0,0,0,0
        .filesystem        db  0,0,0,0,0,0,0,0        ; "FAT12   " or "FAT16   "
        .code:   times 448 db  0 
        .boot_signature    db  0,0                    ; 0x55,0xAA
    }

    virtual at 0
        bootsector bootsector
        sizeof.bootsector = $-$$
    end virtual

    ;---------------------------------------------;
    ;   FAT12 directory entry structure           ;
    ;---------------------------------------------;
    struc dir_entry
    {
        .filename          db  0,0,0,0,0,0,0,0
        .extension         db  0,0,0
        .attributes        db  0                      ; 0x10 = dir for example.
        .reserved          db  0,0,0,0,0,0,0,0,0,0
        .changed_time      dw  0
        .changed_date      dw  0
        .start_cluster     dw  0
        .filesize          dd  0
    }

    virtual at 0
        dir_entry dir_entry
        sizeof.dir_entry = $-$$
    end virtual

    ;---------------------------------------------;
    ;   FAT12 directory entry for LFN             ;
    ;---------------------------------------------;
    struc lfn_entry
    {
        .order             db  0                      ; LFN entry in sequence, never 0x00 or 0xE5.
        .namefirst         dw  0,0,0,0,0              ; 5 first unicode (2byte) chars
        .attribute         db  0                      ; 0x0F for Long File Name identification.
        .reserved          db  0
        .checksum          db  0                      ; 8.3 name checksum
        .namemiddle        dw  0,0,0,0,0,0            ; middle 6 unicode (2byte) chars
        .zero_cluster      dw  0                      ; always zero on LNF entries
        .namelast          dw  0,0                    ; last 2 unicode (2byte) characters.
    }

    virtual at 0
        lfn_entry lfn_entry
        sizeof.lfn_entry = $-$$
    end virtual

    ;---------------------------------------------;
    ;   FAT12 file search/DTA structure           ;
    ;---------------------------------------------;
    struc search
    {
        .searchname:
            times 255      db  0                      ; file search pattern.
        .attribute         db  0                      ; search attribute.
        .direntry          dw  0                      ; directory entry number, 0 based
        .dircluster        dw  0                      ; starting cluster of dir, 0 root
        .foundattrib       db  0                      ; attribute of matching file
        .foundtime         dw  0                      ; file time
        .founddate         dw  0                      ; file date
        .foundsize         dw  0                      ; file size
    }

    virtual at 0
        search search
        sizeof.search = $-$$
    end virtual

    ;---------------------------------------------;
    ;   FAT12 file-handle structure               ;
    ;---------------------------------------------;
    struc filehandle
    {
        .handles           db  0                      ; reference count or or zero for unused
        .mode              db  0                      ; open mode. 0=read, 1=write, 2=r/w.
        .lfn_entry         dw  0                      ; file LFN directory entry position
        .direntry          dw  0                      ; file directory entry position
        .cluster           dw  0                      ; file first cluster
        .attribute         db  0                      ; file attributes
        .filetime          dw  0                      ; last modified time
        .filedate          dw  0                      ; last modified date
        .filesize          dd  0                      ; filesize
        .position          dd  0                      ; R/W position in file
        .clusterpos        dw  0                      ; cluster number of last cluster read
        .shortname:
            times 11       db  0                      ; short name
        .fullname:
            times 255      db  0                      ; the full LFN
    }

    virtual at 0
        filehandle filehandle
        sizeof.filehandle = $-$$
    end virtual

    ;------------------------------------------;
    ;   FAT cluster constants used             ;
    ;------------------------------------------;
    cluster_free        = 0x000                       ; up for grabs.
    cluster_reserved    = 0xFF0                       ; 0xFF0-0xFF6. 0xFF7=bad.
    cluster_last        = 0xFF8                       ; 0xFF8-0xFFF last cluster.

    ;------------------------------------------;
    ;   Directory entry first char constants   ;
    ;------------------------------------------;
    entry_free          = 0xE5                        ; up for grabs.
    entry_last          = 0x00                        ; this and remaining is free
    entry_japan_kludge  = 0x0E                        ; should be outputed as 0xE5.
    entry_dot           = 0x2E                        ; ASCII dot, check for "." or ".." dirs

    ;------------------------------------------;
    ;   Directory entry attribute masks        ;
    ;------------------------------------------;
    mask_readonly       = 0x01
    mask_hidden         = 0x02
    mask_system         = 0x04
    mask_volume_label   = 0x08
    mask_subdirectory   = 0x10
    mask_archive        = 0x20

    ;------------------------------------------;
    ;   Long File Name entry constants         ;
    ;------------------------------------------;
    lfn_last_entry_mask = 0x40                         ; LFN sequence-order mask for last
    attribute_lfn       = 0x0F                         ; attrb. byte value for LFN dir entry


;--------------------------------------------------------------;
;   init_fat12  -  detect if drive fs is fat12 and init        ;
;--------------------------------------------------------------;
;                                                              ;
;       in:  reg = pointer to VFS drive info                   ;
;                                                              ;
;       out: reg = pointer to struct(s) if FAT12 found         ;
;                                                              ;
;--------------------------------------------------------------;
init_fat12:
        push   eax
        ;...

     ;-----------------------------; 
     ;   calculate root location   ; 
     ;-----------------------------; 
        xor    eax, eax 
        mov    al, byte [fd0.boot.fats_per_drive] 
        mul    word [fd0.boot.sectors_per_fat] 
        add    ax, word [fd0.boot.reserved_sect] 
        mov    [fd0.root_dir], ax  

;   working with 
;mov  si, [drive] 
;mov  ax, [si+fat12.boot.sectorssize] 

        ; a bit more code here 
        pop    eax
        ret

;--------------------------------------------------------------;
; calc_lfn_chksum   - get long file name checksum              ;
;--------------------------------------------------------------;
;                                                              ;
;          in:   esi = pointer to 11 byte 8.3 filename         ;
;                                                              ;
;          out:   ax = checksum                                ;
;                                                              ;
;--------------------------------------------------------------;
calc_lfn_chksum:
        push   cx
        push   esi

        mov    cx, 11
        xor    ax, ax                                 ; return value start with null
    .l1:
        push   cx
        movzx  cx, byte [esi]                         ; add next char to sum
        add    ax, cx
        pop    cx
        shr    ax, 1                                  ; shift sum right by 1
        inc    esi                                    ; prepare for next character
        loop   .l1

        pop    esi    
        pop    cx
        ret

;--------------------------------------------------------------;
;   get_dir_entry  -  get a directory entry or amount          ;
;--------------------------------------------------------------;
;                                                              ;
;       in:  esi = pointer to prev dir entry or 0 for root     ;
;            cx  = entry no. to extract or 0 for none          ;
;                                                              ;
;       out: cx  = number of entries or unchanged if set       ;
;            edi = pointer to dir entry or unchanged if cx=0   ;
;--------------------------------------------------------------;
get_dir_entry:
        ;......
        ret

;--------------------------------------------------------------;
;   get_fat_entry  -  get a fat entry/cluster number           ;
;--------------------------------------------------------------;
;                                                              ;
;       in:  cx  = fat entry/cluster number                    ;
;                                                              ;
;       out: cx  = next fat entry/cluster no. or 0 if none     ;
;--------------------------------------------------------------;
get_fat_entry:
        ;...
        ret

;--------------------------------------------------------------;
;   get_cluster  -  get a cluster                              ;
;--------------------------------------------------------------;
;                                                              ;
;       in:  cx  = fat entry/cluster number                    ;
;                                                              ;
;       out: edi = pointer to cluster or zero if none          ;
;--------------------------------------------------------------;
get_cluster:
        ;...
        ret