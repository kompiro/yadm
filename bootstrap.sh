#!/usr/bin/env bash

set -eux

YADM_VERSION=3.5.0

# yadm が入っていない環境 (VSCode の dotfiles.installCommand から呼ばれる devcontainer など) では
# yadm 本体 (単一のスクリプト) を ~/.local/bin に置く。root 権限やパッケージマネージャーには依存しない
if ! command -v yadm > /dev/null 2>&1; then
  mkdir -p "${HOME}/.local/bin"
  curl -fsSL "https://raw.githubusercontent.com/yadm-dev/yadm/${YADM_VERSION}/yadm" -o "${HOME}/.local/bin/yadm"
  chmod +x "${HOME}/.local/bin/yadm"
  export PATH="${HOME}/.local/bin:${PATH}"
fi

# clone 後に ~/.config/yadm/bootstrap (asdf のツール導入や ~/.bashrc の設定) まで実行する。
# 非対話で実行されるので、確認プロンプトを出さないよう --bootstrap を明示する
yadm clone https://github.com/kompiro/yadm/ --bootstrap
