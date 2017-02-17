DOTFILES
========

Setting up vim
--------------

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

Then create a symlink to .vimrc in the dotfiles
ln -s /path/to/clone/.vimrc ~/.vimrc

After this enter vim, by typing vim in shell
Then run:
:PluginInstall

You might need to compile ycm to work with C files.
Anyway, you're good to go

Setting up Tmux
---------------

Create a symlink to .tmux.conf in the dotfiles
ln -s /path/to/clone/.tmux.conf ~/.tmux.conf

First  set up tmux plugin manager (tpm)

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

Then run prefix + I , which in my case is C-b I

You're good to go with tmux

