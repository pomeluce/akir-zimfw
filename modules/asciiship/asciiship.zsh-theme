# vim:et sts=2 sw=2 ft=zsh

_prompt_asciiship_vimode() {
  case ${KEYMAP} in
    vicmd) print -n '%S%(!.#.)%s' ;;
    *) print -n '%(!.#.)' ;;
  esac
}

_prompt_asciiship_keymap_select() {
  zle reset-prompt
  zle -R
}
if autoload -Uz is-at-least && is-at-least 5.3; then
  autoload -Uz add-zle-hook-widget && \
      add-zle-hook-widget -Uz keymap-select _prompt_asciiship_keymap_select
else
  zle -N zle-keymap-select _prompt_asciiship_keymap_select
fi

typeset -g VIRTUAL_ENV_DISABLE_PROMPT=1

setopt nopromptbang prompt{cr,percent,sp,subst}

autoload -Uz add-zsh-hook

# Use True color (24-bit) if available.
if [[ "${terminfo[colors]}" -ge 256 ]]; then
  azim_dark="%F{0}"
  azim_turquoise="%F{73}"
  azim_orange="%F{179}"
  azim_bg_orange="%K{179}"
  azim_red="%F{167}"
  azim_limegreen="%F{107}"
  azim_magenta="%F{177}"
else
  azim_dark="%F{black}"
  azim_turquoise="%F{cyan}"
  azim_orange="%F{yellow}"
  azim_bg_orange="%K{yellow}"
  azim_red="%F{red}"
  azim_limegreen="%F{green}"
  azim_magenta="%F{magenta}"
fi
# Reset color.
azim_reset_color="%f"
azim_reset_bg="%k"

# Depends on git-info module to show git information
typeset -gA git_info

if (( ${+functions[git-info]} )); then
  zstyle ':zim:git-info' verbose yes
  zstyle ':zim:git-info:branch' format '%b'
  zstyle ':zim:git-info:commit' format 'HEAD %{$azim_limegreen%}(%c)%{$azim_reset_color%}'
  zstyle ':zim:git-info:action' format '(%{$azim_magenta%}%a%{$azim_reset_color%})'
  zstyle ':zim:git-info:stashed' format ' %{$azim_limegreen%}%{$azim_reset_color%}'
  zstyle ':zim:git-info:unindexed' format ' %{$azim_orange%}!%{$azim_reset_color%}'
  zstyle ':zim:git-info:untracked' format ' %{$azim_red%}?%{$azim_reset_color%}'
  zstyle ':zim:git-info:indexed' format ' %{$azim_limegreen%}↑%{$azim_reset_color%}'
  zstyle ':zim:git-info:ahead' format ' %{$azim_magenta%}>%{$azim_reset_color%}'
  zstyle ':zim:git-info:behind' format ' %{$azim_turquoise%}<%{$azim_reset_color%}'
  zstyle ':zim:git-info:keys' format \
      'status' '%S%I%u%i%A%B' \
      'prompt' 'on %{$azim_turquoise%} %b%{$azim_reset_color%}%s${(e)git_info[status]:+"${(e)git_info[status]}"}'
  add-zsh-hook precmd git-info
fi

PS1='
%(!.%B%{$azim_red%}%n%{$azim_reset_color%}%b in .${SSH_TTY:+"%{$azim_orange%}%{$azim_bg_orange%}%{$azim_dark%}%n%{$azim_reset_color%}%{$azim_reset_bg%}%{$azim_orange%}%{$azim_reset_color%} in "})${SSH_TTY:+"%{$azim_limegreen%}%m%{$azim_reset_color%} in "}%{$azim_limegreen%}%~%{$azim_reset_color%} ${(e)git_info[prompt]}${VIRTUAL_ENV:+" via %{$azim_orange%}${VIRTUAL_ENV:t}%{$azim_reset_color%}"}
%(?.%{$azim_limegreen%}.%{$azim_red%})$(_prompt_asciiship_vimode)%{$azim_reset_color%} '

unset RPS1
