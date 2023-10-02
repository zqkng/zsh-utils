###############################################################################
# ~/.zsh/zshrc.d/insert-stdout-widget.zsh
# ----------------------------------------
# Insert the output from the previous command to the command line.
#
###############################################################################

zmodload -i zsh/parameter

insert-last-command-output() {
  LBUFFER+="$(eval $history[$((HISTCMD-1))])"
}

zle -N insert-stdout-widget insert-last-command-output
# bindkey: <ALT>-x
bindkey '^[x' insert-stdout-widget

