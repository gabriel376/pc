#!/bin/bash

read -e -p "disk: " -i "/dev/sda" disk
read -e -p "boot: " -i "BIOS" boot
read -e -p "swap: " -i "4000" swap
read -e -p "country: " -i "BR" country
read -e -p "username: " -i "gabriel" username
read -e -p "timezone: " -i "America/Sao_Paulo" timezone
read -e -p "locale: " -i "en_US.UTF-8" locale
read -e -p "hostname: " -i "archlinux" hostname

timedatectl set-ntp true

wget -O /etc/pacman.d/mirrorlist https://www.archlinux.org/mirrorlist/?country=${country}
sed -i 's/^#\(Server\)/\1/' /etc/pacman.d/mirrorlist

if [[ ${boot} == "BIOS" ]]; then
    parted -s -a optimal -- ${disk}                       \
           unit mib                                       \
           mklabel msdos                                  \
           mkpart primary linux-swap 1 $(( 1 + ${swap} )) \
           mkpart primary ext4 $(( 1 + ${swap} )) -1
    mkswap ${disk}1
    swapon ${disk}1
    yes | mkfs.ext4 ${disk}2
    mount ${disk}2 /mnt
    pacstrap /mnt base linux linux-firmware dhcpcd sudo grub

else
    parted -s -a optimal -- ${disk}                           \
           unit mib                                           \
           mklabel gpt                                        \
           mkpart primary fat32 1 513 set 1 esp on            \
           mkpart primary linux-swap 513 $(( 513 + ${swap} )) \
           mkpart primary ext4 $(( 513 + ${swap} )) -1
    yes | mkfs.fat -F32 ${disk}1
    mkswap ${disk}2
    swapon ${disk}2
    yes | mkfs.ext4 ${disk}3
    mount ${disk}3 /mnt
    mkdir -p /mnt/boot/efi
    mount ${disk}1 /mnt/boot/efi
    pacstrap /mnt base linux linux-firmware dhcpcd sudo grub efibootmgr
fi

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt <<EOF
ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime
hwclock --systohc

sed -i "s/^#\(${locale}\)/\1/" /etc/locale.gen
locale-gen

tee /etc/locale.conf <<EOF2
LANG=${locale}
EOF2

tee /etc/hostname <<EOF2
${hostname}
EOF2

tee /etc/hosts <<EOF2
127.0.0.1    localhost
::1          localhost
127.0.1.1    ${hostname}.localdomain    ${hostname}
EOF2

systemctl enable dhcpcd.service

useradd -m -G wheel ${username}
sed -i 's/^# \(%wheel ALL=(ALL) ALL\)/\1/' /etc/sudoers
echo "root:root" | chpasswd
echo "${username}:${username}" | chpasswd

[[ ${boot} == "BIOS" ]]                     \
   && grub-install --target=i386-pc ${disk} \
   || grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=${hostname}
grub-mkconfig -o /boot/grub/grub.cfg
EOF
