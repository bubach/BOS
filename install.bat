@echo off
echo Put an empty floppy in drive a: and
pause
echo.
cd kernel
..\utils\fasm kernel.asm kernel.sys
cd ..\boot
..\utils\fasm BOS_boot.asm BOS_boot.bin
cd..
.\utils\partcopy .\boot\BOS_boot.bin 0 200 -f0
copy .\kernel\kernel.sys a:
echo.
echo Complete. Thank you for using my crappy
echo installer.. (and for testing BOS 0.04)
echo.
pause