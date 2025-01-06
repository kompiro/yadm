#!/bin/bash -i

set -ex

URL=${URL:-"https://github.com/kompiro/yadm"}
REF=${REF:-"main"}

su - "$_REMOTE_USER" <<EOF
echo "URL:$URL"
echo "REF:$REF"
yadm clone $URL --bootstrap -b $REF
EOF
