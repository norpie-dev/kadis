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
    echo "$locale.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
    echo "LANG=$locale.UTF-8" >> /etc/locale.conf
}

network_configuration() {
    echo "$hostname" >> /etc/hostname

    echo "127.0.0.1 localhost" >> /etc/hosts
    echo "::1 localhost" >> /etc/hosts
    echo "127.0.1.1 $hostname.localdomain $hostname" >> /etc/hosts

    pacman -S networkmanager --noconfirm
    systemctl enable --now NetworkManager
}

boot_loader() {
    pacman -S grub efibootmgr os-prober --noconfirm
    echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
    grub-mkconfig -o /boot/grub/grub.cfg
}

microcode_updates() {
    if [[ $microcode == "amd" || $microcode == "intel" ]]; then
        pacman -S "$microcode-ucode" --noconfirm
    fi
}

default_packages() {
    pacman -S --noconfirm zsh git openssh
    systemctl enable --now sshd
}

user_setup() {
    useradd $username
    echo "$username ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    echo -e "$password\n$password" | passwd $username
    echo -e "$password\n$password" | passwd
    echo -e "/bin/zsh" | chsh $username
    echo -e "/bin/zsh" | chsh
    mkdir -p /home
}

setup_dots() {
    cd /home
    git clone https://github.com/norpie-dev/dots
    mv dots $username
    cd $username
    mv ".git" ".dots"
    cd ..
    chown $username:$username $username -R
}

package_update &&
time_zone &&
localization &&
network_configuration &&
boot_loader &&
microcode_updates &&
default_packages &&
user_setup &&
setup_dots &&
exit
