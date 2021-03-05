#!/bin/sh

install_network_packages() {
    for package in $(cat network.pacman); 
    do
        echo "installing \"$package\"..."
        install_pacman_package $package
        if [ $? -eq 0 ]; then
            echo "installed \"$package\""
        else
            echo "failed to install \"$package\""
        fi
    done
    ln -s /etc/runit/sv/connmand /etc/runit/runsvdir/current/
}

install_pacman_package() {
    pacman -S --noconfirm --needed $1 > /dev/null 2>&1
}

system_clock() {
    get_input "Enter your region"
    region=$returnvalue
    get_input "Enter your city"
    city=$returnvalue
    [ ! -d /usr/share/zoneinfo/$region ] && echo "Non-existing region" && exit 1
    [ ! -f /usr/share/zoneinfo/$region/$city ] && echo "Non-existing city" && exit 1
    ln -s /usr/share/zoneinfo/$region/$city /etc/localtime
    hwclock --systohc
}

localisation() {
    get_input "Enter your locale"
    locale=$returnvalue
    [[ $(grep $locale /etc/locale.gen) == "" ]] && echo "Non-existing locale" && exit 1
    grep $locale /etc/locale.gen | sed 's/#//g' >> /etc/locale.gen
    echo "LANG=$locale.UTF-8" >> /etc/locale.conf
    locale-gen
}

boot_loader() {
    pacman -S --needed --noconfirm grub efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg
}

make_user() {
    get_input "Enter your username"
    username=$returnvalue
    get_input "Enter your password"
    password=$returnvalue
    export HOME=/home/$username
    useradd -m $username
    echo "$username ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    echo -e "$password\n$password" | passwd $username
    echo -e "$password\n$password" | passwd
}

network_config() {
    get_input "Enter your hostname" 
    hostname=$returnvalue
    echo $hostname >> /etc/hostname
    echo "127.0.0.1 localhost" >> /etc/hosts
    echo "::1 localhost" >> /etc/hosts
    echo "127.0.0.1 $hostname.localdomain $hostname" >> /etc/hosts
}

get_input() {
    echo "$1: "
    read
    returnvalue=${REPLY}
}

system_clock
localisation
boot_loader
make_user
install_network_packages
network_config
