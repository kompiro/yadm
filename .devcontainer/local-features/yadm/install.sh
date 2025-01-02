#!/bin/bash -i

set -ex

URL=${URL:-"https://github.com/kompiro/yadm"}

su - "$_REMOTE_USER" <<EOF
yadm clone $URL --bootstrap
EOF

echo $TEST_MESSAGE
echo "yadm install finished"