# eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

# starship
eval "$(starship init zsh)"

# key bindings emacs mode
bindkey -e

#if type brew &>/dev/null; then
#  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
#  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
#
#  autoload -Uz compinit
#  compinit
#fi

#autoload -Uz vcs_info
#setopt prompt_subst
#zstyle ':vcs_info:*' enable git
#zstyle ':vcs_info:git:*' check-for-changes true
#zstyle ':vcs_info:git:*' stagedstr "!"
#zstyle ':vcs_info:git:*' unstagedstr "+"
##zstyle ':vcs_info:*' formats "%r%F{green}%c%u[%b]%f"
#zstyle ':vcs_info:*' formats "%c%u%b"
#zstyle ':vcs_info:*' actionformats '[%b|%a]'
#precmd () {
#         vcs_info
#  if [ $TERM = "screen-256color" ]; then
#  local current_path=`pwd | sed -e s/\ /_/g`
#  local current_dir=`basename $current_path`
#  tmux rename-window "$current_dir $vcs_info_msg_0_"
#  fi
#}
## RPROMPT=$RPROMPT'${vcs_info_msg_0_}'
#
#PROMPT='%F{green}%n@%m%f❯ '

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# 履歴ファイルの保存先
export HISTFILE=${HOME}/.zsh_history

# メモリに保存される履歴の件数
export HISTSIZE=1000

# 履歴ファイルに保存される履歴の件数
export SAVEHIST=100000

# 重複を記録しない
setopt hist_ignore_dups

## Setup pure https://github.com/sindresorhus/pure
#fpath+=$HOME/.zsh/pure

# autoload -U promptinit; promptinit
# prompt pure
#export PATH="/home/linuxbrew/.linuxbrew/opt/python@3.8/bin:$PATH"

export EDITOR=vi

setopt autocd

# Setup asdf
. ~/.asdf/asdf.sh

# Setup direnv
eval "$(direnv hook zsh)"

# setup zsh utilities

## zsh-history-substring-search
# source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh

## zsh-autosuggestions
# source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
:
## zsh-syntax-highlighting
# source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# craete alias for cli tools
alias k='kubectl'
alias vi='nvim'
alias ls='exa'

# The next line updates PATH for the Google Cloud SDK.
if [ -f '$HOME/google-cloud-sdk/path.zsh.inc' ]; then . '$HOME/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '$HOME/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/google-cloud-sdk/completion.zsh.inc'; fi

_update_vscode_ipc_hook_cli() {
    local var
    var=$(env |grep '^VSCODE_IPC_HOOK_CLI=')
    if [ "$?" -eq 0 ]; then
        tmux set-environment VSCODE_IPC_HOOK_CLI "$var"
    fi
}
if [[ -n "$TMUX" ]]; then
  add-zsh-hook precmd _update_vscode_ipc_hook_cli
fi

# fpath=($fpath ~/.zsh/completion)

alias gcd='cd `ghq root`/`ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :100 $(ghq root)/{}/README.*"`'
