# ZDOTDIR を変えると ~/.zprofile は読まれなくなる。
# そこにはマシンごとのログイン設定 (Mac の brew shellenv、コンテナの ~/.profile 読み込みなど) が
# 置かれていることがあるので、あれば引き続き読み込む
[ -f "$HOME/.zprofile" ] && . "$HOME/.zprofile"
