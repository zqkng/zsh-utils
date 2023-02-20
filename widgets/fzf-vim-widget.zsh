###############################################################################
# ~/.zsh/zshrc.d/fzf-vim-widget.zsh
# ---------------------------------
# Select file(s) that match the (optional) pattern with `fzf` and
#   open with `vim`.
#
###############################################################################

_fvim() {
  local files=(${(f)"$(fd --type f --hidden ${@} | fzf --multi --select-1 --exit-0)"})

  if [[ -n ${files} ]]
  then
    # To suppress VIM input warning (STDIN expected to be from terminal):
    # - set STDIN as /dev/tty
    #vim -- ${files} </dev/tty;
    echo "${files}" | xargs -o vim; 
    # Save the executed command^ to zsh history (with filenames expanded)
    print -s "vim -- ${files}";
    # Print selected filenames to console
    echo "${files}\n";
  fi

  # Clean prompt after invoking widget
  zle reset-prompt;
}
# One-liner (except command not saved to history and no console output):
#   > `fd --type f --hidden ${@} | fzf -m -1 -0 | xargs -o vim`

zle -N fzf-vim-widget _fvim
# bindkey: <CTRL>-v
bindkey '^v' fzf-vim-widget
