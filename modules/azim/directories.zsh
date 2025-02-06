# Changing/making/removing directory
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias sudo='sudo '

alias -- -='cd -'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

alias md='mkdir -p'
alias rd='rmdir'
alias rmf='rm -rf'
alias lnk='ln -s'
alias rlnk='ln -snf'
alias ds='du -sh ./* | sort -hr'

# deveop commands alias
command -v nvim &> /dev/null && alias v='nvim'
command -v nvim &> /dev/null && alias vim='nvim'
command -v npm &> /dev/null && alias n='npm'
command -v pnpm &> /dev/null && alias p='pnpm'
command -v yarn &> /dev/null && alias y='yarn'

function d () {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}
compdef _dirs d

# List directory contents
if command -v lsd &> /dev/null; then
  alias l='lsd -lah'
  alias ll='lsd -lh'
  alias ls='lsd --color=auto'
  alias la='lsd -lAh'
  alias lsa='lsd -lah'
  alias lt='lsd --tree'
  alias lta='lsd -a --tree'
  alias ltd='lsd --tree --depth ${1}'
  alias ltda='lsd -a --tree --depth ${1}'
else
  alias ls='ls --color=auto'
  alias lsa='ls -lah'
  alias l='ls -lah'
  alias ll='ls -lh'
  alias la='ls -lAh'
fi
