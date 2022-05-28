# If you come from bash you might have to change your $PATH.
 export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
  export ZSH=/home/arjunmahishi/.oh-my-zsh

ZSH_THEME="arjunmahishi"

plugins=(
  zsh-autosuggestions
  zsh-syntax-highlighting
  git virtualenv
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

export WORKON_HOME=~/.venvs
export PIP_VIRTUALENV_BASE=~/.venvs
