# shellcheck shell=bash
# cdwt: プロジェクトルートと .claude/worktrees/ 配下の worktree を行き来する。
# cd はサブシェルからでは効かないので、スクリプトではなく関数として bash / zsh の両方から読み込む。
#
#   cdwt           worktree の中にいればプロジェクトルートへ戻る。
#                   ルート側にいれば fzf で worktree を選んで移動する
#   cdwt <name>    .claude/worktrees/<name> へ移動する (例: cdwt feat/my-feature)。
#                   完全一致が無ければ <name> であいまい検索し、複数あれば fzf で選ぶ
#   cdwt list      worktree を一覧する
#   cdwt help      使い方を表示する
#   Alt+W          fzf でプロジェクトルートか worktree を選んで移動する (Ctrl+R のようなキー操作)

# 今いる worktree から見たメインの作業ツリー (プロジェクトルート) を返す
_cdwt_root() {
  local common
  common=$(git rev-parse --path-format=absolute --git-common-dir 2> /dev/null) || return 1
  case "${common}" in
    */.git) printf '%s\n' "${common%/.git}" ;;
    *) return 1 ;;
  esac
}

# .claude/worktrees/ 配下の worktree を、そこからの相対パス (= ブランチ名) で列挙する
_cdwt_list() {
  local root=$1
  git -C "${root}" worktree list --porcelain |
    sed -n "s|^worktree ${root}/\.claude/worktrees/||p"
}

# fzf でプロジェクトルートか worktree を選び、その絶対パスを返す
_cdwt_pick() {
  local root target
  root=$(_cdwt_root) || return 1
  target=$({
    printf '%s\n' '(root)'
    _cdwt_list "${root}"
  } | fzf --height=40% --reverse --prompt='worktree> ' --header="${root}") || return
  case "${target}" in
    '(root)') printf '%s\n' "${root}" ;;
    *) printf '%s\n' "${root}/.claude/worktrees/${target}" ;;
  esac
}

_cdwt_help() {
  cat << 'EOF'
使い方: cdwt [<name> | list | help]

  cdwt           worktree の中にいればプロジェクトルートへ戻る。
                  ルートにいれば fzf で worktree を選んで移動する
  cdwt <name>    .claude/worktrees/<name> へ移動する (例: cdwt feat/my-feature)。
                  完全一致が無ければ <name> であいまい検索し、
                  1 件ならそのまま移動、複数あれば fzf で選ぶ
  cdwt list      .claude/worktrees/ 配下の worktree を一覧する
  cdwt help      この使い方を表示する (-h / --help も可)

<name> と list は Tab で補完できる。
Alt+W を押すと、プロジェクトルートと worktree を fzf で選んで移動できる。
EOF
}

cdwt() {
  case "${1-}" in
    help | -h | --help)
      _cdwt_help
      return
      ;;
  esac

  local root wt_dir target
  if ! root=$(_cdwt_root); then
    echo "cdwt: git リポジトリの中で実行してください" >&2
    return 1
  fi
  wt_dir="${root}/.claude/worktrees"

  if [ "${1-}" = list ]; then
    _cdwt_list "${root}"
    return
  fi

  if [ $# -eq 0 ]; then
    case "${PWD}/" in
      "${wt_dir}"/*)
        cd "${root}" || return
        return
        ;;
    esac
  elif [ -d "${wt_dir}/$1" ]; then
    cd "${wt_dir}/$1" || return
    return
  fi

  if ! command -v fzf > /dev/null 2>&1; then
    echo "cdwt: fzf が見つかりません。worktree:" >&2
    _cdwt_list "${root}" >&2
    return 1
  fi
  local candidates
  candidates=$(_cdwt_list "${root}")
  if [ $# -gt 0 ]; then
    candidates=$(printf '%s\n' "${candidates}" | fzf --filter="$1")
    if [ -z "${candidates}" ]; then
      echo "cdwt: '$1' に一致する worktree がありません" >&2
      return 1
    fi
    # 1 つに絞れたら選ばずに移動する
    case "${candidates}" in
      *"
"*) ;;
      *)
        cd "${wt_dir}/${candidates}" || return
        return
        ;;
    esac
  fi
  target=$(printf '%s\n' "${candidates}" | fzf --height=40% --reverse --query="${1-}") || return
  [ -n "${target}" ] || return
  cd "${wt_dir}/${target}" || return
}

# 補完: サブコマンドと worktree 名を候補に出す
if [ -n "${ZSH_VERSION-}" ]; then
  _cdwt_complete() {
    local root
    root=$(_cdwt_root) || return 1
    (( CURRENT == 2 )) || return 1
    # worktree 名は 1 行に 1 つなので、改行で分割させる
    # shellcheck disable=SC2046
    compadd -- list help $(_cdwt_list "${root}")
  }
  # compdef は compinit の後でないと使えない
  if (( ${+functions[compdef]} )); then
    compdef _cdwt_complete cdwt
  fi
elif [ -n "${BASH_VERSION-}" ]; then
  _cdwt_complete() {
    local root
    root=$(_cdwt_root) || return
    [ "${COMP_CWORD}" -eq 1 ] || return
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "list help $(_cdwt_list "${root}")" -- "${COMP_WORDS[COMP_CWORD]}"))
  }
  complete -F _cdwt_complete cdwt
fi

# Alt+W: fzf で選んだ先へ移動する。fzf の Alt+C と同じく cd の行を実行させるので、
# プロンプトの再描画 (starship) や direnv の切り替えが通常の cd と同じように効き、履歴にも残る
case $- in
  *i*) ;;
  *) return 0 ;;
esac
if [ -n "${ZSH_VERSION-}" ]; then
  _cdwt_widget() {
    local dir
    if ! _cdwt_root > /dev/null; then
      zle -M "cdwt: git リポジトリの中で実行してください"
      return 1
    fi
    dir=$(_cdwt_pick)
    if [ -z "${dir}" ]; then
      zle redisplay
      return 0
    fi
    # 入力途中の行は退避し、次のプロンプトで戻す
    zle push-line
    # BUFFER は zle の編集中の行
    # shellcheck disable=SC2034
    BUFFER="builtin cd -- $(printf '%q' "${dir}")"
    zle accept-line
    local ret=$?
    zle reset-prompt
    return "${ret}"
  }
  zle -N _cdwt_widget
  bindkey '\ew' _cdwt_widget
elif [ -n "${BASH_VERSION-}" ]; then
  # bind -x の関数からは行を実行できないので、Alt+W を「\C-x\C-w (選ぶ) → \C-x\C-v (実行)」の
  # 2 段のマクロにする。\C-x\C-v には選んだときだけ accept-line を割り当て、
  # キャンセルしたときは入力途中の行を実行しないよう再描画だけにする
  _cdwt_widget() {
    local dir
    dir=$(_cdwt_pick)
    if [ -n "${dir}" ]; then
      READLINE_LINE="builtin cd -- $(printf '%q' "${dir}")"
      READLINE_POINT=${#READLINE_LINE}
      bind -m emacs-standard '"\C-x\C-v": accept-line'
    else
      bind -m emacs-standard '"\C-x\C-v": redraw-current-line'
    fi
  }
  bind -m emacs-standard -x '"\C-x\C-w": _cdwt_widget'
  bind -m emacs-standard '"\ew": "\C-x\C-w\C-x\C-v"'
fi
