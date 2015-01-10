#! /bin/sh

# BOS MacOS X Installer version 0.2
# You must be root to run this script because of the floppy/loopback device

echo
echo " BOS - MacOS X installer"
echo "-------------------------"
echo "Requires: Homebrew mtools"
echo

if [ `id -u` != "0" ]; then
    echo "You must be root to use this installer!"
    echo
fi

if [ -z "$1" ]; then
    echo "Usage is:"
    echo "$0 image  - Creates a floppy image called bos.img"
    echo "$0 floppy - Install BOS into a floppy ( must be inserted )"
    echo
    echo "Note: this installer will create a bootable image/floppy."
    echo "Floppy creation is not tested ( I don't have a floppy reader ) and it should be already formatted"
    exit
fi

echo "Compiling BOS..."
../utils/osxfasm ../kernel/kernel.asm ../kernel/kernel.sys
../utils/osxfasm ../boot/BOS_boot.asm ../boot/BOS_boot.bin

if [ "$1" = "floppy" ]; then
    echo "Starting floppy installation..."

    #Install BOS_boot.bin as bootsector into bos.img
    dd if=../boot/BOS_boot.bin of=/dev/fd0 bs=1 count=512
    mount /mnt/floppy

    #Insert kernel.sys into image
    cp ../kernel/kernel.sys /mnt/floppy

    #Umount & cleanup
    umount /mnt/floppy

    echo "BOS installed."

else
    echo "Starting image creation..."

    #Create image
    rm -rf ../bos.img
    mformat -C -f 1440 -v BOS -i ../bos.img ::

    #Erhm, it isn't pretty....
    DISKNAME=`hdiutil attach -nomount ../bos.img`
    diskutil mount $DISKNAME
    MOUNTNAME=`diskutil info $DISKNAME | grep 'Mount Point' | cut -d : -f 2 | sed 's/^ *//g' | sed 's/ *$//g';`

    #Mounted, copy kernel.sys
    cp ../kernel/kernel.sys $MOUNTNAME

    #Install BOS_boot.bin as bootsector into bos.img
    umount $DISKNAME
    dd if=../boot/BOS_boot.bin of=$DISKNAME bs=1 count=512

    #Detach
    hdiutil detach $DISKNAME
    chmod 0777 ../bos.img

    echo "BOS image created!"
fi