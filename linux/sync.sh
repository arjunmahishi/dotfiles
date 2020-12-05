#!/bin/sh

# clean 
find . -maxdepth 1 -name ".*" | grep -v "git\|^.$" | xargs sudo rm -rf

# copy
sudo cp ~/.vimrc .
sudo cp ~/.zshrc .
sudo cp ~/.zsh_aliases .
sudo cp ~/.config/nvim/init.vim .
git commit -am "Linux: `date|awk '{print $NF"-"$2"-"$3,$4}'`"
git push origin master
