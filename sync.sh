#!/bin/sh

# clean 
find . -maxdepth 1 -name ".*" | grep -v "git\|^.$" | xargs sudo rm -rf

# copy
sudo cp ~/.vimrc ./linux/.
sudo cp ~/.zshrc ./linux/.
sudo cp ~/.zsh_aliases ./common/.
sudo cp ~/.config/nvim/init.vim ./linux/.
git commit -am "`date|awk '{print $NF"-"$2"-"$3,$4}'`"
git push origin master
