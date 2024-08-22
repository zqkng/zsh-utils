###############################################################################
# ~/.zsh/zshrc.d/prompt.zsh
# -------------------------
# Prompt configurations for zsh.
#
# LEFT PROMPT: (pyvenv)[user@hostname: ~/pwd](git:branch){#jobs}
# RIGHT PROMPT: VI_MODE="NORMAL" or VI_MODE="INSERT"
#
###############################################################################

# Enable command substitution in prompt
setopt PROMPT_SUBST

## SETUP VCS (VERSION CONTROL SYSTEM) INFO
# Initialize built-in zsh functions for vcs info
autoload -Uz add-zsh-hook add-zle-hook-widget vcs_info
# Run `vcs_info` before prompt is displayed (precmd)
# TODO: make vcs_info() run async
add-zsh-hook precmd vcs_info
# Specify `git` as the vcs
zstyle ':vcs_info:*' enable git
# Enable checking for (un)staged changes
zstyle ':vcs_info:*' check-for-changes true

# Get Python virtualenv info
function venv_info() {
  if [ -z "$VIRTUAL_ENV" ]; then
    VIRTUAL_ENV_PROMPT=""
  else
    VIRTUAL_ENV_PROMPT="(`basename \"$VIRTUAL_ENV\"`)"
  fi
}
# Run `venv_info` before prompt is displayed (precmd)
add-zsh-hook precmd venv_info

# Update vi mode (RPROMPT) before input line is redrawn
function line_pre_redraw() {
    local _previous_vi_mode="${VI_MODE}"

    case "${KEYMAP}" in
        vicmd)
            case "${REGION_ACTIVE}" in
                1)
                    VI_MODE="[VISUAL]"
                    ;;
                2)
                    VI_MODE="[V-LINE]"
                    ;;
                *)
                    # VI_MODE="NORMAL"
                    VI_MODE="%F{220}%B◆%b%f"
                    ;;
            esac
            ;;
        viins|main)
            if [[ "${ZLE_STATE}" == *overwrite* ]]; then
                VI_MODE="[REPLACE]"
            else
                # VI_MODE="INSERT"
                VI_MODE="%F{39}%B◇%b%f"
            fi
            ;;
    esac

    if [[ "${VI_MODE}" != "${_previous_vi_mode}" ]]; then
        RPROMPT="${VI_MODE}"
        zle reset-prompt
    fi
}
add-zle-hook-widget zle-line-pre-redraw line_pre_redraw

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
 
  # Set custom strings for vcs repo status
  # + (staged), ! (unstaged), ? (untracked), ^ (stashed)
  zstyle ':vcs_info:*' stagedstr "${red}+"
  zstyle ':vcs_info:*' unstagedstr "${red}!"
  # TODO: add untracked and stashed git info to prompt
  # Set the formats for `vcs_info`
  zstyle ':vcs_info:*:*' formats       '(%s:%b%c%u'${magenta}')'
  zstyle ':vcs_info:*:*' actionformats '(%s:%b|%a%c%u'${magenta}')'
  
  local _git=${magenta}'${vcs_info_msg_0_}%f'
  local _venv=${cyan}'${VIRTUAL_ENV_PROMPT}%f'
  
  PROMPT="${_venv}%B[%b${_user}%B:%b${_cwd}%B]%b${_git}${_jobs}"$'\n'"${_exit}${_symbol}"
}
