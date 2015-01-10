#! /bin/sh

# BOS Linux Installer version 0.2
# You must be root to run this script because of the floppy/loopback device

echo
echo -e "\E[33;1mBOS\E[0m - \E[32;1mLinux installer\E[0m"
echo

if [ `id -u` != "0" ]; then
    echo -e "\E[31;1mYou must be root to use this installer!\E[0m"
    echo
fi

if [ -z "$1" ]; then
    echo "Usage is:"
    echo -e "\E[31m$0 image\E[0m  - Creates a floppy image called bos.img"
    echo -e "\E[31m$0 floppy\E[0m - Install BOS into a floppy ( must be inserted )"
    echo
    echo "Note: this installer will create a bootable image/floppy."
    echo "Floppy creation is not tested ( I don't have a floppy reader ) and it should be already formatted"
    exit
fi

echo -e "\E[32mCompiling BOS...\E[0m"
../utils/fasm ../kernel/kernel.asm ../kernel/kernel.sys
../utils/fasm ../boot/BOS_boot.asm ../boot/BOS_boot.bin

if [ "$1" = "floppy" ]; then
    echo -e "\E[32mStarting floppy installation...\E[0m"

    #Install BOS_boot.bin as bootsector into bos.img
    dd if=boot/BOS_boot.bin of=/dev/fd0 bs=1 count=512
    mount /mnt/floppy

    #Insert kernel.sys into image
    cp ../kernel/kernel.sys /mnt/floppy

    #Umount & cleanup
    umount /mnt/floppy

    echo -e "\E[33mBOS installed.\E[0m"

else
    echo -e "\E[32mStarting image creation...\E[0m"

    #Create empty image
    if [ -e ../bos.img ]; then
        rm -f ../bos.img
    fi
    dd if=/dev/zero of=bos.img bs=1k count=1440

    #Format image in MSDOS format and mount it
    mkdosfs ../bos.img
    losetup /dev/loop3 ../bos.img

    #Install BOS_boot.bin as bootsector into bos.img
    dd if=../boot/BOS_boot.bin of=/dev/loop3 bs=1 count=512
    if [ ! -e tmpmnt ]; then
        mkdir tmpmnt
    fi
    mount -tmsdos /dev/loop3 tmpmnt

    #Insert kernel.sys into image
    cp ../kernel/kernel.sys tmpmnt

    #Umount & cleanup
    umount /dev/loop3
    if [ -e tmpmnt ]; then
        rm -rf tmpmnt
    fi
    losetup -d /dev/loop3

    echo -e "\E[33mBOS image created! ( better do a chown on it now ;) )\E[0m"
fi