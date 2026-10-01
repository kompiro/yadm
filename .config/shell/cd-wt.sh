# shellcheck shell=bash
# cd-wt: プロジェクトルートと .claude/worktrees/ 配下の worktree を行き来する。
# cd はサブシェルからでは効かないので、スクリプトではなく関数として bash / zsh の両方から読み込む。
#
#   cd-wt           worktree の中にいればプロジェクトルートへ戻る。
#                   ルート側にいれば fzf で worktree を選んで移動する
#   cd-wt <name>    .claude/worktrees/<name> へ移動する (例: cd-wt feat/my-feature)。
#                   一致するものが無ければ <name> を初期クエリにして fzf で選ぶ

# 今いる worktree から見たメインの作業ツリー (プロジェクトルート) を返す
_cd_wt_root() {
  local common
  common=$(git rev-parse --path-format=absolute --git-common-dir 2> /dev/null) || return 1
  case "${common}" in
    */.git) printf '%s\n' "${common%/.git}" ;;
    *) return 1 ;;
  esac
}

# .claude/worktrees/ 配下の worktree を、そこからの相対パス (= ブランチ名) で列挙する
_cd_wt_list() {
  local root=$1
  git -C "${root}" worktree list --porcelain |
    sed -n "s|^worktree ${root}/\.claude/worktrees/||p"
}

cd-wt() {
  local root wt_dir target
  if ! root=$(_cd_wt_root); then
    echo "cd-wt: git リポジトリの中で実行してください" >&2
    return 1
  fi
  wt_dir="${root}/.claude/worktrees"

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
    echo "cd-wt: fzf が見つかりません。worktree:" >&2
    _cd_wt_list "${root}" >&2
    return 1
  fi
  local candidates
  candidates=$(_cd_wt_list "${root}")
  if [ $# -gt 0 ]; then
    candidates=$(printf '%s\n' "${candidates}" | fzf --filter="$1")
    if [ -z "${candidates}" ]; then
      echo "cd-wt: '$1' に一致する worktree がありません" >&2
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
  [ -n "${target}" ] && cd "${wt_dir}/${target}"
}

# 補完: worktree 名を候補に出す
if [ -n "${ZSH_VERSION-}" ]; then
  _cd_wt_complete() {
    local root
    root=$(_cd_wt_root) || return 1
    compadd -- $(_cd_wt_list "${root}")
  }
  # compdef は compinit の後でないと使えない
  if (( ${+functions[compdef]} )); then
    compdef _cd_wt_complete cd-wt
  fi
elif [ -n "${BASH_VERSION-}" ]; then
  _cd_wt_complete() {
    local root
    root=$(_cd_wt_root) || return
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "$(_cd_wt_list "${root}")" -- "${COMP_WORDS[COMP_CWORD]}"))
  }
  complete -F _cd_wt_complete cd-wt
fi
