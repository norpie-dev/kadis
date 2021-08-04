#!/bin/sh

get_input() {
    echo "$1"
    read
    returnvalue=${REPLY}
}

get_input "Enter your region:"
region=$returnvalue
get_input "Enter your city:"
city=$returnvalue
get_input "Enter your locale:"
locale=$returnvalue
get_input "Enter your hostname:"
hostname=$returnvalue
microcode=$(cat /proc/cpuinfo | grep "model name" | uniq | awk '{print tolower($4)}')
get_input "Enter your username:"
username=$returnvalue
get_input "Enter your password:"
password=$returnvalue

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
    if [[ $microcode == "amd" || $microcode == "intel" ]]; then
        pacman -S "$microcode-ucode"
    fi
}

user_setup() {
    mkdir -p /home/$username
    useradd -m $username
    echo "$username ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    echo -e "$password\n$password" | passwd $username
    echo -e "$password\n$password" | passwd
}

package_update
time_zone
localization
network_configuration
boot_loader
microcode_updates
user_setup
