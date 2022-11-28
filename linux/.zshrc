# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/home/arjun/.oh-my-zsh

ZSH_THEME="arjunmahishi"

plugins=(
  zsh-autosuggestions
  git
  virtualenv
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin
export PATH=$PATH:/usr/local/go/bin

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  --no-use # This loads nvm

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# disable cowsay for ansible
export ANSIBLE_NOCOWS=1

# source the aliases file
source ~/.zsh_aliases
source ~/last9_aliases


# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
export PATH="$PATH:$HOME/.local/bin"

export WORKON_HOME=~/.venvs
export PIP_VIRTUALENV_BASE=~/.venvs

export GOPATH="$HOME/go"; export GOROOT="/usr/local/go"; export PATH="$GOPATH/bin:$PATH"; # g-install: do NOT edit, see https://github.com/stefanmaric/g
alias goenv="$GOPATH/bin/g"; # g-install: do NOT edit, see https://github.com/stefanmaric/g

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

source /usr/share/doc/fzf/examples/key-bindings.zsh
