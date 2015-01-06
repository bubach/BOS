;----------------------------------------------------------;
; BOS 0.04                       Christoffer Bubach, 2005. ;
;----------------------------------------------------------;
;                                                          ;
;      Realmode functions to set a20-gate.                 ;
;                                                          ;
;----------------------------------------------------------;

;----------------------;
;   enable a20 gate    ;
;----------------------;
enable_a20:
	  in	  al, 0x64			      ; first try..
	  test	  al, 2
	  jnz	  enable_a20
	  mov	  al, 0xD1
	  out	  0x64, al
     .d6:
	  in	  al, 0x64
	  and	  ax, 2
	  jnz	  .d6
	  mov	  al, 0xDF
	  out	  0x60, al

	  call	  a20_test
	  jz	  .ok

	  in	  al, 0x92			      ; try again, diffrent method.
	  or	  al, 0x02
	  out	  0x92, al

	  call	  a20_test
	  jz	  .ok

	  ;    ERROR!
	  ; a20-gate not set! Do something about it here... ;)

     .ok:
	  ret

;------------------------;
;  test if A20 is set    ;
;------------------------;
a20_test:
	  mov	  al, byte [fs:0]
	  mov	  ah, al
	  not	  al
	  xchg	  al, byte [gs:0x10]
	  cmp	  ah, byte [fs:0]
	  mov	  [gs:0x10], al
	  ret