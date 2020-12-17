#!/bin/sh

# clean 
find . -maxdepth 1 -name ".*" | grep -v "git\|^.$" | xargs rm -rf

# copy
cp ~/.vimrc .
cp ~/.ackrc .
cp ~/.zshrc .
cp ~/.zsh_aliases .
cp ~/.config/nvim/init.vim .
cp ~/.config/alacritty/alacritty.yml .
cp ~/.tmux.conf .

git status .
