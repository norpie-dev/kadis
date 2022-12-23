#!/bin/sh

echo $@
exit

package_update() {
    pacman -Syu --noconfirm
}

time_zone() {
    ln -sf /usr/share/zoneinfo/"$1"/"$2" /etc/localtime
    hwclock --systohc
}

localization() {
    echo "$3.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
    echo "LANG=$3.UTF-8" >> /etc/locale.conf
}

network_configuration() {
    echo "$4" >> /etc/hostname

    echo "127.0.0.1 localhost" >> /etc/hosts
    echo "::1 localhost" >> /etc/hosts
    echo "127.0.1.1 $4.localdomain $4" >> /etc/hosts

    pacman -S networkmanager --noconfirm
    systemctl enable NetworkManager
}

boot_loader() {
    pacman -S grub efibootmgr os-prober --noconfirm
    echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
    mkdir /boot/grub
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
    grub-mkconfig -o /boot/grub/grub.cfg
}

microcode_updates() {
    microcode=$(cat /proc/cpuinfo | grep "model name" | uniq | awk '{print tolower($4)}')
    if [[ $microcode == "amd" || $microcode == "intel" ]]; then
        pacman -S "$microcode-ucode" --noconfirm
    fi
}

default_packages() {
    pacman -S --noconfirm zsh git openssh
    systemctl enable sshd
}

user_setup() {
    useradd $5
    echo "$5 ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    echo -e "$6\n$6" | passwd $5
    echo -e "$6\n$6" | passwd
    echo -e "/bin/zsh" | chsh $5
    echo -e "/bin/zsh" | chsh
    mkdir -p /home
}

setup_dots() {
    cd /home
    git clone https://github.com/norpie-dev/dots
    mv dots $5
    cd $5
    mv ".git" ".dots"
    cd ..
    chown $5:$5 $5 -R
}

package_update &&
time_zone &&
localization &&
network_configuration &&
boot_loader &&
microcode_updates &&
default_packages &&
user_setup &&
#setup_dots &&
exit
