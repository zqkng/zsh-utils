###############################################################################
# ~/.zsh/zshrc.d/prompt.zsh
# -------------------------
# Prompt configurations for zsh
#
###############################################################################

# Enable command substitution in prompt
setopt PROMPT_SUBST

# Create prompt
() {
  if [[ $({tput colors} 2>/dev/null) == 256 ]]
  then
      local red='%F{196}'
      local blue='%F{39}'
      local green='%F{40}'
      local yellow='%F{220}'
      local magenta='%F{141}'
      local cyan='%F{180}'
  else
      local red='%F{red}'
      local blue='%F{blue}'
      local green='%F{green}'
      local yellow='%F{yellow}'
      local magenta='%F{magenta}'
      local cyan='%F{cyan}'
  fi

  local _user=${green}'%n@%m%f'
  local _cwd=${blue}'%2~%f'
  local _jobs=${yellow}'%1(j.{%j}.)%f'
  
  #local _char='❯'
  local _char='⟩'
  #local _exit='%B%(?.'${green}'✔︎.'${red}'✘) %b%f'
  local _exit='%B%(?..'${red}${_char}')%b'
  #local _symbol='%B%#%b '
  local _symbol='%B%(!.#.'${_char}')%b%f '
  
  PROMPT="%B[%b${_user}%B:%b${_cwd}%B]%b${_jobs}"$'\n'"${_exit}${_symbol}"
}
