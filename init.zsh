export AZIM_HOME=$(cd $(dirname $0);pwd)
AZIM_CACHE=$HOME/.cache/azim
ZIM_CONFIG_FILE=$AZIM_HOME/zimrc
ZIM_HOME=$HOME/.cache/zim

# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

# Initialize modules.
if [[ -f ${ZIM_HOME}/init.zsh ]]; then
  source ${ZIM_HOME}/init.zsh
fi

# hooks start
[[ $AZIM_HISTORY_SHOW == false ]] || _azim_history_show
[[ $AZIM_IN_LASTDIR == false ]] || _azim_in_lastdir
