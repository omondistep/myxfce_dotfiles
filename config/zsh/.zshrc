export ZDOTDIR="$HOME/.config/zsh"
export ZSH="$ZDOTDIR/oh-my-zsh"
export ZSH_CACHE_DIR="$ZDOTDIR/cache"

ZSH_THEME=""

plugins=(git zoxide sudo copyfile copypath dirhistory history)

source $ZSH/oh-my-zsh.sh

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

export EDITOR=nvim
export VISUAL=nvim
export BROWSER=chromium

alias ls='ls -aFh --color=always'
alias la='ls -Alh'
alias ll='ls -l'
alias vim='nvim'
alias vi='nvim'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias diff='diff --color=auto'

setopt hist_ignore_dups
setopt hist_ignore_space
setopt share_history
setopt auto_cd
setopt correct
setopt no_beep
setopt interactive_comments

HISTSIZE=50000
SAVEHIST=50000
HISTFILE="$ZDOTDIR/.zsh_history"
