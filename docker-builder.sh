#!/bin/sh
: "${GITHUB_OUTPUT:=$(mktemp --suffix=.builder.log)}"
time1=$(date +%s.%N)

set -eux
mkdir -p output
chmod 777 output
docker build -t claude-desktop-debian .
docker run \
  --rm \
  -it \
  -v ./output:/home/builder/output \
  claude-desktop-debian $@

time2=$(date +%s.%N)
diff=$(echo "scale=40;${time2} - ${time1}" | bc)
echo "time=$diff" >> "$GITHUB_OUTPUT"
