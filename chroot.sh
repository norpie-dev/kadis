#!/bin/sh

region=
city=
locale=
hostname=
microcode_updates=
microcode=
username=
password=

package_update() {
    pacman -Syu --noconfirm
}

time_zone() {
    ln -sf /usr/share/zoneinfo/"$region"/"$city" /etc/localtime
    hwclock --systohc
}

localization() {
    echo "$locale.UTF-8" >> /etc/locale.gen
    locale-gen
    echo "LANG=$locale.UTF-8" >> /etc/locale.conf
}

network_configuration() {
    echo "$hostname" >> /etc/hostname

    echo "127.0.0.1 localhost" >> /etc/hosts
    echo "::1 localhost" >> /etc/hosts
    echo "127.0.1.1 $hostname.localdomain $hostname" >> /etc/hosts

    pacman -S networkmanager --noconfirm
    systemctl enable NetworkManager
}

boot_loader() {
    pacman -S grub efibootmgr os-prober --noconfirm
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
    grub-mkconfig -o /boot/grub/grub.cfg
}

microcode_updates() {
    if [[ $has_microcode_updates ]]; then
        pacman -S "$microcode-ucode"
    fi
}

user_setup() {
    mkdir -p /home/konsta
    useradd -m $username
    echo "$username ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    echo -e "$password\n$password" | passwd $username
    echo -e "$password\n$password" | passwd
}
