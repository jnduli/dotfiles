#!/bin/bash

set -euo pipefail

# TODO:
# - [ ] have replace_symlinks_or_move_files_to_old() also create missing dirs

# dotfiles folder
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
    packages+='i3-gaps feh maim scrot dunst dmenu xautolock alacritty'
    packages+=' git curl tmux ledger rsync'
    packages+=' python neovim python-pynvim'
    packages+=' font-iosevka'
    packages+=' nss-certs'
    packages+=' fontconfig gcc-toolchain setxkbmap'
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
    packages+='i3 feh maim scrot dunst dmenu xautolock alacritty'
    packages+=' git curl tmux ledger rsync'
    packages+=' python3-dev python3-pip neovim python3-pynvim'
    packages+=' fontconfig'
    apt update && apt install --yes $packages

    # install iosevka font
    curl -L "https://github.com/be5invis/Iosevka/releases/download/v29.2.0/PkgTTC-Iosevka-29.2.0.zip" > /tmp/iosevka.zip
    unzip /tmp/iosevka.zip -d ~/.font/

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
install_archlinux_ackages() {
    is_archlinux_or_exit
    local packages=''
    # window manager packages
    # i3 group contains i3-wm, i3blocks, i3lock, i3status
    # dunst -> notifications
    packages+='i3 feh maim scrot dunst dmenu xautolock alacritty'

    # I'm still dependent on xfce4 for somethings so I install the group
    packages+=' xfce4'

    packages+=' gvim git curl tmux xdg-user-dirs ledger rsync ranger'

    # fonts
    # TODO: install with yay: fontpreview-ueberzug-git terminus-font-ttf
    packages+=' noto-fonts-emoji ttf-fira-code ttf-fira-mono ttf-jetbrains-mono ttf-ubuntu-font-family adobe-source-code-pro-fonts ttc-iosevka'

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

# Sets up vim and vim and all plugins in use
vim_setup(){
    # set up .vimrc and init.vim
    replace_symlinks_or_move_files_to_old "$HOME/.vimrc" "${DOTFILES_DIR}/editors/vimrc"
    local vimrc_path="$HOME/.vimrc"
    local dotfile_vimrc="${DOTFILES_DIR}/editors/vimrc"
    replace_symlinks_or_move_files_to_old "$vimrc_path" "$dotfile_vimrc"
    local neovim_folder="$HOME/.config/nvim"
    mkdir -p "$neovim_folder"
    replace_symlinks_or_move_files_to_old "${neovim_folder}/init.vim" "${DOTFILES_DIR}/editors/nvim-init.vim"
    # set up Plug (plugin manager)
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    # install vim plugins
    nvim -c ':PlugInstall' -c 'qa!'

    # personal snippets setup
    local snippets_dest="${HOME}/.vim/mysnippets"
    mkdir -p "$snippets_dest"
    local snippets_src="${DOTFILES_DIR}/editors/vimsnippets"
    for dotfile in "${snippets_src}"/*
    do
        local filename
        filename=$(basename "$dotfile")
        local dest_file="${snippets_dest}/${filename}"
        replace_symlinks_or_move_files_to_old "$dest_file" "$dotfile" 
    done
}


# sets up i3 and i3 status configs and wallpaper/lock images
i3_setup() {
    # set up i3wm configs
    local i3wm_folder="${HOME}/.config/i3"
    local i3status_folder="${HOME}/.config/i3status"
    mkdir -p "$i3wm_folder"
    mkdir -p "$i3status_folder"

    local i3wm_config="${i3wm_folder}/config"
    local dotfiles_i3wm="${DOTFILES_DIR}/i3/i3wm_config"
    replace_symlinks_or_move_files_to_old "$i3wm_config" "$dotfiles_i3wm"

    local i3status_config="${i3status_folder}/config"
    local dotfiles_i3status="${DOTFILES_DIR}/i3/i3status_config"
    replace_symlinks_or_move_files_to_old "$i3status_config" "$dotfiles_i3status"

    # set up wallpaper image
    local i3_wallpaper="${HOME}/images/i3_wallpaper.png"
    if [ ! -f "$i3_wallpaper" ]; then
        curl --fail --location --output "$i3_wallpaper" --create-dirs https://raw.githubusercontent.com/dracula/wallpaper/master/arch.png
    fi

    # set up lock screen image
    local i3_lock="${HOME}/images/i3_lock.png"
    if [ ! -f "$i3_lock" ]; then
        curl --fail --location --output "$i3_lock" --create-dirs https://raw.githubusercontent.com/dracula/wallpaper/master/arch.png
    fi
}

# sets up i3 and i3 status configs and wallpaper/lock images
sway_setup() {
    # set up sway configs
    local sway_folder="${HOME}/.config/sway"
    mkdir -p "$sway_folder"

    local dotfiles_sway="${DOTFILES_DIR}/swayconfig"
    local sway_config="${sway_folder}/config"
    replace_symlinks_or_move_files_to_old "$sway_config" "$dotfiles_sway"
}

# sets up X files to help launch i3 and xfce4
X_setup() {
    local xinitrc="${HOME}/.xinitrc"
    local dotfile_xinitrc="${DOTFILES_DIR}/X11/xinitrc"
    replace_symlinks_or_move_files_to_old "$xinitrc" "$dotfile_xinitrc"

    local xserverrc="${HOME}/.xserverrc"
    local dotfile_xserver="${DOTFILES_DIR}/X11/xserverrc"
    replace_symlinks_or_move_files_to_old "$xserverrc" "$dotfile_xserver"

    # xdg-dirs setup
    local user_dirs_conf="${HOME}/.config/user-dirs.conf"
    local dotfile_user_dirs_conf="${DOTFILES_DIR}/X11/user-dirs.conf"
    replace_symlinks_or_move_files_to_old "$user_dirs_conf" "$dotfile_user_dirs_conf"

    local user_dirs_dirs="${HOME}/.config/user-dirs.dirs"
    local dotfile_user_dirs_dirs="${DOTFILES_DIR}/X11/user-dirs.dirs"
    replace_symlinks_or_move_files_to_old "$user_dirs_dirs" "$dotfile_user_dirs_dirs"
}


# Install ohmyzsh, tpm and set up configs
shell_setup() {
    # installing oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # set up .zshrc
    replace_symlinks_or_move_files_to_old "$HOME/.zshrc" "${DOTFILES_DIR}/shells/zshrc"
    # set up bash files
    replace_symlinks_or_move_files_to_old "${HOME}/.bashrc" "${DOTFILES_DIR}/shells/.bashrc"
    replace_symlinks_or_move_files_to_old "${HOME}/.bash_profile" "${DOTFILES_DIR}/shells/.bash_profile"

    # set up tmux
    replace_symlinks_or_move_files_to_old "${HOME}/.tmux.conf" "${DOTFILES_DIR}/shells/tmux-conf"
    # tpm setup and tpm plugins
    git_clone_with_failure_message https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
    sh -c "${HOME}/.tmux/plugins/tpm/bin/install_plugins"
}

other_applications_setup(){
    # set up location for custom scripts
    mkdir -p "$HOME/.local/bin"
    local local_bin="$HOME/.local/bin"
    # set up projects folder
    mkdir -p "$HOME/projects"

    # set up .ledgerrc
    local ledgerrc="$HOME/.ledgerrc"
    local dotfile_ledgerrc="${DOTFILES_DIR}/apps/ledgerrc"
    replace_symlinks_or_move_files_to_old "$ledgerrc" "$dotfile_ledgerrc"

    # clone ledger repo
    git_clone_with_failure_message ssh://rookie@jnduli.co.ke:/home/rookie/git/ledger.git "$HOME/docs/ledger"

    # weekly entries
    git_clone_with_failure_message ssh://rookie@jnduli.co.ke:/home/rookie/git/weekly.git "$HOME/docs/weekly"
    replace_symlinks_or_move_files_to_old "$local_bin/week_entry" "$HOME/docs/weekly/week_entry.sh"

    # clone personal vimwiki
    git_clone_with_failure_message ssh://rookie@jnduli.co.ke:/home/rookie/git/vimwiki.git "$HOME/vimwiki"
    # pass
    git_clone_with_failure_message ssh://rookie@jnduli.co.ke:/home/rookie/git/password-store.git "$HOME/.password-store"

    # clone blog site
    git_clone_with_failure_message https://github.com/jnduli/blog_jnduli.co.ke.git "$HOME/projects/blog"

    # pomodoro repo and setup
    git_clone_with_failure_message https://github.com/jnduli/pomodoro.git "$HOME/projects/pomodoro"
    replace_symlinks_or_move_files_to_old "$local_bin/pomodoro" "$HOME/projects/pomodoro/pomodoro.sh"


    # tasklite
    mkdir -p "$HOME/.config/tasklite"
    replace_symlinks_or_move_files_to_old "$HOME/.config/tasklite/config.yaml" "$DOTFILES_DIR/apps/tasklite_config.yaml"

    # set up dunstrc
    mkdir -p "$HOME/.config/dunst"
    replace_symlinks_or_move_files_to_old "$HOME/.config/dunst/dunstrc" "$DOTFILES_DIR/apps/dunstrc"
    # set up gruvbox hard theme for xfce4 terminal
    mkdir -p "$HOME/.local/share/xfce4/terminal/colorschemes"
    replace_symlinks_or_move_files_to_old "$HOME/.local/share/xfce4/terminal/colorschemes/gruvbox-dark-hard.theme" "$DOTFILES_DIR/apps/xfce4_terminal_gruvbox-dark-hard.theme"

	# set up dunstrc
    mkdir -p "$HOME/.config/alacritty"
    replace_symlinks_or_move_files_to_old "$HOME/.config/alacritty/alacritty.yml" "$DOTFILES_DIR/apps/alacritty.yml"
}

custom_scripts_setup() {
    local local_bin="$HOME/.local/bin"
    for full_path in "$DOTFILES_DIR"/scripts/*; do
        local fname="${full_path##*/}"
        # prefix command with comma
        replace_symlinks_or_move_files_to_old "${local_bin}/,${fname}" "$full_path"
    done
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
Copyright (C) 2019: John Nduli K.                                                                                                      
install.sh
 This installs dependencies for various files in the dotfiles.
 It also sets up symlinks to the various dotfiles in this repository.

 The following are setup: vim, neovim, i3, X, zsh, tmux, ledger
 It also sets up some useful repositories I regularly use

 -h: Show help file
 -g: install guix packages
 -i <os_name>: install packages for os. Support oses are ubuntu and arch
 -s : Other set up instructions
EOF
}

options () {
    while getopts "hi:sg" OPTION; do
        case $OPTION in
            h)
                show_help
                exit 1
                ;;
	    g)
		guix_install_packages
		exit 1
		;;
            i)
                os=${OPTARG}
                if [[ $os == "ubuntu" ]]; then
                    ubuntu_install_packages
                elif [[ $os == "arch" ]]; then
                    install_archlinux_ackages
                else
                    echo "Invalid OS ${os} provided"
                    exit 1
                fi
                exit
                ;;
            s)
                vim_setup
                i3_setup
                X_setup
                shell_setup
                other_applications_setup
                custom_scripts_setup
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
