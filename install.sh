#!/bin/sh

# Link files from dotfiles
ln -s ~/.dotfiles/pylintrc ~/.pylintrc
ln -s ~/.dotfiles/.elinks ~/.elinks
ln -s ~/.dotfiles/.muttrc ~/.muttrc
ln -s ~/.dotfiles/.mutt ~/.mutt
ln -fs ~/.dotfiles/mc ~/.config/mc 
ln -s ~/.dotfiles/.Xdefaults ~/.Xdefaults

/usr/bin/git clone https://github.com/farazdagi/vim-go-ide.git ~/.vim_go_runtime
ln -s ~/.vim_go_runtime ~/.vim
/usr/bin/git clone https://github.com/jceb/vim-orgmode.git ~/.vim/bundle/pristine/vim-orgmode
/usr/bin/git clone https://github.com/joonty/vdebug.git  ~/.vim/bundle/pristine/vdebug
/usr/bin/git clone https://github.com/vim-scripts/DoxygenToolkit.vim.git ~/.vim/bundle/pristine/DoxygenToolkit.vim
/usr/bin/git clone https://github.com/ctrlpvim/ctrlp.vim.git ~/.vim/bundle/pristine/ctrlp.vim
/usr/bin/git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
ln -s ~/.fzf ~/.vim/bundle/pristine/fzf
/usr/bin/git clone https://github.com/junegunn/fzf.vim.git ~/.vim/bundle/pristine/fzf.vim
/usr/bin/git clone https://github.com/Shougo/neosnippet-snippets.git  ~/.vim/bundle/pristine/neosnippet-snippets
/usr/bin/git clone https://github.com/vim-airline/vim-airline ~/.vim/bundle/pristine/vim-airline
~/.fzf/install
ln -s ~/.dotfiles/custom_config.vim ~/.vim
~/.vim/bin/update_plugins
~/.vim/bin/install
ln -s ~/.vimrc.go ~/vimrc
