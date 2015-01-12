;----------------------------------------------------------;
; BOS kernel                Christoffer Bubach, 2012-2015. ;
;----------------------------------------------------------;
;                                                          ;
;    FAT12 driver.                                         ;
;                                                          ;
;----------------------------------------------------------;
      struc disk
      {
          .disk_number         db  0                  ; which disk?
          .root_dir            dw  0                  ; position of rootdir
          .fat_1               dd  0                  ; position of fat1
          .fat_2               dd  0                  ; position of fat2
          .data_area           dw  0                  ; position of dataarea
          .disk_size           dd  0
          .free_space          dd  0
          .boot                bootsector  
          ; ..... some other values
      }
      struc bootsector                                ; 512 bytes
      {
          .jumper              db  0,0,0
          .oem                 db  0,0,0,0,0,0,0,0
          .sectorsize          dw  0
          .sect_per_clust      db  0  
          ;.... more values here
      }

      virtual at 0
          bootsector bootsector
          sizeof.bootsector = $
      end virtual

      virtual at 0
          disk disk 
          sizeof.disk = $     
      end virtual


fd0 disk            ; define fd0 data..  

;drv dd 0
;mov edi, drv+disk.boot

     ;-----------------------------; 
     ;   calculate root location   ; 
     ;-----------------------------; 
          xor     eax, eax 
          mov     al, byte [fd0.boot.fats_per_drive] 
          mul     word [fd0.boot.sectors_per_fat] 
          add     ax, word [fd0.boot.reserved_sect] 
          mov     [fd0.root_dir], ax  

;mov  si, [dsk] 
;mov  ax, [si+disk.boot.sectorssize] 


init_fat12:
        push   eax
        ; a bit more code here 
        pop    eax
        ret