#!/usr/bin/env bash

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# Enable bash programmable completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# Disable bell
if [[ $- == *i* ]]; then bind "set bell-style none"; fi

# History
export HISTFILESIZE=10000
export HISTSIZE=500
export HISTTIMEFORMAT="%F %T"
export HISTCONTROL=erasedups:ignoredups:ignorespace
shopt -s checkwinsize histappend
PROMPT_COMMAND='history -a'

# XDG dirs
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Allow Ctrl+S for history navigation
[[ $- == *i* ]] && stty -ixon

# Completion settings
if [[ $- == *i* ]]; then
  bind "set completion-ignore-case on"
  bind "set show-all-if-ambiguous On"
fi

# Editor
export EDITOR=nvim
export VISUAL=nvim
export BROWSER=chromium
alias vim='nvim'

# Colored output
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'

# man page colors
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Aliases
alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias cls='clear'
alias vi='nvim'
alias ..='cd ..'
alias ...='cd ../..'
alias la='ls -Alh'
alias ls='ls -aFh --color=always'
alias ll='ls -l'
alias lx='ls -lXBh'
alias lt='ls -ltrh'
alias grep='grep --color=auto'

# Git shortcuts
alias gcom='git add . && git commit -m'
alias lazyg='git add . && git commit -m "$1" && git push'

# PATH
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# Starship prompt
if command -v starship &>/dev/null; then
  eval "$(starship init bash)"
fi

# Zoxide
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash)"
fi

# Source bashrc.d
for f in ~/.bashrc.d/*; do source "$f"; done 2>/dev/null || true
