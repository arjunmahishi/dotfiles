# dotfiles 
A collection of dotfiles I use/used across work/personal laptops

# Tools to install

- brew
- git
- zsh
- oh-my-zsh
- zsh plugins (use the script)
- nvim
- vim-plug
- tmux
- tmux plugin manager
- yarn (required for some of the nvim plugins)
- [fzf](https://github.com/junegunn/fzf)
- [delta](https://github.com/dandavison/delta)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- htop
- jq
- fd
- wget
- doom emacs and emacs
  ```
  brew tap d12frosted/emacs-plus
  brew install emacs-plus --with-native-comp --with-modern-doom3-icon

  git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
  ~/.config/emacs/bin/doom install
  ```

### Some commands

```bash
brew install tmux nvim fzf git-delta ripgrep htop jq fd wget

# To install useful key bindings and fuzzy completion:
$(brew --prefix)/opt/fzf/install
```
