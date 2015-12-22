;----------------------------------------------------------;
; BOS 0.04                       Christoffer Bubach, 2004. ;
;----------------------------------------------------------;
;   Keymap.                                                ;
; Only USA-type are supported so far. (poor едц...)        ;
;                                                          ;
;----------------------------------------------------------;

keymap:
    db    0
    db    '1234567890-=', bspace
    db    tab,'qwertyuiop[]',enter_key
    db    ctrl_key,'asdfghjkl;',39,'`',lshift
    db    '\','zxcvbnm,./',rshift,prnscr,alt_key,' '
    db    caps,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,numlock
    db    scroll,home,arrowup,pgup,num_sub,arrowleft,center5,arrowright
    db    num_plus,_end,arrowdown,pgdn,_ins,del

keymap_caps:
    db    0
    db    '1234567890-=', bspace
    db    tab,'QWERTYUIOP[]',enter_key
    db    ctrl_key,'ASDFGHJKL;',39,'`',lshift
    db    '\','ZXCVBNM,./',rshift,prnscr,alt_key,' '
    db    caps,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,numlock
    db    scroll,home,arrowup,pgup,num_sub,arrowleft,center5,arrowright
    db    num_plus,_end,arrowdown,pgdn,_ins,del

keymap_caps_shift:
    db    0
    db    '!@#$%^&*()_+', bspace
    db    tab,'qwertyuiop{}',enter_key
    db    ctrl_key,'asdfghjkl:"~',lshift
    db    '|zxcvbnm<>?',rshift,prnscr,alt_key,' '
    db    caps,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,numlock
    db    scroll,home,arrowup,pgup,num_sub,arrowleft,center5,arrowright
    db    num_plus,_end,arrowdown,pgdn,_ins,del

keymap_shift:
    db    0
    db    '!@#$%^&*()_+', bspace
    db    tab,'QWERTYUIOP{}',enter_key
    db    ctrl_key,'ASDFGHJKL:"~',lshift
    db    '|ZXCVBNM<>?',rshift,prnscr,alt_key,' '
    db    caps,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,numlock
    db    scroll,home,arrowup,pgup,num_sub,arrowleft,center5,arrowright
    db    num_plus,_end,arrowdown,pgdn,_ins,del


enter_key   =    0
bspace      =    0
tab         =    0
ctrl_key    =    0
lshift      =    0
rshift      =    0
prnscr      =    0
alt_key     =    0
caps        =    0
f1          =    0
f2          =    0
f3          =    0
f4          =    0
f5          =    0
f6          =    0
f7          =    0
f8          =    0
f9          =    0
f10         =    0
f11         =    0
f12         =    0
numlock     =    0
scroll      =    0
home        =    0
arrowup     =    0
pgup        =    0
num_sub     =    0
arrowleft   =    0
center5     =    0
arrowright  =    0
num_plus    =    0
_end        =    0
arrowdown   =    0
pgdn        =    0
_ins        =    0
del         =    0