#!/bin/sh

# Link files from dotfiles
ln -s ~/.dotfiles/pylintrc ~/.pylintrc
ln -s ~/.dotfiles/.elinks ~/.elinks
ln -s ~/.dotfiles/.muttrc ~/.muttrc
ln -s ~/.dotfiles/.mutt ~/.mutt

/usr/bin/git clone https://github.com/farazdagi/vim-go-ide.git ~/.vim
/usr/bin/git clone https://github.com/jceb/vim-orgmode.git ~/.vim/bundle/pristine/vim-orgmode
/usr/bin/git clone https://github.com/joonty/vdebug.git  ~/.vim/bundle/pristine/vdebug
/usr/bin/git clone https://github.com/vim-scripts/DoxygenToolkit.vim.git ~/.vim/bundle/pristine/DoxygenToolkit.vim
/usr/bin/git clone https://github.com/ctrlpvim/ctrlp.vim.git ~/.vim/bundle/pristine/ctrlp.vim
/usr/bin/git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
ln -s ~/.fzf ~/.vim/bundle/pristine/fzf
/usr/bin/git clone https://github.com/junegunn/fzf.vim.git ~/.vim/bundle/pristine/fzf.vim
ln -s ~/.dotfiles/custom_config.vim ~/.vim
