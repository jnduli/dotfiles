# TODO: should I set up toggle-touchpad?

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

# installs packages using pacman required for dotfiles to work well
install_packages() {
    is_archlinux_or_exit
    local packages=''
    # i3 dependent packages
    # i3 group contains i3-wm, i3blocks, i3lock, i3status
    # dunst installed for notifications
    packages+='i3 feh scrot dunst'

    # I'm still dependent on xfce4 for somethings so I install the group
    # dmenu for openning apps, xautolock to lock screen
    packages+=' xfce4 dmenu xautolock'

    # editors I use
    packages+=' gvim neovim python-pynvim git curl'

    # other packages
    packages+=' powerline-fonts tmux xdg-user-dirs ledger'

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
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    # install vim plugins
    vim -c ':PlugInstall' -c 'qa!'

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
        curl --fail --location --output "$i3_wallpaper" --create-dirs https://imgs.xkcd.com/comics/real_programmers.png
    fi

    # set up lock screen image
    local i3_lock="${HOME}/images/i3_lock.png"
    if [ ! -f "$i3_lock" ]; then
        curl --fail --location --output "$i3_lock" --create-dirs https://imgs.xkcd.com/comics/standards.png 
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
    local user_dirs_conf="${HOME}/.config/users-dirs.conf"
    local dotfile_user_dirs_conf="${HOME}/X11/user-dirs.conf"
    replace_symlinks_or_move_files_to_old "$user_dirs_conf" "$dotfile_user_dirs_conf"

    local user_dirs_dirs="${HOME}/.config/users-dirs.dirs"
    local dotfile_user_dirs_dirs="${HOME}/X11/user-dirs.dirs"
    replace_symlinks_or_move_files_to_old "$user_dirs_dirs" "$dotfile_user_dirs_dirs"
}


# Install ohmyzsh, tpm and set up configs
shell_setup() {
    # installing oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # set up .zshrc
    local zshrc_path="$HOME/.zshrc"
    local dotfile_zshrc="${DOTFILES_DIR}/shells/zshrc"
    replace_symlinks_or_move_files_to_old "$zshrc_path" "$dotfile_zshrc"

    # set up tmux
    local tmux_conf="${HOME}/.tmux.conf"
    local dotfiles_tmux="${DOTFILES_DIR}/shells/tmux-conf"
    replace_symlinks_or_move_files_to_old "$tmux_conf" "$dotfiles_tmux"

    # tpm setup and tpm plugins
    git_clone_with_failure_message https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
    sh -c "${HOME}/.tmux/plugins/tpm/bin/install_plugins"
}

other_applications_setup(){
    # set up .ledgerrc
    local ledgerrc="$HOME/.ledgerrc"
    local dotfile_ledgerrc="${DOTFILES_DIR}/apps/ledgerrc"
    replace_symlinks_or_move_files_to_old "$ledgerrc" "$dotfile_ledgerrc"

    # clone ledger repo
    git_clone_with_failure_message ssh://rookie@jnduli.co.ke:/home/rookie/git/ledger.git "$HOME/docs/ledger"

    # clone personal vimwiki
    git_clone_with_failure_message ssh://rookie@jnduli.co.ke:/home/rookie/git/vimwiki.git "$HOME/vimwiki"

    mkdir -p "$HOME/projects"
    # clone blog site
    git_clone_with_failure_message https://github.com/jnduli/blog_jnduli.co.ke.git "$HOME/projects/blog"

    # pomodoro repo and setup
    git_clone_with_failure_message https://github.com/jnduli/pomodoro.git "$HOME/projects/pomodoro"

    mkdir -p "$HOME/.local/bin"
    # set up custom scripts
    local local_bin="$HOME/.local/bin"
    # pomodoro
    replace_symlinks_or_move_files_to_old "$local_bin/pomodoro.sh" "$HOME/projects/pomodoro/pomodoro.sh"
    # dishes.sh
    replace_symlinks_or_move_files_to_old "$local_bin/dishes.sh" "$DOTFILES_DIR/scripts/dishes.sh"
    # communication_prompt
    replace_symlinks_or_move_files_to_old "$local_bin/communication_prompt.sh" "$DOTFILES_DIR/scripts/communication_prompt.sh"

    # set up dunstrc
    mkdir -p "$HOME/.config/dunst"
    replace_symlinks_or_move_files_to_old "$HOME/.config/dunst/dunstrc" "$DOTFILES_DIR/apps/dunstrc"
# TODO: download repositories required for use e.g. pomodoro, ledger, vimwiki
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
 -i : Ignores package installations
EOF
}


options () {
    while getopts "hi" OPTION; do
        case $OPTION in
            h)
                show_help
                exit 1
                ;;
            i)
                echo "Ignoring packages install"
                IGNORE_INSTALL=1
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
    done
}


main () {
    options "$@"
    if [[ "$IGNORE_INSTALL" != 1 ]]; then
        install_packages
    fi
    vim_setup
    i3_setup
    X_setup
    shell_setup
    other_applications_setup
}

main "$@"
