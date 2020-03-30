# dotfiles folder
DOTFILES_DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")
# check that os is archlinux
is_archlinux_or_exit() {
    if [ -f "/etc/arch-release" ]; then
        return 0
    else
        exit 1
    fi
}

install_packages() {
    is_archlinux_or_exit
    local packages=''
    # i3 dependent packages
    # i3 group contains i3-wm, i3blocks, i3lock, i3status
    packages+='i3 feh scrot'

    # I'm still dependent on xfce4 for somethings so I install the group
    # dmenu for openning apps, xautolock to lock screen
    packages+=' xfce4 dmenu xautolock'

    # editors I use
    packages+=' gvim neovim python-pynvim git'

    pacman -Sy --noconfirm "$packages"
}

# if a file is a symlink, replace this will new file
# if it is an actual file, move this to path.old
# symlink path with file in dotfiles
# Arguments:
#   filepath: the location of file
#   localpath: file in dotfiles folder to replace
replace_symlinks_or_move_files_to_old(){
    if [ -L "$1" ]; then
        echo "${1} is a symlink, replacing the link to ${2}"
    elif [ -f "$1" ]; then
        echo "Moving ${1} to ${1}.old"
        mv "${1}" "${1}.old"
    fi
    echo "Symlinking ${1} to ${2}"
    ln -s "${2}" "${1}"
}

vim_setup(){
    local vimrc_path="$HOME/.vimrc"
    local dotfile_vimrc="${DOTFILES_DIR}/.vimrc"
    replace_symlinks_or_move_files_to_old "$vimrc_path" "$dotfile_vimrc"
    local neovim_init_path="$HOME/.config/nvim/init.vim"
    local dotfile_neovim="${DOTFILES_DIR}/nvim-init.vim"
    replace_symlinks_or_move_files_to_old "$neovim_init_path" "$dotfile_neovim"
    # set up .vimrc and init.vim
    # set up Plug (plugin manager)
    # vim -c ':PlugInstall' -c 'qa!'
}

show_help() {
    cat <<EOF
This installs dependencies for various files in the dotfiles.
It also sets up symlinks to the various dotfiles in this repository.
EOF
}

# install_packages
vim_setup

# For i3, the following need to be installed in archlinux
#redshift-gtk
#pactl

#polkit-gnome-authentication-agent?
#xfce4-power-manager?
#xrandr?

#should I set up toggle-touchpad?

##nvim and vim things
#install vim plugins

## install thing for XDG things

## install xfce4 and xinitrc and xserverrc
