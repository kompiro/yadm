#!/bin/bash -i

set -ex

URL=${URL:-"https://github.com/kompiro/yadm"}
REF=${REF:-"main"}

su - "$_REMOTE_USER" <<EOF
echo "URL:$URL"
echo "REF:$REF"
# bootstrap の mise install が GitHub API を叩くので、未認証のレート制限 (60 回/時) に当たらないようトークンを渡す。
# su - で環境変数がリセットされるので、ここで export する
if [ -n "$GITHUBTOKEN" ]; then export GITHUB_TOKEN="$GITHUBTOKEN"; fi
yadm clone $URL --bootstrap -b $REF
EOF
