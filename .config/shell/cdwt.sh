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
