#!/usr/bin/env bash
set -x
# ./certs 当前写成绝对路径防止找不到
FILE="/opt/nginx/certs/live/yanxianhe.com/fullchain.pem"
PREVIOUS_HASH="/opt/nginx/certs/live/yanxianhe.com/fullchain_hash.txt"

if [ ! -f "$PREVIOUS_HASH" ]; then
    sha256sum "$FILE" | awk '{print $1}' > "$PREVIOUS_HASH"
fi

CURRENT_HASH=$(sha256sum "$FILE" | awk '{print $1}')
SAVED_HASH=$(cat "$PREVIOUS_HASH")
if [ "$CURRENT_HASH" != "$SAVED_HASH" ]; then
    sudo nginx -s reload
    #docker exec -it nginx nginx -s reload 
fi

# 更新保存的哈希值
echo "$CURRENT_HASH" > "$PREVIOUS_HASH"
