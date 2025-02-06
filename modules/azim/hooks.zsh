# Load add-zsh-hook
autoload -Uz add-zsh-hook
# disable autocorrect
unsetopt correct
# tab 补全
autoload -U compinit && compinit
# Load all stock functions (from $fpath files) called below.
autoload -U compaudit compinit zrecompile

# 如果 cache 目录未设置, 则使用默认的 cache 目录
if [[ -z "$ZSH_CACHE_DIR" ]]; then
  ZSH_CACHE_DIR="$AZIM_HOME/cache"
fi

# 默认执行历史命令绑定
if [[ -z "$AZIM_HISTORY_SHOW" ]]; then
  AZIM_HISTORY_SHOW=true
fi

# 自动进入上次退出目录, 默认不开启
if [[ -z "$AZIM_IN_LASTDIR" ]]; then
  AZIM_IN_LASTDIR=false
fi

# 获取主机名
SHORT_HOST="${HOST/.*/}"

# ctrl + r 展开 history 列表, 并查找
_azim_history_show() {
  function fzf_history_list (){
    if [ $#LBUFFER -gt 0 ]; then
      BUFFER=$(history -n | awk '!seen [$0]++' | fzf --query $LBUFFER)
    else
      BUFFER=$(history -n | awk '!seen [$0]++' | fzf)
    fi
    CURSOR=$#BUFFER
    zle redisplay
  }
  zle -N fzf_history_list
  bindkey '^r' fzf_history_list
}

# 进入终端时, 自动 cd 到上次的目录
_azim_in_lastdir() {
  chpwd_hook() { echo $PWD > $AZIM_HOME/cache/currentdir }
  add-zsh-hook -Uz chpwd chpwd_hook
  currentdir=$(cat $AZIM_HOME/cache/currentdir 2>/dev/null || echo "")
  [ -d "$currentdir" ] && cd $currentdir
}
