#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

IGNORE_INSTALL=0

# check that os is archlinux and exits otherwise
is_archlinux_or_exit() {
    if [ -f "/etc/arch-release" ]; then
        return 0
    else
        exit 1
    fi
}

is_ubuntu_or_exit() {
    cat /etc/lsb-release | grep -q "Ubuntu"
}

guix_install_packages() {
    local packages=''
    packages+='i3-gaps feh maim scrot dunst dmenu i3lock alacritty xdg-utils rofi'
    packages+=' git curl tmux ledger rsync'
    packages+=' python neovim python-pynvim'
    packages+=' font-iosevka'
    packages+=' nss-certs'
    packages+=' fontconfig gcc-toolchain setxkbmap'
    packages+=' bind:utils'
    guix install $packages
}

ubuntu_install_packages() {
    is_ubuntu_or_exit
    echo "found ubuntu"
    apt update
    apt install --yes software-properties-common ca-certificates curl

    # ref: https://i3wm.org/docs/repositories.html
    echo "Adding i3 ppa repo"
    /usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2024.03.04_all.deb keyring.deb SHA256:f9bb4340b5ce0ded29b7e014ee9ce788006e9bbfe31e96c09b2118ab91fca734
    apt install ./keyring.deb
    echo "deb https://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list

    # neovim ubuntu update: https://github.com/neovim/neovim/blob/master/INSTALL.md#ubuntu
    add-apt-repository --yes ppa:neovim-ppa/unstable

    local packages=''
    packages+='i3 feh maim scrot dunst dmenu xautolock alacritty rofi'
    packages+=' git curl tmux ledger rsync'
    packages+=' python3-dev python3-pip neovim python3-pynvim'
    packages+=' fontconfig'
    apt update && apt install --yes $packages

    # install iosevka font
    curl -L "https://github.com/be5invis/Iosevka/releases/download/v29.2.0/PkgTTC-Iosevka-29.2.0.zip" > /tmp/iosevka.zip
    unzip /tmp/iosevka.zip -d ~/.font/

    # install iosevka nerd font
    curl -L "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Iosevka.zip" > /tmp/iosevka.zip
    unzip /tmp/iosevka -d $HOME/.local/share/fonts/

    # install rust and alacritty. Ref: https://github.com/alacritty/alacritty/blob/master/INSTALL.md#building
    apt install git
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    git clone --depth 1 https://github.com/alacritty/alacritty.git /tmp/alacritty
    cd /tmp/alacritty
    apt install --yes cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
    source ~/.cargo/env
    cargo build --release
    cp target/release/alacritty /usr/bin/alacritty
    tic -xe alacritty,alacritty-direct extra/alacritty.info
}

# installs packages using pacman required for dotfiles to work well
install_archlinux_packages() {
    is_archlinux_or_exit
    local packages=''
    # window manager packages
    # i3 group contains i3-wm, i3blocks, i3lock, i3status
    # deleted xautolock, change i3 to use i3lock
    # dunst -> notifications
    # TODO: find alternative to xautolock
    packages+='xorg-xinit i3 feh maim scrot dunst dmenu rofi alacritty xfce4 brightnessctl'
    packages+=' nvim git curl tmux xdg-user-dirs ledger rsync openssh stow'

    # fonts
    # TODO: install with yay: fontpreview-ueberzug-git terminus-font-ttf
    packages+=' noto-fonts-emoji ttf-fira-code ttf-fira-mono ttf-jetbrains-mono ttf-ubuntu-font-family adobe-source-code-pro-fonts ttc-iosevka'
    packages+=' ttf-iosevka-nerd'

    sudo pacman -Sy --noconfirm $packages
}

# if a file is a symlink, replace this will new file
# if it is an actual file, move this to path.old
# symlink path with file in dotfiles
# Arguments:
#   sym_filepath: the location of symlink
#   localpath: file in dotfiles folder to replace
replace_symlinks_or_move_files_to_old(){
    if [ -L "$1" ]; then
        echo "${1} is a symlink, replacing the link to ${2}"
    elif [ -f "$1" ]; then
        echo "Moving ${1} to ${1}.old"
        mv "${1}" "${1}.old"
    fi
    echo "Symlinking ${1} to ${2}"
    ln --force --symbolic "${2}" "${1}"
}

config_setup() {
    # FIXME: find better way to do install on-my-zsh
    # sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    stow --dotfiles X11 xdg-user-dirs tmux zsh bash
    stow --dotfiles i3 i3status dunst alacritty ledger nvim
    # set up wallpaper and lockscreen images
    local i3_wallpaper="${HOME}/images/i3_wallpaper.png"
    if [ ! -f "$i3_wallpaper" ]; then
        curl --fail --location --output "$i3_wallpaper" --create-dirs https://raw.githubusercontent.com/dracula/wallpaper/master/first-collection/linux.png
    fi
    local i3_lock="${HOME}/images/i3_lock.png"
    if [ ! -f "$i3_lock" ]; then
        curl --fail --location --output "$i3_lock" --create-dirs https://raw.githubusercontent.com/dracula/wallpaper/master/first-collection/arch.png
    fi

    # tpm setup and tpm plugins
    # mkdir -p ${HOME}/.tmux/plugins/
    # git_clone_with_failure_message https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
    # sh -c "${HOME}/.tmux/plugins/tpm/bin/install_plugins"
}

other_applications_setup(){
    # set up location for custom scripts
    mkdir -p "$HOME/.local/bin"
    local local_bin="$HOME/.local/bin"
    # set up projects folder
    mkdir -p "$HOME/projects"

    # clone personal vimwiki
    git_clone_with_failure_message ssh://rookie@jnduli.co.ke:/home/rookie/git/vimwiki.git "$HOME/vimwiki"
    # pass
    git_clone_with_failure_message ssh://rookie@jnduli.co.ke:/home/rookie/git/password-store.git "$HOME/.password-store"

    # clone blog site
    git_clone_with_failure_message https://github.com/jnduli/blog_jnduli.co.ke.git "$HOME/projects/blog"

    # pomodoro repo and setup
    git_clone_with_failure_message https://github.com/jnduli/pomodoro.git "$HOME/projects/pomodoro"
    replace_symlinks_or_move_files_to_old "$local_bin/pomodoro" "$HOME/projects/pomodoro/pomodoro.sh"

    # set up gruvbox hard theme for xfce4 terminal
    mkdir -p "$HOME/.local/share/xfce4/terminal/colorschemes"
    replace_symlinks_or_move_files_to_old "$HOME/.local/share/xfce4/terminal/colorschemes/gruvbox-dark-hard.theme" "$DOTFILES_DIR/apps/xfce4_terminal_gruvbox-dark-hard.theme"

}

custom_scripts_setup() {
    local local_bin="$HOME/.local/bin"
    mkdir -p "$local_bin"
    stow --dotfiles scripts
}

git_clone_with_failure_message() {
    local giturl="$1"
    local folder="$2"
    if [ -d "$folder" ]; then
        echo "Cannot clone ${giturl} because folder ${folder} exists"
    fi
    git clone "$giturl" "$folder"
}


show_help() {
    cat <<EOF
Copyright (C) 2024: John Nduli K.                                                                                                      
install.sh
 Installs packages and configuration for various programs.
 Clones common repostories I use.
 Installs custom scripts to $HOME/.local/bin

 -h: Show help file
 -i <os_name>: install packages for os. os_name can be ubuntu, arch or guix.
 -s : Other set up instructions
EOF
}

manual_instructions() {
    cat <<EOF
Run the following to have a good time
    1. install yay
    2. yay -S xautolock 
    3. install oh-my-zsh
EOF
}

options () {
    while getopts "hi:sg" OPTION; do
        case $OPTION in
            h)
                show_help
                exit 1
                ;;
            i)
                os=${OPTARG}
                if [[ $os == "ubuntu" ]]; then
                    ubuntu_install_packages
                elif [[ $os == "arch" ]]; then
                    install_archlinux_packages
                    manual_instructions
                elif [[ $os == "guix" ]]; then
                    guix_install_packages
                else
                    echo "Invalid OS ${os} provided"
                    exit 1
                fi
                exit
                ;;
            s)
                config_setup
                other_applications_setup
                custom_scripts_setup
                manual_instructions
                exit
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
    done
}


options "$@"
