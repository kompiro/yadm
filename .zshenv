# zsh の設定は ~/.config/zsh に置く。
# devcontainer のイメージなどが ~/.zshrc を最初から置いていると、yadm clone はそれを
# 上書きせず残すため、yadm の設定が読まれなくなる。ZDOTDIR を分けてぶつからないようにする。
# yadm は $HOME 直下にチェックアウトするので、XDG_CONFIG_HOME ではなく $HOME/.config を参照する
export ZDOTDIR="$HOME/.config/zsh"

# 環境ごとの環境変数は yadm で管理しない $ZDOTDIR/.zshenv.local に書く。
# zsh は .zshenv を ~/.zshenv しか読まないので、ここで明示的に読み込む
if [ -f "$ZDOTDIR/.zshenv.local" ]; then
  . "$ZDOTDIR/.zshenv.local"
fi
