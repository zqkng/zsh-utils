###############################################################################
# ~/.zsh/zshrc.d/fzf-git-widget.zsh
# ---------------------------------
# Interactive `git` commands via `fzf`.
#
###############################################################################

_is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

_fzf_git_view() {
  fzf --height 50% --min-height 20 --border --bind ctrl-/:toggle-preview "$@"
}

# List staged/unstaged/untracked [f]iles
# command: `git status`; preview: `git diff`
# binding: <CTRL>-g, <CTRL>-f
_fzf_gf() {
  _is_in_git_repo || return
  git -c color.status=always status --short |
  _fzf_git_view --ansi --multi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1})' |
  cut -c4- | sed 's/.* -> //'
}

# List [b]ranches
# command: `git branch`; preview: `git log`
# binding: <CTRL>-g, <CTRL>-b
_fzf_gb() {
  _is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  _fzf_git_view --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

# List [t]ags
# command: `git tag`; preview: `git show`
# binding: <CTRL>-g, <CTRL>-t
_fzf_gt() {
  _is_in_git_repo || return
  git tag --sort -version:refname |
  _fzf_git_view --multi --preview-window right:70% \
    --preview 'git show --color=always {}'
}

# List commit [h]ashes
# command: `git log`; preview: `git show`
# binding: <CTRL>-g, <CTRL>-h
_fzf_gh() {
  _is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  _fzf_git_view --ansi --multi --no-sort --reverse --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' |
  grep -o "[a-f0-9]\{7,\}"
}

# List all [r]emotes
# command: `git remote`; preview: `git log`
# binding: <CTRL>-g, <CTRL>-r
_fzf_gr() {
  _is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  _fzf_git_view --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1}' |
  cut -d$'\t' -f1
}

# List modifications [s]tashed away
# command: `git stash`; preview: `git show`
# binding: <CTRL>-g, <CTRL>-s
_fzf_gs() {
  _is_in_git_repo || return
  git stash list | _fzf_git_view --reverse -d: --preview 'git show --color=always {1}' |
  cut -d: -f1
}

_join_lines() {
  local item
  while read item; do
    echo -n "${(q)item} "
  done
}

() {
  local c
  for c in $@; do
    eval "fzf-git$c-widget() { local result=\$(_fzf_g$c | _join_lines); zle reset-prompt; LBUFFER+=\$result }"
    eval "zle -N fzf-git$c-widget"
    eval "bindkey '^g$c' fzf-git$c-widget"
  done
} f b t r h s
