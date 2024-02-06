#!/bin/sh
DOTS_GIT_REPO="https://github.com/norpie/dots"
PACKAGES_FILE="/pkgs.list"
HOME=$(find /home -maxdepth 1 -mindepth 1 -type d | awk 'NR == 1')
USERNAME=$(basename $HOME)

install_aur_package() {
    cat $PACKAGES_FILE | xargs sudo -U $USERNAME yay -S --noconfirm --needed
}

change_shell() {
    sudo chsh -s /usr/bin/zsh
    sudo chsh -s /usr/bin/zsh $USERNAME
}

install_dots() {
    cd $HOME
    git clone --bare "$DOTS_GIT_REPO" "$HOME/.dots"
    git --git-dir=$HOME/.dots --work-tree=$HOME checkout
}

install_yay() {
    mkdir -p "$HOME/Downloads"
    cd "$HOME/Downloads"
    YAY_REPO="https://aur.archlinux.org/yay.git"
    git clone $YAY_REPO
    cd yay
    change_perms
    sudo -u $USERNAME makepkg -si --noconfirm
    cd ..
    rm yay -rf
    cd /
}

change_perms() {
    chown $USERNAME:$USERNAME /home/$USERNAME -R
}

complete_install() {
    pacman -Syu --noconfirm
    pacman -S --noconfirm git
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    change_shell
    install_dots
    install_yay
    install_aur_packages
    change_perms
}

complete_install
