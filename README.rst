DOTFILES
========

TODO:
- [ ] add gruvbox theme to set up processes
- [ ] update docs


Setting up vim
--------------

```
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

Then create a symlink to .vimrc in the dotfiles

```
ln -s /path/to/clone/.vimrc ~/.vimrc
```

After this enter vim, by typing vim in shell
Then run:

```
:PluginInstall
```

You might need to compile ycm to work with C files.
Anyway, you're good to go

Setting up Tmux
---------------

Create a symlink to .tmux.conf in the dotfiles

```
ln -s /path/to/clone/.tmux.conf ~/.tmux.conf
```

First  set up tmux plugin manager (tpm)

```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then run prefix + I , which in my case is C-b I

You're good to go with tmux

Window Managers
---------------
The repository contains my config files for i3 and swaywm. To set this
up:

For i3: 

```
ln -s /path/to/dotfiles/swayconfig ~/.config/sway/config
```

For swaywm:

```
ln -s /path/to/dotfiles/i3config  ~/.config/i3/config
```

Others
------
To set up toggletouchpad in i3:

```
ln -s /path/to/clone/scripts/toggletouchpad.sh /usr/local/bin/toggletouchpad
```
