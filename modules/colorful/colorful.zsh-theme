setopt PROMPT_SUBST

autoload -U add-zsh-hook
autoload -Uz vcs_info

# Use True color (24-bit) if available.
if [[ "${terminfo[colors]}" -ge 256 ]]; then
  azim_turquoise="%F{73}"
  azim_orange="%F{179}"
  azim_red="%F{167}"
  azim_limegreen="%F{107}"
else
  azim_turquoise="%F{cyan}"
  azim_orange="%F{yellow}"
  azim_red="%F{red}"
  azim_limegreen="%F{green}"
fi

# Reset color.
azim_reset_color="%f"

# VCS style formats.
FMT_UNSTAGED="%{$azim_reset_color%} %{$azim_orange%}!"
FMT_STAGED="%{$azim_reset_color%} %{$azim_limegreen%}↑"
FMT_ACTION="(%{$azim_limegreen%}%a%{$azim_reset_color%})"
FMT_VCS_STATUS="on %{$azim_turquoise%} %b%u%c%{$azim_reset_color%}"

zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr    "${FMT_UNSTAGED}"
zstyle ':vcs_info:*' stagedstr      "${FMT_STAGED}"
zstyle ':vcs_info:*' actionformats  "${FMT_VCS_STATUS} ${FMT_ACTION}"
zstyle ':vcs_info:*' formats        "${FMT_VCS_STATUS}"
zstyle ':vcs_info:*' nvcsformats    ""
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

# Check for untracked files.
+vi-git-untracked() {
  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
    git status --porcelain | grep --max-count=1 '^??' &> /dev/null; then
    hook_com[staged]+="%{$azim_reset_color%} %{$azim_red%}?"
  fi
}

# Executed before each prompt.
add-zsh-hook precmd vcs_info

# akir-zimfw prompt style.
PROMPT=$'%{$azim_limegreen%}%~%{$azim_reset_color%} ${vcs_info_msg_0_}\n%(?.%{$azim_limegreen%}.%{$azim_red%})%(!.#.)%{$azim_reset_color%} '

# define last command
LAST_CMD=""
IS_FIRST=true

_azim_precmd_hook() {
  if [[ $IS_FIRST == true || $LAST_CMD == "clear" || $LAST_CMD == "reset" || $LAST_CMD == "tput clear" ]]; then
    LAST_CMD="" # reset
  else
    echo  # add new line
  fi
  IS_FIRST=false
}

# preexec hook, set last command
_azim_preexec_hook() {
  LAST_CMD="$1"
}

add-zsh-hook precmd _azim_precmd_hook
add-zsh-hook preexec _azim_preexec_hook
