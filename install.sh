# dotfiles folder
DOTFILES_DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

# check that os is archlinux and exits otherwise
is_archlinux_or_exit() {
    if [ -f "/etc/arch-release" ]; then
        return 0
    else
        exit 1
    fi
}

# installs packages using pacman required for dotfiles to work well
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
    packages+=' gvim neovim python-pynvim git curl'

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
    ln --force --symbolic "${2}" "${1}"
}

# Sets up vim and vim and all plugins in use
vim_setup(){
    # set up .vimrc and init.vim
    local vimrc_path="$HOME/.vimrc"
    local dotfile_vimrc="${DOTFILES_DIR}/editors/vimrc"
    replace_symlinks_or_move_files_to_old "$vimrc_path" "$dotfile_vimrc"
    local neovim_folder="$HOME/.config/nvim"
    mkdir -p "$neovim_folder"
    local neovim_init_path="${neovim_folder}/init.vim"
    local dotfile_neovim="${DOTFILES_DIR}/editors/nvim-init.vim"
    replace_symlinks_or_move_files_to_old "$neovim_init_path" "$dotfile_neovim"
    # set up Plug (plugin manager)
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    # install vim plugins
    vim -c ':PlugInstall' -c 'qa!'
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
        curl --fail --location --output "$i3_wallpaper" --create-dirs https://imgs.xkcd.com/comics/real_programmers.png
    fi

    # set up lock screen image
    local i3_lock="${HOME}/images/i3_lock.png"
    if [ ! -f "$i3_lock" ]; then
        curl --fail --location --output "$i3_lock" --create-dirs https://imgs.xkcd.com/comics/standards.png 
    fi
}


# sets up X files to help launch i3 and xfce4
X_setup() {
    local xinitrc="${HOME}/.xinitrc"
    local dotfile_xinitrc="${DOTFILES_DIR}/X11/xinitrc"
    replace_symlinks_or_move_files_to_old "$xinitrc" "$dotfile_xinitrc"

    local xserverrc="${HOME}/.xserverrc"
    local dotfile_xserver="${DOTFILES_DIR}/X11/xserverrc"
    replace_symlinks_or_move_files_to_old "$xserverrc" "$dotfile_xserver"
}

show_help() {
    cat <<EOF
This installs dependencies for various files in the dotfiles.
It also sets up symlinks to the various dotfiles in this repository.

The following are setup:
    vim, neovim, and their respective plugins
EOF
}


# TODO: set up shells and tmux
# TODO: set up applications e.g. ledgerrc
# TODO: download repositories required for use e.g. pomodoro, ledger, vimwiki


main () {
    install_packages
    vim_setup
    i3_setup
    X_setup
}

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
