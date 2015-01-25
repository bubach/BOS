;-------------------------------------------------------;
;                      BOS kernel                       ;
;-------------------------------------------------------;
;    BOS 32-bit kernel, expects to be loaded at 32kb    ;
;    in mem.   Small amount of 16-bit code included.    ;
;                                                       ;
;    Homepage:   http://bos.asmhackers.net/             ;
;    Repository: http://github.com/bubach/BOS           ;
;                                                       ;
;         by: Christoffer Bubach, 2003-2015             ;
;-------------------------------------------------------;
use16
org 0x8000

;---------------------------;
;  jump to starting point   ;
;---------------------------;
        jmp    start

;----------------------------------------;
;     16-bit include files               ;
;----------------------------------------;
    include  '16bit/a20.asm'                          ; Function to set the a20-gate.
    include  '16bit/gdt.asm'                          ; Global Description Table.
    include  '16bit/idt.asm'                          ; The Interrupt Description Table.
    include  '16bit/mem.asm'                          ; Get memory size.
    include  '16bit/variables.asm'                    ; For/from realmode.
    include  '16bit/init16bit.asm'                    ; Save "go back to 16-bit"-info.



;--------------------------;
;   16-bit entry point     ;
;--------------------------;
start:
        cli
        mov    ax, cs
        mov    ds, ax
                                                      ; fasm is more strict about
        xor    eax, eax                               ; "org 0x10000" then nasm, so
        mov    es, ax                                 ; i have to do -0x10000 from
        mov    fs, ax                                 ; all variable addresses while
        mov    gs, ax                                 ; in realmode.
        sti

        call   enable_a20
        call   init16bit                              ; ...  :P

        cli
        mov    ax, cs                                 ; save cs
        mov    [realmode_cs], ax                      ; in variables.inc

        lgdt   [gdtr]                                 ; Load the GDT descriptor
        lidt   [idtr]                                 ; Load the IDT descriptor

        mov    eax, cr0
        or     al, 1
        mov    cr0, eax

        jmp    pword 0x08:flush                       ; dword in nasm



;--------------------------;
;   32-bit entry point     ;
;--------------------------;
use32
flush:
        mov     ax, 0x10                              ; refresh all segment registers
        mov     ds, ax
        mov     es, ax
        mov     fs, ax
        mov     gs, ax
        mov     ss, ax
        mov     esp, 0xFFFC

        call    bos_init                              ; fix everything

        mov     bx, 0x04B1                            ; start the shell
        call    setcursor
        mov     esi, bos_shell
        mov     bl, 0x07
        call    print
        call    init_cmd
        jmp     shell

        ;int     0x32

    .hang:
        cli
        hlt
        jmp     .hang                                 ; hang, just in case..


;----------------------------------------;
;     32-bit include files               ;
;----------------------------------------;
    include  'int/idt.asm'                            ; The Interrupt Description Table.
    include  'vga/text.asm'                           ; The default textmode functions.
    include  'init/init32b.asm'                       ; Function that starts up BOS
    include  'vars/strings.asm'                       ; All strings in english (soon).
    include  'init/bios.asm'                          ; Get back to realmode and do an INT.
    include  'init/pic.asm'                           ; PIC rutines.
    include  'system/services.asm'                    ; System service handler (int 0x32).
    include  'kbd/keyboard.asm'                       ; Keyboard ISR.
    include  'kbd/keymap.asm'                         ; Keymap(s).
    include  'shell/shell.asm'                        ; File with shell/kernel monitor functions.
    include  'shell/commands.asm'                     ; Command table, for valid shell commands.
    include  'int/isr.asm'                            ; Interrupt Service Rutines.
    include  'int/debug.asm'                          ; Print contents of all regs and hang.
    include  'init/cmos.asm'                          ; To get CMOS data.
    include  'shell/clock.asm'                        ; Print time and date.
    include  'init/timer.asm'                         ; Timer IRQ.
    include  'vga/vga.asm'                            ; VGA functions.
;    include  'vga/font8x16.asm'                       ; Standard font.
    include  'fdc/dma.asm'                            ; DMA code.
    include  'fdc/fdc.asm'                            ; Floppy code.
    include  'vga/mario.asm'                          ; Mario sprite.
    include  'sound/speaker.asm'                      ; PC speaker.
    include  'ram/mem.asm'                            ; Memory allocation and freeing.
    include  'vfs/parse.asm'                          ; Path parser for VFS functions.