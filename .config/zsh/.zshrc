# eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

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


# 履歴ファイルの保存先
export HISTFILE=$HOME/.history/.zsh_history

# メモリに保存される履歴の件数
export HISTSIZE=1000

# 履歴ファイルに保存される履歴の件数
export SAVEHIST=100000

# 重複を記録しない
setopt hist_ignore_dups

## コマンドラインの先頭がスペースで始まる場合ヒストリに追加しない
setopt hist_ignore_space
## history (fc -l) コマンドをヒストリリストから取り除く。
setopt hist_no_store
## 余分な空白は詰めて記録
setopt hist_reduce_blanks

## シェルを横断して.zsh_historyに記録
setopt inc_append_history

## ヒストリを共有
setopt share_history


## Setup pure https://github.com/sindresorhus/pure
#fpath+=$HOME/.zsh/pure

# autoload -U promptinit; promptinit
# prompt pure
#export PATH="/home/linuxbrew/.linuxbrew/opt/python@3.8/bin:$PATH"

export EDITOR=nvim

setopt autocd

# mise 本体は ~/.local/bin に入る
path=("$HOME/.local/bin" $path)

# Setup mise
# shims を PATH の先頭に入れる。ツールの版は ~/.config/mise/config.toml か、
# プロジェクトの mise.toml / .tool-versions で決まる
path=("${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/shims" $path)
typeset -U path

# delta の pager を ov にする。ov が無い環境 (devcontainer など) では delta 既定の less を使う。
# delta の navigate = true が付ける見出し (Δ / added: など) をファイル単位の区切りにし、
# 区切りの行を画面上部に固定する。hunk の見出し (•) は検索の対象にしてジャンプしやすくする
if command -v ov > /dev/null 2>&1; then
  export DELTA_PAGER="ov -F --section-delimiter '^(commit|added:|removed:|renamed:|Δ)' --section-header --pattern '•'"
fi

# starship
eval "$(starship init zsh)"

# fzf (0.48 以降は --zsh で補完とキーバインドを出力できる)
if command -v fzf > /dev/null 2>&1; then
  source <(fzf --zsh)
fi

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

[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"
